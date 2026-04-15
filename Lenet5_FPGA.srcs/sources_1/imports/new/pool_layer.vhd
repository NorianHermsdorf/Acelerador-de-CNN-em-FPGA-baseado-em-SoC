library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.package_of_types.all;

entity pool_layer is
    generic(
        IMG_WIDTH    : INTEGER := 32;
        IMG_HEIGHT   : INTEGER := 32;
        KERNEL       : INTEGER := 2;
        STRIDE       : INTEGER := 2;
        CHANNELS     : INTEGER := 6;
        BRAM_LATENCY : INTEGER := 2
    );
    Port (
        clk, rst : in  std_logic;
        
        start    : in  std_logic;
        busy     : out std_logic;
        done     : out std_logic;
        
        IN_BASE  : in  unsigned(ADDR_AB_WIDTH-1 downto 0);
        OUT_BASE : in  unsigned(ADDR_AB_WIDTH-1 downto 0);
            
        -- BRAM ENTRADA
        x_rd_addr : out std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        x_rd_din  : in  std_logic_vector(BRAM_WIDTH-1 downto 0);
        
        -- BRAM SAÍDA
        y_wr_addr : out std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        y_wr_dout  : out std_logic_vector(BRAM_WIDTH-1 downto 0);
        y_wr_we   : out std_logic_vector(WE_WIDTH-1 downto 0)
    );
end pool_layer;

architecture Behavioral of pool_layer is

    -- ====================================================
    -- CONSTANTES E SINAIS GLOBAIS
    -- ====================================================
    CONSTANT PIXELS_PER_WORD : integer := ceil_div(BRAM_WIDTH, DATA_WIDTH);
    CONSTANT PIXELS_PER_IMG  : integer := IMG_WIDTH * IMG_HEIGHT; 
    CONSTANT WORDS_PER_IMG   : integer := ceil_div(PIXELS_PER_IMG, PIXELS_PER_WORD); 
    
    CONSTANT OUT_IMG_WIDTH   : integer := (IMG_WIDTH - KERNEL) / STRIDE + 1;
    CONSTANT OUT_IMG_HEIGHT   : integer := (IMG_HEIGHT - KERNEL) / STRIDE + 1;
    CONSTANT TOTAL_WINDOWS   : integer := OUT_IMG_WIDTH * OUT_IMG_HEIGHT;

    -- Sinais de Controle Espacial e Loop
    signal channel_cnt : integer range 0 to CHANNELS := 0;
    signal pixel_cnt   : integer range 0 to PIXELS_PER_IMG := 0;
    signal spatial_cnt : unsigned(ADDR_AB_WIDTH - 1 downto 0) := (others => '0');
    signal lat_cnt     : integer range 0 to BRAM_LATENCY + 1 := 0;
    signal new_channel : std_logic := '0';
    signal start_pool  : std_logic := '0';
    signal done_pool   : std_logic := '0';
    signal finish_layer   : std_logic := '0';

    signal out_addr_idx: unsigned(ADDR_AB_WIDTH-1 downto 0) := (others => '0');
    
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
    signal max_r        : signed(DATA_WIDTH - 1 downto 0);
    
    -- Sinais do Empacotador de Saída
    signal y_pack       : std_logic_vector(BRAM_WIDTH-1 downto 0) := (others => '0');
    signal y_byte_idx   : integer range 0 to PIXELS_PER_WORD - 1 := 0;

    -- Máquina de Estados
    type states is(IDLE, LOAD_PIXELS, WAIT_LATENCY, STREAM_PIXELS, FLUSH_PIPE, NEXT_CHANNEL, DONE_LAYER);
    signal state : states := IDLE;
    
    type w_states is (W_IDLE, W_POOLING, W_NEXT_CHANNEL);
    signal w_state : w_states := W_IDLE;
    
    signal lb_reset : std_logic := '0';

begin

    busy <= '1' when state /= IDLE else '0';
    
    -- ====================================================
    -- PROCESSO 1: FSM PRODUTORA (Busca na BRAM e alimenta Line Buffer)
    -- ====================================================
    process(clk)
        variable current_pixel : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                new_channel <= '0';
                finish_layer <= '0';
                p_valid_r <= '0';
                start_pool <= '0';
            else
                p_valid_r <= '0';

                case state is
                    when IDLE =>
                        done <= '0';
                        if start = '1' then
                            start_pool <= '1';
                            channel_cnt  <= 0;
                            x_addr_idx   <= 0;
                            new_channel <= '0';
                            finish_layer <= '0';
                            state        <= LOAD_PIXELS;
                        end if;

                    when LOAD_PIXELS =>
                        pixel_cnt   <= 0;
                        new_channel <= '0';
                        
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
                            
                            -- Prefetch da próxima palavra se houver
                            if (x_addr_idx < (channel_cnt + 1) * WORDS_PER_IMG) then 
                                x_rd_addr <= std_logic_vector(IN_BASE + to_unsigned(x_addr_idx, ADDR_AB_WIDTH));
                                x_addr_idx <= x_addr_idx + 1;
                            end if;
                            
                            state <= STREAM_PIXELS;
                        end if;
                        
                    when STREAM_PIXELS =>
                        -- INJEÇÃO DE PIXELS NO LINE BUFFER
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
                            state <= FLUSH_PIPE; 
                            p_valid_r <= '0';
                        end if;

                    when FLUSH_PIPE =>
                        if(done_pool = '1') then
                            state <= NEXT_CHANNEL;
                        end if;
                    when NEXT_CHANNEL =>
                        if (channel_cnt < CHANNELS - 1) then
                            channel_cnt <= channel_cnt + 1;
                            new_channel <= '1';
                            state <= LOAD_PIXELS;
                        else
                            finish_layer <= '1';
                            state <= DONE_LAYER;
                        end if;

                    when DONE_LAYER =>
                        done <= '1';
                        if start = '0' then
                            state <= IDLE; 
                        end if;
                        
                end case;
            end if;
        end if;
    end process;

    -- ====================================================
    -- PROCESSO 2: CONSUMIDOR (Empacota os resultados e Grava)
    -- ====================================================
    process(clk)
        variable y_pack_next : std_logic_vector(BRAM_WIDTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' or state = IDLE then
                y_wr_we <= (others => '0');
                y_byte_idx <= 0;
                y_pack <= (others => '0');
                done_pool <= '0';
                out_addr_idx <= (others => '0');
            else
                case w_state is
                    when W_IDLE =>
                        if(start_pool = '1') then
                            done_pool <= '0';
                            lb_reset    <= '1';
                            spatial_cnt <= (others => '0');
                            
                            w_state <= W_POOLING;
                        end if;
                    when W_POOLING =>
                        lb_reset    <= '0';
                         -- CONTROLE ESPACIAL (Baseado nas janelas válidas que saem do LB)
                        if (win_valid_r = '1') then
                            spatial_cnt <= spatial_cnt + 1;
                        else
                            if (spatial_cnt = TOTAL_WINDOWS) then
                                w_state <= W_NEXT_CHANNEL; 
                                done_pool <= '1';
                            end if;
                        end if;
                        
                        if (win_valid_r = '1') then
                            y_pack_next := y_pack;
                            y_pack_next((8 * y_byte_idx) + 7 downto (8 * y_byte_idx)) := std_logic_vector(max_r);
                            
                            -- Escreve na BRAM se encheu a palavra OU se é a última janela do canal
                            if (y_byte_idx = PIXELS_PER_WORD - 1) or (spatial_cnt = TOTAL_WINDOWS - 1) then
                                y_wr_dout  <= y_pack_next;
                                y_wr_addr <= std_logic_vector(OUT_BASE + out_addr_idx);
                                out_addr_idx <= out_addr_idx + 1;
                                y_wr_we <= (others => '1');
                                
                                y_pack <= (others => '0');
                                y_byte_idx <= 0;
                            else
                                y_wr_we <= (others => '0');
                                y_pack <= y_pack_next;
                                y_byte_idx <= y_byte_idx + 1;
                            end if;
                        else
                            y_wr_we <= (others => '0');
                        end if;
                    when W_NEXT_CHANNEL =>
                        if(new_channel = '1') then
                            spatial_cnt <= (others => '0');
                            lb_reset    <= '1';
                            w_state <= W_POOLING;
                            done_pool <= '0';
                        elsif(finish_layer = '1') then
                            w_state <= W_IDLE;   
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- ====================================================
    -- INSTÂNCIAS 
    -- ====================================================
    max_pooling: ENTITY WORK.pool_datapath_max
        generic map( 
            KERNEL => KERNEL 
        )
        port map( 
            window_in => window_out_r, 
            max_out   => max_r 
        );
    
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
