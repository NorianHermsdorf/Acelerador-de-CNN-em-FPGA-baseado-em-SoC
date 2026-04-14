LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.package_of_types.all;

ENTITY fc_control IS
    GENERIC(
        LANES        : INTEGER := 16;
        N_INPUTS      : INTEGER := 32;
        N_NEURONS    : INTEGER := 16;
        ACTIVATION   : STRING := "RELU";
        SHIFT        : NATURAL := 0
        
    );
    PORT(
        clk, rst : in  std_logic;
        start    : in  std_logic;
        busy, done : out std_logic;
        
        -- Endereços Base
        W_BASE : in unsigned(ADDR_W_WIDTH-1 downto 0);
        IN_BASE : in unsigned(ADDR_AB_WIDTH-1 downto 0);
        OUT_BASE : in unsigned(ADDR_AB_WIDTH-1 downto 0);
        
        -- Porta (Pesos + Bias)
        w_rd_addr    : out std_logic_vector(ADDR_W_WIDTH-1 downto 0);
        w_rd_din   : in  std_logic_vector(BRAM_WIDTH-1 downto 0);
        
        -- Porta BRAM A (Entradas X)
        x_rd_addr : out std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        x_rd_din : in  std_logic_vector(BRAM_WIDTH-1 downto 0);
        
        -- Porta BRAM B Escrita (Saída)
        y_wr_addr : out std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        y_wr_dout  : out std_logic_vector(BRAM_WIDTH-1 downto 0);
        y_wr_we   : out std_logic_vector(WE_WIDTH-1 downto 0);
        
        -- Datapath
        dp_step_en, dp_load_bias, dp_last : out std_logic;
        dp_lane_en : out std_logic_vector(1 to LANES);
        dp_x_in    : out signed(DATA_WIDTH-1 downto 0);
        dp_w_in, dp_bias_in : out signed_array(1 to LANES);
        mac_result      : in long_signed_array(1 to LANES);
        mac_result_valid    : in std_logic
    );
END fc_control;

ARCHITECTURE Behavioral OF fc_control IS
    
    CONSTANT BYTES_PER_WORD : integer := ceil_div(BRAM_WIDTH, DATA_WIDTH); -- 16 bytes
    constant GROUPS  : integer := ceil_div(N_NEURONS, LANES);
    constant WORDS_TOTAL_W : integer := (GROUPS * (N_INPUTS + 1));
    constant WORDS_TOTAL_X : integer := ceil_div(N_INPUTS, BYTES_PER_WORD);
    
    type states is (IDLE, FETCH_PARALLEL_INIT, WAIT_INIT_DATA, 
                    RUN_BATCH, WAIT_Y, WRITE_OUT, NEXT_GROUP, DONE_S);
    signal state : states := IDLE;
    
    -- Índices
    signal g_idx    : integer range 0 to GROUPS-1 := 0;
    signal xw_idx   : integer range 0 to BYTES_PER_WORD := 0;
    signal w_req_idx : integer range 0 to N_INPUTS := 0; ---contador de requisições
    signal step_idx : integer range 0 to N_INPUTS := 0; ---(0..N_IN-1)
    
    signal x_addr_idx: integer range 0 to WORDS_TOTAL_X := 0;
    signal w_b_addr_idx: integer range 0 to WORDS_TOTAL_W - 1 := 0;

    -- Buffers
    signal x_curr_buf : std_logic_vector(BRAM_WIDTH-1 downto 0); -- Buffer em uso
    signal x_next_buf : std_logic_vector(BRAM_WIDTH-1 downto 0); -- Buffer de prefetch
    
    -- Controle de Latência
    signal lat_cnt : integer range 0 to BRAM_LATENCY+1 := 0;
    signal lane_en_r : std_logic_vector(1 to LANES) := (others => '0');
     
BEGIN
    
    busy <= '1' when state /= IDLE else '0';
    
    PROCESS(clk)
        variable base_neuron : integer;
        variable n_left      : integer;
        variable current_byte: std_logic_vector(DATA_WIDTH - 1 downto 0);
        variable global_byte_idx : integer;
        variable bias_addr_off : integer;
        variable out_vec     : std_logic_vector(BRAM_WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then
            if rst='1' then
                state <= IDLE;
                dp_step_en <= '0';
                y_wr_we <= (others => '0');
            else
                -- Pulsos Default
                dp_step_en <= '0'; dp_load_bias <= '0'; 
                dp_last <= '0';
                y_wr_we <= (others => '0');
                
                case state is
                    when IDLE =>
                        done <= '0';
                        if start = '1' then
                            g_idx <= 0;
                            state <= FETCH_PARALLEL_INIT;
                        end if;

                    -- ========================================================
                    -- 1. DISPARO SIMULTÂNEO (Bias na A + Primeiro X na B)
                    -- ========================================================
                    when FETCH_PARALLEL_INIT =>
                        -- A) Configura Lanes
                        base_neuron := g_idx * LANES;
                        n_left := N_NEURONS - base_neuron;
                        for i in 1 to LANES loop
                            if i <= n_left then lane_en_r(i) <= '1'; else lane_en_r(i) <= '0'; end if;
                        end loop;
                        
                        w_rd_addr <= std_logic_vector(W_BASE + to_unsigned(w_b_addr_idx, ADDR_W_WIDTH));
                        w_b_addr_idx <= w_b_addr_idx + 1; -- incrementa 
                        
                        -- C) Dispara Leitura X[0] (Porta B)
                        xw_idx <= 0;
                        x_rd_addr <= std_logic_vector(IN_BASE); -- Endereço 0 da entrada
                        x_addr_idx <= x_addr_idx + 1;
                        
                        lat_cnt <= 0;
                        state <= WAIT_INIT_DATA;

                    when WAIT_INIT_DATA =>
                        if lat_cnt < BRAM_LATENCY then
                            lat_cnt <= lat_cnt + 1;
                        else
                            -- Dados chegaram!
                            
                            -- 1. Carrega Bias no Datapath (Porta A)
                            dp_lane_en <= lane_en_r;
                            for i in 1 to LANES loop
                                dp_bias_in(i) <= signed(w_rd_din(8*i-1 downto 8*(i-1)));
                                dp_w_in(i)    <= (others => '0');
                            end loop;
                            dp_x_in <= (others => '0');
                            dp_load_bias <= '1';
                            dp_step_en   <= '1';
                            
                            -- 2. Guarda X[0] no Buffer (Porta B)
                            x_curr_buf <= x_rd_din;
                            
                            w_rd_addr <= std_logic_vector(W_BASE + to_unsigned(w_b_addr_idx, ADDR_W_WIDTH));
                            w_b_addr_idx <= w_b_addr_idx + 1;
                            
                            w_req_idx <= 1;
                            
                            step_idx <= 0;
                            lat_cnt <= 0;
                            state <= RUN_BATCH;
                        end if;

                    when RUN_BATCH =>
                        
                        -- PEDIDO DE PESOS (Pipeline Especulativo)
                        -- Sempre pede o próximo peso para manter o fluxo contínuo.
                        if (step_idx < N_INPUTS) then
                             -- Dispara leitura do próximo peso
                             if(w_req_idx < N_INPUTS) then
                                w_rd_addr <= std_logic_vector(W_BASE + to_unsigned(w_b_addr_idx, ADDR_W_WIDTH));
                                w_b_addr_idx <= w_b_addr_idx + 1;
                                
                                w_req_idx <= w_req_idx + 1;
                             end if;
                        end if;

                        -- VERIFICAÇÃO DE LATÊNCIA (Apenas para o PRIMEIRO dado)
                        -- Isso só segura o datapath até o primeiro peso chegar.
                        -- Depois que lat_cnt atinge o limite, o fluxo é contínuo.
                        if lat_cnt < BRAM_LATENCY then
                            lat_cnt <= lat_cnt + 1;
                            dp_step_en <= '0'; -- Pausa o datapath, mas os pesos continuam sendo pedidos acima!
                        else
                            -- Pipeline cheio! Processa dados a cada clock.
                            if(step_idx < N_INPUTS) then
                                
                                -- 1. Processamento do Dado Atual
                                current_byte := get_byte(x_curr_buf, xw_idx);
                                dp_x_in <= signed(current_byte);
                                dp_lane_en <= lane_en_r;
                                dp_step_en <= '1';
                                dp_load_bias <= '0';
                                
                                -- Nota: w_addr já foi tratado lá em cima
                                
                                -- Aplica pesos (que chegaram da latência)
                                for i in 1 to LANES loop
                                    dp_w_in(i) <= signed(w_rd_din(8*i-1 downto 8*(i-1)));
                                    dp_bias_in(i) <= (others => '0');
                                end loop;
                                
                                -- 2. Lógica de Pipeline de Memória (Prefetch X)
                                if(xw_idx = 0) then 
                                    if (x_addr_idx < WORDS_TOTAL_X) then 
                                        x_rd_addr <= std_logic_vector(IN_BASE + to_unsigned(x_addr_idx, ADDR_AB_WIDTH));
                                        x_addr_idx <= x_addr_idx + 1;
                                    end if;
                                end if;
                                
                                -- Captura Buffer X
                                if(xw_idx = BRAM_LATENCY + 1) then
                                    x_next_buf <= x_rd_din;
                                end if;
                                
                                -- 3. Avanço de Índices
                                if(xw_idx = BYTES_PER_WORD - 1) then
                                    xw_idx <= 0; 
                                    x_curr_buf <= x_next_buf; 
                                else
                                    xw_idx <= xw_idx + 1;
                                end if;
                                
                                if (step_idx = N_INPUTS - 1) then
                                    dp_last <= '1';
                                    state <= WAIT_Y;
                                end if;
                                
                                step_idx <= step_idx + 1; 
                            end if;
                        end if;
                    -- ========================================================
                    -- 3. FINALIZAÇÃO E ESCRITA
                    -- ========================================================
                    when WAIT_Y =>
                        dp_step_en <= '0';
                        if mac_result_valid = '1' then state <= WRITE_OUT; end if;

                    when WRITE_OUT =>
                        -- (Igual ao anterior: empacota e grava)
                        out_vec := (others => '0');
                        for i in 1 to LANES loop
                            if lane_en_r(i)='1' then
                                out_vec(8*i-1 downto 8*(i-1)) := std_logic_vector(act_func(mac_result(i), ACTIVATION, SHIFT));
                            end if;
                        end loop;
                        y_wr_addr <= std_logic_vector(OUT_BASE + to_unsigned(g_idx, ADDR_AB_WIDTH));
                        y_wr_dout  <= out_vec;
                        y_wr_we   <= (others => '1');
                        state <= NEXT_GROUP;

                    when NEXT_GROUP =>
                        if g_idx = GROUPS - 1 then
                            state <= DONE_S;
                        else
                            g_idx <= g_idx + 1;
                            x_addr_idx <= 0;
                            state <= FETCH_PARALLEL_INIT; -- Volta a carregar Bias e X[0] em paralelo
                        end if;

                    when DONE_S =>
                        done <= '1';
                        if start='0' then state <= IDLE; end if;
                end case;
            end if;
        end if;
    end process;
END Behavioral;