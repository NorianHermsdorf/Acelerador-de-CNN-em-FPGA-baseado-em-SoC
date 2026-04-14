library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.package_of_types.all;

entity pool_datapath_max is
    Generic(
        KERNEL : INTEGER := 2
    );
    Port(
        window_in : in signed_array(1 to (KERNEL * KERNEL));
        max_out : out signed(DATA_WIDTH - 1 downto 0) 
    );
end pool_datapath_max;

architecture Behavioral of pool_datapath_max is
    constant n_elements : integer := (KERNEL * KERNEL);
begin
    process(window_in)
    variable current_max : signed(DATA_WIDTH-1 downto 0); ---10 bits
    begin
        current_max := window_in(1);
        
        for i in 2 to n_elements loop
            if(window_in(i) > current_max) then
                current_max := window_in(i);   
            end if;
        end loop;
               
        max_out <= current_max;
    end process;
end Behavioral;
