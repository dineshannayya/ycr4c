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
////  ycr4  cross bar                                                     ////
////                                                                      ////
////  This file is part of the ycr cores project                          ////
////  https://github.com/dineshannayya/ycr4c.git                          ////
////                                                                      ////
////  Description:                                                        ////
////     map  the four core imem/dmem Memory request one of the 5 port    ////
////     cross-bar feature in enabled.
////                                                                      ////
////  To Do:                                                              ////
////    nothing                                                           ////
////                                                                      ////
////  Author(s):                                                          ////
////      - Dinesh Annayya, dinesha@opencores.org                         ////
////                                                                      ////
////  Revision :                                                          ////
////     v0:    19 Mar 2022,  Dinesh A                                    ////
////             Initial Version                                          ////
////                                                                      ////
//////////////////////////////////////////////////////////////////////////////
`include "ycr_memif.svh"
`include "ycr_arch_description.svh"

module ycr4_cross_bar
#(
    parameter YCR_PORT1_ADDR_MASK      = `YCR_DMEM_AWIDTH'hFFFF0000,
    parameter YCR_PORT1_ADDR_PATTERN   = `YCR_DMEM_AWIDTH'h00010000,
    parameter YCR_PORT2_ADDR_MASK      = `YCR_DMEM_AWIDTH'hFFFF0000,
    parameter YCR_PORT2_ADDR_PATTERN   = `YCR_DMEM_AWIDTH'h00020000,
    parameter YCR_PORT3_ADDR_MASK      = `YCR_DMEM_AWIDTH'hFFFF0000,
    parameter YCR_PORT3_ADDR_PATTERN   = `YCR_DMEM_AWIDTH'h00020000,
    parameter YCR_PORT4_ADDR_MASK      = `YCR_DMEM_AWIDTH'hFFFF0000,
    parameter YCR_PORT4_ADDR_PATTERN   = `YCR_DMEM_AWIDTH'h00020000
) (
    // Control signals
    input   logic                           rst_n,
    input   logic                           clk,

    // Core-0 imem interface
    output  logic                          core0_imem_req_ack,
    input   logic                          core0_imem_req,
    input   logic                          core0_imem_cmd,
    input   logic [1:0]                    core0_imem_width,
    input   logic [`YCR_IMEM_AWIDTH-1:0]   core0_imem_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]    core0_imem_bl,             // IMEM burst size
    input   logic [`YCR_IMEM_DWIDTH-1:0]   core0_imem_wdata,
    output  logic [`YCR_IMEM_DWIDTH-1:0]   core0_imem_rdata,
    output  logic [1:0]                    core0_imem_resp,

    // Core-0 dmem interface
    output  logic                          core0_dmem_req_ack,
    input   logic                          core0_dmem_req,
    input   logic                          core0_dmem_cmd,
    input   logic [1:0]                    core0_dmem_width,
    input   logic [`YCR_IMEM_AWIDTH-1:0]   core0_dmem_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]    core0_dmem_bl,             
    input   logic [`YCR_IMEM_DWIDTH-1:0]   core0_dmem_wdata,
    output  logic [`YCR_IMEM_DWIDTH-1:0]   core0_dmem_rdata,
    output  logic [1:0]                    core0_dmem_resp,

    // Core-1 imem interface
    output  logic                          core1_imem_req_ack,
    input   logic                          core1_imem_req,
    input   logic                          core1_imem_cmd,
    input   logic [1:0]                    core1_imem_width,
    input   logic [`YCR_DMEM_AWIDTH-1:0]   core1_imem_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]    core1_imem_bl,             
    input   logic [`YCR_IMEM_DWIDTH-1:0]   core1_imem_wdata,
    output  logic [`YCR_DMEM_DWIDTH-1:0]   core1_imem_rdata,
    output  logic [1:0]                    core1_imem_resp,

    // Core-0 dmem interface
    output  logic                          core1_dmem_req_ack,
    input   logic                          core1_dmem_req,
    input   logic                          core1_dmem_cmd,
    input   logic [1:0]                    core1_dmem_width,
    input   logic [`YCR_IMEM_AWIDTH-1:0]   core1_dmem_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]    core1_dmem_bl,             
    input   logic [`YCR_IMEM_DWIDTH-1:0]   core1_dmem_wdata,
    output  logic [`YCR_IMEM_DWIDTH-1:0]   core1_dmem_rdata,
    output  logic [1:0]                    core1_dmem_resp,

    // Core-2 imem interface
    output  logic                          core2_imem_req_ack,
    input   logic                          core2_imem_req,
    input   logic                          core2_imem_cmd,
    input   logic [1:0]                    core2_imem_width,
    input   logic [`YCR_DMEM_AWIDTH-1:0]   core2_imem_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]    core2_imem_bl,             
    input   logic [`YCR_IMEM_DWIDTH-1:0]   core2_imem_wdata,
    output  logic [`YCR_DMEM_DWIDTH-1:0]   core2_imem_rdata,
    output  logic [1:0]                    core2_imem_resp,

    // Core-2 dmem interface
    output  logic                          core2_dmem_req_ack,
    input   logic                          core2_dmem_req,
    input   logic                          core2_dmem_cmd,
    input   logic [1:0]                    core2_dmem_width,
    input   logic [`YCR_IMEM_AWIDTH-1:0]   core2_dmem_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]    core2_dmem_bl,             
    input   logic [`YCR_IMEM_DWIDTH-1:0]   core2_dmem_wdata,
    output  logic [`YCR_IMEM_DWIDTH-1:0]   core2_dmem_rdata,
    output  logic [1:0]                    core2_dmem_resp,

    // Core-3 imem interface
    output  logic                          core3_imem_req_ack,
    input   logic                          core3_imem_req,
    input   logic                          core3_imem_cmd,
    input   logic [1:0]                    core3_imem_width,
    input   logic [`YCR_IMEM_AWIDTH-1:0]   core3_imem_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]    core3_imem_bl,             
    input   logic [`YCR_IMEM_DWIDTH-1:0]   core3_imem_wdata,
    output  logic [`YCR_IMEM_DWIDTH-1:0]   core3_imem_rdata,
    output  logic [1:0]                    core3_imem_resp,

    // Core-3 dmem interface
    output  logic                          core3_dmem_req_ack,
    input   logic                          core3_dmem_req,
    input   logic                          core3_dmem_cmd,
    input   logic [1:0]                    core3_dmem_width,
    input   logic [`YCR_IMEM_AWIDTH-1:0]   core3_dmem_addr,
    input   logic [`YCR_IMEM_BSIZE-1:0]    core3_dmem_bl,             
    input   logic [`YCR_IMEM_DWIDTH-1:0]   core3_dmem_wdata,
    output  logic [`YCR_IMEM_DWIDTH-1:0]   core3_dmem_rdata,
    output  logic [1:0]                    core3_dmem_resp,

    // PORT0 interface
    input   logic                          port0_req_ack,
    output  logic                          port0_req,
    output  logic                          port0_cmd,
    output  logic [1:0]                    port0_width,
    output  logic [`YCR_IMEM_AWIDTH-1:0]   port0_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    port0_bl,             
    output  logic [`YCR_IMEM_DWIDTH-1:0]   port0_wdata,
    input   logic [`YCR_IMEM_DWIDTH-1:0]   port0_rdata,
    input   logic [1:0]                    port0_resp,

    // PORT1 interface
    input   logic                          port1_req_ack,
    output  logic                          port1_req,
    output  logic                          port1_cmd,
    output  logic [1:0]                    port1_width,
    output  logic [`YCR_IMEM_AWIDTH-1:0]   port1_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    port1_bl,             
    output  logic [`YCR_IMEM_DWIDTH-1:0]   port1_wdata,
    input   logic [`YCR_IMEM_DWIDTH-1:0]   port1_rdata,
    input   logic [1:0]                    port1_resp,

    // PORT2 interface
    input   logic                          port2_req_ack,
    output  logic                          port2_req,
    output  logic                          port2_cmd,
    output  logic [1:0]                    port2_width,
    output  logic [`YCR_IMEM_AWIDTH-1:0]   port2_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    port2_bl,             
    output  logic [`YCR_IMEM_DWIDTH-1:0]   port2_wdata,
    input   logic [`YCR_IMEM_DWIDTH-1:0]   port2_rdata,
    input   logic [1:0]                    port2_resp,
    
    // PORT3 interface
    input   logic                          port3_req_ack,
    output  logic                          port3_req,
    output  logic                          port3_cmd,
    output  logic [1:0]                    port3_width,
    output  logic [`YCR_IMEM_AWIDTH-1:0]   port3_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    port3_bl,             
    output  logic [`YCR_IMEM_DWIDTH-1:0]   port3_wdata,
    input   logic [`YCR_IMEM_DWIDTH-1:0]   port3_rdata,
    input   logic [1:0]                    port3_resp,

    // PORT4 interface
    input   logic                          port4_req_ack,
    output  logic                          port4_req,
    output  logic                          port4_cmd,
    output  logic [1:0]                    port4_width,
    output  logic [`YCR_DMEM_AWIDTH-1:0]   port4_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    port4_bl,             
    output  logic [`YCR_DMEM_DWIDTH-1:0]   port4_wdata,
    input   logic [`YCR_DMEM_DWIDTH-1:0]   port4_rdata,
    input   logic [1:0]                    port4_resp
);

typedef enum logic [2:0] {
    YCR_SEL_PORT0,
    YCR_SEL_PORT1,
    YCR_SEL_PORT2,
    YCR_SEL_PORT3,
    YCR_SEL_PORT4
} type_ycr_sel_e;


// P0
wire                        core0_imem_req_ack_p0;
wire                        core0_imem_lack_p0;
wire [`YCR_IMEM_DWIDTH-1:0] core0_imem_rdata_p0;
wire [1:0]                  core0_imem_resp_p0;

wire                        core0_dmem_req_ack_p0;
wire                        core0_dmem_lack_p0;
wire [`YCR_IMEM_DWIDTH-1:0] core0_dmem_rdata_p0;
wire [1:0]                  core0_dmem_resp_p0;

wire                        core1_imem_req_ack_p0;
wire                        core1_imem_lack_p0;
wire [`YCR_IMEM_DWIDTH-1:0] core1_imem_rdata_p0;
wire [1:0]                  core1_imem_resp_p0;

wire                        core1_dmem_req_ack_p0;
wire                        core1_dmem_lack_p0;
wire [`YCR_IMEM_DWIDTH-1:0] core1_dmem_rdata_p0;
wire [1:0]                  core1_dmem_resp_p0;


wire                        core2_imem_req_ack_p0;
wire                        core2_imem_lack_p0;
wire [`YCR_IMEM_DWIDTH-1:0] core2_imem_rdata_p0;
wire [1:0]                  core2_imem_resp_p0;

wire                        core2_dmem_req_ack_p0;
wire                        core2_dmem_lack_p0;
wire [`YCR_IMEM_DWIDTH-1:0] core2_dmem_rdata_p0;
wire [1:0]                  core2_dmem_resp_p0;

wire                        core3_imem_req_ack_p0;
wire                        core3_imem_lack_p0;
wire [`YCR_IMEM_DWIDTH-1:0] core3_imem_rdata_p0;
wire [1:0]                  core3_imem_resp_p0;

wire                        core3_dmem_req_ack_p0;
wire                        core3_dmem_lack_p0;
wire [`YCR_IMEM_DWIDTH-1:0] core3_dmem_rdata_p0;
wire [1:0]                  core3_dmem_resp_p0;

// P1
wire                        core0_imem_req_ack_p1;
wire                        core0_imem_lack_p1;
wire [`YCR_IMEM_DWIDTH-1:0] core0_imem_rdata_p1;
wire [1:0]                  core0_imem_resp_p1;

wire                        core0_dmem_req_ack_p1;
wire                        core0_dmem_lack_p1;
wire [`YCR_IMEM_DWIDTH-1:0] core0_dmem_rdata_p1;
wire [1:0]                  core0_dmem_resp_p1;

wire                        core1_imem_req_ack_p1;
wire                        core1_imem_lack_p1;
wire [`YCR_IMEM_DWIDTH-1:0] core1_imem_rdata_p1;
wire [1:0]                  core1_imem_resp_p1;

wire                        core1_dmem_req_ack_p1;
wire                        core1_dmem_lack_p1;
wire [`YCR_IMEM_DWIDTH-1:0] core1_dmem_rdata_p1;
wire [1:0]                  core1_dmem_resp_p1;


wire                        core2_imem_req_ack_p1;
wire                        core2_imem_lack_p1;
wire [`YCR_IMEM_DWIDTH-1:0] core2_imem_rdata_p1;
wire [1:0]                  core2_imem_resp_p1;

wire                        core2_dmem_req_ack_p1;
wire                        core2_dmem_lack_p1;
wire [`YCR_IMEM_DWIDTH-1:0] core2_dmem_rdata_p1;
wire [1:0]                  core2_dmem_resp_p1;

wire                        core3_imem_req_ack_p1;
wire                        core3_imem_lack_p1;
wire [`YCR_IMEM_DWIDTH-1:0] core3_imem_rdata_p1;
wire [1:0]                  core3_imem_resp_p1;

wire                        core3_dmem_req_ack_p1;
wire                        core3_dmem_lack_p1;
wire [`YCR_IMEM_DWIDTH-1:0] core3_dmem_rdata_p1;
wire [1:0]                  core3_dmem_resp_p1;

// P2
wire                        core0_imem_req_ack_p2;
wire                        core0_imem_lack_p2;
wire [`YCR_IMEM_DWIDTH-1:0] core0_imem_rdata_p2;
wire [1:0]                  core0_imem_resp_p2;

wire                        core0_dmem_req_ack_p2;
wire                        core0_dmem_lack_p2;
wire [`YCR_IMEM_DWIDTH-1:0] core0_dmem_rdata_p2;
wire [1:0]                  core0_dmem_resp_p2;

wire                        core1_imem_req_ack_p2;
wire                        core1_imem_lack_p2;
wire [`YCR_IMEM_DWIDTH-1:0] core1_imem_rdata_p2;
wire [1:0]                  core1_imem_resp_p2;

wire                        core1_dmem_req_ack_p2;
wire                        core1_dmem_lack_p2;
wire [`YCR_IMEM_DWIDTH-1:0] core1_dmem_rdata_p2;
wire [1:0]                  core1_dmem_resp_p2;


wire                        core2_imem_req_ack_p2;
wire                        core2_imem_lack_p2;
wire [`YCR_IMEM_DWIDTH-1:0] core2_imem_rdata_p2;
wire [1:0]                  core2_imem_resp_p2;

wire                        core2_dmem_req_ack_p2;
wire                        core2_dmem_lack_p2;
wire [`YCR_IMEM_DWIDTH-1:0] core2_dmem_rdata_p2;
wire [1:0]                  core2_dmem_resp_p2;

wire                        core3_imem_req_ack_p2;
wire                        core3_imem_lack_p2;
wire [`YCR_IMEM_DWIDTH-1:0] core3_imem_rdata_p2;
wire [1:0]                  core3_imem_resp_p2;

wire                        core3_dmem_req_ack_p2;
wire                        core3_dmem_lack_p2;
wire [`YCR_IMEM_DWIDTH-1:0] core3_dmem_rdata_p2;
wire [1:0]                  core3_dmem_resp_p2;

// P3
wire                        core0_imem_req_ack_p3;
wire                        core0_imem_lack_p3;
wire [`YCR_IMEM_DWIDTH-1:0] core0_imem_rdata_p3;
wire [1:0]                  core0_imem_resp_p3;

wire                        core0_dmem_req_ack_p3;
wire                        core0_dmem_lack_p3;
wire [`YCR_IMEM_DWIDTH-1:0] core0_dmem_rdata_p3;
wire [1:0]                  core0_dmem_resp_p3;

wire                        core1_imem_req_ack_p3;
wire                        core1_imem_lack_p3;
wire [`YCR_IMEM_DWIDTH-1:0] core1_imem_rdata_p3;
wire [1:0]                  core1_imem_resp_p3;

wire                        core1_dmem_req_ack_p3;
wire                        core1_dmem_lack_p3;
wire [`YCR_IMEM_DWIDTH-1:0] core1_dmem_rdata_p3;
wire [1:0]                  core1_dmem_resp_p3;


wire                        core2_imem_req_ack_p3;
wire                        core2_imem_lack_p3;
wire [`YCR_IMEM_DWIDTH-1:0] core2_imem_rdata_p3;
wire [1:0]                  core2_imem_resp_p3;

wire                        core2_dmem_req_ack_p3;
wire                        core2_dmem_lack_p3;
wire [`YCR_IMEM_DWIDTH-1:0] core2_dmem_rdata_p3;
wire [1:0]                  core2_dmem_resp_p3;

wire                        core3_imem_req_ack_p3;
wire                        core3_imem_lack_p3;
wire [`YCR_IMEM_DWIDTH-1:0] core3_imem_rdata_p3;
wire [1:0]                  core3_imem_resp_p3;

wire                        core3_dmem_req_ack_p3;
wire                        core3_dmem_lack_p3;
wire [`YCR_IMEM_DWIDTH-1:0] core3_dmem_rdata_p3;
wire [1:0]                  core3_dmem_resp_p3;

// P4
wire                        core0_imem_req_ack_p4;
wire                        core0_imem_lack_p4;
wire [`YCR_IMEM_DWIDTH-1:0] core0_imem_rdata_p4;
wire [1:0]                  core0_imem_resp_p4;

wire                        core0_dmem_req_ack_p4;
wire                        core0_dmem_lack_p4;
wire [`YCR_IMEM_DWIDTH-1:0] core0_dmem_rdata_p4;
wire [1:0]                  core0_dmem_resp_p4;

wire                        core1_imem_req_ack_p4;
wire                        core1_imem_lack_p4;
wire [`YCR_IMEM_DWIDTH-1:0] core1_imem_rdata_p4;
wire [1:0]                  core1_imem_resp_p4;

wire                        core1_dmem_req_ack_p4;
wire                        core1_dmem_lack_p4;
wire [`YCR_IMEM_DWIDTH-1:0] core1_dmem_rdata_p4;
wire [1:0]                  core1_dmem_resp_p4;


wire                        core2_imem_req_ack_p4;
wire                        core2_imem_lack_p4;
wire [`YCR_IMEM_DWIDTH-1:0] core2_imem_rdata_p4;
wire [1:0]                  core2_imem_resp_p4;

wire                        core2_dmem_req_ack_p4;
wire                        core2_dmem_lack_p4;
wire [`YCR_IMEM_DWIDTH-1:0] core2_dmem_rdata_p4;
wire [1:0]                  core2_dmem_resp_p4;

wire                        core3_imem_req_ack_p4;
wire                        core3_imem_ack_p4;
wire [`YCR_IMEM_DWIDTH-1:0] core3_imem_rdata_p4;
wire [1:0]                  core3_imem_resp_p4;

wire                        core3_dmem_req_ack_p4;
wire                        core3_dmem_lack_p4;
wire [`YCR_IMEM_DWIDTH-1:0] core3_dmem_rdata_p4;
wire [1:0]                  core3_dmem_resp_p4;

// As RISC request are pipe lined and address is not hold during complete
// trasaction, we need to hold the target id untill the last ack is received
// for current trasaction and avoid out of order flows, we need block request
// to next block, when current transaction is pending

// CORE- 0
logic       core0_imem_lack,core0_dmem_lack;
logic       core0_imem_lock,core0_dmem_lock;
logic [2:0] core0_imem_tid,core0_imem_tid_h,core0_imem_tid_t;
logic [2:0] core0_dmem_tid,core0_dmem_tid_h,core0_dmem_tid_t;

assign core0_imem_tid_t = func_taget_id(core0_imem_addr);
assign core0_imem_tid = (core0_imem_lock) ? core0_imem_tid_h: core0_imem_tid_t;

always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        core0_imem_lock  <= 1'b0;
        core0_imem_tid_h   <= 3'h0;
    end else if(core0_imem_req && core0_imem_req_ack) begin
        core0_imem_lock  <= 1'b1;
        core0_imem_tid_h <= core0_imem_tid_t;
     end else if(core0_imem_lack) begin
        core0_imem_lock  <= 1'b0;
    end
end

assign core0_dmem_tid_t = func_taget_id(core0_dmem_addr);
assign core0_dmem_tid = (core0_dmem_lock) ? core0_dmem_tid_h: core0_dmem_tid_t;
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        core0_dmem_lock  <= 1'b0;
        core0_dmem_tid_h   <= 3'h0;
    end else if(core0_dmem_req && core0_dmem_req_ack) begin
        core0_dmem_lock  <= 1'b1;
        core0_dmem_tid_h <= core0_dmem_tid_t;
     end else if(core0_dmem_lack) begin
        core0_dmem_lock  <= 1'b0;
    end
end


// CORE- 1
logic           core1_imem_lack,core1_dmem_lack;
logic           core1_imem_lock,core1_dmem_lock;
logic [2:0]     core1_imem_tid,core1_imem_tid_h,core1_imem_tid_t;
logic [2:0]     core1_dmem_tid,core1_dmem_tid_h,core1_dmem_tid_t;

assign core1_imem_tid_t = func_taget_id(core1_imem_addr);
assign core1_imem_tid = (core1_imem_lock) ? core1_imem_tid_h: core1_imem_tid_t;
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        core1_imem_lock  <= 1'b0;
        core1_imem_tid_h <= 3'h0;
    end else if(core1_imem_req && core1_imem_req_ack) begin
        core1_imem_lock  <= 1'b1;
        core1_imem_tid_h <= core1_imem_tid_t;
     end else if(core1_imem_lack) begin
        core1_imem_lock  <= 1'b0;
    end
end

assign core1_dmem_tid_t = func_taget_id(core1_dmem_addr);
assign core1_dmem_tid = (core1_dmem_lock) ? core1_dmem_tid_h: core1_dmem_tid_t;
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        core1_dmem_lock  <= 1'b0;
        core1_dmem_tid_h   <= 3'h0;
    end else if(core1_dmem_req && core1_dmem_req_ack) begin
        core1_dmem_lock  <= 1'b1;
        core1_dmem_tid_h <= core1_dmem_tid_t;
     end else if(core1_dmem_lack) begin
        core1_dmem_lock  <= 1'b0;
    end
end

// CORE- 2
logic           core2_imem_lack,core2_dmem_lack;
logic           core2_imem_lock,core2_dmem_lock;
logic [2:0]     core2_imem_tid,core2_imem_tid_h,core2_imem_tid_t;
logic [2:0]     core2_dmem_tid,core2_dmem_tid_h,core2_dmem_tid_t;

assign core2_imem_tid_t = func_taget_id(core2_imem_addr);
assign core2_imem_tid   = (core2_imem_lock) ? core2_imem_tid_h: core2_imem_tid_t;
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        core2_imem_lock  <= 1'b0;
        core2_imem_tid_h <= 3'h0;
    end else if(core2_imem_req && core2_imem_req_ack) begin
        core2_imem_lock  <= 1'b1;
        core2_imem_tid_h <= core2_imem_tid_t;
     end else if(core2_imem_lack) begin
        core2_imem_lock  <= 1'b0;
    end
end

assign core2_dmem_tid_t = func_taget_id(core2_dmem_addr);
assign core2_dmem_tid   = (core2_dmem_lock) ? core2_dmem_tid_h: core2_dmem_tid_t;
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        core2_dmem_lock  <= 1'b0;
        core2_dmem_tid_h   <= 3'h0;
    end else if(core2_dmem_req && core2_dmem_req_ack) begin
        core2_dmem_lock  <= 1'b1;
        core2_dmem_tid_h <= core2_dmem_tid_t;
     end else if(core2_dmem_lack) begin
        core2_dmem_lock  <= 1'b0;
    end
end

// CORE- 3
logic           core3_imem_lack,core3_dmem_lack;
logic           core3_imem_lock,core3_dmem_lock;
logic  [2:0]    core3_imem_tid,core3_imem_tid_h,core3_imem_tid_t;
logic  [2:0]    core3_dmem_tid,core3_dmem_tid_h,core3_dmem_tid_t;

assign core3_imem_tid_t = func_taget_id(core3_imem_addr);
assign core3_imem_tid   = (core3_imem_lock) ? core3_imem_tid_h: core3_imem_tid_t;
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        core3_imem_lock  <= 1'b0;
        core3_imem_tid_h <= 3'h0;
    end else if(core3_imem_req && core3_imem_req_ack) begin
        core3_imem_lock  <= 1'b1;
        core3_imem_tid_h <= core3_imem_tid_t;
     end else if(core3_imem_lack) begin
        core3_imem_lock  <= 1'b0;
    end
end

assign core3_dmem_tid_t = func_taget_id(core3_dmem_addr);
assign core3_dmem_tid   = (core3_dmem_lock) ? core3_dmem_tid_h: core3_dmem_tid_t;
always_ff @(negedge rst_n, posedge clk) begin
    if (~rst_n) begin
        core3_dmem_lock  <= 1'b0;
        core3_dmem_tid_h   <= 3'h0;
    end else if(core3_dmem_req && core3_dmem_req_ack) begin
        core3_dmem_lock  <= 1'b1;
        core3_dmem_tid_h <= core3_dmem_tid;
     end else if(core0_dmem_lack) begin
        core3_dmem_lock  <= 1'b0;
    end
end

//------------------ End of tid generation ---------------------------------
// CORE0 IMEM
assign core0_imem_req_ack = 
	                      (core0_imem_tid == 3'b000) ? core0_imem_req_ack_p0 :
	                      (core0_imem_tid == 3'b001) ? core0_imem_req_ack_p1 :
	                      (core0_imem_tid == 3'b010) ? core0_imem_req_ack_p2 :
	                      (core0_imem_tid == 3'b011) ? core0_imem_req_ack_p3 :
	                      (core0_imem_tid == 3'b100) ? core0_imem_req_ack_p4 :
			      'h0;
assign core0_imem_lack = 
	                      (core0_imem_tid == 3'b000) ? core0_imem_lack_p0 :
	                      (core0_imem_tid == 3'b001) ? core0_imem_lack_p1 :
	                      (core0_imem_tid == 3'b010) ? core0_imem_lack_p2 :
	                      (core0_imem_tid == 3'b011) ? core0_imem_lack_p3 :
	                      (core0_imem_tid == 3'b100) ? core0_imem_lack_p4 :
			      'h0;

assign core0_imem_rdata  = 
	                      (core0_imem_tid == 3'b000) ? core0_imem_rdata_p0 :
	                      (core0_imem_tid == 3'b001) ? core0_imem_rdata_p1 :
	                      (core0_imem_tid == 3'b010) ? core0_imem_rdata_p2 :
	                      (core0_imem_tid == 3'b011) ? core0_imem_rdata_p3 :
	                      (core0_imem_tid == 3'b100) ? core0_imem_rdata_p4 :
			      'h0;

assign core0_imem_resp  = 
	                      (core0_imem_tid == 3'b000) ? core0_imem_resp_p0 :
	                      (core0_imem_tid == 3'b001) ? core0_imem_resp_p1 :
	                      (core0_imem_tid == 3'b010) ? core0_imem_resp_p2 :
	                      (core0_imem_tid == 3'b011) ? core0_imem_resp_p3 :
	                      (core0_imem_tid == 3'b100) ? core0_imem_resp_p4 :
			      'h0;

// CORE0 DMEM
assign core0_dmem_req_ack = 
	                      (core0_dmem_tid == 3'b000) ? core0_dmem_req_ack_p0 :
	                      (core0_dmem_tid == 3'b001) ? core0_dmem_req_ack_p1 :
	                      (core0_dmem_tid == 3'b010) ? core0_dmem_req_ack_p2 :
	                      (core0_dmem_tid == 3'b011) ? core0_dmem_req_ack_p3 :
	                      (core0_dmem_tid == 3'b100) ? core0_dmem_req_ack_p4 :
			      'h0;
assign core0_dmem_lack = 
	                      (core0_dmem_tid == 3'b000) ? core0_dmem_lack_p0 :
	                      (core0_dmem_tid == 3'b001) ? core0_dmem_lack_p1 :
	                      (core0_dmem_tid == 3'b010) ? core0_dmem_lack_p2 :
	                      (core0_dmem_tid == 3'b011) ? core0_dmem_lack_p3 :
	                      (core0_dmem_tid == 3'b100) ? core0_dmem_lack_p4 :
			      'h0;

assign core0_dmem_rdata  = 
	                      (core0_dmem_tid == 3'b000) ? core0_dmem_rdata_p0 :
	                      (core0_dmem_tid == 3'b001) ? core0_dmem_rdata_p1 :
	                      (core0_dmem_tid == 3'b010) ? core0_dmem_rdata_p2 :
	                      (core0_dmem_tid == 3'b011) ? core0_dmem_rdata_p3 :
	                      (core0_dmem_tid == 3'b100) ? core0_dmem_rdata_p4 :
			      'h0;

assign core0_dmem_resp  = 
	                      (core0_dmem_tid == 3'b000) ? core0_dmem_resp_p0 :
	                      (core0_dmem_tid == 3'b001) ? core0_dmem_resp_p1 :
	                      (core0_dmem_tid == 3'b010) ? core0_dmem_resp_p2 :
	                      (core0_dmem_tid == 3'b011) ? core0_dmem_resp_p3 :
	                      (core0_dmem_tid == 3'b100) ? core0_dmem_resp_p4 :
			      'h0;

// CORE1 IMEM
assign core1_imem_req_ack = 
	                      (core1_imem_tid == 3'b000) ? core1_imem_req_ack_p0 :
	                      (core1_imem_tid == 3'b001) ? core1_imem_req_ack_p1 :
	                      (core1_imem_tid == 3'b010) ? core1_imem_req_ack_p2 :
	                      (core1_imem_tid == 3'b011) ? core1_imem_req_ack_p3 :
	                      (core1_imem_tid == 3'b100) ? core1_imem_req_ack_p4 :
			      'h0;
assign core1_imem_lack = 
	                      (core1_imem_tid == 3'b000) ? core1_imem_lack_p0 :
	                      (core1_imem_tid == 3'b001) ? core1_imem_lack_p1 :
	                      (core1_imem_tid == 3'b010) ? core1_imem_lack_p2 :
	                      (core1_imem_tid == 3'b011) ? core1_imem_lack_p3 :
	                      (core1_imem_tid == 3'b100) ? core1_imem_lack_p4 :
			      'h0;

assign core1_imem_rdata  = 
	                      (core1_imem_tid == 3'b000) ? core1_imem_rdata_p0 :
	                      (core1_imem_tid == 3'b001) ? core1_imem_rdata_p1 :
	                      (core1_imem_tid == 3'b010) ? core1_imem_rdata_p2 :
	                      (core1_imem_tid == 3'b011) ? core1_imem_rdata_p3 :
	                      (core1_imem_tid == 3'b100) ? core1_imem_rdata_p4 :
			      'h0;

assign core1_imem_resp  = 
	                      (core1_imem_tid == 3'b000) ? core1_imem_resp_p0 :
	                      (core1_imem_tid == 3'b001) ? core1_imem_resp_p1 :
	                      (core1_imem_tid == 3'b010) ? core1_imem_resp_p2 :
	                      (core1_imem_tid == 3'b011) ? core1_imem_resp_p3 :
	                      (core1_imem_tid == 3'b100) ? core1_imem_resp_p4 :
			      'h0;

// CORE0 DMEM
assign core1_dmem_req_ack = 
	                      (core1_dmem_tid == 3'b000) ? core1_dmem_req_ack_p0 :
	                      (core1_dmem_tid == 3'b001) ? core1_dmem_req_ack_p1 :
	                      (core1_dmem_tid == 3'b010) ? core1_dmem_req_ack_p2 :
	                      (core1_dmem_tid == 3'b011) ? core1_dmem_req_ack_p3 :
	                      (core1_dmem_tid == 3'b100) ? core1_dmem_req_ack_p4 :
			      'h0;
assign core1_dmem_lack = 
	                      (core1_dmem_tid == 3'b000) ? core1_dmem_lack_p0 :
	                      (core1_dmem_tid == 3'b001) ? core1_dmem_lack_p1 :
	                      (core1_dmem_tid == 3'b010) ? core1_dmem_lack_p2 :
	                      (core1_dmem_tid == 3'b011) ? core1_dmem_lack_p3 :
	                      (core1_dmem_tid == 3'b100) ? core1_dmem_lack_p4 :
			      'h0;

assign core1_dmem_rdata  = 
	                      (core1_dmem_tid == 3'b000) ? core1_dmem_rdata_p0 :
	                      (core1_dmem_tid == 3'b001) ? core1_dmem_rdata_p1 :
	                      (core1_dmem_tid == 3'b010) ? core1_dmem_rdata_p2 :
	                      (core1_dmem_tid == 3'b011) ? core1_dmem_rdata_p3 :
	                      (core1_dmem_tid == 3'b100) ? core1_dmem_rdata_p4 :
			      'h0;

assign core1_dmem_resp  = 
	                      (core1_dmem_tid == 3'b000) ? core1_dmem_resp_p0 :
	                      (core1_dmem_tid == 3'b001) ? core1_dmem_resp_p1 :
	                      (core1_dmem_tid == 3'b010) ? core1_dmem_resp_p2 :
	                      (core1_dmem_tid == 3'b011) ? core1_dmem_resp_p3 :
	                      (core1_dmem_tid == 3'b100) ? core1_dmem_resp_p4 :
			      'h0;

// CORE2 IMEM
assign core2_imem_req_ack = 
	                      (core2_imem_tid == 3'b000) ? core2_imem_req_ack_p0 :
	                      (core2_imem_tid == 3'b001) ? core2_imem_req_ack_p1 :
	                      (core2_imem_tid == 3'b010) ? core2_imem_req_ack_p2 :
	                      (core2_imem_tid == 3'b011) ? core2_imem_req_ack_p3 :
	                      (core2_imem_tid == 3'b100) ? core2_imem_req_ack_p4 :
			      'h0;
assign core2_imem_lack = 
	                      (core2_imem_tid == 3'b000) ? core2_imem_lack_p0 :
	                      (core2_imem_tid == 3'b001) ? core2_imem_lack_p1 :
	                      (core2_imem_tid == 3'b010) ? core2_imem_lack_p2 :
	                      (core2_imem_tid == 3'b011) ? core2_imem_lack_p3 :
	                      (core2_imem_tid == 3'b100) ? core2_imem_lack_p4 :
			      'h0;

assign core2_imem_rdata  = 
	                      (core2_imem_tid == 3'b000) ? core2_imem_rdata_p0 :
	                      (core2_imem_tid == 3'b001) ? core2_imem_rdata_p1 :
	                      (core2_imem_tid == 3'b010) ? core2_imem_rdata_p2 :
	                      (core2_imem_tid == 3'b011) ? core2_imem_rdata_p3 :
	                      (core2_imem_tid == 3'b100) ? core2_imem_rdata_p4 :
			      'h0;

assign core2_imem_resp  = 
	                      (core2_imem_tid == 3'b000) ? core2_imem_resp_p0 :
	                      (core2_imem_tid == 3'b001) ? core2_imem_resp_p1 :
	                      (core2_imem_tid == 3'b010) ? core2_imem_resp_p2 :
	                      (core2_imem_tid == 3'b011) ? core2_imem_resp_p3 :
	                      (core2_imem_tid == 3'b100) ? core2_imem_resp_p4 :
			      'h0;

// CORE2 DMEM
assign core2_dmem_req_ack = 
	                      (core2_dmem_tid == 3'b000) ? core2_dmem_req_ack_p0 :
	                      (core2_dmem_tid == 3'b001) ? core2_dmem_req_ack_p1 :
	                      (core2_dmem_tid == 3'b010) ? core2_dmem_req_ack_p2 :
	                      (core2_dmem_tid == 3'b011) ? core2_dmem_req_ack_p3 :
	                      (core2_dmem_tid == 3'b100) ? core2_dmem_req_ack_p4 :
			      'h0;
assign core2_dmem_lack = 
	                      (core2_dmem_tid == 3'b000) ? core2_dmem_lack_p0 :
	                      (core2_dmem_tid == 3'b001) ? core2_dmem_lack_p1 :
	                      (core2_dmem_tid == 3'b010) ? core2_dmem_lack_p2 :
	                      (core2_dmem_tid == 3'b011) ? core2_dmem_lack_p3 :
	                      (core2_dmem_tid == 3'b100) ? core2_dmem_lack_p4 :
			      'h0;

assign core2_dmem_rdata  = 
	                      (core2_dmem_tid == 3'b000) ? core2_dmem_rdata_p0 :
	                      (core2_dmem_tid == 3'b001) ? core2_dmem_rdata_p1 :
	                      (core2_dmem_tid == 3'b010) ? core2_dmem_rdata_p2 :
	                      (core2_dmem_tid == 3'b011) ? core2_dmem_rdata_p3 :
	                      (core2_dmem_tid == 3'b100) ? core2_dmem_rdata_p4 :
			      'h0;

assign core2_dmem_resp  = 
	                      (core2_dmem_tid == 3'b000) ? core2_dmem_resp_p0 :
	                      (core2_dmem_tid == 3'b001) ? core2_dmem_resp_p1 :
	                      (core2_dmem_tid == 3'b010) ? core2_dmem_resp_p2 :
	                      (core2_dmem_tid == 3'b011) ? core2_dmem_resp_p3 :
	                      (core2_dmem_tid == 3'b100) ? core2_dmem_resp_p4 :
			      'h0;

// CORE3 IMEM
assign core3_imem_req_ack = 
	                      (core3_imem_tid == 3'b000) ? core3_imem_req_ack_p0 :
	                      (core3_imem_tid == 3'b001) ? core3_imem_req_ack_p1 :
	                      (core3_imem_tid == 3'b010) ? core3_imem_req_ack_p2 :
	                      (core3_imem_tid == 3'b011) ? core3_imem_req_ack_p3 :
	                      (core3_imem_tid == 3'b100) ? core3_imem_req_ack_p4 :
			      'h0;
assign core3_imem_lack = 
	                      (core3_imem_tid == 3'b000) ? core3_imem_lack_p0 :
	                      (core3_imem_tid == 3'b001) ? core3_imem_lack_p1 :
	                      (core3_imem_tid == 3'b010) ? core3_imem_lack_p2 :
	                      (core3_imem_tid == 3'b011) ? core3_imem_lack_p3 :
	                      (core3_imem_tid == 3'b100) ? core3_imem_lack_p4 :
			      'h0;

assign core3_imem_rdata  = 
	                      (core3_imem_tid == 3'b000) ? core3_imem_rdata_p0 :
	                      (core3_imem_tid == 3'b001) ? core3_imem_rdata_p1 :
	                      (core3_imem_tid == 3'b010) ? core3_imem_rdata_p2 :
	                      (core3_imem_tid == 3'b011) ? core3_imem_rdata_p3 :
	                      (core3_imem_tid == 3'b100) ? core3_imem_rdata_p4 :
			      'h0;

assign core3_imem_resp  = 
	                      (core3_imem_tid == 3'b000) ? core3_imem_resp_p0 :
	                      (core3_imem_tid == 3'b001) ? core3_imem_resp_p1 :
	                      (core3_imem_tid == 3'b010) ? core3_imem_resp_p2 :
	                      (core3_imem_tid == 3'b011) ? core3_imem_resp_p3 :
	                      (core3_imem_tid == 3'b100) ? core3_imem_resp_p4 :
			      'h0;

// CORE3 DMEM
assign core3_dmem_req_ack = 
	                      (core3_dmem_tid == 3'b000) ? core3_dmem_req_ack_p0 :
	                      (core3_dmem_tid == 3'b001) ? core3_dmem_req_ack_p1 :
	                      (core3_dmem_tid == 3'b010) ? core3_dmem_req_ack_p2 :
	                      (core3_dmem_tid == 3'b011) ? core3_dmem_req_ack_p3 :
	                      (core3_dmem_tid == 3'b100) ? core3_dmem_req_ack_p4 :
			      'h0;
assign core3_dmem_lack = 
	                      (core3_dmem_tid == 3'b000) ? core3_dmem_lack_p0 :
	                      (core3_dmem_tid == 3'b001) ? core3_dmem_lack_p1 :
	                      (core3_dmem_tid == 3'b010) ? core3_dmem_lack_p2 :
	                      (core3_dmem_tid == 3'b011) ? core3_dmem_lack_p3 :
	                      (core3_dmem_tid == 3'b100) ? core3_dmem_lack_p4 :
			      'h0;

assign core3_dmem_rdata  = 
	                      (core3_dmem_tid == 3'b000) ? core3_dmem_rdata_p0 :
	                      (core3_dmem_tid == 3'b001) ? core3_dmem_rdata_p1 :
	                      (core3_dmem_tid == 3'b010) ? core3_dmem_rdata_p2 :
	                      (core3_dmem_tid == 3'b011) ? core3_dmem_rdata_p3 :
	                      (core3_dmem_tid == 3'b100) ? core3_dmem_rdata_p4 :
			      'h0;

assign core3_dmem_resp  = 
	                      (core3_dmem_tid == 3'b000) ? core3_dmem_resp_p0 :
	                      (core3_dmem_tid == 3'b001) ? core3_dmem_resp_p1 :
	                      (core3_dmem_tid == 3'b010) ? core3_dmem_resp_p2 :
	                      (core3_dmem_tid == 3'b011) ? core3_dmem_resp_p3 :
	                      (core3_dmem_tid == 3'b100) ? core3_dmem_resp_p4 :
			      'h0;

ycr4_router  u_router_p0 (
    // Control signals
          .rst_n                      (rst_n                   ),
          .clk                        (clk                     ),
                                                                  
          .taget_id                   (3'b000                  ),

    // core0-imem interface
          .core0_imem_tid             (core0_imem_tid          ),
          .core0_imem_req_ack         (core0_imem_req_ack_p0   ),
          .core0_imem_lack            (core0_imem_lack_p0      ),
          .core0_imem_req             (core0_imem_req          ),
          .core0_imem_cmd             (core0_imem_cmd          ),
          .core0_imem_width           (core0_imem_width        ),
          .core0_imem_addr            (core0_imem_addr         ),
          .core0_imem_bl              (core0_imem_bl           ),
          .core0_imem_wdata           (core0_imem_wdata        ),
          .core0_imem_rdata           (core0_imem_rdata_p0     ),
          .core0_imem_resp            (core0_imem_resp_p0      ),

    // core0-dmem interface
          .core0_dmem_tid             (core0_dmem_tid          ),
          .core0_dmem_req_ack         (core0_dmem_req_ack_p0   ),
          .core0_dmem_lack            (core0_dmem_lack_p0      ),
          .core0_dmem_req             (core0_dmem_req          ),
          .core0_dmem_cmd             (core0_dmem_cmd          ),
          .core0_dmem_width           (core0_dmem_width        ),
          .core0_dmem_addr            (core0_dmem_addr         ),
          .core0_dmem_bl              (core0_dmem_bl           ),
          .core0_dmem_wdata           (core0_dmem_wdata        ),
          .core0_dmem_rdata           (core0_dmem_rdata_p0     ),
          .core0_dmem_resp            (core0_dmem_resp_p0      ),

    // core1-imem interface
          .core1_imem_tid             (core1_imem_tid          ),
          .core1_imem_req_ack         (core1_imem_req_ack_p0   ),
          .core1_imem_lack            (core1_imem_lack_p0      ),
          .core1_imem_req             (core1_imem_req          ),
          .core1_imem_cmd             (core1_imem_cmd          ),
          .core1_imem_width           (core1_imem_width        ),
          .core1_imem_addr            (core1_imem_addr         ),
          .core1_imem_bl              (core1_imem_bl           ),
          .core1_imem_wdata           (core1_imem_wdata        ),
          .core1_imem_rdata           (core1_imem_rdata_p0     ),
          .core1_imem_resp            (core1_imem_resp_p0      ),

    // core1-dmem interface
          .core1_dmem_tid             (core1_dmem_tid          ),
          .core1_dmem_req_ack         (core1_dmem_req_ack_p0   ),
          .core1_dmem_lack            (core1_dmem_lack_p0      ),
          .core1_dmem_req             (core1_dmem_req          ),
          .core1_dmem_cmd             (core1_dmem_cmd          ),
          .core1_dmem_width           (core1_dmem_width        ),
          .core1_dmem_addr            (core1_dmem_addr         ),
          .core1_dmem_bl              (core1_dmem_bl           ),
          .core1_dmem_wdata           (core1_dmem_wdata        ),
          .core1_dmem_rdata           (core1_dmem_rdata_p0     ),
          .core1_dmem_resp            (core1_dmem_resp_p0      ),

    // core2-imem interface
          .core2_imem_tid             (core2_imem_tid          ),
          .core2_imem_req_ack         (core2_imem_req_ack_p0   ),
          .core2_imem_lack            (core2_imem_lack_p0      ),
          .core2_imem_req             (core2_imem_req          ),
          .core2_imem_cmd             (core2_imem_cmd          ),
          .core2_imem_width           (core2_imem_width        ),
          .core2_imem_addr            (core2_imem_addr         ),
          .core2_imem_bl              (core2_imem_bl           ),
          .core2_imem_wdata           (core2_imem_wdata        ),
          .core2_imem_rdata           (core2_imem_rdata_p0     ),
          .core2_imem_resp            (core2_imem_resp_p0      ),

    // core2-dmem interface
          .core2_dmem_tid             (core2_dmem_tid          ),
          .core2_dmem_req_ack         (core2_dmem_req_ack_p0   ),
          .core2_dmem_lack            (core2_dmem_lack_p0      ),
          .core2_dmem_req             (core2_dmem_req          ),
          .core2_dmem_cmd             (core2_dmem_cmd          ),
          .core2_dmem_width           (core2_dmem_width        ),
          .core2_dmem_addr            (core2_dmem_addr         ),
          .core2_dmem_bl              (core2_dmem_bl           ),
          .core2_dmem_wdata           (core2_dmem_wdata        ),
          .core2_dmem_rdata           (core2_dmem_rdata_p0     ),
          .core2_dmem_resp            (core2_dmem_resp_p0      ),

    // core3-imem interface
          .core3_imem_tid             (core3_imem_tid          ),
          .core3_imem_req_ack         (core3_imem_req_ack_p0   ),
          .core3_imem_lack            (core3_imem_lack_p0      ),
          .core3_imem_req             (core3_imem_req          ),
          .core3_imem_cmd             (core3_imem_cmd          ),
          .core3_imem_width           (core3_imem_width        ),
          .core3_imem_addr            (core3_imem_addr         ),
          .core3_imem_bl              (core3_imem_bl           ),
          .core3_imem_wdata           (core3_imem_wdata        ),
          .core3_imem_rdata           (core3_imem_rdata_p0     ),
          .core3_imem_resp            (core3_imem_resp_p0      ),

    // core3-dmem interface
          .core3_dmem_tid             (core3_dmem_tid          ),
          .core3_dmem_req_ack         (core3_dmem_req_ack_p0   ),
          .core3_dmem_lack            (core3_dmem_lack_p0      ),
          .core3_dmem_req             (core3_dmem_req          ),
          .core3_dmem_cmd             (core3_dmem_cmd          ),
          .core3_dmem_width           (core3_dmem_width        ),
          .core3_dmem_addr            (core3_dmem_addr         ),
          .core3_dmem_bl              (core3_dmem_bl           ),
          .core3_dmem_wdata           (core3_dmem_wdata        ),
          .core3_dmem_rdata           (core3_dmem_rdata_p0     ),
          .core3_dmem_resp            (core3_dmem_resp_p0      ),

    // core interface
          .core_req_ack               (port0_req_ack            ),
          .core_req                   (port0_req                ),
          .core_cmd                   (port0_cmd                ),
          .core_width                 (port0_width              ),
          .core_addr                  (port0_addr               ),
          .core_bl                    (port0_bl                 ),
          .core_wdata                 (port0_wdata              ),
          .core_rdata                 (port0_rdata              ),
          .core_resp                  (port0_resp               )   

);

ycr4_router  u_router_p1 (
    // Control signals
          .rst_n                      (rst_n                   ),
          .clk                        (clk                     ),
                                                                  
          .taget_id                   (3'b001                  ),

    // core0-imem interface
          .core0_imem_tid             (core0_imem_tid          ),
          .core0_imem_req_ack         (core0_imem_req_ack_p1   ),
          .core0_imem_lack            (core0_imem_lack_p1      ),
          .core0_imem_req             (core0_imem_req          ),
          .core0_imem_cmd             (core0_imem_cmd          ),
          .core0_imem_width           (core0_imem_width        ),
          .core0_imem_addr            (core0_imem_addr         ),
          .core0_imem_bl              (core0_imem_bl           ),
          .core0_imem_wdata           (core0_imem_wdata        ),
          .core0_imem_rdata           (core0_imem_rdata_p1     ),
          .core0_imem_resp            (core0_imem_resp_p1      ),

    // core0-dmem interface
          .core0_dmem_tid             (core0_dmem_tid          ),
          .core0_dmem_req_ack         (core0_dmem_req_ack_p1   ),
          .core0_dmem_lack            (core0_dmem_lack_p1      ),
          .core0_dmem_req             (core0_dmem_req          ),
          .core0_dmem_cmd             (core0_dmem_cmd          ),
          .core0_dmem_width           (core0_dmem_width        ),
          .core0_dmem_addr            (core0_dmem_addr         ),
          .core0_dmem_bl              (core0_dmem_bl           ),
          .core0_dmem_wdata           (core0_dmem_wdata        ),
          .core0_dmem_rdata           (core0_dmem_rdata_p1     ),
          .core0_dmem_resp            (core0_dmem_resp_p1      ),

    // core1-imem interface
          .core1_imem_tid             (core1_imem_tid          ),
          .core1_imem_req_ack         (core1_imem_req_ack_p1   ),
          .core1_imem_lack            (core1_imem_lack_p1      ),
          .core1_imem_req             (core1_imem_req          ),
          .core1_imem_cmd             (core1_imem_cmd          ),
          .core1_imem_width           (core1_imem_width        ),
          .core1_imem_addr            (core1_imem_addr         ),
          .core1_imem_bl              (core1_imem_bl           ),
          .core1_imem_wdata           (core1_imem_wdata        ),
          .core1_imem_rdata           (core1_imem_rdata_p1     ),
          .core1_imem_resp            (core1_imem_resp_p1      ),

    // core1-dmem interface
          .core1_dmem_tid             (core1_dmem_tid          ),
          .core1_dmem_req_ack         (core1_dmem_req_ack_p1   ),
          .core1_dmem_lack            (core1_dmem_lack_p1      ),
          .core1_dmem_req             (core1_dmem_req          ),
          .core1_dmem_cmd             (core1_dmem_cmd          ),
          .core1_dmem_width           (core1_dmem_width        ),
          .core1_dmem_addr            (core1_dmem_addr         ),
          .core1_dmem_bl              (core1_dmem_bl           ),
          .core1_dmem_wdata           (core1_dmem_wdata        ),
          .core1_dmem_rdata           (core1_dmem_rdata_p1     ),
          .core1_dmem_resp            (core1_dmem_resp_p1      ),

    // core2-imem interface
          .core2_imem_tid             (core2_imem_tid          ),
          .core2_imem_req_ack         (core2_imem_req_ack_p1   ),
          .core2_imem_lack            (core2_imem_lack_p1      ),
          .core2_imem_req             (core2_imem_req          ),
          .core2_imem_cmd             (core2_imem_cmd          ),
          .core2_imem_width           (core2_imem_width        ),
          .core2_imem_addr            (core2_imem_addr         ),
          .core2_imem_bl              (core2_imem_bl           ),
          .core2_imem_wdata           (core2_imem_wdata        ),
          .core2_imem_rdata           (core2_imem_rdata_p1     ),
          .core2_imem_resp            (core2_imem_resp_p1      ),

    // core2-dmem interface
          .core2_dmem_tid             (core2_dmem_tid          ),
          .core2_dmem_req_ack         (core2_dmem_req_ack_p1   ),
          .core2_dmem_lack            (core2_dmem_lack_p1      ),
          .core2_dmem_req             (core2_dmem_req          ),
          .core2_dmem_cmd             (core2_dmem_cmd          ),
          .core2_dmem_width           (core2_dmem_width        ),
          .core2_dmem_addr            (core2_dmem_addr         ),
          .core2_dmem_bl              (core2_dmem_bl           ),
          .core2_dmem_wdata           (core2_dmem_wdata        ),
          .core2_dmem_rdata           (core2_dmem_rdata_p1     ),
          .core2_dmem_resp            (core2_dmem_resp_p1      ),

    // core3-imem interface
          .core3_imem_tid             (core3_imem_tid          ),
          .core3_imem_req_ack         (core3_imem_req_ack_p1   ),
          .core3_imem_lack            (core3_imem_lack_p1      ),
          .core3_imem_req             (core3_imem_req          ),
          .core3_imem_cmd             (core3_imem_cmd          ),
          .core3_imem_width           (core3_imem_width        ),
          .core3_imem_addr            (core3_imem_addr         ),
          .core3_imem_bl              (core3_imem_bl           ),
          .core3_imem_wdata           (core3_imem_wdata        ),
          .core3_imem_rdata           (core3_imem_rdata_p1     ),
          .core3_imem_resp            (core3_imem_resp_p1      ),

    // core3-dmem interface
          .core3_dmem_tid             (core3_dmem_tid          ),
          .core3_dmem_req_ack         (core3_dmem_req_ack_p1   ),
          .core3_dmem_lack            (core3_dmem_lack_p1      ),
          .core3_dmem_req             (core3_dmem_req          ),
          .core3_dmem_cmd             (core3_dmem_cmd          ),
          .core3_dmem_width           (core3_dmem_width        ),
          .core3_dmem_addr            (core3_dmem_addr         ),
          .core3_dmem_bl              (core3_dmem_bl           ),
          .core3_dmem_wdata           (core3_dmem_wdata        ),
          .core3_dmem_rdata           (core3_dmem_rdata_p1     ),
          .core3_dmem_resp            (core3_dmem_resp_p1      ),

    // core interface
          .core_req_ack               (port1_req_ack           ),
          .core_req                   (port1_req               ),
          .core_cmd                   (port1_cmd               ),
          .core_width                 (port1_width             ),
          .core_addr                  (port1_addr              ),
          .core_bl                    (port1_bl                ),
          .core_wdata                 (port1_wdata             ),
          .core_rdata                 (port1_rdata             ),
          .core_resp                  (port1_resp              )   

);

ycr4_router  u_router_p2 (
    // Control signals
          .rst_n                      (rst_n                   ),
          .clk                        (clk                     ),
                                                                  
          .taget_id                   (3'b010                  ),

    // core0-imem interface
          .core0_imem_tid             (core0_imem_tid          ),
          .core0_imem_req_ack         (core0_imem_req_ack_p2   ),
          .core0_imem_lack            (core0_imem_lack_p2      ),
          .core0_imem_req             (core0_imem_req          ),
          .core0_imem_cmd             (core0_imem_cmd          ),
          .core0_imem_width           (core0_imem_width        ),
          .core0_imem_addr            (core0_imem_addr         ),
          .core0_imem_bl              (core0_imem_bl           ),
          .core0_imem_wdata           (core0_imem_wdata        ),
          .core0_imem_rdata           (core0_imem_rdata_p2     ),
          .core0_imem_resp            (core0_imem_resp_p2      ),

    // core0-dmem interface
          .core0_dmem_tid             (core0_dmem_tid          ),
          .core0_dmem_req_ack         (core0_dmem_req_ack_p2   ),
          .core0_dmem_lack            (core0_dmem_lack_p2      ),
          .core0_dmem_req             (core0_dmem_req          ),
          .core0_dmem_cmd             (core0_dmem_cmd          ),
          .core0_dmem_width           (core0_dmem_width        ),
          .core0_dmem_addr            (core0_dmem_addr         ),
          .core0_dmem_bl              (core0_dmem_bl           ),
          .core0_dmem_wdata           (core0_dmem_wdata        ),
          .core0_dmem_rdata           (core0_dmem_rdata_p2     ),
          .core0_dmem_resp            (core0_dmem_resp_p2      ),

    // core1-imem interface
          .core1_imem_tid             (core1_imem_tid          ),
          .core1_imem_req_ack         (core1_imem_req_ack_p2   ),
          .core1_imem_lack            (core1_imem_lack_p2      ),
          .core1_imem_req             (core1_imem_req          ),
          .core1_imem_cmd             (core1_imem_cmd          ),
          .core1_imem_width           (core1_imem_width        ),
          .core1_imem_addr            (core1_imem_addr         ),
          .core1_imem_bl              (core1_imem_bl           ),
          .core1_imem_wdata           (core1_imem_wdata        ),
          .core1_imem_rdata           (core1_imem_rdata_p2     ),
          .core1_imem_resp            (core1_imem_resp_p2      ),

    // core1-dmem interface
          .core1_dmem_tid             (core1_dmem_tid          ),
          .core1_dmem_req_ack         (core1_dmem_req_ack_p2   ),
          .core1_dmem_lack            (core1_dmem_lack_p2      ),
          .core1_dmem_req             (core1_dmem_req          ),
          .core1_dmem_cmd             (core1_dmem_cmd          ),
          .core1_dmem_width           (core1_dmem_width        ),
          .core1_dmem_addr            (core1_dmem_addr         ),
          .core1_dmem_bl              (core1_dmem_bl           ),
          .core1_dmem_wdata           (core1_dmem_wdata        ),
          .core1_dmem_rdata           (core1_dmem_rdata_p2     ),
          .core1_dmem_resp            (core1_dmem_resp_p2      ),

    // core2-imem interface
          .core2_imem_tid             (core2_imem_tid          ),
          .core2_imem_req_ack         (core2_imem_req_ack_p2   ),
          .core2_imem_lack            (core2_imem_lack_p2      ),
          .core2_imem_req             (core2_imem_req          ),
          .core2_imem_cmd             (core2_imem_cmd          ),
          .core2_imem_width           (core2_imem_width        ),
          .core2_imem_addr            (core2_imem_addr         ),
          .core2_imem_bl              (core2_imem_bl           ),
          .core2_imem_wdata           (core2_imem_wdata        ),
          .core2_imem_rdata           (core2_imem_rdata_p2     ),
          .core2_imem_resp            (core2_imem_resp_p2      ),

    // core2-dmem interface
          .core2_dmem_tid             (core2_dmem_tid          ),
          .core2_dmem_req_ack         (core2_dmem_req_ack_p2   ),
          .core2_dmem_lack            (core2_dmem_lack_p2      ),
          .core2_dmem_req             (core2_dmem_req          ),
          .core2_dmem_cmd             (core2_dmem_cmd          ),
          .core2_dmem_width           (core2_dmem_width        ),
          .core2_dmem_addr            (core2_dmem_addr         ),
          .core2_dmem_bl              (core2_dmem_bl           ),
          .core2_dmem_wdata           (core2_dmem_wdata        ),
          .core2_dmem_rdata           (core2_dmem_rdata_p2     ),
          .core2_dmem_resp            (core2_dmem_resp_p2      ),

    // core3-imem interface
          .core3_imem_tid             (core3_imem_tid          ),
          .core3_imem_req_ack         (core3_imem_req_ack_p2   ),
          .core3_imem_lack            (core3_imem_lack_p2      ),
          .core3_imem_req             (core3_imem_req          ),
          .core3_imem_cmd             (core3_imem_cmd          ),
          .core3_imem_width           (core3_imem_width        ),
          .core3_imem_addr            (core3_imem_addr         ),
          .core3_imem_bl              (core3_imem_bl           ),
          .core3_imem_wdata           (core3_imem_wdata        ),
          .core3_imem_rdata           (core3_imem_rdata_p2     ),
          .core3_imem_resp            (core3_imem_resp_p2      ),

    // core3-dmem interface
          .core3_dmem_tid             (core3_dmem_tid          ),
          .core3_dmem_req_ack         (core3_dmem_req_ack_p2   ),
          .core3_dmem_lack            (core3_dmem_lack_p2      ),
          .core3_dmem_req             (core3_dmem_req          ),
          .core3_dmem_cmd             (core3_dmem_cmd          ),
          .core3_dmem_width           (core3_dmem_width        ),
          .core3_dmem_addr            (core3_dmem_addr         ),
          .core3_dmem_bl              (core3_dmem_bl           ),
          .core3_dmem_wdata           (core3_dmem_wdata        ),
          .core3_dmem_rdata           (core3_dmem_rdata_p2     ),
          .core3_dmem_resp            (core3_dmem_resp_p2      ),

    // core interface
          .core_req_ack               (port2_req_ack            ),
          .core_req                   (port2_req                ),
          .core_cmd                   (port2_cmd                ),
          .core_width                 (port2_width              ),
          .core_addr                  (port2_addr               ),
          .core_bl                    (port2_bl                 ),
          .core_wdata                 (port2_wdata              ),
          .core_rdata                 (port2_rdata              ),
          .core_resp                  (port2_resp               )   

);

ycr4_router  u_router_p3 (
    // Control signals
          .rst_n                      (rst_n                   ),
          .clk                        (clk                     ),
                                                                  
          .taget_id                   (3'b011                  ),

    // core0-imem interface
          .core0_imem_tid             (core0_imem_tid          ),
          .core0_imem_req_ack         (core0_imem_req_ack_p3   ),
          .core0_imem_lack            (core0_imem_lack_p3      ),
          .core0_imem_req             (core0_imem_req          ),
          .core0_imem_cmd             (core0_imem_cmd          ),
          .core0_imem_width           (core0_imem_width        ),
          .core0_imem_addr            (core0_imem_addr         ),
          .core0_imem_bl              (core0_imem_bl           ),
          .core0_imem_wdata           (core0_imem_wdata        ),
          .core0_imem_rdata           (core0_imem_rdata_p3     ),
          .core0_imem_resp            (core0_imem_resp_p3      ),

    // core0-dmem interface
          .core0_dmem_tid             (core0_dmem_tid          ),
          .core0_dmem_req_ack         (core0_dmem_req_ack_p3   ),
          .core0_dmem_lack            (core0_dmem_lack_p3      ),
          .core0_dmem_req             (core0_dmem_req          ),
          .core0_dmem_cmd             (core0_dmem_cmd          ),
          .core0_dmem_width           (core0_dmem_width        ),
          .core0_dmem_addr            (core0_dmem_addr         ),
          .core0_dmem_bl              (core0_dmem_bl           ),
          .core0_dmem_wdata           (core0_dmem_wdata        ),
          .core0_dmem_rdata           (core0_dmem_rdata_p3     ),
          .core0_dmem_resp            (core0_dmem_resp_p3      ),

    // core1-imem interface
          .core1_imem_tid             (core1_imem_tid          ),
          .core1_imem_req_ack         (core1_imem_req_ack_p3   ),
          .core1_imem_lack            (core1_imem_lack_p3      ),
          .core1_imem_req             (core1_imem_req          ),
          .core1_imem_cmd             (core1_imem_cmd          ),
          .core1_imem_width           (core1_imem_width        ),
          .core1_imem_addr            (core1_imem_addr         ),
          .core1_imem_bl              (core1_imem_bl           ),
          .core1_imem_wdata           (core1_imem_wdata        ),
          .core1_imem_rdata           (core1_imem_rdata_p3     ),
          .core1_imem_resp            (core1_imem_resp_p3      ),

    // core1-dmem interface
          .core1_dmem_tid             (core1_dmem_tid          ),
          .core1_dmem_req_ack         (core1_dmem_req_ack_p3   ),
          .core1_dmem_lack            (core1_dmem_lack_p3      ),
          .core1_dmem_req             (core1_dmem_req          ),
          .core1_dmem_cmd             (core1_dmem_cmd          ),
          .core1_dmem_width           (core1_dmem_width        ),
          .core1_dmem_addr            (core1_dmem_addr         ),
          .core1_dmem_bl              (core1_dmem_bl           ),
          .core1_dmem_wdata           (core1_dmem_wdata        ),
          .core1_dmem_rdata           (core1_dmem_rdata_p3     ),
          .core1_dmem_resp            (core1_dmem_resp_p3      ),

    // core2-imem interface
          .core2_imem_tid             (core2_imem_tid          ),
          .core2_imem_req_ack         (core2_imem_req_ack_p3   ),
          .core2_imem_lack            (core2_imem_lack_p3      ),
          .core2_imem_req             (core2_imem_req          ),
          .core2_imem_cmd             (core2_imem_cmd          ),
          .core2_imem_width           (core2_imem_width        ),
          .core2_imem_addr            (core2_imem_addr         ),
          .core2_imem_bl              (core2_imem_bl           ),
          .core2_imem_wdata           (core2_imem_wdata        ),
          .core2_imem_rdata           (core2_imem_rdata_p3     ),
          .core2_imem_resp            (core2_imem_resp_p3      ),

    // core2-dmem interface
          .core2_dmem_tid             (core2_dmem_tid          ),
          .core2_dmem_req_ack         (core2_dmem_req_ack_p3   ),
          .core2_dmem_lack            (core2_dmem_lack_p3      ),
          .core2_dmem_req             (core2_dmem_req          ),
          .core2_dmem_cmd             (core2_dmem_cmd          ),
          .core2_dmem_width           (core2_dmem_width        ),
          .core2_dmem_addr            (core2_dmem_addr         ),
          .core2_dmem_bl              (core2_dmem_bl           ),
          .core2_dmem_wdata           (core2_dmem_wdata        ),
          .core2_dmem_rdata           (core2_dmem_rdata_p3     ),
          .core2_dmem_resp            (core2_dmem_resp_p3      ),

    // core3-imem interface
          .core3_imem_tid             (core3_imem_tid          ),
          .core3_imem_req_ack         (core3_imem_req_ack_p3   ),
          .core3_imem_lack            (core3_imem_lack_p3      ),
          .core3_imem_req             (core3_imem_req          ),
          .core3_imem_cmd             (core3_imem_cmd          ),
          .core3_imem_width           (core3_imem_width        ),
          .core3_imem_addr            (core3_imem_addr         ),
          .core3_imem_bl              (core3_imem_bl           ),
          .core3_imem_wdata           (core3_imem_wdata        ),
          .core3_imem_rdata           (core3_imem_rdata_p3     ),
          .core3_imem_resp            (core3_imem_resp_p3      ),

    // core3-dmem interface
          .core3_dmem_tid             (core3_dmem_tid          ),
          .core3_dmem_req_ack         (core3_dmem_req_ack_p3   ),
          .core3_dmem_lack            (core3_dmem_lack_p3      ),
          .core3_dmem_req             (core3_dmem_req          ),
          .core3_dmem_cmd             (core3_dmem_cmd          ),
          .core3_dmem_width           (core3_dmem_width        ),
          .core3_dmem_addr            (core3_dmem_addr         ),
          .core3_dmem_bl              (core3_dmem_bl           ),
          .core3_dmem_wdata           (core3_dmem_wdata        ),
          .core3_dmem_rdata           (core3_dmem_rdata_p3     ),
          .core3_dmem_resp            (core3_dmem_resp_p3      ),

    // core interface
          .core_req_ack               (port3_req_ack            ),
          .core_req                   (port3_req                ),
          .core_cmd                   (port3_cmd                ),
          .core_width                 (port3_width              ),
          .core_addr                  (port3_addr               ),
          .core_bl                    (port3_bl                 ),
          .core_wdata                 (port3_wdata              ),
          .core_rdata                 (port3_rdata              ),
          .core_resp                  (port3_resp               )   

);

ycr4_router  u_router_p4 (
    // Control signals
          .rst_n                      (rst_n                   ),
          .clk                        (clk                     ),
                                                                  
          .taget_id                   (3'b100                  ),

    // core0-imem interface
          .core0_imem_tid             (core0_imem_tid          ),
          .core0_imem_req_ack         (core0_imem_req_ack_p4   ),
          .core0_imem_lack            (core0_imem_lack_p4      ),
          .core0_imem_req             (core0_imem_req          ),
          .core0_imem_cmd             (core0_imem_cmd          ),
          .core0_imem_width           (core0_imem_width        ),
          .core0_imem_addr            (core0_imem_addr         ),
          .core0_imem_bl              (core0_imem_bl           ),
          .core0_imem_wdata           (core0_imem_wdata        ),
          .core0_imem_rdata           (core0_imem_rdata_p4     ),
          .core0_imem_resp            (core0_imem_resp_p4      ),

    // core0-dmem interface
          .core0_dmem_tid             (core0_dmem_tid          ),
          .core0_dmem_req_ack         (core0_dmem_req_ack_p4   ),
          .core0_dmem_lack            (core0_dmem_lack_p4      ),
          .core0_dmem_req             (core0_dmem_req          ),
          .core0_dmem_cmd             (core0_dmem_cmd          ),
          .core0_dmem_width           (core0_dmem_width        ),
          .core0_dmem_addr            (core0_dmem_addr         ),
          .core0_dmem_bl              (core0_dmem_bl           ),
          .core0_dmem_wdata           (core0_dmem_wdata        ),
          .core0_dmem_rdata           (core0_dmem_rdata_p4     ),
          .core0_dmem_resp            (core0_dmem_resp_p4      ),

    // core1-imem interface
          .core1_imem_tid             (core1_imem_tid          ),
          .core1_imem_req_ack         (core1_imem_req_ack_p4   ),
          .core1_imem_lack            (core1_imem_lack_p4      ),
          .core1_imem_req             (core1_imem_req          ),
          .core1_imem_cmd             (core1_imem_cmd          ),
          .core1_imem_width           (core1_imem_width        ),
          .core1_imem_addr            (core1_imem_addr         ),
          .core1_imem_bl              (core1_imem_bl           ),
          .core1_imem_wdata           (core1_imem_wdata        ),
          .core1_imem_rdata           (core1_imem_rdata_p4     ),
          .core1_imem_resp            (core1_imem_resp_p4      ),

    // core1-dmem interface
          .core1_dmem_tid             (core1_dmem_tid          ),
          .core1_dmem_req_ack         (core1_dmem_req_ack_p4   ),
          .core1_dmem_lack            (core1_dmem_lack_p4      ),
          .core1_dmem_req             (core1_dmem_req          ),
          .core1_dmem_cmd             (core1_dmem_cmd          ),
          .core1_dmem_width           (core1_dmem_width        ),
          .core1_dmem_addr            (core1_dmem_addr         ),
          .core1_dmem_bl              (core1_dmem_bl           ),
          .core1_dmem_wdata           (core1_dmem_wdata        ),
          .core1_dmem_rdata           (core1_dmem_rdata_p4     ),
          .core1_dmem_resp            (core1_dmem_resp_p4      ),

    // core2-imem interface
          .core2_imem_tid             (core2_imem_tid          ),
          .core2_imem_req_ack         (core2_imem_req_ack_p4   ),
          .core2_imem_lack            (core2_imem_lack_p4      ),
          .core2_imem_req             (core2_imem_req          ),
          .core2_imem_cmd             (core2_imem_cmd          ),
          .core2_imem_width           (core2_imem_width        ),
          .core2_imem_addr            (core2_imem_addr         ),
          .core2_imem_bl              (core2_imem_bl           ),
          .core2_imem_wdata           (core2_imem_wdata        ),
          .core2_imem_rdata           (core2_imem_rdata_p4     ),
          .core2_imem_resp            (core2_imem_resp_p4      ),

    // core2-dmem interface
          .core2_dmem_tid             (core2_dmem_tid          ),
          .core2_dmem_req_ack         (core2_dmem_req_ack_p4   ),
          .core2_dmem_lack            (core2_dmem_lack_p4      ),
          .core2_dmem_req             (core2_dmem_req          ),
          .core2_dmem_cmd             (core2_dmem_cmd          ),
          .core2_dmem_width           (core2_dmem_width        ),
          .core2_dmem_addr            (core2_dmem_addr         ),
          .core2_dmem_bl              (core2_dmem_bl           ),
          .core2_dmem_wdata           (core2_dmem_wdata        ),
          .core2_dmem_rdata           (core2_dmem_rdata_p4     ),
          .core2_dmem_resp            (core2_dmem_resp_p4      ),

    // core3-imem interface
          .core3_imem_tid             (core3_imem_tid          ),
          .core3_imem_req_ack         (core3_imem_req_ack_p4   ),
          .core3_imem_lack            (core3_imem_lack_p4      ),
          .core3_imem_req             (core3_imem_req          ),
          .core3_imem_cmd             (core3_imem_cmd          ),
          .core3_imem_width           (core3_imem_width        ),
          .core3_imem_addr            (core3_imem_addr         ),
          .core3_imem_bl              (core3_imem_bl           ),
          .core3_imem_wdata           (core3_imem_wdata        ),
          .core3_imem_rdata           (core3_imem_rdata_p4     ),
          .core3_imem_resp            (core3_imem_resp_p4      ),

    // core3-dmem interface
          .core3_dmem_tid             (core3_dmem_tid          ),
          .core3_dmem_req_ack         (core3_dmem_req_ack_p4   ),
          .core3_dmem_lack            (core3_dmem_lack_p4      ),
          .core3_dmem_req             (core3_dmem_req          ),
          .core3_dmem_cmd             (core3_dmem_cmd          ),
          .core3_dmem_width           (core3_dmem_width        ),
          .core3_dmem_addr            (core3_dmem_addr         ),
          .core3_dmem_bl              (core3_dmem_bl           ),
          .core3_dmem_wdata           (core3_dmem_wdata        ),
          .core3_dmem_rdata           (core3_dmem_rdata_p4     ),
          .core3_dmem_resp            (core3_dmem_resp_p4      ),

    // core interface
          .core_req_ack               (port4_req_ack            ),
          .core_req                   (port4_req                ),
          .core_cmd                   (port4_cmd                ),
          .core_width                 (port4_width              ),
          .core_addr                  (port4_addr               ),
          .core_bl                    (port4_bl                 ),
          .core_wdata                 (port4_wdata              ),
          .core_rdata                 (port4_rdata              ),
          .core_resp                  (port4_resp               )   

);

//---------------------------------------------
// Select the taget id based on address
//---------------------------------------------

function type_ycr_sel_e      func_taget_id;
input [`YCR_DMEM_AWIDTH-1:0] mem_addr;
begin
   func_taget_id    = YCR_SEL_PORT0;
   if ((mem_addr & YCR_PORT1_ADDR_MASK) == YCR_PORT1_ADDR_PATTERN) begin
       func_taget_id    = YCR_SEL_PORT1;
   end else if ((mem_addr & YCR_PORT2_ADDR_MASK) == YCR_PORT2_ADDR_PATTERN) begin
       func_taget_id    = YCR_SEL_PORT2;
   end else if ((mem_addr & YCR_PORT3_ADDR_MASK) == YCR_PORT3_ADDR_PATTERN) begin
       func_taget_id    = YCR_SEL_PORT3;
   end else if ((mem_addr & YCR_PORT4_ADDR_MASK) == YCR_PORT4_ADDR_PATTERN) begin
       func_taget_id    = YCR_SEL_PORT4;
   end
end
endfunction


endmodule
