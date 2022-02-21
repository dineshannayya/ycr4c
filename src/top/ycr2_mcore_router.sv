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
////  yifive multi-core memory router                                     ////
////                                                                      ////
////  This file is part of the yifive cores project                       ////
////  https://github.com/dineshannayya/ycr.git                            ////
////                                                                      ////
////  Description:                                                        ////
////     multi-core memory router                                         ////
////     map  the two core Memory request                                 ////
////                                                                      ////
////  To Do:                                                              ////
////    nothing                                                           ////
////                                                                      ////
////  Author(s):                                                          ////
////      - Dinesh Annayya, dinesha@opencores.org                         ////
////                                                                      ////
////  Revision :                                                          ////
////     v0:    21 Feb 2022,  Dinesh A                                    ////
////             Initial Version                                          ////
////                                                                      ////
//////////////////////////////////////////////////////////////////////////////

`include "ycr_memif.svh"
`include "ycr_arch_description.svh"

module ycr2_mcore_router (
    // Control signals
    input   logic                           rst_n,
    input   logic                           clk,

    // core0 interface
    output  logic                           core0_req_ack,
    input   logic                           core0_req,
    input   logic                           core0_cmd,
    input   logic [1:0]                     core0_width,
    input   logic [`YCR_IMEM_AWIDTH-1:0]    core0_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]     core0_bl,
    input   logic [`YCR_IMEM_DWIDTH-1:0]    core0_wdata,
    output  logic [`YCR_IMEM_DWIDTH-1:0]    core0_rdata,
    output  logic [1:0]                     core0_resp,

    // core1 interface
    output  logic                           core1_req_ack,
    input   logic                           core1_req,
    input   logic                           core1_cmd,
    input   logic [1:0]                     core1_width,
    input   logic [`YCR_DMEM_AWIDTH-1:0]    core1_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]     core1_bl,
    input   logic [`YCR_IMEM_DWIDTH-1:0]    core1_wdata,
    output  logic [`YCR_DMEM_DWIDTH-1:0]    core1_rdata,
    output  logic [1:0]                     core1_resp,


    // core interface
    input   logic                          core_req_ack,
    output  logic                          core_req,
    output  logic                          core_cmd,
    output  logic [1:0]                    core_width,
    output  logic [`YCR_IMEM_AWIDTH-1:0]   core_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    core_bl,
    output  logic [`YCR_IMEM_DWIDTH-1:0]   core_wdata,
    input   logic [`YCR_IMEM_DWIDTH-1:0]   core_rdata,
    input   logic [1:0]                    core_resp

);


wire core_ack = (core_resp == YCR_MEM_RESP_RDY_LOK);

// Arbitor to select between external wb vs uart wb
wire [1:0] grnt;

ycr_arb u_arb(
	.clk      (clk                ), 
	.rstn     (rst_n              ), 
	.req      ({core1_req,core0_req}), 
	.ack      (core_ack           ), 
	.gnt      (grnt               )
        );

// Select  the master based on the grant
assign core_req   = (grnt == 2'b00) ? core0_req    : (grnt == 2'b01) ? core1_req   : 1'b0; 
assign core_cmd   = (grnt == 2'b00) ? core0_cmd    : (grnt == 2'b01) ? core1_cmd   : 'h0; 
assign core_width = (grnt == 2'b00) ? core0_width  : (grnt == 2'b01) ? core1_width : 'h0; 
assign core_addr  = (grnt == 2'b00) ? core0_addr   : (grnt == 2'b01) ? core1_addr  : 'h0; 
assign core_bl    = (grnt == 2'b00) ? core0_bl     : (grnt == 2'b01) ? core1_bl    : 'h0; 
assign core_wdata = (grnt == 2'b00) ? core0_wdata  : (grnt == 2'b01) ? core1_wdata : 'h0; 

assign core0_req_ack    = (grnt == 2'b00) ? core_req_ack : 'h0;
assign core0_rdata      = (grnt == 2'b00) ? core_rdata   : 'h0;
assign core0_resp       = (grnt == 2'b00) ? core_resp    : 'h0;

assign core1_req_ack    = (grnt == 2'b01) ? core_req_ack : 'h0;
assign core1_rdata      = (grnt == 2'b01) ? core_rdata   : 'h0;
assign core1_resp       = (grnt == 2'b01) ? core_resp    : 'h0;


endmodule : ycr2_mcore_router
