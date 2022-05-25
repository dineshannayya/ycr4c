`define UNIT_DELAY #0.1

`ifdef GL
       `include "libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
       `include "libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
       `include "libs.ref/sky130_fd_sc_hvl/verilog/primitives.v"
       `include "libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v"
       `include "libs.ref//sky130_fd_sc_hd/verilog/sky130_ef_sc_hd__fakediode_2.v"
       `include "netlist/ycr_top_wb.gv"
`else
     `include "core/pipeline/ycr_pipe_hdu.sv"
     `include "core/pipeline/ycr_pipe_tdu.sv"
     `include "core/pipeline/ycr_ipic.sv"
     `include "core/pipeline/ycr_pipe_csr.sv"
     `include "core/pipeline/ycr_pipe_exu.sv"
     `include "core/pipeline/ycr_pipe_ialu.sv"
     `include "core/pipeline/ycr_pipe_idu.sv"
     `include "core/pipeline/ycr_pipe_ifu.sv"
     `include "core/pipeline/ycr_pipe_lsu.sv"
     `include "core/pipeline/ycr_pipe_mprf.sv"
     `include "core/pipeline/ycr_pipe_mul.sv"
     `include "core/pipeline/ycr_pipe_div.sv"
     `include "core/pipeline/ycr_pipe_top.sv"
     `include "core/primitives/ycr_reset_cells.sv"
     `include "core/primitives/ycr_cg.sv"
     `include "core/ycr_clk_ctrl.sv"
     `include "core/ycr_tapc_shift_reg.sv"
     `include "core/ycr_tapc.sv"
     `include "core/ycr_tapc_synchronizer.sv"
     `include "core/ycr_core_top.sv"
     `include "core/ycr_dm.sv"
     `include "core/ycr_dmi.sv"
     `include "core/ycr_scu.sv"
     `include "core/pipeline/ycr_tracelog.sv"
     `include "top/ycr_dmem_router.sv"
     `include "top/ycr_dp_memory.sv"
     `include "top/ycr_tcm.sv"
     `include "top/ycr_timer.sv"
     `include "top/ycr_dmem_wb.sv"
     `include "top/ycr_imem_wb.sv"
     `include "top/ycr4_top_wb.sv"
     `include "top/ycr_intf.sv"
     `include "top/ycr_sram_mux.sv"
     `include "top/ycr4_iconnect.sv"
     `include "top/ycr4_router.sv"
     `include "top/ycr4_cross_bar.sv"
     `include "top/ycr_req_retiming.sv"
     `include "lib/ycr_async_wbb.sv"
     `include "lib/ycr_arb.sv"
     `include "lib/sync_fifo2.sv"
     `include "lib/async_fifo.sv"
     `include "lib/clk_skew_adjust.gv"
     `include "lib/ctech_cells.sv"
     `include "cache/src/core/icache_top.sv"
     `include "cache/src/core/icache_app_fsm.sv"
     `include "cache/src/core/icache_tag_fifo.sv"
     `include "cache/src/core/dcache_tag_fifo.sv"
     `include "cache/src/core/dcache_top.sv"
`endif
