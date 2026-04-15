library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.package_of_types.all;

entity conv_control is
    generic(
        IMG_WIDTH  : INTEGER := 32;
        IMG_HEIGHT : INTEGER := 32;
        KERNEL     : INTEGER := 5;
        STRIDE     : INTEGER := 1;
        CHANNELS   : INTEGER := 6;
        FILTERS    : INTEGER := 5;
        ACTIVATION   : STRING := "RELU";
        BRAM_LATENCY : INTEGER := 2;
        SHIFT      : NATURAL := 8;
        PARALLEL_FILTERS : INTEGER := 1
    );
    Port (
        clk, rst : in  std_logic;
        
        start    : in  std_logic;
        busy     : out std_logic;
        done     : out std_logic;
        
        FILTER_BASE: in unsigned(ADDR_W_WIDTH-1 downto 0);
        IN_BASE  : in  unsigned(ADDR_AB_WIDTH-1 downto 0);
        OUT_BASE : in  unsigned(ADDR_AB_WIDTH-1 downto 0);
        
        -- BRAM FILTROS
        w_rd_addr : out std_logic_vector(ADDR_W_WIDTH-1 downto 0);
        w_rd_din : in  std_logic_vector(BRAM_WIDTH-1 downto 0);
          
        -- BRAM ENTRADA
        x_rd_addr : out std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        x_rd_din : in  std_logic_vector(BRAM_WIDTH-1 downto 0);
        
        -- BRAM SAÍDA
        y_wr_addr : out std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        y_wr_dout  : out std_logic_vector(BRAM_WIDTH-1 downto 0);
        y_wr_we   : out std_logic_vector(WE_WIDTH-1 downto 0);
        
        -- BRAM BUFFER DE SOMAS PARCIAIS
        ps_wr_addr : out std_logic_vector(ADDR_PSUM_WIDTH-1 downto 0);
        ps_wr_dout  : out std_logic_vector(BRAM_PSUM_WIDTH-1 downto 0);
        ps_wr_we   : out std_logic_vector(PSUM_WE_WIDTH-1 downto 0);
        
        ps_rd_addr : out std_logic_vector(ADDR_PSUM_WIDTH-1 downto 0);
        ps_rd_din : in  std_logic_vector(BRAM_PSUM_WIDTH-1 downto 0);
        ps_rd_en   : out std_logic;
        
        -- CONV DATAPATH
        window_out  : out signed_array(1 to KERNEL * KERNEL);
        weights_out : out array_signed_array(1 TO PARALLEL_FILTERS);
        result_in : in long_signed_array(1 TO PARALLEL_FILTERS)       
    );
end conv_control;

architecture Behavioral of conv_control is

    -- ====================================================
    -- CONSTANTES E SINAIS GLOBAIS
    -- ====================================================
    CONSTANT DP_LATENCY : integer := 4; -- <-- NOVA LATENCIA DO DATAPATH
    
    CONSTANT MAX_KERNEL_SIZE : integer := KERNEL * KERNEL;
    CONSTANT PIXELS_PER_WORD : integer := ceil_div(BRAM_WIDTH, DATA_WIDTH);
    CONSTANT WEIGHTS_PER_WORD : integer := PIXELS_PER_WORD;
    CONSTANT PIXELS_PER_IMG  : integer := IMG_WIDTH * IMG_HEIGHT; 
    CONSTANT WORDS_PER_IMG   : integer := ceil_div(PIXELS_PER_IMG, PIXELS_PER_WORD); 
    CONSTANT WORDS_PER_FILTER : integer := ceil_div(MAX_KERNEL_SIZE, WEIGHTS_PER_WORD);
    CONSTANT TOTAL_FILTER_WORDS : integer := WORDS_PER_FILTER * PARALLEL_FILTERS;
    CONSTANT OUT_IMG_WIDTH : integer := (IMG_WIDTH - KERNEL) / STRIDE + 1;
    CONSTANT TOTAL_WINDOWS : integer := OUT_IMG_WIDTH * OUT_IMG_WIDTH;
    CONSTANT WORDS_PER_OUT : integer := ceil_div(TOTAL_WINDOWS, PIXELS_PER_WORD);
    CONSTANT TOTAL_BIAS_WORDS : integer := ceil_div(FILTERS, WEIGHTS_PER_WORD);
    
    -- Sinais de Controle Espacial e Loop
    signal channel_cnt : integer range 0 to CHANNELS := 0;
    signal filter_cnt  : integer range 0 to FILTERS := 0;
    signal pixel_cnt   : integer range 0 to PIXELS_PER_IMG := 0;
    signal spatial_cnt : unsigned(ADDR_PSUM_WIDTH - 1 downto 0) := (others => '0');
    signal out_addr_idx: unsigned(ADDR_AB_WIDTH-1 downto 0) := (others => '0');
    signal lat_cnt : integer range 0 to BRAM_LATENCY + 1 := 0;
    signal filter_req_cnt : integer range 0 to 63 := 0;
    signal filter_read_cnt : integer range 0 to 63 := 0;
    signal filter_idx : integer range 1 to PARALLEL_FILTERS := 1;
    signal filter_word_idx: integer range 0 to WORDS_PER_FILTER - 1;
    signal bias_words_cnt : integer range 0 to TOTAL_BIAS_WORDS + 1;
    signal bias_read_cnt : integer range 0 to TOTAL_BIAS_WORDS + 1:= 0;
    signal conv_done : std_logic := '0';
    signal last_window : std_logic := '0';
    signal start_conv : std_logic := '0';
    signal finish_conv : std_logic := '0';
    signal new_filter : std_logic := '0';
    signal new_channel : std_logic := '0'; 
    signal w_lat_cnt : integer range 0 to BRAM_LATENCY + 1 := 0;
    signal weight_ptr : integer range 0 to (FILTERS * CHANNELS) + FILTERS:= 0;
    
    -- Sinais de Leitura da BRAM de Entrada
    signal x_byte_idx : integer range 0 to PIXELS_PER_WORD - 1 := 0;
    signal x_addr_idx : integer := 0;
    signal x_curr_buf : std_logic_vector(BRAM_WIDTH-1 downto 0) := (others => '0');
    signal x_next_buf : std_logic_vector(BRAM_WIDTH-1 downto 0);
    
    -- Interface com o Line Buffer e Datapath
    signal pixel_r      : signed(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal p_valid_r    : std_logic := '0';
    signal win_valid_r  : std_logic := '0';
    signal window_out_r : signed_array(1 to (KERNEL * KERNEL));
    
    signal weights_in_r : array_signed_array(1 TO PARALLEL_FILTERS) := (others => (others => (others=> '0')));
    signal conv_result_r: long_signed_array(1 TO PARALLEL_FILTERS) := (others => (others=> '0'));
    signal bias_r : long_signed_array(1 TO TOTAL_BIAS_WORDS * WEIGHTS_PER_WORD) := (others => (others=> '0'));
    
    -- ====================================================
    -- SINAIS DO SHIFT REGISTER (O Túnel do Tempo de 4 posições)
    -- ====================================================
    type addr_array_t is array (0 to DP_LATENCY - 1) of std_logic_vector(ADDR_PSUM_WIDTH - 1 downto 0);
    signal addr_sr        : addr_array_t := (others => (others => '0'));
    signal valid_sr       : std_logic_vector(DP_LATENCY - 1 downto 0) := (others => '0');
    signal last_window_sr : std_logic_vector(DP_LATENCY - 1 downto 0) := (others => '0');
    
    type chan_array_t is array (0 to DP_LATENCY - 1) of integer range 0 to CHANNELS;
    signal channel_sr     : chan_array_t := (others => 0);
    
    -- ====================================================
    -- SINAIS DO EMPACOTADOR DE SAÍDA
    -- ====================================================
    signal y_pack     : std_logic_vector(BRAM_WIDTH-1 downto 0) := (others => '0');
    signal y_byte_idx : integer range 0 to PIXELS_PER_WORD - 1 := 0;
    
    type pack_array_t is array(1 to PARALLEL_FILTERS) of std_logic_vector(BRAM_WIDTH-1 downto 0);
    signal y_pack_arr : pack_array_t := (others => (others => '0'));

    type out_addr_array_t is array(1 to PARALLEL_FILTERS) of unsigned(ADDR_AB_WIDTH-1 downto 0);
    signal out_word_cnt : unsigned(ADDR_AB_WIDTH-1 downto 0) := (others => '0');

    -- Fila de Escrita
    signal write_queue      : pack_array_t := (others => (others => '0'));
    signal addr_queue       : out_addr_array_t := (others => (others => '0'));
    signal items_in_queue   : integer range 0 to PARALLEL_FILTERS := 0;
    
    -- Máquina de Estados
    type states is(IDLE, LOAD_PIXELS, WAIT_LATENCY, STREAM_PIXELS, FLUSH_PIPE, NEXT_CHANNEL, DONE_LAYER);
    signal state : states := IDLE;
    
    type w_states is(W_IDLE, W_LOAD_BIAS, W_LOAD_FILTERS, W_CONVOLUTION, W_DONE_CONVOLUTION);
    signal w_state: w_states := W_IDLE;
    
    signal lb_reset : std_logic := '0';

begin

    busy <= '1' when state /= IDLE else '0';
    
    window_out  <= window_out_r;
    weights_out <= weights_in_r;
    conv_result_r <= result_in;
    
    -- ====================================================
    -- O GATILHO DA BRAM DE PSUM (Dinâmico e Limpo)
    -- Dispara a leitura 2 ciclos depois que o dado entra (Índice 1 do SR)
    -- ====================================================
    ps_rd_addr <= addr_sr(DP_LATENCY - BRAM_LATENCY - 1);
    ps_rd_en   <= '1' when (valid_sr(DP_LATENCY - BRAM_LATENCY - 1) = '1' and channel_sr(DP_LATENCY - BRAM_LATENCY - 1) /= 0) else '0';

    -- ====================================================
    -- PROCESSO 1: FSM PRODUTORA
    -- ====================================================
    process(clk)
        variable current_pixel : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
            else
                p_valid_r <= '0';

                case state is
                    when IDLE =>
                        done <= '0';
                        if start = '1' then
                            start_conv <= '1';
                            channel_cnt  <= 0;
                            filter_cnt   <= 0;
                            x_addr_idx   <= 0;
                            out_addr_idx <= (others => '0');
                            last_window <= '0';
                            state        <= LOAD_PIXELS;
                        end if;

                    when LOAD_PIXELS =>
                        start_conv <= '0';
                        new_channel <= '0';
                        new_filter <= '0';
                        lb_reset    <= '0';
                        spatial_cnt <= (others => '0');
                        pixel_cnt   <= 0;
                        
                        x_rd_addr <= std_logic_vector(IN_BASE + to_unsigned(x_addr_idx, ADDR_AB_WIDTH));
                        x_addr_idx <= x_addr_idx + 1;
                        x_byte_idx  <= 0;
                        lat_cnt <= 0;
                        
                        state <= WAIT_LATENCY;
                        
                    when WAIT_LATENCY =>
                        if lat_cnt < BRAM_LATENCY then
                            lat_cnt <= lat_cnt + 1;
                        else
                            x_curr_buf <= x_rd_din; 
                            x_rd_addr <= std_logic_vector(IN_BASE + to_unsigned(x_addr_idx, ADDR_AB_WIDTH));
                            x_addr_idx <= x_addr_idx + 1;
                            state <= STREAM_PIXELS;
                        end if;
                        
                    when STREAM_PIXELS =>
                        if (pixel_cnt < PIXELS_PER_IMG) then
                            current_pixel := get_byte(x_curr_buf, x_byte_idx);
                            pixel_r       <= signed(current_pixel);
                            p_valid_r     <= '1';
                            pixel_cnt     <= pixel_cnt + 1;
                            
                            if(x_byte_idx = BRAM_LATENCY + 1) then
                                x_next_buf <= x_rd_din; 
                            end if;
                            
                            if(x_byte_idx = PIXELS_PER_WORD - 1) then
                                x_byte_idx <= 0;
                                x_curr_buf <= x_next_buf; 
                                
                                if (x_addr_idx < (channel_cnt + 1) * WORDS_PER_IMG) then 
                                    x_rd_addr <= std_logic_vector(IN_BASE + to_unsigned(x_addr_idx, ADDR_AB_WIDTH));
                                    x_addr_idx <= x_addr_idx + 1;
                                end if;
                            else
                                x_byte_idx <= x_byte_idx + 1;
                            end if;
                        else
                            p_valid_r <= '0';
                        end if;

                        -- Contador Espacial
                        if (win_valid_r = '1') then
                            if (spatial_cnt = TOTAL_WINDOWS - 1) then
                                state <= FLUSH_PIPE; 
                            end if;
                            spatial_cnt <= spatial_cnt + 1;
                        end if;

                    when FLUSH_PIPE =>
                        -- Mantém o relógio girando até o Shift Register secar inteiro (Todos os 4 estágios = 0)
                        if (unsigned(valid_sr) = 0 and win_valid_r = '0') then
                            if(conv_done = '1') then
                                state <= NEXT_CHANNEL;
                            end if;
                        end if;

                    when NEXT_CHANNEL =>
                        lb_reset <= '1';
                        if (channel_cnt < CHANNELS - 1) then
                            channel_cnt <= channel_cnt + 1;
                            new_channel <= '1';
                            state <= LOAD_PIXELS;
                        else
                            if (filter_cnt < FILTERS - PARALLEL_FILTERS) then
                                filter_cnt  <= filter_cnt + PARALLEL_FILTERS;
                                channel_cnt <= 0;
                                x_addr_idx   <= 0;
                                new_channel <= '1';
                                new_filter <= '1';
                                state       <= LOAD_PIXELS;
                            else
                                finish_conv <= '1';
                                state <= DONE_LAYER;
                            end if;
                        end if;

                    when DONE_LAYER =>
                        done <= '1';
                        if start = '0' then
                            start_conv <= '0'; 
                            finish_conv <= '0';
                            state <= IDLE; 
                        end if;
                        
                end case;
            end if;
        end if;
    end process;

    -- ====================================================
    -- PROCESSO 2: SHIFT REGISTER (Agora acompanha o Datapath)
    -- ====================================================
    process(clk)
    begin
        if rising_edge(clk) then
            -- Estágio 0
            addr_sr(0)    <= std_logic_vector(spatial_cnt);
            valid_sr(0)   <= win_valid_r;
            channel_sr(0) <= channel_cnt;
            last_window_sr(0) <= last_window;
            
            -- Estágio 1 até DP_LATENCY - 1
            for i in 1 to DP_LATENCY - 1 loop
                addr_sr(i)    <= addr_sr(i - 1);
                valid_sr(i)   <= valid_sr(i - 1);
                channel_sr(i) <= channel_sr(i - 1);
                last_window_sr(i) <= last_window_sr(i - 1);
            end loop;
        end if;
    end process;

    -- ====================================================
    -- PROCESSO 3: CONSUMIDOR (No final do Túnel: DP_LATENCY - 1)
    -- ====================================================
    process(clk)
        variable soma_parcial  : long_signed_array(1 to PARALLEL_FILTERS);
        variable psum_unpacked : signed(ACC_WIDTH-1 downto 0);
        variable ps_pack_next  : std_logic_vector(BRAM_PSUM_WIDTH-1 downto 0);
        
        variable valor_ativado : std_logic_vector(DATA_WIDTH - 1 downto 0);
        variable y_pack_next   : std_logic_vector(BRAM_WIDTH - 1 downto 0);
        
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ps_wr_we   <= (others => '0');
                y_wr_we    <= (others => '0');
                y_byte_idx <= 0;
                weight_ptr <= 0;
                w_state <= W_IDLE;
            else
                ps_wr_we <= (others => '0');
                y_wr_we  <= (others => '0');
                
                case w_state is
                
                    when W_IDLE =>
                        if(start_conv = '1')then
                            conv_done <= '0';
                            weight_ptr <= 0;
                            filter_req_cnt <= 0;
                            filter_read_cnt <= 0;
                            filter_word_idx <= 0;
                            filter_idx <= 1;
                            bias_words_cnt <= 0;
                            bias_read_cnt <= 0;
                            w_lat_cnt <= 0;
                            w_state <= W_LOAD_BIAS;
                        end if;
                        
                    when W_LOAD_BIAS =>
                        if(bias_words_cnt < TOTAL_BIAS_WORDS) then
                            w_rd_addr <= std_logic_vector(FILTER_BASE + to_unsigned(weight_ptr, ADDR_W_WIDTH));
                            weight_ptr <= weight_ptr + 1;
                            bias_words_cnt <= bias_words_cnt + 1;
                        end if;
                        
                        if(w_lat_cnt <= BRAM_LATENCY) then
                            w_lat_cnt <= w_lat_cnt + 1;
                        else
                            if(bias_read_cnt < TOTAL_BIAS_WORDS) then
                                for i in 0 to WEIGHTS_PER_WORD - 1 loop
                                    bias_r(i + (bias_read_cnt*WEIGHTS_PER_WORD) + 1) <= resize(signed(w_rd_din((i + 1) * DATA_WIDTH - 1 downto (i * DATA_WIDTH))), ACC_WIDTH);
                                end loop;
                                bias_read_cnt <= bias_read_cnt + 1;
                            else
                                w_lat_cnt <= 0;
                                w_state <= W_LOAD_FILTERS;
                            end if;
                        end if;
                        
                    when W_LOAD_FILTERS =>
                        if(filter_req_cnt < TOTAL_FILTER_WORDS) then
                            w_rd_addr <= std_logic_vector(FILTER_BASE + to_unsigned(weight_ptr, ADDR_W_WIDTH));
                            weight_ptr <= weight_ptr + 1;
                            filter_req_cnt <= filter_req_cnt + 1;
                        end if;
                        
                        if(w_lat_cnt <= BRAM_LATENCY) then
                            w_lat_cnt <= w_lat_cnt + 1;
                        else
                            if(filter_read_cnt < PARALLEL_FILTERS * WORDS_PER_FILTER) then
                                for i in 0 to WEIGHTS_PER_WORD - 1 loop
                                    if((i + (filter_word_idx*WEIGHTS_PER_WORD) + 1) <= MAX_KERNEL_SIZE) then
                                        weights_in_r(filter_idx)(i + (filter_word_idx*WEIGHTS_PER_WORD) + 1) <= slv_to_signed(w_rd_din((i + 1) * DATA_WIDTH - 1 downto (i * DATA_WIDTH)));
                                    end if;
                                end loop;
                                
                                if(filter_word_idx < WORDS_PER_FILTER - 1) then
                                    filter_word_idx <= filter_word_idx + 1;       
                                else
                                    filter_word_idx <= 0;                                   
                                    if(filter_idx < PARALLEL_FILTERS) then
                                        filter_idx <= filter_idx + 1;
                                    end if;                                     
                                end if;
                                
                                filter_read_cnt <= filter_read_cnt + 1;                         
                            else
                                w_state <= W_CONVOLUTION;
                            end if;
                        end if;
                        
                    when W_CONVOLUTION =>
                        -- O dado chegou no final do túnel? (Índice DP_LATENCY - 1)
                        if (valid_sr(DP_LATENCY - 1) = '1') then
                            
                            for p in 1 to PARALLEL_FILTERS loop
                                psum_unpacked := signed(ps_rd_din((p * ACC_WIDTH) - 1 downto ((p-1) * ACC_WIDTH) ));
                                if (channel_sr(DP_LATENCY - 1) = 0) then
                                    soma_parcial(p) := conv_result_r(p); 
                                else
                                    soma_parcial(p) := conv_result_r(p) + psum_unpacked; 
                                end if;
                                
                                ps_pack_next((p * ACC_WIDTH) - 1 downto ((p - 1) * ACC_WIDTH)) := std_logic_vector(soma_parcial(p));
                                  
                            end loop;
                           
                            -- É O ÚLTIMO CANAL?
                            if (channel_sr(DP_LATENCY - 1) = CHANNELS - 1) then
                                ps_wr_we <= (others => '0');
                                
                                for p in 1 to PARALLEL_FILTERS loop
                                
                                    y_pack_next := y_pack_arr(p);
                                    y_pack_next((DATA_WIDTH * y_byte_idx) + DATA_WIDTH - 1 downto (DATA_WIDTH * y_byte_idx)) := std_logic_vector(act_func(soma_parcial(p) + bias_r(filter_cnt + p), ACTIVATION, SHIFT));
                                    
                                    if (y_byte_idx = PIXELS_PER_WORD - 1) or (unsigned(addr_sr(DP_LATENCY - 1)) = TOTAL_WINDOWS - 1) then
                                        
                                        write_queue(p) <= y_pack_next;
                                        y_pack_arr(p) <= (others => '0');
                                        addr_queue(p) <= to_unsigned((filter_cnt + p - 1) * WORDS_PER_OUT, ADDR_AB_WIDTH) + out_word_cnt;
                                        
                                    else
                                        y_pack_arr(p) <= y_pack_next;
                                    end if;
                                end loop;
                                
                                if (y_byte_idx = PIXELS_PER_WORD - 1) or (unsigned(addr_sr(DP_LATENCY - 1)) = TOTAL_WINDOWS - 1) then
                                    y_byte_idx <= 0;
                                    out_word_cnt <= out_word_cnt + 1;
                                    
                                    if (filter_cnt + PARALLEL_FILTERS > FILTERS) then
                                        items_in_queue <= FILTERS - filter_cnt; 
                                    else
                                        items_in_queue <= PARALLEL_FILTERS; 
                                    end if;
                                else
                                    y_byte_idx <= y_byte_idx + 1;
                                end if;   
                                           
                            else
                                -- CANAIS INTERMEDIÁRIOS
                                ps_wr_addr <= addr_sr(DP_LATENCY - 1);
                                ps_wr_dout  <= ps_pack_next;
                                ps_wr_we   <= (others => '1');
                            end if;
                            
                            if(unsigned(addr_sr(DP_LATENCY - 1)) = TOTAL_WINDOWS - 1) then
                                w_state <= W_DONE_CONVOLUTION;
                            end if;   
                                      
                        end if;
                        
                    when W_DONE_CONVOLUTION =>
                        if(items_in_queue = 0) then
                            conv_done <= '1';
                               
                            if (new_channel = '1') then
                                if(new_filter = '1') then
                                    out_word_cnt <= (others => '0');
                                end if;
                                w_lat_cnt <= 0;
                                filter_req_cnt <= 0;
                                filter_read_cnt <= 0;
                                filter_word_idx <= 0;
                                filter_idx <= 1;
                                conv_done <= '0';
                                w_state <= W_LOAD_FILTERS;
                                
                            elsif(finish_conv = '1') then
                                conv_done <= '0';
                                w_state <= W_IDLE;
                            end if;
                        else
                            conv_done <= '0'; 
                        end if;
                end case;                
            end if;
            
            -- GRAVADOR EM BACKGROUND
            if (items_in_queue > 0) then
                y_wr_we   <= (others => '1');
                y_wr_dout  <= write_queue(items_in_queue);
                y_wr_addr <= std_logic_vector(OUT_BASE + addr_queue(items_in_queue));
                items_in_queue <= items_in_queue - 1;
            else
                y_wr_we <= (others => '0');
            end if;
        
        end if;
    end process;

    -- ====================================================
    -- INSTÂNCIAS 
    -- ====================================================
    line_b: ENTITY WORK.line_buffer
        generic map( 
            IMG_WIDTH => IMG_WIDTH, 
            KERNEL    => KERNEL, 
            STRIDE    => STRIDE 
        )
        port map( 
            clk         => clk, 
            rst         => lb_reset, 
            pixel_in    => pixel_r, 
            pixel_valid => p_valid_r,
            win_valid   => win_valid_r,
            window_out  => window_out_r 
        );      
end Behavioral;
