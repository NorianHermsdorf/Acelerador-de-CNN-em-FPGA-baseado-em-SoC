vlib work
vlib activehdl

vlib activehdl/xilinx_vip
vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/blk_mem_gen_v8_4_3
vlib activehdl/axi_lite_ipif_v3_0_4
vlib activehdl/lib_cdc_v1_0_2
vlib activehdl/interrupt_control_v3_1_4
vlib activehdl/axi_gpio_v2_0_21
vlib activehdl/xlslice_v1_0_2
vlib activehdl/xlconcat_v2_1_3
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_vip_v1_1_5
vlib activehdl/processing_system7_vip_v1_0_7
vlib activehdl/axi_bram_ctrl_v4_1_1
vlib activehdl/proc_sys_reset_v5_0_13
vlib activehdl/generic_baseblocks_v2_1_0
vlib activehdl/axi_register_slice_v2_1_19
vlib activehdl/fifo_generator_v13_2_4
vlib activehdl/axi_data_fifo_v2_1_18
vlib activehdl/axi_crossbar_v2_1_20
vlib activehdl/xlconstant_v1_1_6
vlib activehdl/axi_protocol_converter_v2_1_19
vlib activehdl/axi_clock_converter_v2_1_18
vlib activehdl/axi_dwidth_converter_v2_1_19

vmap xilinx_vip activehdl/xilinx_vip
vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap blk_mem_gen_v8_4_3 activehdl/blk_mem_gen_v8_4_3
vmap axi_lite_ipif_v3_0_4 activehdl/axi_lite_ipif_v3_0_4
vmap lib_cdc_v1_0_2 activehdl/lib_cdc_v1_0_2
vmap interrupt_control_v3_1_4 activehdl/interrupt_control_v3_1_4
vmap axi_gpio_v2_0_21 activehdl/axi_gpio_v2_0_21
vmap xlslice_v1_0_2 activehdl/xlslice_v1_0_2
vmap xlconcat_v2_1_3 activehdl/xlconcat_v2_1_3
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_5 activehdl/axi_vip_v1_1_5
vmap processing_system7_vip_v1_0_7 activehdl/processing_system7_vip_v1_0_7
vmap axi_bram_ctrl_v4_1_1 activehdl/axi_bram_ctrl_v4_1_1
vmap proc_sys_reset_v5_0_13 activehdl/proc_sys_reset_v5_0_13
vmap generic_baseblocks_v2_1_0 activehdl/generic_baseblocks_v2_1_0
vmap axi_register_slice_v2_1_19 activehdl/axi_register_slice_v2_1_19
vmap fifo_generator_v13_2_4 activehdl/fifo_generator_v13_2_4
vmap axi_data_fifo_v2_1_18 activehdl/axi_data_fifo_v2_1_18
vmap axi_crossbar_v2_1_20 activehdl/axi_crossbar_v2_1_20
vmap xlconstant_v1_1_6 activehdl/xlconstant_v1_1_6
vmap axi_protocol_converter_v2_1_19 activehdl/axi_protocol_converter_v2_1_19
vmap axi_clock_converter_v2_1_18 activehdl/axi_clock_converter_v2_1_18
vmap axi_dwidth_converter_v2_1_19 activehdl/axi_dwidth_converter_v2_1_19

vlog -work xilinx_vip  -sv2k12 "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"D:/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/Vivado/2019.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/Vivado/2019.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/Vivado/2019.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"D:/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/lenet5/ip/lenet5_lenet5_top_0_0/sim/lenet5_lenet5_top_0_0.v" \

vlog -work blk_mem_gen_v8_4_3  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/c001/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/lenet5/ip/lenet5_blk_mem_gen_0_0/sim/lenet5_blk_mem_gen_0_0.v" \
"../../../bd/lenet5/ip/lenet5_blk_mem_gen_0_1/sim/lenet5_blk_mem_gen_0_1.v" \
"../../../bd/lenet5/ip/lenet5_blk_mem_gen_0_2/sim/lenet5_blk_mem_gen_0_2.v" \
"../../../bd/lenet5/ip/lenet5_blk_mem_gen_0_3/sim/lenet5_blk_mem_gen_0_3.v" \

vcom -work axi_lite_ipif_v3_0_4 -93 \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work interrupt_control_v3_1_4 -93 \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/a040/hdl/interrupt_control_v3_1_vh_rfs.vhd" \

vcom -work axi_gpio_v2_0_21 -93 \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/9c6e/hdl/axi_gpio_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/lenet5/ip/lenet5_axi_gpio_0_0/sim/lenet5_axi_gpio_0_0.vhd" \

vlog -work xlslice_v1_0_2  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/f044/hdl/xlslice_v1_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/lenet5/ip/lenet5_xlslice_0_0/sim/lenet5_xlslice_0_0.v" \
"../../../bd/lenet5/ip/lenet5_xlslice_0_1/sim/lenet5_xlslice_0_1.v" \
"../../../bd/lenet5/ip/lenet5_xlslice_1_0/sim/lenet5_xlslice_1_0.v" \

vlog -work xlconcat_v2_1_3  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/442e/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/lenet5/ip/lenet5_xlconcat_0_0/sim/lenet5_xlconcat_0_0.v" \
"../../../bd/lenet5/ip/lenet5_xlslice_3_0/sim/lenet5_xlslice_3_0.v" \
"../../../bd/lenet5/ip/lenet5_xlslice_3_1/sim/lenet5_xlslice_3_1.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_5  -sv2k12 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/d4a8/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_7  -sv2k12 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/lenet5/ip/lenet5_processing_system7_0_0_1/sim/lenet5_processing_system7_0_0.v" \

vcom -work axi_bram_ctrl_v4_1_1 -93 \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/70bf/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/lenet5/ip/lenet5_bram_ctrl_a_0/sim/lenet5_bram_ctrl_a_0.vhd" \
"../../../bd/lenet5/ip/lenet5_bram_ctrl_b_0/sim/lenet5_bram_ctrl_b_0.vhd" \
"../../../bd/lenet5/ip/lenet5_bram_ctrl_pesos_0/sim/lenet5_bram_ctrl_pesos_0.vhd" \

vcom -work proc_sys_reset_v5_0_13 -93 \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/lenet5/ip/lenet5_rst_ps7_0_100M_0/sim/lenet5_rst_ps7_0_100M_0.vhd" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_19  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/4d88/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_4  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/1f5a/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_4 -93 \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_4  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_18  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/5b9c/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_20  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ace7/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/lenet5/ip/lenet5_xbar_0/sim/lenet5_xbar_0.v" \

vlog -work xlconstant_v1_1_6  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/66e7/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/lenet5/ip/lenet5_xlconstant_0_1/sim/lenet5_xlconstant_0_1.v" \
"../../../bd/lenet5/ip/lenet5_xlslice_3_2/sim/lenet5_xlslice_3_2.v" \

vlog -work axi_protocol_converter_v2_1_19  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/c83a/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/lenet5/ip/lenet5_auto_pc_1/sim/lenet5_auto_pc_1.v" \

vlog -work axi_clock_converter_v2_1_18  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ac9d/hdl/axi_clock_converter_v2_1_vl_rfs.v" \

vlog -work axi_dwidth_converter_v2_1_19  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/e578/hdl/axi_dwidth_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl" "+incdir+../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ip/lenet5_processing_system7_0_0_1" "+incdir+D:/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/lenet5/ip/lenet5_auto_us_0/sim/lenet5_auto_us_0.v" \
"../../../bd/lenet5/ip/lenet5_auto_ds_0/sim/lenet5_auto_ds_0.v" \
"../../../bd/lenet5/ip/lenet5_auto_pc_0/sim/lenet5_auto_pc_0.v" \
"../../../bd/lenet5/sim/lenet5.v" \

vlog -work xil_defaultlib \
"glbl.v"

