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
////  yifive interface block                                              ////
////                                                                      ////
////  This file is part of the yifive cores project                       ////
////  https://github.com/dineshannayya/ycr.git                           ////
////                                                                      ////
////  Description:                                                        ////
////     Holds interface block and timer & reset sync logic               ////
////     Instruction memory router                                        ////
////                                                                      ////
////  To Do:                                                              ////
////    nothing                                                           ////
////                                                                      ////
////  Author(s):                                                          ////
////      - Dinesh Annayya, dinesha@opencores.org                         ////
////                                                                      ////
////  Revision :                                                          ////
////     v0:    June 7, 2021, Dinesh A                                    ////
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

module ycr_cache_top (
    // Control
    input   logic                          cpu_intf_rst_n_sync,    // Regular Reset signal
    // From clock gen
    input   logic                          core_clk,               // Core clock


    input   logic                          wb_rst_n,       // Wish bone reset
    input   logic                          wb_clk,         // wish bone clock

   `ifdef YCR_ICACHE_EN
   // Wishbone ICACHE I/F
   output logic                            wb_icache_cyc_o, // strobe/request
   output logic                            wb_icache_stb_o, // strobe/request
   output logic   [YCR_WB_WIDTH-1:0]       wb_icache_adr_o, // address
   output logic                            wb_icache_we_o,  // write
   output logic   [3:0]                    wb_icache_sel_o, // byte enable
   output logic   [9:0]                    wb_icache_bl_o,  // Burst Length
   output logic                            wb_icache_bry_o, // Burst Ready 

   input logic   [YCR_WB_WIDTH-1:0]        wb_icache_dat_i, // data input
   input logic                             wb_icache_ack_i, // acknowlegement
   input logic                             wb_icache_lack_i,// last acknowlegement
   input logic                             wb_icache_err_i,  // error

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
   output logic   [YCR_WB_WIDTH-1:0]       wb_dcache_adr_o, // address
   output logic                             wb_dcache_we_o,  // write
   output logic   [YCR_WB_WIDTH-1:0]       wb_dcache_dat_o, // data output
   output logic   [3:0]                     wb_dcache_sel_o, // byte enable
   output logic   [9:0]                     wb_dcache_bl_o,  // Burst Length
   output logic                             wb_dcache_bry_o, // Burst Ready

   input logic   [YCR_WB_WIDTH-1:0]        wb_dcache_dat_i, // data input
   input logic                              wb_dcache_ack_i, // acknowlegement
   input logic                              wb_dcache_lack_i,// last acknowlegement
   input logic                              wb_dcache_err_i,  // error

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

   // I/F with ycr_mintf
   input logic                           cfg_icache_pfet_dis      ,
   input logic                           cfg_icache_ntag_pfet_dis ,
   input logic                           cfg_dcache_pfet_dis      ,
   input logic                           cfg_dcache_force_flush   ,

    // Towards icache
   output  logic                         icache_req_ack,
   input   logic                         icache_req,
   input   logic                         icache_cmd,
   input   logic [1:0]                   icache_width,
   input   logic [`YCR_DMEM_AWIDTH-1:0]  icache_addr,
   input   logic [`YCR_IMEM_BSIZE-1:0]   icache_bl,             
   input   logic [`YCR_DMEM_DWIDTH-1:0]  icache_wdata,
   output  logic [`YCR_DMEM_DWIDTH-1:0]  icache_rdata,
   output  logic [1:0]                   icache_resp,

    // Towards dcache
   output logic                          dcache_req_ack,
   input  logic                          dcache_req,
   input  logic                          dcache_cmd,
   input  logic [1:0]                    dcache_width,
   input  logic [`YCR_DMEM_AWIDTH-1:0]   dcache_addr,
   input  logic [`YCR_IMEM_BSIZE-1:0]    dcache_bl,             
   input  logic [`YCR_DMEM_DWIDTH-1:0]   dcache_wdata,
   output  logic [`YCR_DMEM_DWIDTH-1:0]  dcache_rdata,
   output  logic [1:0]                   dcache_resp

);
//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------

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


`ifdef YCR_ICACHE_EN

// Icache top
icache_top  #(.MEM_BL(`YCR_IMEM_BSIZE) )u_icache (
	.mclk                         (core_clk),	   //Clock input 
	.rst_n                        (cpu_intf_rst_n_sync),  //Active Low Asynchronous Reset Signal Input

	.cfg_pfet_dis                 (cfg_icache_pfet_dis),// To disable Next Pre data Pre fetch, default = 0
	.cfg_ntag_pfet_dis            (cfg_icache_ntag_pfet_dis),// To disable next Tag refill, default = 0

	// Wishbone CPU I/F
        .cpu_mem_req                 (icache_req),        // strobe/request
        .cpu_mem_addr                (icache_addr),       // address
        .cpu_mem_bl                  (icache_bl),       // address
	.cpu_mem_width               (icache_width),

        .cpu_mem_req_ack             (icache_req_ack),    // data input
        .cpu_mem_rdata               (icache_rdata),      // data input
        .cpu_mem_resp                (icache_resp),        // acknowlegement

	// Wishbone CPU I/F
        .wb_app_stb_o                 (wb_icache_cclk_stb_o  ), // strobe/request
        .wb_app_adr_o                 (wb_icache_cclk_adr_o  ), // address
        .wb_app_we_o                  (wb_icache_cclk_we_o   ), // write
        .wb_app_dat_o                 (wb_icache_cclk_dat_o  ), // data output
        .wb_app_sel_o                 (wb_icache_cclk_sel_o  ), // byte enable
        .wb_app_bl_o                  (wb_icache_cclk_bl_o   ), // Burst Length
                                                    
        .wb_app_dat_i                 (wb_icache_cclk_dat_i  ), // data input
        .wb_app_ack_i                 (wb_icache_cclk_ack_i  ), // acknowlegement
        .wb_app_lack_i                (wb_icache_cclk_lack_i ), // last acknowlegement
        .wb_app_err_i                 (wb_icache_cclk_err_i  ), // error

        // CACHE SRAM Memory I/F
        .cache_mem_clk0               (icache_mem_clk0        ), // CLK
        .cache_mem_csb0               (icache_mem_csb0        ), // CS#
        .cache_mem_web0               (icache_mem_web0        ), // WE#
        .cache_mem_addr0              (icache_mem_addr0       ), // Address
        .cache_mem_wmask0             (icache_mem_wmask0      ), // WMASK#
        .cache_mem_din0               (icache_mem_din0        ), // Write Data
        
        // SRAM-0 PORT-1, IMEM I/F
        .cache_mem_clk1               (icache_mem_clk1        ), // CLK
        .cache_mem_csb1               (icache_mem_csb1        ), // CS#
        .cache_mem_addr1              (icache_mem_addr1       ), // Address
        .cache_mem_dout1              (icache_mem_dout1       ) // Read Data


);

// Async Wishbone clock domain translation
ycr_async_wbb u_async_icache(

    // Master Port
       .wbm_rst_n       (cpu_intf_rst_n_sync ),  // Regular Reset signal
       .wbm_clk_i       (core_clk ),  // System clock
       .wbm_cyc_i       (wb_icache_cclk_stb_o ),  // strobe/request
       .wbm_stb_i       (wb_icache_cclk_stb_o ),  // strobe/request
       .wbm_adr_i       (wb_icache_cclk_adr_o ),  // address
       .wbm_we_i        (wb_icache_cclk_we_o  ),  // write
       .wbm_dat_i       (wb_icache_cclk_dat_o ),  // data output
       .wbm_sel_i       (wb_icache_cclk_sel_o ),  // byte enable
       .wbm_bl_i        (wb_icache_cclk_bl_o  ),  // Burst Count
       .wbm_dat_o       (wb_icache_cclk_dat_i ),  // data input
       .wbm_ack_o       (wb_icache_cclk_ack_i ),  // acknowlegement
       .wbm_lack_o      (wb_icache_cclk_lack_i),  // Last Burst access
       .wbm_err_o       (wb_icache_cclk_err_i ),  // error

    // Slave Port
       .wbs_rst_n       (wb_rst_n             ),  // Regular Reset signal
       .wbs_clk_i       (wb_clk               ),  // System clock
       .wbs_cyc_o       (wb_icache_cyc_o      ),  // strobe/request
       .wbs_stb_o       (wb_icache_stb_o      ),  // strobe/request
       .wbs_adr_o       (wb_icache_adr_o      ),  // address
       .wbs_we_o        (wb_icache_we_o       ),  // write
       .wbs_dat_o       (                     ),  // data output- Unused
       .wbs_sel_o       (wb_icache_sel_o      ),  // byte enable
       .wbs_bl_o        (wb_icache_bl_o       ),  // Burst Count
       .wbs_bry_o       (wb_icache_bry_o      ),  // Burst Ready
       .wbs_dat_i       (wb_icache_dat_i      ),  // data input
       .wbs_ack_i       (wb_icache_ack_i      ),  // acknowlegement
       .wbs_lack_i      (wb_icache_lack_i     ),  // Last Ack
       .wbs_err_i       (wb_icache_err_i      )   // error

    );



`endif

`ifdef YCR_DCACHE_EN

// dcache top
dcache_top  u_dcache (
	.mclk                         (core_clk),	       //Clock input 
	.rst_n                        (cpu_intf_rst_n_sync),      //Active Low Asynchronous Reset Signal Input

	.cfg_pfet_dis                 (cfg_dcache_pfet_dis),   // To disable Next Pre data Pre fetch, default = 0
	.cfg_force_flush              (cfg_dcache_force_flush),// Force flush

	// Wishbone CPU I/F
        .cpu_mem_req                 (dcache_req),        // strobe/request
        .cpu_mem_cmd                 (dcache_cmd),        // address
        .cpu_mem_addr                (dcache_addr),       // address
	.cpu_mem_width               (dcache_width),
        .cpu_mem_wdata               (dcache_wdata),      // data input

        .cpu_mem_req_ack             (dcache_req_ack),    // data input
        .cpu_mem_rdata               (dcache_rdata),      // data input
        .cpu_mem_resp                (dcache_resp),        // acknowlegement

	// Wishbone CPU I/F
        .wb_app_stb_o                 (wb_dcache_cclk_stb_o  ), // strobe/request
        .wb_app_adr_o                 (wb_dcache_cclk_adr_o  ), // address
        .wb_app_we_o                  (wb_dcache_cclk_we_o   ), // write
        .wb_app_dat_o                 (wb_dcache_cclk_dat_o  ), // data output
        .wb_app_sel_o                 (wb_dcache_cclk_sel_o  ), // byte enable
        .wb_app_bl_o                  (wb_dcache_cclk_bl_o   ), // Burst Length
                                                    
        .wb_app_dat_i                 (wb_dcache_cclk_dat_i  ), // data input
        .wb_app_ack_i                 (wb_dcache_cclk_ack_i  ), // acknowlegement
        .wb_app_lack_i                (wb_dcache_cclk_lack_i ), // last acknowlegement
        .wb_app_err_i                 (wb_dcache_cclk_err_i  ),  // error

        // CACHE SRAM Memory I/F
        .cache_mem_clk0               (dcache_mem_clk0       ), // CLK
        .cache_mem_csb0               (dcache_mem_csb0       ), // CS#
        .cache_mem_web0               (dcache_mem_web0       ), // WE#
        .cache_mem_addr0              (dcache_mem_addr0      ), // Address
        .cache_mem_wmask0             (dcache_mem_wmask0     ), // WMASK#
        .cache_mem_din0               (dcache_mem_din0       ), // Write Data
        .cache_mem_dout0              (dcache_mem_dout0      ), // Read Data
        
        // SRAM-0 PORT-1, IMEM I/F
        .cache_mem_clk1               (dcache_mem_clk1       ), // CLK
        .cache_mem_csb1               (dcache_mem_csb1       ), // CS#
        .cache_mem_addr1              (dcache_mem_addr1      ), // Address
        .cache_mem_dout1              (dcache_mem_dout1      )  // Read Data

);

// Async Wishbone clock domain translation
ycr_async_wbb u_async_dcache(

    // Master Port
       .wbm_rst_n       (cpu_intf_rst_n_sync ),  // Regular Reset signal
       .wbm_clk_i       (core_clk ),  // System clock
       .wbm_cyc_i       (wb_dcache_cclk_stb_o ),  // strobe/request
       .wbm_stb_i       (wb_dcache_cclk_stb_o ),  // strobe/request
       .wbm_adr_i       (wb_dcache_cclk_adr_o ),  // address
       .wbm_we_i        (wb_dcache_cclk_we_o  ),  // write
       .wbm_dat_i       (wb_dcache_cclk_dat_o ),  // data output
       .wbm_sel_i       (wb_dcache_cclk_sel_o ),  // byte enable
       .wbm_bl_i        (wb_dcache_cclk_bl_o  ),  // Burst Count
       .wbm_dat_o       (wb_dcache_cclk_dat_i ),  // data input
       .wbm_ack_o       (wb_dcache_cclk_ack_i ),  // acknowlegement
       .wbm_lack_o      (wb_dcache_cclk_lack_i),  // Last Burst access
       .wbm_err_o       (wb_dcache_cclk_err_i ),  // error

    // Slave Port
       .wbs_rst_n       (wb_rst_n             ),  // Regular Reset signal
       .wbs_clk_i       (wb_clk               ),  // System clock
       .wbs_cyc_o       (wb_dcache_cyc_o      ),  // strobe/request
       .wbs_stb_o       (wb_dcache_stb_o      ),  // strobe/request
       .wbs_adr_o       (wb_dcache_adr_o      ),  // address
       .wbs_we_o        (wb_dcache_we_o       ),  // write
       .wbs_dat_o       (wb_dcache_dat_o      ),  // data output
       .wbs_sel_o       (wb_dcache_sel_o      ),  // byte enable
       .wbs_bl_o        (wb_dcache_bl_o       ),  // Burst Count
       .wbs_bry_o       (wb_dcache_bry_o      ),  // Burst Ready
       .wbs_dat_i       (wb_dcache_dat_i      ),  // data input
       .wbs_ack_i       (wb_dcache_ack_i      ),  // acknowlegement
       .wbs_lack_i      (wb_dcache_lack_i     ),  // Last Ack
       .wbs_err_i       (wb_dcache_err_i      )   // error

    );



`endif


endmodule : ycr_cache_top
