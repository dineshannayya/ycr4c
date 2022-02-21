//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021, Dinesh Annayya                           ////
//                                                                        ////
// Licensed under the Apache License, Version 2.0 (the "License");        ////
// you may not use this file except in compliance with the License.       ////
// You may obtain a copy of the License at                                ////
//                                                                        ////
//      http://www.apache.org/licenses/LICENSE-2.0                        ////
//                                                                        ////
// Unless required by applicable law or agreed to in writing, software    ////
// distributed under the License is distributed on an "AS IS" BASIS,      ////
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.///
// See the License for the specific language governing permissions and    ////
// limitations under the License.                                         ////
// SPDX-License-Identifier: Apache-2.0                                    ////
// SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>           ////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////                                                                      ////
////  yifive multi-core interface block                                   ////
////                                                                      ////
////  This file is part of the yifive cores project                       ////
////  https://github.com/dineshannayya/ycr2c.git                          ////
////                                                                      ////
////  Description:                                                        ////
////     connect the multi-core to common icache/dcache/tcm memory        ////
////     Instruction memory router                                        ////
////                                                                      ////
////  To Do:                                                              ////
////    nothing                                                           ////
////                                                                      ////
////  Author(s):                                                          ////
////      - Dinesh Annayya, dinesha@opencores.org                         ////
////                                                                      ////
////  Revision :                                                          ////
////     v0:    Feb 21, 2021, Dinesh A                                    ////
////             Initial version                                          ////
////                                                                      ////
//////////////////////////////////////////////////////////////////////////////

`include "ycr_arch_description.svh"
`include "ycr_memif.svh"
`include "ycr_wb.svh"
`ifdef YCR_IPIC_EN
`include "ycr_ipic.svh"
`endif // YCR_IPIC_EN

`ifdef YCR_TCM_EN
 `define YCR_IMEM_ROUTER_EN
`endif // YCR_TCM_EN

module ycr2_mintf (
`ifdef USE_POWER_PINS
    input logic                          vccd1,    // User area 1 1.8V supply
    input logic                          vssd1,    // User area 1 digital ground
`endif
    input  logic   [3:0]                 cfg_cska_riscv,
    input  logic                         wbd_clk_int,
    output logic                         wbd_clk_riscv,

    // Control
    input   logic                           pwrup_rst_n,            // Power-Up Reset
    input   logic                           rst_n,                  // Regular Reset signal
    input   logic [1:0]                     core_debug_sel,

    // From Global Register
    input   logic [`YCR_NUMCORES-1:0]       cpu_core_rst_n,        // CPU Reset (Core Reset)
    input   logic                           cpu_intf_rst_n,        // CPU interface reset

    // From clock gen
    input   logic                           core_clk,               // Core clock
    input   logic                           rtc_clk,                // Real-time clock


    output  logic [63:0]                    riscv_debug,

`ifdef YCR_DBG_EN
    // -- JTAG I/F
    input   logic                           trst_n,
`endif // YCR_DBG_EN

`ifndef YCR_TCM_MEM
    // SRAM-0 PORT-0
    output  logic                           sram0_clk0,
    output  logic                           sram0_csb0,
    output  logic                           sram0_web0,
    output  logic   [8:0]                   sram0_addr0,
    output  logic   [3:0]                   sram0_wmask0,
    output  logic   [31:0]                  sram0_din0,
    input   logic   [31:0]                  sram0_dout0,

    // SRAM-0 PORT-1
    output  logic                           sram0_clk1,
    output  logic                           sram0_csb1,
    output  logic  [8:0]                    sram0_addr1,
    input   logic  [31:0]                   sram0_dout1,

`endif

    input   logic                           wb_rst_n,       // Wish bone reset
    input   logic                           wb_clk,         // wish bone clock
    // Instruction Memory Interface
    //output  logic                           wbd_imem_stb_o, // strobe/request
    //output  logic   [YCR_WB_WIDTH-1:0]      wbd_imem_adr_o, // address
    //output  logic                           wbd_imem_we_o,  // write
    //output  logic   [YCR_WB_WIDTH-1:0]      wbd_imem_dat_o, // data output
    //output  logic   [3:0]                   wbd_imem_sel_o, // byte enable
    //input   logic   [YCR_WB_WIDTH-1:0]      wbd_imem_dat_i, // data input
    //input   logic                           wbd_imem_ack_i, // acknowlegement
    //input   logic                           wbd_imem_err_i,  // error

    // Data Memory Interface
    output  logic                           wbd_dmem_stb_o, // strobe/request
    output  logic   [YCR_WB_WIDTH-1:0]      wbd_dmem_adr_o, // address
    output  logic                           wbd_dmem_we_o,  // write
    output  logic   [YCR_WB_WIDTH-1:0]      wbd_dmem_dat_o, // data output
    output  logic   [3:0]                   wbd_dmem_sel_o, // byte enable
    input   logic   [YCR_WB_WIDTH-1:0]      wbd_dmem_dat_i, // data input
    input   logic                           wbd_dmem_ack_i, // acknowlegement
    input   logic                           wbd_dmem_err_i, // error

   `ifdef YCR_ICACHE_EN
   // Wishbone ICACHE I/F
   output logic                             wb_icache_cyc_o, // strobe/request
   output logic                             wb_icache_stb_o, // strobe/request
   output logic   [YCR_WB_WIDTH-1:0]        wb_icache_adr_o, // address
   output logic                             wb_icache_we_o,  // write
   output logic   [3:0]                     wb_icache_sel_o, // byte enable
   output logic   [9:0]                     wb_icache_bl_o,  // Burst Length
   output logic                             wb_icache_bry_o, // Burst Ready 

   input logic   [YCR_WB_WIDTH-1:0]         wb_icache_dat_i, // data input
   input logic                              wb_icache_ack_i, // acknowlegement
   input logic                              wb_icache_lack_i,// last acknowlegement
   input logic                              wb_icache_err_i,  // error

   // CACHE SRAM Memory I/F
   output logic                             icache_mem_clk0, // CLK
   output logic                             icache_mem_csb0, // CS#
   output logic                             icache_mem_web0, // WE#
   output logic   [8:0]                     icache_mem_addr0, // Address
   output logic   [3:0]                     icache_mem_wmask0, // WMASK#
   output logic   [31:0]                    icache_mem_din0, // Write Data
   //input  logic   [31:0]                  icache_mem_dout0, // Read Data
   
   // SRAM-0 PORT-1, IMEM I/F
   output logic                             icache_mem_clk1, // CLK
   output logic                             icache_mem_csb1, // CS#
   output logic  [8:0]                      icache_mem_addr1, // Address
   input  logic  [31:0]                     icache_mem_dout1, // Read Data
   `endif

   `ifdef YCR_DCACHE_EN
   // Wishbone ICACHE I/F
   output logic                             wb_dcache_cyc_o, // strobe/request
   output logic                             wb_dcache_stb_o, // strobe/request
   output logic   [YCR_WB_WIDTH-1:0]        wb_dcache_adr_o, // address
   output logic                             wb_dcache_we_o,  // write
   output logic   [YCR_WB_WIDTH-1:0]        wb_dcache_dat_o, // data output
   output logic   [3:0]                     wb_dcache_sel_o, // byte enable
   output logic   [9:0]                     wb_dcache_bl_o,  // Burst Length
   output logic                             wb_dcache_bry_o, // Burst Ready

   input logic   [YCR_WB_WIDTH-1:0]         wb_dcache_dat_i,    // data input
   input logic                              wb_dcache_ack_i,   // acknowlegement
   input logic                              wb_dcache_lack_i,  // last acknowlegement
   input logic                              wb_dcache_err_i,   // error

   // CACHE SRAM Memory I/F
   output logic                             dcache_mem_clk0           , // CLK
   output logic                             dcache_mem_csb0           , // CS#
   output logic                             dcache_mem_web0           , // WE#
   output logic   [8:0]                     dcache_mem_addr0          , // Address
   output logic   [3:0]                     dcache_mem_wmask0         , // WMASK#
   output logic   [31:0]                    dcache_mem_din0           , // Write Data
   input  logic   [31:0]                    dcache_mem_dout0          , // Read Data
   
   // SRAM-0 PORT-1, IMEM I/F
   output logic                             dcache_mem_clk1           , // CLK
   output logic                             dcache_mem_csb1           , // CS#
   output logic  [8:0]                      dcache_mem_addr1          , // Address
   input  logic  [31:0]                     dcache_mem_dout1          , // Read Data

   `endif

    // Towards core
    output   logic                          pwrup_rst_n_sync          ,  // Power-Up reset
    output   logic                          rst_n_sync                ,  // Regular reset
    output   logic [`YCR_NUMCORES-1:0]      cpu_core_rst_n_sync       ,  // CPU reset
    output   logic                          test_mode                 ,  // DFT Test Mode
    output   logic                          test_rst_n                ,  // DFT Test Reset
    input    logic   [48:0]                 core0_debug               ,
    input    logic   [48:0]                 core1_debug               ,
`ifdef YCR_DBG_EN
    // Debug Interface
    output   logic                          tapc_trst_n,              // Test Reset (TRSTn)
`endif
    // Memory-mapped external timer
    output   logic [63:0]                   timer_val,                // Machine timer value
    output   logic                          timer_irq,

    // CORE-0
    // Instruction Memory Interface
    output   logic                          core0_imem_req_ack,        // IMEM request acknowledge
    input    logic                          core0_imem_req,            // IMEM request
    input    logic                          core0_imem_cmd,            // IMEM command
    input    logic [`YCR_IMEM_AWIDTH-1:0]   core0_imem_addr,           // IMEM address
    input    logic [`YCR_IMEM_BSIZE-1:0]    core0_imem_bl,             // IMEM burst size
    output   logic [`YCR_IMEM_DWIDTH-1:0]   core0_imem_rdata,          // IMEM read data
    output   logic [1:0]                    core0_imem_resp,           // IMEM response


    // Data Memory Interface
    output   logic                          core0_dmem_req_ack,        // DMEM request acknowledge
    input    logic                          core0_dmem_req,            // DMEM request
    input    logic                          core0_dmem_cmd,            // DMEM command
    input    logic[1:0]                     core0_dmem_width,          // DMEM data width
    input    logic [`YCR_DMEM_AWIDTH-1:0]   core0_dmem_addr,           // DMEM address
    input    logic [`YCR_DMEM_DWIDTH-1:0]   core0_dmem_wdata,          // DMEM write data
    output   logic [`YCR_DMEM_DWIDTH-1:0]   core0_dmem_rdata,          // DMEM read data
    output   logic [1:0]                    core0_dmem_resp,           // DMEM response

    // CORE-1
    // Instruction Memory Interface
    output   logic                          core1_imem_req_ack,        // IMEM request acknowledge
    input    logic                          core1_imem_req,            // IMEM request
    input    logic                          core1_imem_cmd,            // IMEM command
    input    logic [`YCR_IMEM_AWIDTH-1:0]   core1_imem_addr,           // IMEM address
    input    logic [`YCR_IMEM_BSIZE-1:0]    core1_imem_bl,             // IMEM burst size
    output   logic [`YCR_IMEM_DWIDTH-1:0]   core1_imem_rdata,          // IMEM read data
    output   logic [1:0]                    core1_imem_resp,           // IMEM response


    // Data Memory Interface
    output   logic                          core1_dmem_req_ack,        // DMEM request acknowledge
    input    logic                          core1_dmem_req,            // DMEM request
    input    logic                          core1_dmem_cmd,            // DMEM command
    input    logic[1:0]                     core1_dmem_width,          // DMEM data width
    input    logic [`YCR_DMEM_AWIDTH-1:0]   core1_dmem_addr,           // DMEM address
    input    logic [`YCR_DMEM_DWIDTH-1:0]   core1_dmem_wdata,          // DMEM write data
    output   logic [`YCR_DMEM_DWIDTH-1:0]   core1_dmem_rdata,          // DMEM read data
    output   logic [1:0]                    core1_dmem_resp,           // DMEM response

    output   logic                          core0_uid  ,
    output   logic                          core1_uid  


);
//-------------------------------------------------------------------------------
// Local parameters
//-------------------------------------------------------------------------------
localparam int unsigned YCR_CLUSTER_TOP_RST_SYNC_STAGES_NUM            = 2;

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------

// Instruction memory interface from router to WB bridge
logic                                              wb_imem_req_ack;
logic                                              wb_imem_req;
logic                                              wb_imem_cmd;
logic [`YCR_IMEM_AWIDTH-1:0]                       wb_imem_addr;
logic [`YCR_IMEM_BSIZE-1:0]                        wb_imem_bl;
logic [`YCR_IMEM_DWIDTH-1:0]                       wb_imem_rdata;
logic [1:0]                                        wb_imem_resp;

// Data memory interface from router to WB bridge
logic                                              wb_dmem_req_ack;
logic                                              wb_dmem_req;
logic                                              wb_dmem_cmd;
logic [1:0]                                        wb_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       wb_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       wb_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       wb_dmem_rdata;
logic [1:0]                                        wb_dmem_resp;

`ifdef YCR_TCM_EN
// Instruction memory interface from router to TCM
logic                                              tcm_imem_req_ack;
logic                                              tcm_imem_req;
logic                                              tcm_imem_cmd;
logic [`YCR_IMEM_AWIDTH-1:0]                       tcm_imem_addr;
logic [`YCR_IMEM_DWIDTH-1:0]                       tcm_imem_rdata;
logic [1:0]                                        tcm_imem_resp;

// Data memory interface from router to TCM
logic                                              tcm_dmem_req_ack;
logic                                              tcm_dmem_req;
logic                                              tcm_dmem_cmd;
logic [1:0]                                        tcm_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       tcm_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       tcm_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       tcm_dmem_rdata;
logic [1:0]                                        tcm_dmem_resp;
`endif // YCR_TCM_EN

// Data memory interface from router to memory-mapped timer
logic                                              timer_dmem_req_ack;
logic                                              timer_dmem_req;
logic                                              timer_dmem_cmd;
logic [1:0]                                        timer_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       timer_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       timer_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       timer_dmem_rdata;
logic [1:0]                                        timer_dmem_resp;

`ifdef YCR_ICACHE_EN
// Instruction memory interface from router to icache
logic                                              icache_imem_req_ack;
logic                                              icache_imem_req;
logic                                              icache_imem_cmd;
logic [`YCR_IMEM_AWIDTH-1:0]                       icache_imem_addr;
logic [`YCR_IMEM_BSIZE-1:0]                        icache_imem_bl;
logic [`YCR_IMEM_DWIDTH-1:0]                       icache_imem_rdata;
logic [1:0]                                        icache_imem_resp;

// Data memory interface from router to icache
logic                                              icache_dmem_req_ack;
logic                                              icache_dmem_req;
logic                                              icache_dmem_cmd;
logic [1:0]                                        icache_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       icache_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       icache_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       icache_dmem_rdata;
logic [1:0]                                        icache_dmem_resp;

// instruction/Data memory interface towards icache
logic                                              icache_req_ack;
logic                                              icache_req;
logic                                              icache_cmd;
logic [1:0]                                        icache_width;
logic [`YCR_IMEM_AWIDTH-1:0]                       icache_addr;
logic [`YCR_IMEM_BSIZE-1:0]                        icache_bl;
logic [`YCR_IMEM_DWIDTH-1:0]                       icache_wdata;
logic [`YCR_IMEM_DWIDTH-1:0]                       icache_rdata;
logic [1:0]                                        icache_resp;

`endif // YCR_ICACHE_EN

`ifdef YCR_DCACHE_EN
// Instruction memory interface from router to dcache
logic                                              dcache_imem_req_ack;
logic                                              dcache_imem_req;
logic                                              dcache_imem_cmd;
logic [`YCR_IMEM_AWIDTH-1:0]                       dcache_imem_addr;
logic [`YCR_IMEM_DWIDTH-1:0]                       dcache_imem_rdata;
logic [1:0]                                        dcache_imem_resp;

// Data memory interface from router to icache
logic                                              dcache_dmem_req_ack;
logic                                              dcache_dmem_req;
logic                                              dcache_dmem_cmd;
logic [1:0]                                        dcache_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       dcache_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       dcache_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       dcache_dmem_rdata;
logic [1:0]                                        dcache_dmem_resp;

// instruction/Data memory interface towards icache
logic                                              dcache_req_ack;
logic                                              dcache_req;
logic                                              dcache_cmd;
logic [1:0]                                        dcache_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       dcache_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       dcache_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       dcache_rdata;
logic [1:0]                                        dcache_resp;

`endif // YCR_ICACHE_EN

`ifdef YCR_ICACHE_EN
   // Wishbone ICACHE I/F
   logic                                           wb_icache_cclk_stb_o; // strobe/request
   logic   [YCR_WB_WIDTH-1:0]                      wb_icache_cclk_adr_o; // address
   logic                                           wb_icache_cclk_we_o;  // write
   logic   [YCR_WB_WIDTH-1:0]                      wb_icache_cclk_dat_o; // data output
   logic   [3:0]                                   wb_icache_cclk_sel_o; // byte enable
   logic   [9:0]                                   wb_icache_cclk_bl_o;  // Burst Length

   logic   [YCR_WB_WIDTH-1:0]                      wb_icache_cclk_dat_i; // data input
   logic                                           wb_icache_cclk_ack_i; // acknowlegement
   logic                                           wb_icache_cclk_lack_i;// last acknowlegement
   logic                                           wb_icache_cclk_err_i; // error
`endif

`ifdef YCR_DCACHE_EN
   // Wishbone ICACHE I/F
   logic                                           wb_dcache_cclk_stb_o; // strobe/request
   logic   [YCR_WB_WIDTH-1:0]                      wb_dcache_cclk_adr_o; // address
   logic                                           wb_dcache_cclk_we_o;  // write
   logic   [YCR_WB_WIDTH-1:0]                      wb_dcache_cclk_dat_o; // data output
   logic   [3:0]                                   wb_dcache_cclk_sel_o; // byte enable
   logic   [9:0]                                   wb_dcache_cclk_bl_o;  // Burst Length

   logic   [YCR_WB_WIDTH-1:0]                      wb_dcache_cclk_dat_i; // data input
   logic                                           wb_dcache_cclk_ack_i; // acknowlegement
   logic                                           wb_dcache_cclk_lack_i;// last acknowlegement
   logic                                           wb_dcache_cclk_err_i; // error
`endif
`ifndef YCR_TCM_MEM
    // SRAM-1 PORT-0
    logic                                          sram1_clk0;
    logic                                          sram1_csb0;
    logic                                          sram1_web0;
    logic   [8:0]                                  sram1_addr0;
    logic   [3:0]                                  sram1_wmask0;
    logic   [31:0]                                 sram1_din0;
    logic   [31:0]                                 sram1_dout0;

    // SRAM-1 PORT-1
    logic                                          sram1_clk1;
    logic                                          sram1_csb1;
    logic  [8:0]                                   sram1_addr1;
    logic  [31:0]                                  sram1_dout1;
`endif
// Instruction Memory Interface
logic                                              core_imem_req_ack       ;  // IMEM request acknowledge
logic                                              core_imem_req           ;  // IMEM request
logic                                              core_imem_cmd           ;  // IMEM command
logic [`YCR_IMEM_AWIDTH-1:0]                       core_imem_addr          ;  // IMEM address
logic [`YCR_IMEM_BSIZE-1:0]                        core_imem_bl            ;  // IMEM burst size
logic [`YCR_IMEM_DWIDTH-1:0]                       core_imem_rdata         ;  // IMEM read data
logic [1:0]                                        core_imem_resp          ;  // IMEM response


// Data Memory Interface
logic                                              core_dmem_req_ack       ;  // DMEM request acknowledge
logic                                              core_dmem_req           ;  // DMEM request
logic                                              core_dmem_cmd           ;  // DMEM command
logic[1:0]                                         core_dmem_width         ;  // DMEM data width
logic [`YCR_DMEM_AWIDTH-1:0]                       core_dmem_addr          ;  // DMEM address
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dmem_wdata         ;  // DMEM write data
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dmem_rdata         ;  // DMEM read data
logic [1:0]                                        core_dmem_resp          ;  // DMEM response


logic                                              cpu_intf_rst_n_sync;
logic   [48:0]                                     core_debug;


// Unique core it lower bits
assign core0_uid = 1'b0;
assign core1_uid = 1'b1;

assign core_debug = (core_debug_sel == 2'b0) ? core0_debug : core1_debug;
                                               
// riscv clock skew control
clk_skew_adjust u_skew_riscv
       (
`ifdef USE_POWER_PINS
     .vccd1                   (vccd1                   ),// User area 1 1.8V supply
     .vssd1                   (vssd1                   ),// User area 1 digital ground
`endif
	    .clk_in                  (wbd_clk_int             ), 
	    .sel                     (cfg_cska_riscv          ), 
	    .clk_out                 (wbd_clk_riscv           ) 
       );

genvar core_no;
generate
for (core_no = 0; $unsigned(core_no) < `YCR_NUMCORES; core_no=core_no+1) begin : u_core
    ycr_reset_sync_cell #(
     .STAGES_AMOUNT           (YCR_CLUSTER_TOP_RST_SYNC_STAGES_NUM)
    ) i_reset_sync (
     .rst_n                   (pwrup_rst_n                 ),
     .clk                     (core_clk                    ),
     .test_rst_n              (test_rst_n                  ),
     .test_mode               (test_mode                   ),
     .rst_n_in                (cpu_core_rst_n[core_no]     ),
     .rst_n_out               (cpu_core_rst_n_sync[core_no])
    );
end
endgenerate

// icache request selection betweem imem and dmem
ycr2_mcore_router u_imem_router(
    // Control signals
     .rst_n                   (cpu_intf_rst_n_sync     ),
     .clk                     (core_clk                ),

    // imem interface
     .core0_req_ack           (core0_imem_req_ack      ),
     .core0_req               (core0_imem_req          ),
     .core0_cmd               (core0_imem_cmd          ),
     .core0_addr              (core0_imem_addr         ),
     .core0_bl                (core0_imem_bl           ),
     .core0_width             (YCR_MEM_WIDTH_WORD      ),
     .core0_rdata             (core0_imem_rdata        ),
     .core0_wdata             ('h0                     ),
     .core0_resp              (core0_imem_resp         ),

    // dmem interface
     .core1_req_ack           (core1_imem_req_ack      ),
     .core1_req               (core1_imem_req          ),
     .core1_cmd               (core1_imem_cmd          ),
     .core1_width             (YCR_MEM_WIDTH_WORD      ),
     .core1_addr              (core1_dmem_addr         ),
     .core1_bl                (core1_imem_bl           ),
     .core1_wdata             ('h0                     ),
     .core1_rdata             (core1_imem_rdata        ),
     .core1_resp              (core1_imem_resp         ),

    // icache interface  
     .core_req_ack            (core_imem_req_ack       ),
     .core_req                (core_imem_req           ),
     .core_cmd                (core_imem_cmd           ),
     .core_addr               (core_imem_addr          ),
     .core_bl                 (core_imem_bl            ),
     .core_width              (core_imem_width         ),
     .core_wdata              (                        ),
     .core_rdata              (core_imem_rdata         ),
     .core_resp               (core_imem_resp          )

);

// icache request selection betweem imem and dmem
ycr2_mcore_router u_dmem_router(
    // Control signals
     .rst_n                   (cpu_intf_rst_n_sync     ),
     .clk                     (core_clk                ),

    // core0 interface
     .core0_req_ack           (core0_dmem_req_ack      ),
     .core0_req               (core0_dmem_req          ),
     .core0_cmd               (core0_dmem_cmd          ),
     .core0_addr              (core0_dmem_addr         ),
     .core0_bl                ('h1                     ),
     .core0_width             (core0_dmem_width        ),
     .core0_wdata             (core0_dmem_wdata        ),
     .core0_rdata             (core0_dmem_rdata        ),
     .core0_resp              (core0_dmem_resp         ),

    // core1 interface
     .core1_req_ack           (core1_dmem_req_ack      ),
     .core1_req               (core1_dmem_req          ),
     .core1_cmd               (core1_dmem_cmd          ),
     .core1_addr              (core1_dmem_addr         ),
     .core1_bl                ('h1                     ),
     .core1_width             (core1_dmem_width        ),
     .core1_wdata             (core1_dmem_wdata        ),
     .core1_rdata             (core1_dmem_rdata        ),
     .core1_resp              (core1_dmem_resp         ),

    // core interface  
     .core_req_ack            (core_dmem_req_ack       ),
     .core_req                (core_dmem_req           ),
     .core_cmd                (core_dmem_cmd           ),
     .core_width              (core_dmem_width         ),
     .core_addr               (core_dmem_addr          ),
     .core_bl                 (core_dmem_bl            ),
     .core_wdata              (core_dmem_wdata         ),
     .core_rdata              (core_dmem_rdata         ),
     .core_resp               (core_dmem_resp          )

);


//-------------------------------------------------------------------------------
// YCR Intf instance
//-------------------------------------------------------------------------------
ycr_intf u_intf (
    // Control
     .pwrup_rst_n             (pwrup_rst_n             ), // Power-Up Reset
     .rst_n                   (rst_n                   ), // Regular Reset signal
     .cpu_intf_rst_n          (cpu_intf_rst_n          ), // CPU Reset (Core Reset)
     .core_clk                (core_clk                ), // Core clock
     .rtc_clk                 (rtc_clk                 ), // Real-time clock
     .riscv_debug             (riscv_debug             ),

`ifdef YCR_DBG_EN
    // -- JTAG I/F
     .trst_n                  (trst_n                  ),
`endif // YCR_DBG_EN

`ifndef YCR_TCM_MEM
    // SRAM-0 PORT-0
     .sram0_clk0              (sram0_clk0              ),
     .sram0_csb0              (sram0_csb0              ),
     .sram0_web0              (sram0_web0              ),
     .sram0_addr0             (sram0_addr0             ),
     .sram0_wmask0            (sram0_wmask0            ),
     .sram0_din0              (sram0_din0              ),
    .sram0_dout0                       (sram0_dout0),
    
    // SRAM-0 PORT-1
     .sram0_clk1              (sram0_clk1              ),
     .sram0_csb1              (sram0_csb1              ),
     .sram0_addr1             (sram0_addr1             ),
     .sram0_dout1             (sram0_dout1             ),
 
`endif

     .wb_rst_n                (wb_rst_n                ), // Wish bone reset
     .wb_clk                  (wb_clk                  ), // wish bone clock

    // Instruction Memory Interface
    //.wbd_imem_stb_o                     (),         // strobe/request
    //.wbd_imem_adr_o                     (),         // address
    //.wbd_imem_we_o                      (),         // write
    //.wbd_imem_dat_o                     (),         // data output
    //.wbd_imem_sel_o                     (),         // byte enable
    //.wbd_imem_dat_i                     ('h0),      // data input
    //.wbd_imem_ack_i                     (1'b0),     // acknowlegement
    //.wbd_imem_err_i                     (1'b0),     // error

    // Data Memory Interface
     .wbd_dmem_stb_o          (wbd_dmem_stb_o          ), // strobe/request
     .wbd_dmem_adr_o          (wbd_dmem_adr_o          ), // address
     .wbd_dmem_we_o           (wbd_dmem_we_o           ), // write
     .wbd_dmem_dat_o          (wbd_dmem_dat_o          ), // data output
     .wbd_dmem_sel_o          (wbd_dmem_sel_o          ), // byte enable
     .wbd_dmem_dat_i          (wbd_dmem_dat_i          ), // data input
     .wbd_dmem_ack_i          (wbd_dmem_ack_i          ), // acknowlegement
     .wbd_dmem_err_i          (wbd_dmem_err_i          ), // error

   `ifdef YCR_ICACHE_EN
   // Wishbone ICACHE I/F
     .wb_icache_cyc_o         (                        ), // strobe/request
     .wb_icache_stb_o         (wb_icache_stb_o         ), // strobe/request
     .wb_icache_adr_o         (wb_icache_adr_o         ), // address
     .wb_icache_we_o          (wb_icache_we_o          ), // write
     .wb_icache_sel_o         (wb_icache_sel_o         ), // byte enable
     .wb_icache_bl_o          (wb_icache_bl_o          ), // Burst Length
     .wb_icache_bry_o         (wb_icache_bry_o         ), // Burst Ready
                                                          
     .wb_icache_dat_i         (wb_icache_dat_i         ), // data input
     .wb_icache_ack_i         (wb_icache_ack_i         ), // acknowlegement
     .wb_icache_lack_i        (wb_icache_lack_i        ), // last acknowlegement
     .wb_icache_err_i         (wb_icache_err_i         ), // error

     .icache_mem_clk0         (icache_mem_clk0         ), // CLK
     .icache_mem_csb0         (icache_mem_csb0         ), // CS#
     .icache_mem_web0         (icache_mem_web0         ), // WE#
     .icache_mem_addr0        (icache_mem_addr0        ), // Address
     .icache_mem_wmask0       (icache_mem_wmask0       ), // WMASK#
     .icache_mem_din0         (icache_mem_din0         ), // Write Data
//   .icache_mem_dout0        (icache_mem_dout0        ), // Read Data
                                             
                                             
     .icache_mem_clk1         (icache_mem_clk1         ), // CLK
     .icache_mem_csb1         (icache_mem_csb1         ), // CS#
     .icache_mem_addr1        (icache_mem_addr1        ), // Address
     .icache_mem_dout1        (icache_mem_dout1        ), // Read Data

   `endif


   `ifdef YCR_DCACHE_EN
   // Wishbone DCACHE I/F
     .wb_dcache_cyc_o         (                        ), // strobe/request
     .wb_dcache_stb_o         (wb_dcache_stb_o         ), // strobe/request
     .wb_dcache_adr_o         (wb_dcache_adr_o         ), // address
     .wb_dcache_we_o          (wb_dcache_we_o          ), // write
     .wb_dcache_dat_o         (wb_dcache_dat_o         ), // data output
     .wb_dcache_sel_o         (wb_dcache_sel_o         ), // byte enable
     .wb_dcache_bl_o          (wb_dcache_bl_o          ), // Burst Length
     .wb_dcache_bry_o         (wb_dcache_bry_o         ), // Burst Ready
                                                          
     .wb_dcache_dat_i         (wb_dcache_dat_i         ), // data input
     .wb_dcache_ack_i         (wb_dcache_ack_i         ), // acknowlegement
     .wb_dcache_lack_i        (wb_dcache_lack_i        ), // last acknowlegement
     .wb_dcache_err_i         (wb_dcache_err_i         ), // error

     .dcache_mem_clk0         (dcache_mem_clk0         ), // CLK
     .dcache_mem_csb0         (dcache_mem_csb0         ), // CS#
     .dcache_mem_web0         (dcache_mem_web0         ), // WE#
     .dcache_mem_addr0        (dcache_mem_addr0        ), // Address
     .dcache_mem_wmask0       (dcache_mem_wmask0       ), // WMASK#
     .dcache_mem_din0         (dcache_mem_din0         ), // Write Data
     .dcache_mem_dout0        (dcache_mem_dout0        ), // Read Data
                                             
                                             
     .dcache_mem_clk1         (dcache_mem_clk1         ), // CLK
     .dcache_mem_csb1         (dcache_mem_csb1         ), // CS#
     .dcache_mem_addr1        (dcache_mem_addr1        ), // Address
     .dcache_mem_dout1        (dcache_mem_dout1        ), // Read Data

   `endif
    // Common
     .cpu_intf_rst_n_sync     (cpu_intf_rst_n_sync     ),
     .pwrup_rst_n_sync        (pwrup_rst_n_sync        ), // Power-Up reset
     .rst_n_sync              (rst_n_sync              ), // Regular reset
     .test_mode               (test_mode               ), // DFT Test Mode
     .test_rst_n              (test_rst_n              ), // DFT Test Reset
     .core_debug              (core_debug              ),
`ifdef YCR_DBG_EN
    // Debug Interface
     .tapc_trst_n             (tapc_trst_n             ), // Test Reset (TRSTn)
`endif
    // Memory-mapped external timer
     .timer_val               (timer_val               ), // Machine timer value
     .timer_irq               (timer_irq               ), // Machine timer value
    // Instruction Memory Interface
     .core_imem_req_ack       (core_imem_req_ack       ), // IMEM request acknowledge
     .core_imem_req           (core_imem_req           ), // IMEM request
     .core_imem_cmd           (core_imem_cmd           ), // IMEM command
     .core_imem_addr          (core_imem_addr          ), // IMEM address
     .core_imem_bl            (core_imem_bl            ), // IMEM address
     .core_imem_rdata         (core_imem_rdata         ), // IMEM read data
     .core_imem_resp          (core_imem_resp          ), // IMEM response

    // Data Memory Interface
     .core_dmem_req_ack       (core_dmem_req_ack       ), // DMEM request acknowledge
     .core_dmem_req           (core_dmem_req           ), // DMEM request
     .core_dmem_cmd           (core_dmem_cmd           ), // DMEM command
     .core_dmem_width         (core_dmem_width         ), // DMEM data width
     .core_dmem_addr          (core_dmem_addr          ), // DMEM address
     .core_dmem_wdata         (core_dmem_wdata         ), // DMEM write data
     .core_dmem_rdata         (core_dmem_rdata         ), // DMEM read data
     .core_dmem_resp          (core_dmem_resp          )  // DMEM response

);


endmodule : ycr2_mintf
