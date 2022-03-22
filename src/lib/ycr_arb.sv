//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Arbitor                                                     ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/ycr.git                   ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////      This block implement simple round robine request        ////
//        arbitor for core interface.                             ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 20 Jan 2022, Dinesh A                               ////
////         Initial Version                                      ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

// Note: This logic assumes there are 8 Request 

module ycr_arb(
	input logic        clk, 
	input logic        rstn, 
	input logic [7:0]  req,  // Request
	input logic        req_ack,  // Request
	input logic        lack,  // Ack
	output logic [3:0] gnt   // Grant
       );

///////////////////////////////////////////////////////////////////////
//
// Parameters
//


parameter       FSM_GRANT      = 2'b00,
                WAIT_REQ_ACK   = 2'b01,
                WAIT_LACK      = 2'b10;

parameter       GRANT0     = 4'b0000;
parameter       GRANT1     = 4'b0001;
parameter       GRANT2     = 4'b0010;
parameter       GRANT3     = 4'b0011;
parameter       GRANT4     = 4'b0100;
parameter       GRANT5     = 4'b0101;
parameter       GRANT6     = 4'b0110;
parameter       GRANT7     = 4'b0111;
parameter       GRANTX     = 4'b1111;

///////////////////////////////////////////////////////////////////////
// Local Registers and Wires
//////////////////////////////////////////////////////////////////////

reg [1:0]     	state, next_state;
reg [3:0]       next_gnt;
reg [2:0]       ngnt,next_ngnt; // 1 Bit less than gnt to take care of roll over

///////////////////////////////////////////////////////////////////////
//  Misc Logic 
//////////////////////////////////////////////////////////////////////


always@(posedge clk or negedge rstn)
    if(!rstn) begin
       state   <= FSM_GRANT;
       gnt     <= GRANTX;
       ngnt    <= GRANT0;
    end else begin		
       gnt      <= next_gnt;
       ngnt     <= next_ngnt;
       state    <= next_state;
    end

///////////////////////////////////////////////////////////////////////
//
// Next State Logic 
//   - implements round robin arbitration algorithm
//   - switches grant if current req is dropped or next is asserted
//   - parks at last grant
//////////////////////////////////////////////////////////////////////

logic [3:0] grnt_tmp;

always_comb
   begin
      grnt_tmp      = 'h0;
      next_gnt      = gnt;
      next_ngnt     = ngnt;       
      next_state    = state;	// Default Keep State
      case(state)		
	 FSM_GRANT: begin
	     grnt_tmp = get_gnt({req,req},ngnt);
	     // Switch state only on req_ack, 
	     // To take care of case, where risc core can abrutly can
	     // de-assert req, do take care of jump cases
	     if(grnt_tmp != GRANTX) begin
		 next_gnt  = {1'b0,grnt_tmp[2:0]};
		 if(req_ack) begin
	            grnt_tmp =  next_gnt+1;
		    next_ngnt =   grnt_tmp[2:0];
	     	    next_state   = WAIT_LACK;
	         end else begin
	     	    next_state   = WAIT_REQ_ACK;
	         end
	     end 
      	end
	 WAIT_REQ_ACK: begin
	      if(req_ack) begin
	         grnt_tmp      =next_gnt+1;
		 next_ngnt    = grnt_tmp[2:0];
	     	 next_state   = WAIT_LACK;
	      end else if(req[gnt] == 0) begin // Exit if request is abortly removed
	     	 next_state   = FSM_GRANT;
	     end 
      	end
	WAIT_LACK : begin
		if(lack) begin
	     	    next_gnt     = GRANTX;
	     	    next_state   = FSM_GRANT;
		end
	end
      endcase
   end


function [3:0] get_gnt;
input [15:0] req; // 2*N request
input [3:0]  cur_gnt; // current grnt id
begin
   if(req[cur_gnt]+0 ) begin
   	get_gnt      = cur_gnt;
   end else if(req[cur_gnt+1]) begin
   	get_gnt      = cur_gnt+1;
   end else if(req[cur_gnt+2]) begin
   	get_gnt      = cur_gnt+2;
   end else if(req[cur_gnt+3]) begin
   	get_gnt      = cur_gnt+3;
   end else if(req[cur_gnt+4]) begin
   	get_gnt      = cur_gnt+4;
   end else if(req[cur_gnt+5]) begin
   	get_gnt      = cur_gnt+5;
   end else if(req[cur_gnt+6]) begin
   	get_gnt      = cur_gnt+6;
   end else if(req[cur_gnt+7]) begin
   	get_gnt      = cur_gnt+7;
   end else begin
   	get_gnt      = GRANTX;
   end
end
endfunction


endmodule 
