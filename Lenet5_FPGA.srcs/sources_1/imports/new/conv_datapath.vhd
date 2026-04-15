library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.package_of_types.all;

entity conv_datapath is
    Generic(
        PARALLEL_FILTERS : INTEGER := 1;
        KERNEL           : INTEGER := 5
    );
    Port ( 
        clk        : in  std_logic;
        window_in  : in  signed_array(1 to (KERNEL * KERNEL));
        weights_in : in  array_signed_array(1 TO PARALLEL_FILTERS);
        result_out : out long_signed_array(1 TO PARALLEL_FILTERS) 
    );
end conv_datapath;

architecture Behavioral of conv_datapath is

    CONSTANT KERNEL_SIZE     : INTEGER := KERNEL * KERNEL;
    CONSTANT MAX_KERNEL_SIZE : INTEGER := 25; -- Trava o tamanho maximo fisico para 5x5
    
    type prod_array_t is array(1 to MAX_KERNEL_SIZE) of signed(ACC_WIDTH-1 downto 0);
    type array_prod_array_t is array(1 TO PARALLEL_FILTERS) of prod_array_t;
    signal prods : array_prod_array_t := (others => (others => (others => '0')));

    type stage1_sum is array(1 TO PARALLEL_FILTERS) of prod_array_t;
    signal s1 : stage1_sum := (others => (others => (others => '0'))); 
    signal s2 : stage1_sum := (others => (others => (others => '0')));
    
    -- Atributos para direcionar o uso de DSPs
    attribute use_dsp : string;
    attribute use_dsp of prods : signal is "yes"; 
    attribute use_dsp of s1    : signal is "no";
    attribute use_dsp of s2    : signal is "no";

    -- Registrador para o acumulador final
    signal sum_reg : long_signed_array(1 to PARALLEL_FILTERS);

begin
    
    GEN: for p in 1 to PARALLEL_FILTERS generate
        process(clk)
        begin
            if rising_edge(clk) then
                
                -- ==========================================
                -- ESTAGIO 1: Multiplicacao
                -- ==========================================
                for i in 1 to MAX_KERNEL_SIZE loop
                    if i <= KERNEL_SIZE then
                        prods(p)(i) <= resize(window_in(i) * weights_in(p)(i), ACC_WIDTH);
                    else
                        -- Preenche o resto com zero
                        prods(p)(i) <= (others => '0');
                    end if;
                end loop;
                
                -- ==========================================
                -- ESTAGIO 2: Primeira bateria de somas
                -- ==========================================
                for i in 1 to 12 loop
                    s1(p)(i) <= prods(p)(2*i-1) + prods(p)(2*i);
                end loop;
                s1(p)(13) <= prods(p)(MAX_KERNEL_SIZE);
                
                -- ==========================================
                -- ESTAGIO 3: Segunda bateria de somas
                -- ==========================================
                for i in 1 to 6 loop
                    s2(p)(i) <= s1(p)(2*i-1) + s1(p)(2*i);
                end loop;
                s2(p)(7) <= s1(p)(13);
                
                -- ==========================================
                -- ESTAGIO 4: Acumulador Final
                -- ==========================================
                sum_reg(p) <= s2(p)(1) + s2(p)(2) + s2(p)(3) + s2(p)(4) + s2(p)(5) + s2(p)(6) + s2(p)(7);
                
            end if;
        end process;
    end generate GEN;
    
    result_out <= sum_reg;

end Behavioral;
