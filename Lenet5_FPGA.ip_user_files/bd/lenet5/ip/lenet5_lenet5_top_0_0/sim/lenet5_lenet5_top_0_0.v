// (c) Copyright 1995-2026 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:lenet5_top:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module lenet5_lenet5_top_0_0 (
  clk,
  rst,
  start,
  busy,
  done,
  FILTER_BASE,
  IN_BASE,
  OUT_BASE,
  w_addr,
  w_din,
  a_addr,
  a_din,
  a_dout,
  a_we,
  b_addr,
  b_din,
  b_dout,
  b_we,
  ps_wr_addr,
  ps_wr_dout,
  ps_wr_we,
  ps_rd_addr,
  ps_rd_din,
  ps_rd_en,
  state
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_RESET rst, FREQ_HZ 25000000, PHASE 0.000, CLK_DOMAIN lenet5_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst RST" *)
input wire rst;
input wire start;
output wire busy;
output wire done;
input wire [8 : 0] FILTER_BASE;
input wire [8 : 0] IN_BASE;
input wire [8 : 0] OUT_BASE;
output wire [8 : 0] w_addr;
input wire [127 : 0] w_din;
output wire [8 : 0] a_addr;
input wire [127 : 0] a_din;
output wire [127 : 0] a_dout;
output wire [15 : 0] a_we;
output wire [8 : 0] b_addr;
input wire [127 : 0] b_din;
output wire [127 : 0] b_dout;
output wire [15 : 0] b_we;
output wire [10 : 0] ps_wr_addr;
output wire [31 : 0] ps_wr_dout;
output wire [3 : 0] ps_wr_we;
output wire [10 : 0] ps_rd_addr;
input wire [31 : 0] ps_rd_din;
output wire ps_rd_en;
input wire [2 : 0] state;

  lenet5_top #(
    .BRAM_PSUM_WIDTH(32)
  ) inst (
    .clk(clk),
    .rst(rst),
    .start(start),
    .busy(busy),
    .done(done),
    .FILTER_BASE(FILTER_BASE),
    .IN_BASE(IN_BASE),
    .OUT_BASE(OUT_BASE),
    .w_addr(w_addr),
    .w_din(w_din),
    .a_addr(a_addr),
    .a_din(a_din),
    .a_dout(a_dout),
    .a_we(a_we),
    .b_addr(b_addr),
    .b_din(b_din),
    .b_dout(b_dout),
    .b_we(b_we),
    .ps_wr_addr(ps_wr_addr),
    .ps_wr_dout(ps_wr_dout),
    .ps_wr_we(ps_wr_we),
    .ps_rd_addr(ps_rd_addr),
    .ps_rd_din(ps_rd_din),
    .ps_rd_en(ps_rd_en),
    .state(state)
  );
endmodule
