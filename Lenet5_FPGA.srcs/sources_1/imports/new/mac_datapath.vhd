LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.package_of_types.ALL;

ENTITY mac_datapath IS
    GENERIC(LANES: INTEGER := 32);
    PORT(
        clk, rst   : IN  STD_LOGIC;
        step_en    : IN  STD_LOGIC;
        load_bias  : IN  STD_LOGIC;
        last       : IN  STD_LOGIC;
        lane_en    : IN  STD_LOGIC_VECTOR(1 TO LANES);
        
        x_in       : IN  SIGNED(DATA_WIDTH-1 DOWNTO 0);
        w_in       : IN  signed_array(1 TO LANES);
        bias_in    : IN  signed_array(1 TO LANES);
        
        result      : OUT long_signed_array(1 TO LANES);
        result_valid    : OUT STD_LOGIC
    );
END;

ARCHITECTURE Behavioral OF mac_datapath IS
    
    SIGNAL acc_r : long_signed_array(1 TO LANES) := (OTHERS => (OTHERS => '0'));
    SIGNAL yv_r  : STD_LOGIC := '0';
    
    -- =========================================================================
    -- A "COLEIRA" DO VIVADO: Forçando o mapeamento para DSP48E1
    -- =========================================================================
    ATTRIBUTE use_dsp : STRING;
    ATTRIBUTE use_dsp OF acc_r : SIGNAL IS "yes"; 

BEGIN
    
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                acc_r <= (OTHERS => (OTHERS => '0'));
                yv_r  <= '0';
            ELSE
                yv_r <= '0'; 
                
                IF step_en = '1' THEN
                    FOR i IN 1 TO LANES LOOP
                        IF lane_en(i) = '1' THEN
                            
                            IF load_bias = '1' THEN
                                acc_r(i) <= resize(bias_in(i), ACC_WIDTH);
                            ELSE
                                -- O atributo 'use_dsp = yes' no acc_r obriga o Vivado a puxar
                                -- a multiplicação, a soma e o próprio registrador para dentro do DSP!
                                acc_r(i) <= acc_r(i) + (x_in * w_in(i));
                            END IF;
                            
                        ELSE
                            IF load_bias = '1' THEN 
                                acc_r(i) <= (OTHERS => '0'); 
                            END IF;
                        END IF;
                    END LOOP;
                    
                END IF;
                
                IF last = '1' THEN 
                    yv_r <= '1'; 
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    result       <= acc_r;
    result_valid <= yv_r;
    
END Behavioral;