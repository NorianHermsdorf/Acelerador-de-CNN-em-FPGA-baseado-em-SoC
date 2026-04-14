-makelib xcelium_lib/xilinx_vip -sv \
  "D:/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
  "D:/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
  "D:/Vivado/2019.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
  "D:/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
  "D:/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
  "D:/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
  "D:/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
  "D:/Vivado/2019.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
  "D:/Vivado/2019.1/data/xilinx_vip/hdl/rst_vip_if.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_lenet5_top_0_0/sim/lenet5_lenet5_top_0_0.v" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_3 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/c001/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_blk_mem_gen_0_0/sim/lenet5_blk_mem_gen_0_0.v" \
  "../../../bd/lenet5/ip/lenet5_blk_mem_gen_0_1/sim/lenet5_blk_mem_gen_0_1.v" \
  "../../../bd/lenet5/ip/lenet5_blk_mem_gen_0_2/sim/lenet5_blk_mem_gen_0_2.v" \
  "../../../bd/lenet5/ip/lenet5_blk_mem_gen_0_3/sim/lenet5_blk_mem_gen_0_3.v" \
-endlib
-makelib xcelium_lib/axi_lite_ipif_v3_0_4 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/lib_cdc_v1_0_2 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/interrupt_control_v3_1_4 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/a040/hdl/interrupt_control_v3_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_gpio_v2_0_21 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/9c6e/hdl/axi_gpio_v2_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_axi_gpio_0_0/sim/lenet5_axi_gpio_0_0.vhd" \
-endlib
-makelib xcelium_lib/xlslice_v1_0_2 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/f044/hdl/xlslice_v1_0_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_xlslice_0_0/sim/lenet5_xlslice_0_0.v" \
  "../../../bd/lenet5/ip/lenet5_xlslice_0_1/sim/lenet5_xlslice_0_1.v" \
  "../../../bd/lenet5/ip/lenet5_xlslice_1_0/sim/lenet5_xlslice_1_0.v" \
-endlib
-makelib xcelium_lib/xlconcat_v2_1_3 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/442e/hdl/xlconcat_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_xlconcat_0_0/sim/lenet5_xlconcat_0_0.v" \
  "../../../bd/lenet5/ip/lenet5_xlslice_3_0/sim/lenet5_xlslice_3_0.v" \
  "../../../bd/lenet5/ip/lenet5_xlslice_3_1/sim/lenet5_xlslice_3_1.v" \
-endlib
-makelib xcelium_lib/axi_infrastructure_v1_1_0 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_vip_v1_1_5 -sv \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/d4a8/hdl/axi_vip_v1_1_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/processing_system7_vip_v1_0_7 -sv \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8c62/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_processing_system7_0_0_1/sim/lenet5_processing_system7_0_0.v" \
-endlib
-makelib xcelium_lib/axi_bram_ctrl_v4_1_1 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/70bf/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_bram_ctrl_a_0/sim/lenet5_bram_ctrl_a_0.vhd" \
  "../../../bd/lenet5/ip/lenet5_bram_ctrl_b_0/sim/lenet5_bram_ctrl_b_0.vhd" \
  "../../../bd/lenet5/ip/lenet5_bram_ctrl_pesos_0/sim/lenet5_bram_ctrl_pesos_0.vhd" \
-endlib
-makelib xcelium_lib/proc_sys_reset_v5_0_13 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_rst_ps7_0_100M_0/sim/lenet5_rst_ps7_0_100M_0.vhd" \
-endlib
-makelib xcelium_lib/generic_baseblocks_v2_1_0 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_register_slice_v2_1_19 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/4d88/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_4 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/1f5a/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_4 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_4 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/axi_data_fifo_v2_1_18 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/5b9c/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_crossbar_v2_1_20 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ace7/hdl/axi_crossbar_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_xbar_0/sim/lenet5_xbar_0.v" \
-endlib
-makelib xcelium_lib/xlconstant_v1_1_6 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/66e7/hdl/xlconstant_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_xlconstant_0_1/sim/lenet5_xlconstant_0_1.v" \
  "../../../bd/lenet5/ip/lenet5_xlslice_3_2/sim/lenet5_xlslice_3_2.v" \
-endlib
-makelib xcelium_lib/axi_protocol_converter_v2_1_19 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/c83a/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_auto_pc_1/sim/lenet5_auto_pc_1.v" \
-endlib
-makelib xcelium_lib/axi_clock_converter_v2_1_18 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/ac9d/hdl/axi_clock_converter_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_dwidth_converter_v2_1_19 \
  "../../../../lenet5_pga.srcs/sources_1/bd/lenet5/ipshared/e578/hdl/axi_dwidth_converter_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/lenet5/ip/lenet5_auto_us_0/sim/lenet5_auto_us_0.v" \
  "../../../bd/lenet5/ip/lenet5_auto_ds_0/sim/lenet5_auto_ds_0.v" \
  "../../../bd/lenet5/ip/lenet5_auto_pc_0/sim/lenet5_auto_pc_0.v" \
  "../../../bd/lenet5/sim/lenet5.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

