`include "e203_defines.v"

module e203_exu_longpwbck(
  // lsu单元的写回接口
  input lsu_wbck_i_valid,
  output lsu_wbck_i_ready,
  input [`E203_XLEN-1:0] lsu_wbck_i_wdat,
  input [`E203_ITAG_WIDTH-1:0] lsu_wbck_i_itag,
  input lsu_wbck_i_err,
  input lsu_cmt_i_buserr,
  input [`E203_ADDR_SIZE-1:0] lsu_cmt_i_badaddr, // 产生访存错误的地址
  input lsu_cmt_i_ld, // 产生访存错误的是ld指令
  input lsu_cmt_i_st, // 产生访存错误的是store指令

  // 仲裁后的写回接口，通给最终写回仲裁模块
  output longp_wbck_o_valid,
  input longp_wbck_o_ready,
  output [`E203_XLEN-1:0] longp_wbck_o_wdat,
  output [4:0] longp_wbck_o_flags,
  output [`E203_RFIDX_WIDTH-1:0] longp_wbck_o_rdidx,

  // 仲裁后的异常接口，通给交付模块
  output longp_excp_o_valid,
  input longp_excp_o_ready,
  output longp_excp_o_insterr,
  output longp_excp_o_ld,
  output longp_excp_o_st,
  output longp_excp_o_buserr,
  output [`E203_ADDR_SIZE-1:0] longp_excp_o_badaddr,
  output [`E203_PC_SIZE-1:0] longp_excp_o_pc,

  input oitf_empty,
  input [`E203_ITAG_WIDTH-1:0] oitf_ret_ptr,
  input [`E203_RFIDX_WIDTH-1:0] oitf_ret_rdidx,
  input [`E203_PC_SIZE-1:0] oitf_ret_pc,
  input oitf_ret_rdwen,
  output oitf_ret_ena,

  input clk,
  input rst_n
);

// 使用oitf的读指针作为长指令写回仲裁的选择参考
wire wbck_ready4alu = (lsu_wbck_i_itag == oitf_ret_ptr) & (~oitf_empty);
wire wbck_sel_lsu = lsu_wbck_i_valid & wbck_ready4alu;

assign {longp_excp_o_insterr, longp_excp_o_ld, longp_excp_o_st, longp_excp_o_buserr, longp_excp_o_badaddr} =
  ({(`E203_ADDR_SIZE + 4){wbck_sel_lsu}} & {1'b0, lsu_cmt_i_ld, lsu_cmt_i_st, lsu_cmt_i_buserr, lsu_cmt_i_badaddr});

wire wbck_i_ready;
wire wbck_i_valid;
wire [`E203_FLEN-1:0] wbck_i_wdat;
wire [4:0] wbck_i_flags;
wire [`E203_RFIDX_WIDTH-1:0] wbck_i_rdidx;
wire [`E203_PC_SIZE-1:0] wbck_i_pc;
wire wbck_i_rdwen;
wire wbck_i_err;

assign lsu_wbck_i_ready = wbck_ready4alu & wbck_i_ready;

assign wbck_i_valid = ({1{wbck_sel_lsu}} & lsu_wbck_i_valid);
`ifdef E203_FLEN_IS_32
wire [`E203_FLEN-1:0] lsu_wbck_i_wdat_exd = lsu_wbck_i_wdat;
`else
wire [`E203_FLEN-1:0] lsu_wbck_i_wdat_exd = {{(`E203_FLEN - `E203_XLEN){1'b0}}, lsu_wbck_i_wdat};
`endif

assign wbck_i_wdat = ({`E203_FLEN{wbck_sel_lsu}} & lsu_wbck_i_wdat_exd);
assign wbck_i_flags = 5'b0;
assign wbck_i_err = wbck_sel_lsu & lsu_wbck_i_err;

assign wbck_i_pc = oitf_ret_pc;
assign wbck_i_rdidx = oitf_ret_rdidx;
assign wbck_i_rdwen = oitf_ret_rdwen;

// 只有没有异常错误的指令才需要写回regfile
wire need_wbck = wbck_i_rdwen & (~wbck_i_err);

// 产生了异常错误的指令需要和交付模块握手
wire need_excp = wbck_i_err;

// 需要保证交付模块和最终写回仲裁模块同时能够接受
assign wbck_i_ready = (need_wbck ? longp_wbck_o_ready : 1'b1) &
                      (need_excp ? longp_excp_o_ready : 1'b1);

// 通给最终写回仲裁模块的握手请求
assign longp_wbck_o_valid = need_wbck & wbck_i_valid & (need_wbck ? longp_wbck_o_ready : 1'b1);
// 通给交付模块的握手请求
assign longp_excp_o_valid = need_excp & wbck_i_valid & (need_excp ? longp_excp_o_ready : 1'b1);

assign longp_wbck_o_wdat = wbck_i_wdat;
assign longp_wbck_o_flags = wbck_i_flags;
assign longp_wbck_o_rdidx = wbck_i_rdidx;

assign longp_excp_o_pc = wbck_i_pc;

// 每次从长指令写回仲裁模块成功的写回一个长指令后，便将此指令从oitf中去除
// 以下信号为成功写回一个长指令的使能信号
assign oitf_ret_ena = wbck_i_valid & wbck_i_ready;

endmodule