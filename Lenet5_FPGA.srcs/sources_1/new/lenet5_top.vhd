library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.package_of_types.all;

entity lenet5_top is
    Generic(
        CONSTANT BRAM_PSUM_WIDTH: INTEGER := 32
    );
    Port (
        clk, rst : in  std_logic;
        
        start    : in  std_logic;
        busy     : out std_logic;
        done     : out std_logic;
        
        FILTER_BASE : in unsigned(ADDR_W_WIDTH-1 downto 0);
        IN_BASE     : in unsigned(ADDR_AB_WIDTH-1 downto 0);
        OUT_BASE    : in unsigned(ADDR_AB_WIDTH-1 downto 0);
        
        -- BRAM PESOS
        w_addr : out std_logic_vector(ADDR_W_WIDTH-1 downto 0);
        w_din  : in  std_logic_vector(BRAM_WIDTH-1 downto 0);
          
        -- BRAM A
        a_addr : out std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        a_din  : in  std_logic_vector(BRAM_WIDTH-1 downto 0);
        a_dout : out std_logic_vector(BRAM_WIDTH-1 downto 0);
        a_we   : out std_logic_vector(WE_WIDTH-1 downto 0);
        
        -- BRAM B
        b_addr : out std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        b_din  : in  std_logic_vector(BRAM_WIDTH-1 downto 0);
        b_dout : out std_logic_vector(BRAM_WIDTH-1 downto 0);
        b_we   : out std_logic_vector(WE_WIDTH-1 downto 0);
        
        -- BRAM BUFFER DE SOMAS PARCIAIS
        ps_wr_addr : out std_logic_vector(ADDR_PSUM_WIDTH-1 downto 0);
        ps_wr_dout : out std_logic_vector(BRAM_PSUM_WIDTH-1 downto 0);
        ps_wr_we   : out std_logic_vector(PSUM_WE_WIDTH-1 downto 0);
        
        ps_rd_addr : out std_logic_vector(ADDR_PSUM_WIDTH-1 downto 0);
        ps_rd_din  : in  std_logic_vector(BRAM_PSUM_WIDTH-1 downto 0);
        ps_rd_en   : out std_logic;
        
        state : in std_logic_vector(2 downto 0)    
    );
end lenet5_top;

architecture Behavioral of lenet5_top is
    CONSTANT LANES : integer := 16;
    
    signal sig_window  : signed_array(1 to KERNEL * KERNEL);
    signal sig_weights : array_signed_array(1 TO PARALLEL_FILTERS);
    signal sig_result  : long_signed_array(1 TO PARALLEL_FILTERS);
    
    signal sig_step_en   : std_logic;
    signal sig_load_bias : std_logic;
    signal sig_last      : std_logic;
    signal sig_lane_en   : std_logic_vector(1 to LANES);
    signal sig_x_in      : signed(DATA_WIDTH-1 downto 0);
    signal sig_w_in      : signed_array(1 to LANES);
    signal sig_bias_in   : signed_array(1 to LANES);
    
    signal sig_mac_result           : long_signed_array(1 to LANES);
    signal sig_mac_result_valid     : std_logic;
    
    signal start_layer : std_logic_vector(7 downto 0);
    signal layer_sel   : integer range 1 to 7;
    
    type ctrl_bram is record
        
        done       : std_logic;
        busy       : std_logic;
        w_addr     : std_logic_vector(ADDR_W_WIDTH-1 downto 0);
        a_addr     : std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        a_dout     : std_logic_vector(BRAM_WIDTH-1 downto 0);
        a_we       : std_logic_vector(WE_WIDTH-1 downto 0);
        b_addr     : std_logic_vector(ADDR_AB_WIDTH-1 downto 0);
        b_dout     : std_logic_vector(BRAM_WIDTH-1 downto 0);
        b_we       : std_logic_vector(WE_WIDTH-1 downto 0);
        ps_wr_addr : std_logic_vector(ADDR_PSUM_WIDTH-1 downto 0);
        ps_wr_dout : std_logic_vector(BRAM_PSUM_WIDTH-1 downto 0);
        ps_wr_we   : std_logic_vector(PSUM_WE_WIDTH-1 downto 0);
        ps_rd_addr : std_logic_vector(ADDR_PSUM_WIDTH-1 downto 0);
        ps_rd_en   : std_logic;
    end record;
    
    type conv_datapath_ctrl is record
        window  : signed_array(1 to KERNEL * KERNEL);
        weights : array_signed_array(1 TO PARALLEL_FILTERS);
    end record;
    
    type mac_datapath_ctrl is record
        step_en   : std_logic;
        load_bias : std_logic;
        last      : std_logic;
        lane_en   : std_logic_vector(1 to LANES);
        x_in      : signed(DATA_WIDTH-1 downto 0);
        w_in      : signed_array(1 to LANES);
        bias_in   : signed_array(1 to LANES);
    end record;
    
    type ctrl_bus_array is array(1 to 7) of ctrl_bram;
    signal ctrl_bus : ctrl_bus_array;
    
    type ctrl_conv_datapath_array is array(1 to 2) of conv_datapath_ctrl;
    signal conv_datapath_mux : ctrl_conv_datapath_array;
    
    type ctrl_max_datapath_array is array(1 to 3) of mac_datapath_ctrl;
    signal mac_datapath_mux : ctrl_max_datapath_array;
    
begin
    -- Roteamento das BRAMs
    w_addr     <= ctrl_bus(layer_sel).w_addr;
    a_addr     <= ctrl_bus(layer_sel).a_addr;
    a_dout     <= ctrl_bus(layer_sel).a_dout;
    a_we       <= ctrl_bus(layer_sel).a_we;
    b_addr     <= ctrl_bus(layer_sel).b_addr;
    b_dout     <= ctrl_bus(layer_sel).b_dout;
    b_we       <= ctrl_bus(layer_sel).b_we;
    ps_wr_addr <= ctrl_bus(layer_sel).ps_wr_addr;
    ps_wr_dout <= ctrl_bus(layer_sel).ps_wr_dout;
    ps_wr_we   <= ctrl_bus(layer_sel).ps_wr_we;
    ps_rd_addr <= ctrl_bus(layer_sel).ps_rd_addr;
    ps_rd_en   <= ctrl_bus(layer_sel).ps_rd_en;
    done       <= ctrl_bus(layer_sel).done;
    busy       <= ctrl_bus(layer_sel).busy;       
    
    -- Multiplexador do Datapath de Convolução (C1 e C3)
    sig_window  <= conv_datapath_mux(1).window  when layer_sel = 1 else 
                   conv_datapath_mux(2).window  when layer_sel = 3 else 
                   (others => (others => '0'));

    sig_weights <= conv_datapath_mux(1).weights when layer_sel = 1 else 
                   conv_datapath_mux(2).weights when layer_sel = 3 else 
                   (others => (others => (others => '0')));

    -- Multiplexador do Datapath MAC (FC5, FC6, FC7)
    sig_step_en   <= mac_datapath_mux(1).step_en   when layer_sel = 5 else
                     mac_datapath_mux(2).step_en   when layer_sel = 6 else
                     mac_datapath_mux(3).step_en   when layer_sel = 7 else '0';
                     
    sig_load_bias <= mac_datapath_mux(1).load_bias when layer_sel = 5 else
                     mac_datapath_mux(2).load_bias when layer_sel = 6 else
                     mac_datapath_mux(3).load_bias when layer_sel = 7 else '0';
                     
    sig_last      <= mac_datapath_mux(1).last      when layer_sel = 5 else
                     mac_datapath_mux(2).last      when layer_sel = 6 else
                     mac_datapath_mux(3).last      when layer_sel = 7 else '0';
                     
    sig_lane_en   <= mac_datapath_mux(1).lane_en   when layer_sel = 5 else
                     mac_datapath_mux(2).lane_en   when layer_sel = 6 else
                     mac_datapath_mux(3).lane_en   when layer_sel = 7 else (others => '0');
                     
    sig_x_in      <= mac_datapath_mux(1).x_in      when layer_sel = 5 else
                     mac_datapath_mux(2).x_in      when layer_sel = 6 else
                     mac_datapath_mux(3).x_in      when layer_sel = 7 else (others => '0');
                     
    sig_w_in      <= mac_datapath_mux(1).w_in      when layer_sel = 5 else
                     mac_datapath_mux(2).w_in      when layer_sel = 6 else
                     mac_datapath_mux(3).w_in      when layer_sel = 7 else (others => (others => '0'));
                     
    sig_bias_in   <= mac_datapath_mux(1).bias_in   when layer_sel = 5 else
                     mac_datapath_mux(2).bias_in   when layer_sel = 6 else
                     mac_datapath_mux(3).bias_in   when layer_sel = 7 else (others => (others => '0'));
                     
    process(clk)
        begin
            if(rising_edge(clk)) then
                if(start = '1') then
                    case state is
                        when "001" => --C1
                            start_layer <= "00000010";
                            layer_sel   <= 1;
                            
                        when "010" => --S2
                            start_layer <= "00000100";
                            layer_sel   <= 2;
                            
                        when "011" => --C3
                            start_layer <= "00001000";
                            layer_sel   <= 3;
                            
                        when "100" => -- S4
                            start_layer <= "00010000";
                            layer_sel   <= 4;
                            
                        when "101" => --FC5                       
                            start_layer <= "00100000";
                            layer_sel   <= 5;
                            
                        when "110" => --FC6                           
                            start_layer <= "01000000";
                            layer_sel   <= 6;
                            
                        when "111" => --FC7
                            start_layer <= "10000000";
                            layer_sel   <= 7;
                        when others => --IDLE
                    end case;
                else
                    start_layer <= (others => '0');
                end if;   
            end if;
    end process;
    

    layer_c1: entity work.conv_control
        generic map(
            IMG_WIDTH        => 32,
            IMG_HEIGHT       => 32,
            KERNEL           => 5,
            STRIDE           => 1,
            CHANNELS         => 1,
            FILTERS          => 6,
            ACTIVATION       => "RELU",
            SHIFT            => 11,
            PARALLEL_FILTERS => 1
        )
        port map(
            clk           => clk,
            rst           => rst,
            start         => start_layer(1),
            busy          => ctrl_bus(1).busy,
            done          => ctrl_bus(1).done,
            
            FILTER_BASE   => FILTER_BASE,
            IN_BASE       => IN_BASE,
            OUT_BASE      => OUT_BASE,
            
            w_rd_addr     => ctrl_bus(1).w_addr,
            w_rd_din      => w_din,
             
            x_rd_addr     => ctrl_bus(1).a_addr,
            x_rd_din      => a_din,
            
            y_wr_addr     => ctrl_bus(1).b_addr,
            y_wr_dout     => ctrl_bus(1).b_dout,
            y_wr_we       => ctrl_bus(1).b_we,
            
            ps_wr_addr    => ctrl_bus(1).ps_wr_addr,
            ps_wr_dout    => ctrl_bus(1).ps_wr_dout,
            ps_wr_we      => ctrl_bus(1).ps_wr_we,
        
            ps_rd_addr    => ctrl_bus(1).ps_rd_addr,
            ps_rd_din     => ps_rd_din,
            ps_rd_en      => ctrl_bus(1).ps_rd_en,

            window_out    => conv_datapath_mux(1).window,
            weights_out   => conv_datapath_mux(1).weights,
            result_in     => sig_result
        );
        
        layer_s2: entity work.pool_layer
        generic map(
            IMG_WIDTH  => 28,
            IMG_HEIGHT => 28,
            KERNEL     => 2,
            STRIDE     => 2,
            CHANNELS   => 6
        )
        port map(
            clk       => clk,
            rst       => rst,
            start     => start_layer(2),
            busy      => ctrl_bus(2).busy,
            done      => ctrl_bus(2).done,
            
            IN_BASE   => IN_BASE,
            OUT_BASE  => OUT_BASE,  
               
            x_rd_addr => ctrl_bus(2).b_addr,
            x_rd_din  => b_din,
            
            y_wr_addr => ctrl_bus(2).a_addr,
            y_wr_dout => ctrl_bus(2).a_dout,
            y_wr_we   => ctrl_bus(2).a_we
        );
        
        layer_c3: entity work.conv_control
        generic map(
            IMG_WIDTH  => 14,
            IMG_HEIGHT => 14,
            KERNEL     => 5,
            STRIDE     => 1,
            CHANNELS   => 6,
            FILTERS    => 16,
            ACTIVATION => "RELU",
            SHIFT      => 11,
            PARALLEL_FILTERS => 1
        )
        port map(
            clk           => clk,
            rst           => rst,
            start         => start_layer(3),
            busy          => ctrl_bus(3).busy,
            done          => ctrl_bus(3).done,
            
            FILTER_BASE   => FILTER_BASE,
            IN_BASE       => IN_BASE,
            OUT_BASE      => OUT_BASE,
            
            w_rd_addr     => ctrl_bus(3).w_addr,
            w_rd_din      => w_din,
             
            x_rd_addr     => ctrl_bus(3).a_addr,
            x_rd_din      => a_din,
            
            y_wr_addr     => ctrl_bus(3).b_addr,
            y_wr_dout     => ctrl_bus(3).b_dout,
            y_wr_we       => ctrl_bus(3).b_we,
            
            ps_wr_addr    => ctrl_bus(3).ps_wr_addr,
            ps_wr_dout    => ctrl_bus(3).ps_wr_dout,
            ps_wr_we      => ctrl_bus(3).ps_wr_we,
        
            ps_rd_addr    => ctrl_bus(3).ps_rd_addr,
            ps_rd_din     => ps_rd_din,
            ps_rd_en      => ctrl_bus(3).ps_rd_en,
            
            window_out    => conv_datapath_mux(2).window,
            weights_out   => conv_datapath_mux(2).weights,
            result_in     => sig_result
        );
        
        layer_s4: entity work.pool_layer
        generic map(
            IMG_WIDTH => 10,
            IMG_HEIGHT => 10,
            KERNEL => 2,
            STRIDE => 2,
            CHANNELS => 16
        )
        port map(
            clk           => clk,
            rst           => rst,
            start         => start_layer(4),
            busy          => ctrl_bus(4).busy,
            done          => ctrl_bus(4).done,
            
            IN_BASE       => IN_BASE,
            OUT_BASE      => OUT_BASE,
                  
            x_rd_addr     => ctrl_bus(4).b_addr,
            x_rd_din      => b_din,
            
            y_wr_addr     => ctrl_bus(4).a_addr,
            y_wr_dout     => ctrl_bus(4).a_dout,
            y_wr_we       => ctrl_bus(4).a_we
        );
        
    layer_FC5: entity work.fc_control
        generic map(
            LANES         => LANES,
            N_INPUTS          => 400,
            N_NEURONS     => 120,
            ACTIVATION    => "RELU",
            SHIFT         => 9
    
        )
        port map(
            clk           => clk,
            rst           => rst,
            start         => start_layer(5),
            busy          => ctrl_bus(5).busy, 
            done          => ctrl_bus(5).done,
            
            W_BASE        => FILTER_BASE, 
            IN_BASE       => IN_BASE, 
            OUT_BASE      => OUT_BASE,
            

            w_rd_addr     => ctrl_bus(5).w_addr,
            w_rd_din      => w_din,
            

            x_rd_addr     => ctrl_bus(5).a_addr,
            x_rd_din      => a_din,
            

            y_wr_addr     => ctrl_bus(5).b_addr,
            y_wr_dout     => ctrl_bus(5).b_dout,
            y_wr_we       => ctrl_bus(5).b_we,
            

            dp_step_en       => mac_datapath_mux(1).step_en,
            dp_load_bias     => mac_datapath_mux(1).load_bias,
            dp_last          => mac_datapath_mux(1).last,
            dp_lane_en       => mac_datapath_mux(1).lane_en,
            dp_x_in          => mac_datapath_mux(1).x_in,
            dp_w_in          => mac_datapath_mux(1).w_in, 
            dp_bias_in       => mac_datapath_mux(1).bias_in,
            
            mac_result       => sig_mac_result,
            mac_result_valid => sig_mac_result_valid
        );
        
    layer_FC6: entity work.fc_control
        generic map(
            LANES         => LANES,
            N_INPUTS          => 120,
            N_NEURONS     => 84,
            ACTIVATION    => "RELU",
            SHIFT         => 10
    
        )
        port map(
            clk           => clk,
            rst           => rst,
            start         => start_layer(6),
            busy          => ctrl_bus(6).busy, 
            done          => ctrl_bus(6).done,
            
            W_BASE        => FILTER_BASE, 
            IN_BASE       => IN_BASE, 
            OUT_BASE      => OUT_BASE,
            

            w_rd_addr     => ctrl_bus(6).w_addr,
            w_rd_din      => w_din,
            

            x_rd_addr     => ctrl_bus(6).b_addr,
            x_rd_din      => b_din,
            

            y_wr_addr     => ctrl_bus(6).a_addr,
            y_wr_dout     => ctrl_bus(6).a_dout,
            y_wr_we       => ctrl_bus(6).a_we,
            

            dp_step_en       => mac_datapath_mux(2).step_en,
            dp_load_bias     => mac_datapath_mux(2).load_bias,
            dp_last          => mac_datapath_mux(2).last,
            dp_lane_en       => mac_datapath_mux(2).lane_en,
            dp_x_in          => mac_datapath_mux(2).x_in,
            dp_w_in          => mac_datapath_mux(2).w_in, 
            dp_bias_in       => mac_datapath_mux(2).bias_in,
            
            mac_result       => sig_mac_result,
            mac_result_valid => sig_mac_result_valid
        );
    
    layer_FC7: entity work.fc_control
        generic map(
            LANES         => 16,
            N_INPUTS      => 84,
            N_NEURONS     => 10,
            ACTIVATION    => "LINEAR",
            SHIFT         => 0
    
        )
        port map(
            clk           => clk,
            rst           => rst,
            start         => start_layer(7),
            busy          => ctrl_bus(7).busy, 
            done          => ctrl_bus(7).done,
            
            W_BASE        => FILTER_BASE, 
            IN_BASE       => IN_BASE, 
            OUT_BASE      => OUT_BASE,
            

            w_rd_addr     => ctrl_bus(7).w_addr,
            w_rd_din      => w_din,
            

            x_rd_addr     => ctrl_bus(7).a_addr,
            x_rd_din      => a_din,
            

            y_wr_addr     => ctrl_bus(7).b_addr,
            y_wr_dout     => ctrl_bus(7).b_dout,
            y_wr_we       => ctrl_bus(7).b_we,
            

            dp_step_en       => mac_datapath_mux(3).step_en,
            dp_load_bias     => mac_datapath_mux(3).load_bias,
            dp_last          => mac_datapath_mux(3).last,
            dp_lane_en       => mac_datapath_mux(3).lane_en,
            dp_x_in          => mac_datapath_mux(3).x_in,
            dp_w_in          => mac_datapath_mux(3).w_in, 
            dp_bias_in       => mac_datapath_mux(3).bias_in,
            
            mac_result       => sig_mac_result,
            mac_result_valid => sig_mac_result_valid
        );
           
    conv_datapath: entity work.conv_datapath
        port map(
            clk        => clk,
            window_in  => sig_window,
            weights_in => sig_weights,
            result_out => sig_result
        );  
         
    mac_datapath: entity work.mac_datapath
        generic map(
            LANES        => LANES
        )
        port map(
            clk          => clk,
            rst          => rst,
            
            step_en      => sig_step_en,
            load_bias    => sig_load_bias,
            last         => sig_last,
            lane_en      => sig_lane_en,
            
            x_in         => sig_x_in,
            w_in         => sig_w_in,
            
            bias_in      => sig_bias_in,
            
            result       => sig_mac_result,
            result_valid => sig_mac_result_valid
        );
     
end Behavioral;