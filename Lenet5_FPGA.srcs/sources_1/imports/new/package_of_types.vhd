LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE package_of_types IS
    CONSTANT DATA_WIDTH: INTEGER := 8;
    CONSTANT ACC_WIDTH: INTEGER := 4 * DATA_WIDTH ;
    CONSTANT BRAM_LATENCY: INTEGER := 2;
    CONSTANT BRAM_WIDTH  : INTEGER := 128;
    CONSTANT WE_WIDTH : INTEGER := 16;
    CONSTANT KERNEL: INTEGER := 5;
    CONSTANT PARALLEL_FILTERS: INTEGER := 1;
    CONSTANT BRAM_PSUM_WIDTH: INTEGER := ACC_WIDTH * PARALLEL_FILTERS;
    CONSTANT ADDR_PSUM_WIDTH: INTEGER := 11;
    CONSTANT PSUM_WE_WIDTH: INTEGER := 4;
    CONSTANT ADDR_AB_WIDTH: INTEGER := 9;
    CONSTANT ADDR_W_WIDTH: INTEGER := 13;
    
    SUBTYPE data_signed is SIGNED(DATA_WIDTH-1 DOWNTO 0);
    TYPE signed_array is ARRAY (NATURAL RANGE <>) OF data_signed;
    TYPE array_signed_array is ARRAY (NATURAL RANGE <>) OF signed_array(1 to KERNEL*KERNEL);
    TYPE long_signed_array is ARRAY (NATURAL RANGE <>) OF SIGNED(ACC_WIDTH - 1 downto 0);
    
    function ceil_div(a, b : integer) return integer;
    function slv_to_signed(s: std_logic_vector(DATA_WIDTH-1 downto 0)) return signed;
    function signed_to_slv(s: signed(DATA_WIDTH-1 downto 0)) return std_logic_vector;
    function get_byte(word128 : std_logic_vector; b : integer) return std_logic_vector;
    function act_func(input: signed; act_type: STRING; shift: NATURAL) return signed;
    
END package_of_types;

PACKAGE BODY package_of_types IS
    
    function slv_to_signed(s: std_logic_vector(DATA_WIDTH-1 downto 0)) return signed is
    begin return signed(s); end;
    
    function signed_to_slv(s: signed(DATA_WIDTH-1 downto 0)) return std_logic_vector is
    begin return std_logic_vector(s); end;
    
    function ceil_div(a, b : integer) return integer is
    begin return (a + b - 1) / b; end;

    function get_byte(word128 : std_logic_vector; b : integer) return std_logic_vector is
        variable lo : integer;
    begin
        lo := 8 * b;
        return word128(lo + 7 downto lo);
    end;
    
    FUNCTION relu_func(input: SIGNED; shift: NATURAL) RETURN SIGNED IS
        CONSTANT max_val : INTEGER := (2**(DATA_WIDTH-1)) - 1;
        VARIABLE shifted_input : SIGNED(input'length - 1 downto 0);
        
        BEGIN
            shifted_input := shift_right(input, shift);
            IF(shifted_input < 0) THEN 
              RETURN to_signed(0, DATA_WIDTH);
            ELSIF(shifted_input > to_signed(max_val, shifted_input'length)) THEN 
              RETURN to_signed(max_val, DATA_WIDTH);
            ELSE
              RETURN resize(shifted_input, DATA_WIDTH);
            END IF;
	END relu_func;
    
    FUNCTION sat_func(input: SIGNED; shift: NATURAL) RETURN SIGNED IS
        CONSTANT max_val : INTEGER := (2**(DATA_WIDTH-1)) - 1;
        CONSTANT min_val : INTEGER := -(2**(DATA_WIDTH-1));
        VARIABLE shifted_input : SIGNED(input'length - 1 downto 0);
        
        BEGIN
            shifted_input := shift_right(input, shift);
            IF (shifted_input > to_signed(max_val, shifted_input'length)) THEN
                RETURN to_signed(max_val, DATA_WIDTH);  
            ELSIF (shifted_input < to_signed(min_val, shifted_input'length)) THEN
                RETURN to_signed(min_val, DATA_WIDTH);  
            ELSE
                RETURN resize(shifted_input, DATA_WIDTH);   
            END IF;
    END sat_func;
    
    FUNCTION act_func(input: SIGNED; act_type: STRING; shift: NATURAL) RETURN SIGNED IS
        BEGIN
        
        IF(act_type = "LINEAR") THEN
            return sat_func(input, shift);
        ELSIF(act_type = "RELU") THEN
            RETURN relu_func(input, shift);
        ELSE
            RETURN to_signed(0, DATA_WIDTH);    
        END IF;
    END act_func;
END package_of_types;