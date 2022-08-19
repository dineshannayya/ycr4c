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

module ycr4_cross_bar (
    // Control signals
    input   logic                           rst_n,
    input   logic                           clk,

    input   logic                           cfg_bypass_icache,  // 1 => Bypass icache
    input   logic                           cfg_bypass_dcache,  // 1 => Bypass dcache

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

    // PORT0 interface - dmem
    input   logic                          port0_req_ack,
    output  logic                          port0_req,
    output  logic                          port0_cmd,
    output  logic [1:0]                    port0_width,
    output  logic [`YCR_IMEM_AWIDTH-1:0]   port0_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    port0_bl,             
    output  logic [`YCR_IMEM_DWIDTH-1:0]   port0_wdata,
    input   logic [`YCR_IMEM_DWIDTH-1:0]   port0_rdata,
    input   logic [1:0]                    port0_resp,

    // PORT1 interface - icache
    input   logic                          port1_req_ack,
    output  logic                          port1_req,
    output  logic                          port1_cmd,
    output  logic [1:0]                    port1_width,
    output  logic [`YCR_IMEM_AWIDTH-1:0]   port1_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    port1_bl,             
    output  logic [`YCR_IMEM_DWIDTH-1:0]   port1_wdata,
    input   logic [`YCR_IMEM_DWIDTH-1:0]   port1_rdata,
    input   logic [1:0]                    port1_resp,

    // PORT2 interface - dcache
    input   logic                          port2_req_ack,
    output  logic                          port2_req,
    output  logic                          port2_cmd,
    output  logic [1:0]                    port2_width,
    output  logic [`YCR_IMEM_AWIDTH-1:0]   port2_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    port2_bl,             
    output  logic [`YCR_IMEM_DWIDTH-1:0]   port2_wdata,
    input   logic [`YCR_IMEM_DWIDTH-1:0]   port2_rdata,
    input   logic [1:0]                    port2_resp,
    
    // PORT3 interface - tcm
    input   logic                          port3_req_ack,
    output  logic                          port3_req,
    output  logic                          port3_cmd,
    output  logic [1:0]                    port3_width,
    output  logic [`YCR_IMEM_AWIDTH-1:0]   port3_addr,
    output  logic [`YCR_IMEM_BSIZE-1:0]    port3_bl,             
    output  logic [`YCR_IMEM_DWIDTH-1:0]   port3_wdata,
    input   logic [`YCR_IMEM_DWIDTH-1:0]   port3_rdata,
    input   logic [1:0]                    port3_resp,

    // PORT4 interface - timer
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

// dmem if
logic                          core_dmem_req_ack;
logic                          core_dmem_req;
logic                          core_dmem_cmd;
logic [1:0]                    core_dmem_width;
logic [`YCR_IMEM_AWIDTH-1:0]   core_dmem_addr;
logic [`YCR_IMEM_BSIZE-1:0]    core_dmem_bl;             
logic [`YCR_IMEM_DWIDTH-1:0]   core_dmem_wdata;
logic [`YCR_IMEM_DWIDTH-1:0]   core_dmem_rdata;
logic [1:0]                    core_dmem_resp;

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
     end else if(core3_dmem_lack) begin
        core3_dmem_lock  <= 1'b0;
    end
end

//------------------ End of tid generation ---------------------------------
// CORE0 IMEM
assign core0_imem_req_ack = 
	                      (core0_imem_tid == 3'b000) ? core0_imem_req_ack_p0 :
	                      (core0_imem_tid == 3'b001) ? core0_imem_req_ack_p1 :
			      'h0;
assign core0_imem_lack = 
	                      (core0_imem_tid == 3'b000) ? core0_imem_lack_p0 :
	                      (core0_imem_tid == 3'b001) ? core0_imem_lack_p1 :
			      'h0;

assign core0_imem_rdata  = 
	                      (core0_imem_tid == 3'b000) ? core0_imem_rdata_p0 :
	                      (core0_imem_tid == 3'b001) ? core0_imem_rdata_p1 :
			      'h0;

assign core0_imem_resp  = 
	                      (core0_imem_tid == 3'b000) ? core0_imem_resp_p0 :
	                      (core0_imem_tid == 3'b001) ? core0_imem_resp_p1 :
			      'h0;

// CORE0 DMEM
assign core0_dmem_req_ack = 
	                      (core0_dmem_tid == 3'b000) ? core0_dmem_req_ack_p0 :
	                      (core0_dmem_tid == 3'b001) ? core0_dmem_req_ack_p1 :
			      'h0;
assign core0_dmem_lack = 
	                      (core0_dmem_tid == 3'b000) ? core0_dmem_lack_p0 :
	                      (core0_dmem_tid == 3'b001) ? core0_dmem_lack_p1 :
			      'h0;

assign core0_dmem_rdata  = 
	                      (core0_dmem_tid == 3'b000) ? core0_dmem_rdata_p0 :
	                      (core0_dmem_tid == 3'b001) ? core0_dmem_rdata_p1 :
			      'h0;

assign core0_dmem_resp  = 
	                      (core0_dmem_tid == 3'b000) ? core0_dmem_resp_p0 :
	                      (core0_dmem_tid == 3'b001) ? core0_dmem_resp_p1 :
			      'h0;

// CORE1 IMEM
assign core1_imem_req_ack = 
	                      (core1_imem_tid == 3'b000) ? core1_imem_req_ack_p0 :
	                      (core1_imem_tid == 3'b001) ? core1_imem_req_ack_p1 :
			      'h0;
assign core1_imem_lack = 
	                      (core1_imem_tid == 3'b000) ? core1_imem_lack_p0 :
	                      (core1_imem_tid == 3'b001) ? core1_imem_lack_p1 :
			      'h0;

assign core1_imem_rdata  = 
	                      (core1_imem_tid == 3'b000) ? core1_imem_rdata_p0 :
	                      (core1_imem_tid == 3'b001) ? core1_imem_rdata_p1 :
			      'h0;

assign core1_imem_resp  = 
	                      (core1_imem_tid == 3'b000) ? core1_imem_resp_p0 :
	                      (core1_imem_tid == 3'b001) ? core1_imem_resp_p1 :
			      'h0;

// CORE0 DMEM
assign core1_dmem_req_ack = 
	                      (core1_dmem_tid == 3'b000) ? core1_dmem_req_ack_p0 :
	                      (core1_dmem_tid == 3'b001) ? core1_dmem_req_ack_p1 :
			      'h0;
assign core1_dmem_lack = 
	                      (core1_dmem_tid == 3'b000) ? core1_dmem_lack_p0 :
	                      (core1_dmem_tid == 3'b001) ? core1_dmem_lack_p1 :
			      'h0;

assign core1_dmem_rdata  = 
	                      (core1_dmem_tid == 3'b000) ? core1_dmem_rdata_p0 :
	                      (core1_dmem_tid == 3'b001) ? core1_dmem_rdata_p1 :
			      'h0;

assign core1_dmem_resp  = 
	                      (core1_dmem_tid == 3'b000) ? core1_dmem_resp_p0 :
	                      (core1_dmem_tid == 3'b001) ? core1_dmem_resp_p1 :
			      'h0;

// CORE2 IMEM
assign core2_imem_req_ack = 
	                      (core2_imem_tid == 3'b000) ? core2_imem_req_ack_p0 :
	                      (core2_imem_tid == 3'b001) ? core2_imem_req_ack_p1 :
			      'h0;
assign core2_imem_lack = 
	                      (core2_imem_tid == 3'b000) ? core2_imem_lack_p0 :
	                      (core2_imem_tid == 3'b001) ? core2_imem_lack_p1 :
			      'h0;

assign core2_imem_rdata  = 
	                      (core2_imem_tid == 3'b000) ? core2_imem_rdata_p0 :
	                      (core2_imem_tid == 3'b001) ? core2_imem_rdata_p1 :
			      'h0;

assign core2_imem_resp  = 
	                      (core2_imem_tid == 3'b000) ? core2_imem_resp_p0 :
	                      (core2_imem_tid == 3'b001) ? core2_imem_resp_p1 :
			      'h0;

// CORE2 DMEM
assign core2_dmem_req_ack = 
	                      (core2_dmem_tid == 3'b000) ? core2_dmem_req_ack_p0 :
	                      (core2_dmem_tid == 3'b001) ? core2_dmem_req_ack_p1 :
			      'h0;
assign core2_dmem_lack = 
	                      (core2_dmem_tid == 3'b000) ? core2_dmem_lack_p0 :
	                      (core2_dmem_tid == 3'b001) ? core2_dmem_lack_p1 :
			      'h0;

assign core2_dmem_rdata  = 
	                      (core2_dmem_tid == 3'b000) ? core2_dmem_rdata_p0 :
	                      (core2_dmem_tid == 3'b001) ? core2_dmem_rdata_p1 :
			      'h0;

assign core2_dmem_resp  = 
	                      (core2_dmem_tid == 3'b000) ? core2_dmem_resp_p0 :
	                      (core2_dmem_tid == 3'b001) ? core2_dmem_resp_p1 :
			      'h0;

// CORE3 IMEM
assign core3_imem_req_ack = 
	                      (core3_imem_tid == 3'b000) ? core3_imem_req_ack_p0 :
	                      (core3_imem_tid == 3'b001) ? core3_imem_req_ack_p1 :
			      'h0;
assign core3_imem_lack = 
	                      (core3_imem_tid == 3'b000) ? core3_imem_lack_p0 :
	                      (core3_imem_tid == 3'b001) ? core3_imem_lack_p1 :
			      'h0;

assign core3_imem_rdata  = 
	                      (core3_imem_tid == 3'b000) ? core3_imem_rdata_p0 :
	                      (core3_imem_tid == 3'b001) ? core3_imem_rdata_p1 :
			      'h0;

assign core3_imem_resp  = 
	                      (core3_imem_tid == 3'b000) ? core3_imem_resp_p0 :
	                      (core3_imem_tid == 3'b001) ? core3_imem_resp_p1 :
			      'h0;

// CORE3 DMEM
assign core3_dmem_req_ack = 
	                      (core3_dmem_tid == 3'b000) ? core3_dmem_req_ack_p0 :
	                      (core3_dmem_tid == 3'b001) ? core3_dmem_req_ack_p1 :
			      'h0;
assign core3_dmem_lack = 
	                      (core3_dmem_tid == 3'b000) ? core3_dmem_lack_p0 :
	                      (core3_dmem_tid == 3'b001) ? core3_dmem_lack_p1 :
			      'h0;

assign core3_dmem_rdata  = 
	                      (core3_dmem_tid == 3'b000) ? core3_dmem_rdata_p0 :
	                      (core3_dmem_tid == 3'b001) ? core3_dmem_rdata_p1 :
			      'h0;

assign core3_dmem_resp  = 
	                      (core3_dmem_tid == 3'b000) ? core3_dmem_resp_p0 :
	                      (core3_dmem_tid == 3'b001) ? core3_dmem_resp_p1 :
			      'h0;
//-------------------------------------------------------------------------
// Burst is only support in icache and rest of the interface support only
// single burst, as cross-bar expect last burst access to exit the grant,
// we are generting LOK for dcache, tcm,timer,dmem interface
// ------------------------------------------------------------------------
               
wire [1:0] core_dmem_resp_t   = core_dmem_resp;


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
          .core_req_ack               (core_dmem_req_ack       ),
          .core_req                   (core_dmem_req           ),
          .core_cmd                   (core_dmem_cmd           ),
          .core_width                 (core_dmem_width         ),
          .core_addr                  (core_dmem_addr          ),
          .core_bl                    (core_dmem_bl            ),
          .core_wdata                 (core_dmem_wdata         ),
          .core_rdata                 (core_dmem_rdata         ),
          .core_resp                  (core_dmem_resp_t        )   

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


//-------------------------------------------------------------------------------
// Data memory router
//-------------------------------------------------------------------------------
ycr_dmem_router #(
`ifdef YCR_DCACHE_EN
    .YCR_PORT1_ADDR_MASK       (YCR_DCACHE_ADDR_MASK),
    .YCR_PORT1_ADDR_PATTERN    (YCR_DCACHE_ADDR_PATTERN),
`else // YCR_DCACHE_EN
    .YCR_PORT1_ADDR_MASK       (32'h00000000),
    .YCR_PORT1_ADDR_PATTERN    (32'hFFFFFFFF),
`endif // YCR_DCACHE_EN

`ifdef YCR_TCM_EN
    .YCR_PORT2_ADDR_MASK       (YCR_TCM_ADDR_MASK),
    .YCR_PORT2_ADDR_PATTERN    (YCR_TCM_ADDR_PATTERN),
`else // YCR_TCM_EN
    .YCR_PORT2_ADDR_MASK       (32'h00000000),
    .YCR_PORT2_ADDR_PATTERN    (32'hFFFFFFFF),
`endif // YCR_TCM_EN

    .YCR_PORT3_ADDR_MASK       (YCR_TIMER_ADDR_MASK),
    .YCR_PORT3_ADDR_PATTERN    (YCR_TIMER_ADDR_PATTERN)

) i_dmem_router (
    .rst_n          (rst_n               ),
    .clk            (clk                 ),
    // Interface to core
    .dmem_req_ack   (core_dmem_req_ack   ),
    .dmem_req       (core_dmem_req       ),
    .dmem_cmd       (core_dmem_cmd       ),
    .dmem_bl        (core_dmem_bl        ),
    .dmem_width     (core_dmem_width     ),
    .dmem_addr      (core_dmem_addr      ),
    .dmem_wdata     (core_dmem_wdata     ),
    .dmem_rdata     (core_dmem_rdata     ),
    .dmem_resp      (core_dmem_resp      ),

`ifdef YCR_DCACHE_EN
    // Interface to TCM
    .port1_req_ack  (port2_req_ack    ),
    .port1_req      (port2_req        ),
    .port1_cmd      (port2_cmd        ),
    .port1_width    (port2_width      ),
    .port1_addr     (port2_addr       ),
    .port1_wdata    (port2_wdata      ),
    .port1_rdata    (port2_rdata      ),
    .port1_resp     (port2_resp       ),
`else // YCR_ICACHE_EN
    .port1_req_ack  (1'b0),
    .port1_req      (                    ),
    .port1_cmd      (                    ),
    .port1_width    (                    ),
    .port1_addr     (                    ),
    .port1_wdata    (                    ),
    .port1_rdata    (32'h0               ),
    .port1_resp     (YCR_MEM_RESP_RDY_ER),
`endif // YCR_ICACHE_EN
`ifdef YCR_TCM_EN
    // Interface to TCM
    .port2_req_ack  (port3_req_ack    ),
    .port2_req      (port3_req        ),
    .port2_cmd      (port3_cmd        ),
    .port2_width    (port3_width      ),
    .port2_addr     (port3_addr       ),
    .port2_wdata    (port3_wdata      ),
    .port2_rdata    (port3_rdata      ),
    .port2_resp     (port3_resp       ),
`else // YCR_TCM_EN
    .port2_req_ack  (1'b0),
    .port2_req      (                    ),
    .port2_cmd      (                    ),
    .port2_width    (                    ),
    .port2_addr     (                    ),
    .port2_wdata    (                    ),
    .port2_rdata    (32'h0               ),
    .port2_resp     (YCR_MEM_RESP_RDY_ER),
`endif // YCR_TCM_EN

    // Interface to memory-mapped timer
    .port3_req_ack  (port4_req_ack  ),
    .port3_req      (port4_req      ),
    .port3_cmd      (port4_cmd      ),
    .port3_width    (port4_width    ),
    .port3_addr     (port4_addr     ),
    .port3_wdata    (port4_wdata    ),
    .port3_rdata    (port4_rdata    ),
    .port3_resp     (port4_resp     ),

    // Interface to WB bridge
    .port0_req_ack  (port0_req_ack    ),
    .port0_req      (port0_req        ),
    .port0_cmd      (port0_cmd        ),
    .port0_bl       (port0_bl         ),
    .port0_width    (port0_width      ),
    .port0_addr     (port0_addr       ),
    .port0_wdata    (port0_wdata      ),
    .port0_rdata    (port0_rdata      ),
    .port0_resp     (port0_resp       )
);


//---------------------------------------------
// Select the taget id based on address
//---------------------------------------------

function type_ycr_sel_e      func_taget_id;
input [`YCR_DMEM_AWIDTH-1:0] mem_addr;
begin
   func_taget_id    = YCR_SEL_PORT0;
   if (((mem_addr & YCR_ICACHE_ADDR_MASK) == YCR_ICACHE_ADDR_PATTERN) && (cfg_bypass_icache == 1'b0)) begin
       func_taget_id    = YCR_SEL_PORT1;
   end
end
endfunction


endmodule
