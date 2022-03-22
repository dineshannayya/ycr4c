//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021, Dinesh Annayya                           ////
//                                                                        ////
// Licenseunder the Apache License, Vers2.0(the "License");               ////
// you maynot use this file except in compliance with the License.       ////
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
////  yifive Four core RISCV Top                                          ////
////                                                                      ////
////  This file is part of the yifive cores project                       ////
////  https://github.com/dineshannayya/ycr4.git                           ////
////                                                                      ////
////  Description:                                                        ////
////     integrated 4 Risc core with instruction/data memory & wb         ////
////                                                                      ////
////  To Do:                                                              ////
////    nothing                                                           ////
////                                                                      ////
////  Authors:                                                            ////
////      Dinesh Annayya, dinesha@opencores.org                           ////
////                                                                      ////
////  CPU Memory Map:                                                     ////
////            0x0000_0000 to 0x07FF_FF(128MB) - ICACHE                  ////
////            0x0800_0000 to 0x0BFF_FFFF (64MB)  - DCACHE               ////
////            0x0C48_0000 to 0x0C48_FFFF (64K)   - TCM SRAM             ////
////            0x0C49_0000 to 0x0C49_000F (16)    - TIMER                ////
////                                                                      ////
////  Revision :                                                          ////
////     0.0:    June 7, 2021, Dinesh A                                   ////
////             wishbone integration                                     ////
////     0.1:    June 17, 2021, Dinesh A                                  ////
////             core and wishbone clock domain are seperated             ////
////             Async fifo added in imem and dmem path                   ////
////     0.2:    July 7, 2021, Dinesh A                                   ////
////            64bit debug signal added                                  ////
////     0.3:    Aug 23, 2021, Dinesh A                                   ////
////            timer_irq connective bug fix                              ////
////     1.0:   Jan 20, 2022, Dinesh A                                    ////
////            128MB icache integrated in address range 0x0000_0000 to   ////
////            0x07FF_FFFF                                               ////
////     1.1:   Jan 22, 2022, Dinesh A                                    ////
////            64MB dcache added in the address range 0x0800_0000 to     ////
////            0x0BFF_FFFF                                               ////
////     1.2:   Jan 30, 2022, Dinesh A                                    ////
////            global register newly added in timer register to control  ////
////            icache/dcache operation                                   ////
////     1.3:   Feb 14, 2022, Dinesh A                                    ////
////            Burst Access support added to imem prefetch logic         ////
////            Burst Prefetech support only towards imem address range   ////
////            0x0000_0000 to 0x07FFF_FFFF                               ////
////     1.4:   Feb 20, 2022, Dinesh A                                    ////
////            Total RISC CORE variable added in address at 0xFC1        //// 
////     1.5:   Feb 21, 2022, Dinesh A                                    ////
////            Two Risc core is integrated with common interface block   ////
////     1.6:   Mar 14, 2022, Dinesh A                                    ////
////            fuse_mhartid is internally tied                           ////
////     1.7:   Mar 19, 2022, Dinesh A                                    ////
////            four core is integrated                                   ////
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

module ycr4_top_wb                      (

`ifdef USE_POWER_PINS
         input logic                          vccd1,    // User area 1 1.8V supply
         input logic                          vssd1,    // User area 1 digital ground
`endif
         input  logic   [3:0]                 cfg_cska_riscv,
         input  logic                         wbd_clk_int,
         output logic                         wbd_clk_riscv,

    // Control
    input   logic                             pwrup_rst_n,            // Power-Up Reset
    input   logic                             rst_n,                  // Regular Reset signal
    input   logic [`YCR_NUMCORES-1:0]         cpu_core_rst_n,         // CPReset (Core Reset )
    input   logic                             cpu_intf_rst_n,         // CPU interface reset
    input   logic [1:0]                       core_debug_sel,         // core debug selection
    // input   logic                          test_mode,              // Test mode - unused
    // input   logic                          test_rst_n,             // Test mode's reset - unused
    input   logic                             core_clk,               // Core clock
    input   logic                             rtc_clk,                // Real-time clock
    output  logic [63:0]                      riscv_debug,
`ifdef YCR_DBG_EN
    output  logic                             sys_rst_n_o,            // External System Reset output
                                                                      //   (for the processor cluster's components or
                                                                      //    external SOC (could be useful in small
                                                                      //    YCR-core-centric SOCs))
    output  logic                             sys_rdc_qlfy_o,         // System-to-External SOC Reset Domain Crossing Qualifier
`endif // YCR_DBG_EN

`ifdef YCR_DBG_EN
    input   logic [31:0]                      fuse_idcode,            // TAPC IDCODE
`endif // YCR_DBG_EN

    // IRQ
`ifdef YCR_IPIC_EN
    input   logic [YCR_IRQ_LINES_NUM-1:0]irq_lines,              // IRQ lines to IPIC
`else // YCR_IPIC_EN
    input   logic                        ext_irq,                // External IRQ input
`endif // YCR_IPIC_EN
    input   logic                        soft_irq,               // Software IRQ input

`ifdef YCR_DBG_EN
    // -- JTAG I/F
    input   logic                        trst_n,
    input   logic                        tck,
    input   logic                        tms,
    input   logic                        tdi,
    output  logic                        tdo,
    output  logic                        tdo_en,
`endif // YCR_DBG_EN

`ifndef YCR_TCM_MEM
    // SRAM-0 PORT-0
    output  logic                        sram0_clk0,
    output  logic                        sram0_csb0,
    output  logic                        sram0_web0,
    output  logic   [8:0]                sram0_addr0,
    output  logic   [3:0]                sram0_wmask0,
    output  logic   [31:0]               sram0_din0,
    input   logic   [31:0]               sram0_dout0,

    // SRAM-0 PORT-1
    output  logic                        sram0_clk1,
    output  logic                        sram0_csb1,
    output  logic  [8:0]                 sram0_addr1,
    input   logic  [31:0]                sram0_dout1,

`endif


    input   logic                        wb_rst_n,       // Wish bone reset
    input   logic                        wb_clk,         // wish bone clock

   `ifdef YCR_ICACHE_EN
   // Wishbone ICACHE I/F
   output logic                          wb_icache_stb_o, // strobe/request
   output logic   [YCR_WB_WIDTH-1:0]     wb_icache_adr_o, // address
   output logic                          wb_icache_we_o,  // write
   output logic   [3:0]                  wb_icache_sel_o, // byte enable
   output logic   [9:0]                  wb_icache_bl_o,  // Burst Length
   output logic                          wb_icache_bry_o, // Burst Ready 

   input logic   [YCR_WB_WIDTH-1:0]      wb_icache_dat_i, // data input
   input logic                           wb_icache_ack_i, // acknowlegement
   input logic                           wb_icache_lack_i,// last acknowlegement
   input logic                           wb_icache_err_i,  // error

   // CACHE SRAM Memory I/F
   output logic                          icache_mem_clk0, // CLK
   output logic                          icache_mem_csb0, // CS#
   output logic                          icache_mem_web0, // WE#
   output logic   [8:0]                  icache_mem_addr0, // Address
   output logic   [3:0]                  icache_mem_wmask0, // WMASK#
   output logic   [31:0]                 icache_mem_din0, // Write Data
   //input  logic   [31:0]               icache_mem_dout0, // Read Data
   
   // SRAM-0 PORT-1, IMEM I/F
   output logic                          icache_mem_clk1, // CLK
   output logic                          icache_mem_csb1, // CS#
   output logic  [8:0]                   icache_mem_addr1, // Address
   input  logic  [31:0]                  icache_mem_dout1, // Read Data
   `endif

   `ifdef YCR_DCACHE_EN
   // Wishbone ICACHE I/F
   output logic                          wb_dcache_stb_o, // strobe/request
   output logic   [YCR_WB_WIDTH-1:0]     wb_dcache_adr_o, // address
   output logic                          wb_dcache_we_o,  // write
   output logic   [YCR_WB_WIDTH-1:0]     wb_dcache_dat_o, // data output
   output logic   [3:0]                  wb_dcache_sel_o, // byte enable
   output logic   [9:0]                  wb_dcache_bl_o,  // Burst Length
   output logic                          wb_dcache_bry_o, // Burst Ready

   input logic   [YCR_WB_WIDTH-1:0]      wb_dcache_dat_i, // data input
   input logic                           wb_dcache_ack_i, // acknowlegement
   input logic                           wb_dcache_lack_i,// last acknowlegement
   input logic                           wb_dcache_err_i,  // error

   // CACHE SRAM Memory I/F
   output logic                          dcache_mem_clk0           , // CLK
   output logic                          dcache_mem_csb0           , // CS#
   output logic                          dcache_mem_web0           , // WE#
   output logic   [8:0]                  dcache_mem_addr0          , // Address
   output logic   [3:0]                  dcache_mem_wmask0         , // WMASK#
   output logic   [31:0]                 dcache_mem_din0           , // Write Data
   input  logic   [31:0]                 dcache_mem_dout0          , // Read Data
   
   // SRAM-0 PORT-1, IMEM I/F
   output logic                          dcache_mem_clk1           , // CLK
   output logic                          dcache_mem_csb1           , // CS#
   output logic  [8:0]                   dcache_mem_addr1          , // Address
   input  logic  [31:0]                  dcache_mem_dout1          , // Read Data
   `endif


    // Data Memory Interface
    output  logic                        wbd_dmem_stb_o, // strobe/request
    output  logic   [YCR_WB_WIDTH-1:0]   wbd_dmem_adr_o, // address
    output  logic                        wbd_dmem_we_o,  // write
    output  logic   [YCR_WB_WIDTH-1:0]   wbd_dmem_dat_o, // data output
    output  logic   [3:0]                wbd_dmem_sel_o, // byte enable
    input   logic   [YCR_WB_WIDTH-1:0]   wbd_dmem_dat_i, // data input
    input   logic                        wbd_dmem_ack_i, // acknowlegement
    input   logic                        wbd_dmem_err_i  // error
);

//-------------------------------------------------------------------------------
// Local parameters
//-------------------------------------------------------------------------------
localparam int unsigned YCR_CLUSTER_TOP_RST_SYNC_STAGES_NUM            = 2;

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------
// Reset logic
logic                                               pwrup_rst_n_sync;
logic                                               rst_n_sync;
logic                                               cpu_rst_n_sync;
`ifdef YCR_DBG_EN
logic                                               tapc_trst_n;
`endif // YCR_DBG_EN
logic [`YCR_NUMCORES-1:0]                           cpu_core_rst_n_sync;        // CPU Reset (Core Reset)

//----------------------------------------------------------------
// CORE-0 Specific Signals
// ---------------------------------------------------------------
logic [48:0]                                       core0_debug;
logic [1:0]                                        core0_uid;
logic                                              core0_timer_irq;
logic [63:0]                                       core0_timer_val;

// Instruction memory interface from core to router
logic                                              core0_imem_req_ack;
logic                                              core0_imem_req;
logic                                              core0_imem_cmd;
logic [`YCR_IMEM_AWIDTH-1:0]                       core0_imem_addr;
logic [`YCR_IMEM_BSIZE-1:0]                        core0_imem_bl;
logic [`YCR_IMEM_DWIDTH-1:0]                       core0_imem_rdata;
logic [1:0]                                        core0_imem_resp;

// Data memory interface from core to router
logic                                              core0_dmem_req_ack;
logic                                              core0_dmem_req;
logic                                              core0_dmem_cmd;
logic [1:0]                                        core0_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core0_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       core0_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       core0_dmem_rdata;
logic [1:0]                                        core0_dmem_resp;
//----------------------------------------------------------------
// CORE-1 Specific Signals
// ---------------------------------------------------------------
logic [48:0]                                       core1_debug;
logic [1:0]                                        core1_uid;
logic                                              core1_timer_irq;
logic [63:0]                                       core1_timer_val;

// Instruction memory interface from core to router
logic                                              core1_imem_req_ack;
logic                                              core1_imem_req;
logic                                              core1_imem_cmd;
logic [`YCR_IMEM_AWIDTH-1:0]                       core1_imem_addr;
logic [`YCR_IMEM_BSIZE-1:0]                        core1_imem_bl;
logic [`YCR_IMEM_DWIDTH-1:0]                       core1_imem_rdata;
logic [1:0]                                        core1_imem_resp;

// Data memory interface from core to router
logic                                              core1_dmem_req_ack;
logic                                              core1_dmem_req;
logic                                              core1_dmem_cmd;
logic [1:0]                                        core1_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core1_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       core1_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       core1_dmem_rdata;
logic [1:0]                                        core1_dmem_resp;

//----------------------------------------------------------------
// CORE-2 Specific Signals
// ---------------------------------------------------------------
logic [48:0]                                       core2_debug;
logic [1:0]                                        core2_uid;
logic                                              core2_timer_irq;
logic [63:0]                                       core2_timer_val;
// Instruction memory interface from core to router
logic                                              core2_imem_req_ack;
logic                                              core2_imem_req;
logic                                              core2_imem_cmd;
logic [`YCR_IMEM_AWIDTH-1:0]                       core2_imem_addr;
logic [`YCR_IMEM_BSIZE-1:0]                        core2_imem_bl;
logic [`YCR_IMEM_DWIDTH-1:0]                       core2_imem_rdata;
logic [1:0]                                        core2_imem_resp;

// Data memory interface from core to router
logic                                              core2_dmem_req_ack;
logic                                              core2_dmem_req;
logic                                              core2_dmem_cmd;
logic [1:0]                                        core2_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core2_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       core2_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       core2_dmem_rdata;
logic [1:0]                                        core2_dmem_resp;

//----------------------------------------------------------------
// CORE-3 Specific Signals
// ---------------------------------------------------------------
logic [48:0]                                       core3_debug;
logic [1:0]                                        core3_uid;
logic                                              core3_timer_irq;
logic [63:0]                                       core3_timer_val;
// Instruction memory interface from core to router
logic                                              core3_imem_req_ack;
logic                                              core3_imem_req;
logic                                              core3_imem_cmd;
logic [`YCR_IMEM_AWIDTH-1:0]                       core3_imem_addr;
logic [`YCR_IMEM_BSIZE-1:0]                        core3_imem_bl;
logic [`YCR_IMEM_DWIDTH-1:0]                       core3_imem_rdata;
logic [1:0]                                        core3_imem_resp;

// Data memory interface from core to router
logic                                              core3_dmem_req_ack;
logic                                              core3_dmem_req;
logic                                              core3_dmem_cmd;
logic [1:0]                                        core3_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core3_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       core3_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       core3_dmem_rdata;
logic [1:0]                                        core3_dmem_resp;

//----------------------------------------------------
// Data memory interface from router to WB bridge
// --------------------------------------------------
logic                                              core_dmem_req_ack;
logic                                              core_dmem_req;
logic                                              core_dmem_cmd;
logic [1:0]                                        core_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dmem_rdata;
logic [1:0]                                        core_dmem_resp;

//----------------------------------------------------
// icache interface from router to WB bridge
// --------------------------------------------------
logic                                              core_icache_req_ack;
logic                                              core_icache_req;
logic                                              core_icache_cmd;
logic [1:0]                                        core_icache_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core_icache_addr;
logic [2:0]                                        core_icache_bl;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_icache_rdata;
logic [1:0]                                        core_icache_resp;

//----------------------------------------------------
// dcache interface from router to WB bridge
// --------------------------------------------------
logic                                              core_dcache_req_ack;
logic                                              core_dcache_req;
logic                                              core_dcache_cmd;
logic [1:0]                                        core_dcache_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core_dcache_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dcache_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dcache_rdata;
logic [1:0]                                        core_dcache_resp;



//-------------------------------------------------------------------------------
// YCR Intf instance
//-------------------------------------------------------------------------------
ycr4_iconnect u_connect (

          .core_clk                     (core_clk                     ), // Core clock
          .rtc_clk                      (rtc_clk                      ), // Core clock
	  .pwrup_rst_n                  (pwrup_rst_n                  ),
          .cpu_intf_rst_n               (cpu_intf_rst_n_sync          ), // CPU reset

          .core_debug_sel               (core_debug_sel               ),
	  .riscv_debug                  (riscv_debug                  ),

    // CORE-0
          .core0_debug                  (core0_debug                  ),
          .core0_uid                    (core0_uid                    ),
          .core0_timer_val              (core0_timer_val              ), // Machine timer value
          .core0_timer_irq              (core0_timer_irq              ), // Machine timer value
    // Instruction Memory Interface
          .core0_imem_req_ack           (core0_imem_req_ack           ), // IMEM request acknowledge
          .core0_imem_req               (core0_imem_req               ), // IMEM request
          .core0_imem_cmd               (core0_imem_cmd               ), // IMEM command
          .core0_imem_addr              (core0_imem_addr              ), // IMEM address
          .core0_imem_bl                (core0_imem_bl                ), // IMEM address
          .core0_imem_rdata             (core0_imem_rdata             ), // IMEM read data
          .core0_imem_resp              (core0_imem_resp              ), // IMEM response

    // Data Memory Interface
          .core0_dmem_req_ack           (core0_dmem_req_ack           ), // DMEM request acknowledge
          .core0_dmem_req               (core0_dmem_req               ), // DMEM request
          .core0_dmem_cmd               (core0_dmem_cmd               ), // DMEM command
          .core0_dmem_width             (core0_dmem_width             ), // DMEM data width
          .core0_dmem_addr              (core0_dmem_addr              ), // DMEM address
          .core0_dmem_wdata             (core0_dmem_wdata             ), // DMEM write data
          .core0_dmem_rdata             (core0_dmem_rdata             ), // DMEM read data
          .core0_dmem_resp              (core0_dmem_resp              ), // DMEM response

    // CORE-1
          .core1_debug                  (core1_debug                  ),
          .core1_uid                    (core1_uid                    ),
          .core1_timer_val              (core1_timer_val              ), // Machine timer value
          .core1_timer_irq              (core1_timer_irq              ), // Machine timer value
    // Instruction Memory Interface
          .core1_imem_req_ack           (core1_imem_req_ack           ), // IMEM request acknowledge
          .core1_imem_req               (core1_imem_req               ), // IMEM request
          .core1_imem_cmd               (core1_imem_cmd               ), // IMEM command
          .core1_imem_addr              (core1_imem_addr              ), // IMEM address
          .core1_imem_bl                (core1_imem_bl                ), // IMEM address
          .core1_imem_rdata             (core1_imem_rdata             ), // IMEM read data
          .core1_imem_resp              (core1_imem_resp              ), // IMEM response

    // Data Memory Interface
          .core1_dmem_req_ack           (core1_dmem_req_ack           ), // DMEM request acknowledge
          .core1_dmem_req               (core1_dmem_req               ), // DMEM request
          .core1_dmem_cmd               (core1_dmem_cmd               ), // DMEM command
          .core1_dmem_width             (core1_dmem_width             ), // DMEM data width
          .core1_dmem_addr              (core1_dmem_addr              ), // DMEM address
          .core1_dmem_wdata             (core1_dmem_wdata             ), // DMEM write data
          .core1_dmem_rdata             (core1_dmem_rdata             ), // DMEM read data
          .core1_dmem_resp              (core1_dmem_resp              ), // DMEM response

    // CORE-2
          .core2_debug                  (core2_debug                  ),
          .core2_uid                    (core2_uid                    ),
          .core2_timer_val              (core2_timer_val              ), // Machine timer value
          .core2_timer_irq              (core2_timer_irq              ), // Machine timer value
    // Instruction Memory Interface
          .core2_imem_req_ack           (core2_imem_req_ack           ), // IMEM request acknowledge
          .core2_imem_req               (core2_imem_req               ), // IMEM request
          .core2_imem_cmd               (core2_imem_cmd               ), // IMEM command
          .core2_imem_addr              (core2_imem_addr              ), // IMEM address
          .core2_imem_bl                (core2_imem_bl                ), // IMEM address
          .core2_imem_rdata             (core2_imem_rdata             ), // IMEM read data
          .core2_imem_resp              (core2_imem_resp              ), // IMEM response

    // Data Memory Interface
          .core2_dmem_req_ack           (core2_dmem_req_ack           ), // DMEM request acknowledge
          .core2_dmem_req               (core2_dmem_req               ), // DMEM request
          .core2_dmem_cmd               (core2_dmem_cmd               ), // DMEM command
          .core2_dmem_width             (core2_dmem_width             ), // DMEM data width
          .core2_dmem_addr              (core2_dmem_addr              ), // DMEM address
          .core2_dmem_wdata             (core2_dmem_wdata             ), // DMEM write data
          .core2_dmem_rdata             (core2_dmem_rdata             ), // DMEM read data
          .core2_dmem_resp              (core2_dmem_resp              ), // DMEM response
    
    // CORE-3
          .core3_debug                  (core3_debug                  ),
          .core3_uid                    (core3_uid                    ),
          .core3_timer_val              (core3_timer_val              ), // Machine timer value
          .core3_timer_irq              (core3_timer_irq              ), // Machine timer value
    // Instruction Memory Interface
          .core3_imem_req_ack           (core3_imem_req_ack           ), // IMEM request acknowledge
          .core3_imem_req               (core3_imem_req               ), // IMEM request
          .core3_imem_cmd               (core3_imem_cmd               ), // IMEM command
          .core3_imem_addr              (core3_imem_addr              ), // IMEM address
          .core3_imem_bl                (core3_imem_bl                ), // IMEM address
          .core3_imem_rdata             (core3_imem_rdata             ), // IMEM read data
          .core3_imem_resp              (core3_imem_resp              ), // IMEM response

    // Data Memory Interface
          .core3_dmem_req_ack           (core3_dmem_req_ack           ), // DMEM request acknowledge
          .core3_dmem_req               (core3_dmem_req               ), // DMEM request
          .core3_dmem_cmd               (core3_dmem_cmd               ), // DMEM command
          .core3_dmem_width             (core3_dmem_width             ), // DMEM data width
          .core3_dmem_addr              (core3_dmem_addr              ), // DMEM address
          .core3_dmem_wdata             (core3_dmem_wdata             ), // DMEM write data
          .core3_dmem_rdata             (core3_dmem_rdata             ), // DMEM read data
          .core3_dmem_resp              (core3_dmem_resp              ), // DMEM response

    //------------------------------------------------------------------
    // Toward ycr_intf
    // -----------------------------------------------------------------
          .cfg_icache_pfet_dis          (cfg_icache_pfet_dis          ),
          .cfg_icache_ntag_pfet_dis     (cfg_icache_ntag_pfet_dis     ),
          .cfg_dcache_pfet_dis          (cfg_dcache_pfet_dis          ),
          .cfg_dcache_force_flush       (cfg_dcache_force_flush       ),

    // Interface to dmem router
          .core_dmem_req_ack            (core_dmem_req_ack            ),
          .core_dmem_req                (core_dmem_req                ),
          .core_dmem_cmd                (core_dmem_cmd                ),
          .core_dmem_width              (core_dmem_width              ),
          .core_dmem_addr               (core_dmem_addr               ),
          .core_dmem_wdata              (core_dmem_wdata              ),
          .core_dmem_rdata              (core_dmem_rdata              ),
          .core_dmem_resp               (core_dmem_resp               ),

        `ifdef YCR_ICACHE_EN
            // Interface to TCM
          .core_icache_req_ack           (core_icache_req_ack           ),
          .core_icache_req               (core_icache_req               ),
          .core_icache_cmd               (core_icache_cmd               ),
          .core_icache_width             (core_icache_width             ),
          .core_icache_addr              (core_icache_addr              ),
          .core_icache_bl                (core_icache_bl                ),
          .core_icache_rdata             (core_icache_rdata             ),
          .core_icache_resp              (core_icache_resp              ),
        `endif // YCR_ICACHE_EN
        
        `ifdef YCR_DCACHE_EN
            // Interface to TCM
          .core_dcache_req_ack           (core_dcache_req_ack           ),
          .core_dcache_req               (core_dcache_req               ),
          .core_dcache_cmd               (core_dcache_cmd               ),
          .core_dcache_width             (core_dcache_width             ),
          .core_dcache_addr              (core_dcache_addr              ),
          .core_dcache_wdata             (core_dcache_wdata             ),
          .core_dcache_rdata             (core_dcache_rdata             ),
          .core_dcache_resp              (core_dcache_resp              ),
        `endif // YCR_ICACHE_EN
`ifndef YCR_TCM_MEM
    // SRAM-0 PORT-0
          .sram0_clk0                   (sram0_clk0                   ),
          .sram0_csb0                   (sram0_csb0                   ),
          .sram0_web0                   (sram0_web0                   ),
          .sram0_addr0                  (sram0_addr0                  ),
          .sram0_wmask0                 (sram0_wmask0                 ),
          .sram0_din0                   (sram0_din0                   ),
          .sram0_dout0                  (sram0_dout0                  ),
    
    // SRAM-0 PORT-1
          .sram0_clk1                   (sram0_clk1                   ),
          .sram0_csb1                   (sram0_csb1                   ),
          .sram0_addr1                  (sram0_addr1                  ),
          .sram0_dout1                  (sram0_dout1                  )
 
`endif
);

//----------------------------------------------------------------------
//  Interface
//  -------------------------------------------------------------------

ycr_intf u_intf(
`ifdef USE_POWER_PINS
    .vccd1                     (vccd1), // User area 1 1.8V supply
    .vssd1                     (vssd1), // User area 1 digital ground
`endif

    .cfg_cska_riscv            (cfg_cska_riscv            ),
    .wbd_clk_int               (wbd_clk_int               ),
    .wbd_clk_riscv             (wbd_clk_riscv             ),

    // Control
    .pwrup_rst_n               (pwrup_rst_n               ), // Power-Up Reset
    .core_clk                  (core_clk                  ), // Core clock
    .cpu_intf_rst_n            (cpu_intf_rst_n            ), // CPU interface reset

    .cfg_icache_pfet_dis       (cfg_icache_pfet_dis       ),
    .cfg_icache_ntag_pfet_dis  (cfg_icache_ntag_pfet_dis  ),
    .cfg_dcache_pfet_dis       (cfg_dcache_pfet_dis       ),
    .cfg_dcache_force_flush    (cfg_dcache_force_flush    ),

    // Instruction Memory Interface
    .core_icache_req_ack       (core_icache_req_ack       ), // IMEM request acknowledge
    .core_icache_req           (core_icache_req           ), // IMEM request
    .core_icache_cmd           (core_icache_cmd           ), // IMEM command
    .core_icache_width         (core_icache_width         ),
    .core_icache_addr          (core_icache_addr          ), // IMEM address
    .core_icache_bl            (core_icache_bl            ), // IMEM burst size
    .core_icache_rdata         (core_icache_rdata         ), // IMEM read data
    .core_icache_resp          (core_icache_resp          ), // IMEM response

    // Data Memory Interface
    .core_dcache_req_ack       (core_dcache_req_ack       ), // DMEM request acknowledge
    .core_dcache_req           (core_dcache_req           ), // DMEM request
    .core_dcache_cmd           (core_dcache_cmd           ), // DMEM command
    .core_dcache_width         (core_dcache_width         ), // DMEM data width
    .core_dcache_addr          (core_dcache_addr          ), // DMEM address
    .core_dcache_wdata         (core_dcache_wdata         ), // DMEM write data
    .core_dcache_rdata         (core_dcache_rdata         ), // DMEM read data
    .core_dcache_resp          (core_dcache_resp          ), // DMEM response

    // Data memory interface from router to WB bridge
    .core_dmem_req_ack         (core_dmem_req_ack         ),
    .core_dmem_req             (core_dmem_req             ),
    .core_dmem_cmd             (core_dmem_cmd             ),
    .core_dmem_width           (core_dmem_width           ),
    .core_dmem_addr            (core_dmem_addr            ),
    .core_dmem_wdata           (core_dmem_wdata           ),
    .core_dmem_rdata           (core_dmem_rdata           ),
    .core_dmem_resp            (core_dmem_resp            ),
    //--------------------------------------------
    // Wishbone  
    // ------------------------------------------

    .wb_rst_n                  (wb_rst_n                  ), // Wish bone reset
    .wb_clk                    (wb_clk                    ), // wish bone clock

    // Data Memory Interface
    .wbd_dmem_stb_o            (wbd_dmem_stb_o            ), // strobe/request
    .wbd_dmem_adr_o            (wbd_dmem_adr_o            ), // address
    .wbd_dmem_we_o             (wbd_dmem_we_o             ), // write
    .wbd_dmem_dat_o            (wbd_dmem_dat_o            ), // data output
    .wbd_dmem_sel_o            (wbd_dmem_sel_o            ), // byte enable
    .wbd_dmem_dat_i            (wbd_dmem_dat_i            ), // data input
    .wbd_dmem_ack_i            (wbd_dmem_ack_i            ), // acknowlegement
    .wbd_dmem_err_i            (wbd_dmem_err_i            ), // error

   `ifdef YCR_ICACHE_EN
   // Wishbone ICACHE I/F
   .wb_icache_cyc_o           (wb_icache_cyc_o            ), // strobe/request
   .wb_icache_stb_o           (wb_icache_stb_o            ), // strobe/request
   .wb_icache_adr_o           (wb_icache_adr_o            ), // address
   .wb_icache_we_o            (wb_icache_we_o             ), // write
   .wb_icache_sel_o           (wb_icache_sel_o            ), // byte enable
   .wb_icache_bl_o            (wb_icache_bl_o             ), // Burst Length
   .wb_icache_bry_o           (wb_icache_bry_o            ), // Burst Ready 
                                                        
   .wb_icache_dat_i           (wb_icache_dat_i            ), // data input
   .wb_icache_ack_i           (wb_icache_ack_i            ), // acknowlegement
   .wb_icache_lack_i          (wb_icache_lack_i           ), // last acknowlegement
   .wb_icache_err_i           (wb_icache_err_i            ), // error

   // CACHE SRAM Memory I/F
   .icache_mem_clk0           (icache_mem_clk0            ), // CLK
   .icache_mem_csb0           (icache_mem_csb0            ), // CS#
   .icache_mem_web0           (icache_mem_web0            ), // WE#
   .icache_mem_addr0          (icache_mem_addr0           ), // Address
   .icache_mem_wmask0         (icache_mem_wmask0          ), // WMASK#
   .icache_mem_din0           (icache_mem_din0            ), // Write Data
// .icache_mem_dout0          (icache_mem_dout0           ), // Read Data
   
   // SRAM-0 PORT-1, IMEM I/F
   .icache_mem_clk1           (icache_mem_clk1            ), // CLK
   .icache_mem_csb1           (icache_mem_csb1            ), // CS#
   .icache_mem_addr1          (icache_mem_addr1           ), // Address
   .icache_mem_dout1          (icache_mem_dout1           ), // Read Data
   `endif

   `ifdef YCR_DCACHE_EN
   // Wishbone ICACHE I/F
   .wb_dcache_cyc_o           (wb_dcache_cyc_o            ), // strobe/request
   .wb_dcache_stb_o           (wb_dcache_stb_o            ), // strobe/request
   .wb_dcache_adr_o           (wb_dcache_adr_o            ), // address
   .wb_dcache_we_o            (wb_dcache_we_o             ), // write
   .wb_dcache_dat_o           (wb_dcache_dat_o            ), // data output
   .wb_dcache_sel_o           (wb_dcache_sel_o            ), // byte enable
   .wb_dcache_bl_o            (wb_dcache_bl_o             ), // Burst Length
   .wb_dcache_bry_o           (wb_dcache_bry_o            ), // Burst Ready

   .wb_dcache_dat_i           (wb_dcache_dat_i            ), // data input
   .wb_dcache_ack_i           (wb_dcache_ack_i            ), // acknowlegement
   .wb_dcache_lack_i          (wb_dcache_lack_i           ), // last acknowlegement
   .wb_dcache_err_i           (wb_dcache_err_i            ), // error

   // CACHE SRAM Memory I/F
   .dcache_mem_clk0           (dcache_mem_clk0            ), // CLK
   .dcache_mem_csb0           (dcache_mem_csb0            ), // CS#
   .dcache_mem_web0           (dcache_mem_web0            ), // WE#
   .dcache_mem_addr0          (dcache_mem_addr0           ), // Address
   .dcache_mem_wmask0         (dcache_mem_wmask0          ), // WMASK#
   .dcache_mem_din0           (dcache_mem_din0            ), // Write Data
   .dcache_mem_dout0          (dcache_mem_dout0           ), // Read Data
   
   // SRAM-0 PORT-1, IMEM I/F
   .dcache_mem_clk1           (dcache_mem_clk1            ), // CLK
   .dcache_mem_csb1           (dcache_mem_csb1            ), // CS#
   .dcache_mem_addr1          (dcache_mem_addr1           ), // Address
   .dcache_mem_dout1          (dcache_mem_dout1           )  // Read Data

   `endif
);

//-------------------------------------------------------------------------------
// YCR core_0 instance
//-------------------------------------------------------------------------------
ycr_core_top i_core_top_0 (
    // Common
          .pwrup_rst_n                  (pwrup_rst_n                  ),
          .rst_n                        (rst_n                        ),
          .cpu_rst_n                    (cpu_core_rst_n[0]            ),
          .clk                          (core_clk                     ),
          .core_rst_n_o                 (                             ),
          .core_rdc_qlfy_o              (                             ),
`ifdef YCR_DBG_EN
          .sys_rst_n_o                  (sys_rst_n_o                  ),
          .sys_rdc_qlfy_o               (sys_rdc_qlfy_o               ),
`endif // YCR_DBG_EN

`ifdef YCR_DBG_EN
          .tapc_fuse_idcode_i           (fuse_idcode                  ),
`endif // YCR_DBG_EN

    // IRQ
`ifdef YCR_IPIC_EN
          .core_irq_lines_i             (irq_lines                    ),
`else // YCR_IPIC_EN
          .core_irq_ext_i               (ext_irq                      ),
`endif // YCR_IPIC_EN
          .core_irq_soft_i              (soft_irq                     ),
`ifdef YCR_DBG_EN
    // Debug interface
          .tapc_trst_n                  (tapc_trst_n                  ),
          .tapc_tck                     (tck                          ),
          .tapc_tms                     (tms                          ),
          .tapc_tdi                     (tdi                          ),
          .tapc_tdo                     (tdo                          ),
          .tapc_tdo_en                  (tdo_en                       ),
`endif // YCR_DBG_EN

   //---- inter-connect
          .core_irq_mtimer_i            (core0_timer_irq              ),
          .core_mtimer_val_i            (core0_timer_val              ),
          .core_uid                     (core0_uid                    ),
          .core_debug                   (core0_debug                  ),
    // Instruction memory interface
          .imem2core_req_ack_i          (core0_imem_req_ack           ),
          .core2imem_req_o              (core0_imem_req               ),
          .core2imem_cmd_o              (core0_imem_cmd               ),
          .core2imem_addr_o             (core0_imem_addr              ),
          .core2imem_bl_o               (core0_imem_bl                ),
          .imem2core_rdata_i            (core0_imem_rdata             ),
          .imem2core_resp_i             (core0_imem_resp              ),

    // Data memory interface
          .dmem2core_req_ack_i          (core0_dmem_req_ack           ),
          .core2dmem_req_o              (core0_dmem_req               ),
          .core2dmem_cmd_o              (core0_dmem_cmd               ),
          .core2dmem_width_o            (core0_dmem_width             ),
          .core2dmem_addr_o             (core0_dmem_addr              ),
          .core2dmem_wdata_o            (core0_dmem_wdata             ),
          .dmem2core_rdata_i            (core0_dmem_rdata             ),
          .dmem2core_resp_i             (core0_dmem_resp              )
);




//-------------------------------------------------------------------------------
// YCR core_1 instance
//-------------------------------------------------------------------------------
ycr_core_top i_core_top_1 (
    // Common
          .pwrup_rst_n                  (pwrup_rst_n                  ),
          .rst_n                        (rst_n_sync                   ),
          .cpu_rst_n                    (cpu_core_rst_n[1]            ),
          .clk                          (core_clk                     ),
          .core_rst_n_o                 (                             ),
          .core_rdc_qlfy_o              (                             ),
`ifdef YCR_DBG_EN
          .sys_rst_n_o                  (sys_rst_n_o                  ),
          .sys_rdc_qlfy_o               (sys_rdc_qlfy_o               ),
`endif // YCR_DBG_EN

`ifdef YCR_DBG_EN
          .tapc_fuse_idcode_i           (fuse_idcode                  ),
`endif // YCR_DBG_EN

    // IRQ
`ifdef YCR_IPIC_EN
          .core_irq_lines_i             (irq_lines                    ),
`else // YCR_IPIC_EN
          .core_irq_ext_i               (ext_irq                      ),
`endif // YCR_IPIC_EN
          .core_irq_soft_i              (soft_irq                     ),


`ifdef YCR_DBG_EN
    // Debug interface
          .tapc_trst_n                  (tapc_trst_n                  ),
          .tapc_tck                     (tck                          ),
          .tapc_tms                     (tms                          ),
          .tapc_tdi                     (tdi                          ),
          .tapc_tdo                     (tdo                          ),
          .tapc_tdo_en                  (tdo_en                       ),
`endif // YCR_DBG_EN

   //---- inter-connect
          .core_irq_mtimer_i            (core1_timer_irq              ),
          .core_mtimer_val_i            (core1_timer_val              ),
          .core_uid                     (core1_uid                    ),
          .core_debug                   (core1_debug                  ),
    // Instruction memory interface
          .imem2core_req_ack_i          (core1_imem_req_ack           ),
          .core2imem_req_o              (core1_imem_req               ),
          .core2imem_cmd_o              (core1_imem_cmd               ),
          .core2imem_addr_o             (core1_imem_addr              ),
          .core2imem_bl_o               (core1_imem_bl                ),
          .imem2core_rdata_i            (core1_imem_rdata             ),
          .imem2core_resp_i             (core1_imem_resp              ),

    // Data memory interface
          .dmem2core_req_ack_i          (core1_dmem_req_ack           ),
          .core2dmem_req_o              (core1_dmem_req               ),
          .core2dmem_cmd_o              (core1_dmem_cmd               ),
          .core2dmem_width_o            (core1_dmem_width             ),
          .core2dmem_addr_o             (core1_dmem_addr              ),
          .core2dmem_wdata_o            (core1_dmem_wdata             ),
          .dmem2core_rdata_i            (core1_dmem_rdata             ),
          .dmem2core_resp_i             (core1_dmem_resp              )
);

//-------------------------------------------------------------------------------
// YCR core_2 instance
//-------------------------------------------------------------------------------
ycr_core_top i_core_top_2 (
    // Common
          .pwrup_rst_n                  (pwrup_rst_n                  ),
          .rst_n                        (rst_n_sync                   ),
          .cpu_rst_n                    (cpu_core_rst_n[2]            ),
          .clk                          (core_clk                     ),
          .core_rst_n_o                 (                             ),
          .core_rdc_qlfy_o              (                             ),
`ifdef YCR_DBG_EN
          .sys_rst_n_o                  (sys_rst_n_o                  ),
          .sys_rdc_qlfy_o               (sys_rdc_qlfy_o               ),
`endif // YCR_DBG_EN

    // Fuses
`ifdef YCR_DBG_EN
          .tapc_fuse_idcode_i           (fuse_idcode                  ),
`endif // YCR_DBG_EN

    // IRQ
`ifdef YCR_IPIC_EN
          .core_irq_lines_i             (irq_lines                    ),
`else // YCR_IPIC_EN
          .core_irq_ext_i               (ext_irq                      ),
`endif // YCR_IPIC_EN
          .core_irq_soft_i              (soft_irq                     ),


`ifdef YCR_DBG_EN
    // Debug interface
          .tapc_trst_n                  (tapc_trst_n                  ),
          .tapc_tck                     (tck                          ),
          .tapc_tms                     (tms                          ),
          .tapc_tdi                     (tdi                          ),
          .tapc_tdo                     (tdo                          ),
          .tapc_tdo_en                  (tdo_en                       ),
`endif // YCR_DBG_EN

   //---- inter-connect
          .core_irq_mtimer_i            (core2_timer_irq              ),
          .core_mtimer_val_i            (core2_timer_val              ),
          .core_uid                     (core2_uid                    ),
          .core_debug                   (core2_debug                  ),
    // Instruction memory interface
          .imem2core_req_ack_i          (core2_imem_req_ack           ),
          .core2imem_req_o              (core2_imem_req               ),
          .core2imem_cmd_o              (core2_imem_cmd               ),
          .core2imem_addr_o             (core2_imem_addr              ),
          .core2imem_bl_o               (core2_imem_bl                ),
          .imem2core_rdata_i            (core2_imem_rdata             ),
          .imem2core_resp_i             (core2_imem_resp              ),

    // Data memory interface
          .dmem2core_req_ack_i          (core2_dmem_req_ack           ),
          .core2dmem_req_o              (core2_dmem_req               ),
          .core2dmem_cmd_o              (core2_dmem_cmd               ),
          .core2dmem_width_o            (core2_dmem_width             ),
          .core2dmem_addr_o             (core2_dmem_addr              ),
          .core2dmem_wdata_o            (core2_dmem_wdata             ),
          .dmem2core_rdata_i            (core2_dmem_rdata             ),
          .dmem2core_resp_i             (core2_dmem_resp              )
);

//-------------------------------------------------------------------------------
// YCR core_3 instance
//-------------------------------------------------------------------------------
ycr_core_top i_core_top_3 (
    // Common
          .pwrup_rst_n                  (pwrup_rst_n                  ),
          .rst_n                        (rst_n_sync                   ),
          .cpu_rst_n                    (cpu_core_rst_n[3]            ),
          .clk                          (core_clk                     ),
          .core_rst_n_o                 (                             ),
          .core_rdc_qlfy_o              (                             ),
`ifdef YCR_DBG_EN
          .sys_rst_n_o                  (sys_rst_n_o                  ),
          .sys_rdc_qlfy_o               (sys_rdc_qlfy_o               ),
`endif // YCR_DBG_EN

    // Fuses
`ifdef YCR_DBG_EN
          .tapc_fuse_idcode_i           (fuse_idcode                  ),
`endif // YCR_DBG_EN

    // IRQ
`ifdef YCR_IPIC_EN
          .core_irq_lines_i             (irq_lines                    ),
`else // YCR_IPIC_EN
          .core_irq_ext_i               (ext_irq                      ),
`endif // YCR_IPIC_EN
          .core_irq_soft_i              (soft_irq                     ),

`ifdef YCR_DBG_EN
    // Debug interface
          .tapc_trst_n                  (tapc_trst_n                  ),
          .tapc_tck                     (tck                          ),
          .tapc_tms                     (tms                          ),
          .tapc_tdi                     (tdi                          ),
          .tapc_tdo                     (tdo                          ),
          .tapc_tdo_en                  (tdo_en                       ),
`endif // YCR_DBG_EN

   //---- inter-connect
          .core_irq_mtimer_i            (core3_timer_irq              ),
          .core_mtimer_val_i            (core3_timer_val              ),
          .core_uid                     (core3_uid                    ),
          .core_debug                   (core3_debug                  ),
    // Instruction memory interface
          .imem2core_req_ack_i          (core3_imem_req_ack           ),
          .core2imem_req_o              (core3_imem_req               ),
          .core2imem_cmd_o              (core3_imem_cmd               ),
          .core2imem_addr_o             (core3_imem_addr              ),
          .core2imem_bl_o               (core3_imem_bl                ),
          .imem2core_rdata_i            (core3_imem_rdata             ),
          .imem2core_resp_i             (core3_imem_resp              ),

    // Data memory interface
          .dmem2core_req_ack_i          (core3_dmem_req_ack           ),
          .core2dmem_req_o              (core3_dmem_req               ),
          .core2dmem_cmd_o              (core3_dmem_cmd               ),
          .core2dmem_width_o            (core3_dmem_width             ),
          .core2dmem_addr_o             (core3_dmem_addr              ),
          .core2dmem_wdata_o            (core3_dmem_wdata             ),
          .dmem2core_rdata_i            (core3_dmem_rdata             ),
          .dmem2core_resp_i             (core3_dmem_resp              )
);

endmodule : ycr4_top_wb

