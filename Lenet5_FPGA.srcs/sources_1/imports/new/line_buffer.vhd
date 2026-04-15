LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.package_of_types.all;

ENTITY line_buffer IS
    GENERIC(
        IMG_WIDTH : INTEGER := 32;
        KERNEL    : INTEGER := 5;
        STRIDE    : INTEGER := 1
    );
    PORT ( 
        clk, rst : in std_logic;
        
        -- Entrada Serial
        pixel_in    : in signed(DATA_WIDTH - 1 downto 0);
        pixel_valid : in std_logic;
        
        -- Saída
        win_valid   : out std_logic;
        window_out  : out signed_array(1 to KERNEL*KERNEL)
    );
END line_buffer;

ARCHITECTURE Behavioral OF line_buffer IS

    -- Memórias e Registradores
    type ram_t is array (0 to IMG_WIDTH-1) of signed(DATA_WIDTH-1 downto 0);
    type line_buff_t is array (0 to KERNEL-2) of ram_t;
    signal line_rams : line_buff_t;
    signal wr_ptr    : integer range 0 to IMG_WIDTH-1 := 0;
    
    type window_matrix_t is array (0 to KERNEL-1, 0 to KERNEL-1) of signed(DATA_WIDTH-1 downto 0);
    signal win_regs : window_matrix_t;

    -- Contadores de Posição (Sinais guardam o estado ATUAL)
    signal col_idx : integer range 0 to IMG_WIDTH-1 := 0;
    signal row_idx : integer range 0 to IMG_WIDTH-1 := 0;
    
    -- Warmup
    signal fill_cnt : integer := 0;
    constant WARMUP_CYCLES : integer := (IMG_WIDTH * (KERNEL-1)) + KERNEL;

BEGIN

    PROCESS(clk)
        variable new_col : signed_array(0 to KERNEL-1);
        
        -- Variáveis para manipulação de coordenadas
        variable v_curr_col : integer;
        variable v_curr_row : integer;
        variable v_stride_ok : std_logic;
    BEGIN
        if rising_edge(clk) then
            if rst = '1' then
                wr_ptr    <= 0;
                fill_cnt  <= 0;
                col_idx   <= 0;
                row_idx   <= 0;
                win_valid <= '0';
            else
                if pixel_valid = '1' then
                    
                    -- ========================================================
                    -- 1. CAPTURA COORDENADAS ATUAIS
                    -- ========================================================
                    v_curr_col := col_idx;
                    v_curr_row := row_idx;

                    -- ========================================================
                    -- 2. PIPELINE DE DADOS (Shift Register & RAM)
                    -- ========================================================
                    -- Recupera coluna antiga das RAMs
                    for i in 0 to KERNEL-2 loop
                        new_col(i) := line_rams(i)(wr_ptr); 
                    end loop;
                    new_col(KERNEL-1) := pixel_in; -- Pixel novo entra embaixo

                    -- Atualiza RAMs 
                    line_rams(KERNEL-2)(wr_ptr) <= pixel_in;
                    for i in 0 to KERNEL-3 loop
                        line_rams(i)(wr_ptr) <= line_rams(i+1)(wr_ptr);
                    end loop;
                    
                    if wr_ptr = IMG_WIDTH-1 then wr_ptr <= 0;
                    else wr_ptr <= wr_ptr + 1; end if;

                    -- Atualiza Janela (Shift Horizontal)
                    for r in 0 to KERNEL-1 loop
                        for c in 0 to KERNEL-2 loop
                            win_regs(r, c) <= win_regs(r, c+1);
                        end loop;
                        win_regs(r, KERNEL-1) <= new_col(r);
                    end loop;

                    -- ========================================================
                    -- 3. VALIDAÇÃO (USANDO O VALOR ATUAL)
                    -- ========================================================
                    
                    -- Verifica se já processamos pixels suficientes para encher o buffer
                    if fill_cnt < WARMUP_CYCLES then
                        fill_cnt <= fill_cnt + 1;
                    end if;

                    -- o valor final neste clock, a janela já está pronta.
                    if fill_cnt >= WARMUP_CYCLES - 1 then
            
                        -- Garante que temos pixels suficientes à esquerda e acima.
                        if (v_curr_col >= KERNEL-1) and (v_curr_row >= KERNEL-1) then
                            
                            -- Checagem de Stride
                            v_stride_ok := '0';
                            
                            if STRIDE = 1 then
                                v_stride_ok := '1';
                                
                            elsif STRIDE = 2 then
                                -- Pooling 2x2
                                if ((v_curr_col mod 2) /= 0) and ((v_curr_row mod 2) /= 0) then
                                    v_stride_ok := '1';
                                end if;
                            else
                                -- Genérico
                                if ((v_curr_col mod STRIDE) = (STRIDE-1)) and 
                                   ((v_curr_row mod STRIDE) = (STRIDE-1)) then
                                    v_stride_ok := '1';
                                end if;
                            end if;
                            
                            win_valid <= v_stride_ok;
                        else
                            -- Janela inválida
                            win_valid <= '0';
                        end if;
                    else
                        win_valid <= '0';
                    end if;

                    -- ========================================================
                    -- 4. ATUALIZAÇÃO DOS CONTADORES (PREPARA PRÓXIMO CLOCK)
                    -- ========================================================
                    if v_curr_col = IMG_WIDTH - 1 then
                        col_idx <= 0; 
                        if v_curr_row = IMG_WIDTH - 1 then 
                             row_idx <= 0; -- Wrap vertical (nova imagem)
                        else
                             row_idx <= v_curr_row + 1;
                        end if;
                    else
                        col_idx <= v_curr_col + 1;
                    end if;

                else
                    win_valid <= '0';
                end if;
            end if;
        end if;
    END PROCESS;

    -- Saída Flattened
    GEN_FLAT: for r in 0 to KERNEL-1 generate
        GEN_FLAT_C: for c in 0 to KERNEL-1 generate
            window_out( (r*KERNEL) + c + 1 ) <= win_regs(r, c);
        end generate;
    end generate;

END Behavioral;
