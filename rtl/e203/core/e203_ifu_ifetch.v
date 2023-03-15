`include "e203_defines.v"

// PC生成
// 如果是reset后第一次取指，使用顶层输入pc_rtvec作为PC值
// 对于顺序取指，如果当前指令是16位，则下一条指令为PC+2，如果是32位，则下一条指令为PC+4
// 如果是分支指令，使用bpu预测的跳转地址
// 如果是来自EXU的流水线冲刷，则使用EXU送过来的新PC值
module e203_ifu_ifetch(
  output [`E203_PC_SIZE-1:0] inspect_pc,

  input [`E203_PC_SIZE-1:0] pc_rtvec,

  output ifu_req_valid,
  input ifu_req_ready,
  output [`E203_PC_SIZE-1:0] ifu_req_pc,
  output ifu_req_seq,
  output ifu_req_seq_rv32,
  output [`E203_PC_SIZE-1:0] ifu_req_last_pc,

  input ifu_rsp_valid,
  output ifu_rsp_ready,
  input ifu_rsp_err,
  input [`E203_INSTR_SIZE-1:0] ifu_rsp_instr,

  output [`E203_INSTR_SIZE-1:0] ifu_o_ir,
  output [`E203_PC_SIZE-1:0] ifu_o_pc,
  output ifu_o_pc_vld,
  output [`E203_RFIDX_WIDTH-1:0] ifu_o_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] ifu_o_rs2idx,
  output ifu_o_prdt_taken,
  output ifu_o_misalgn,
  output ifu_o_buserr,
  output ifu_o_muldiv_b2b,
  output ifu_o_valid,
  input ifu_o_ready,

  output pipe_flush_ack,
  input pipe_flush_req,
  input [`E203_PC_SIZE-1:0] pipe_flush_add_op1,
  input [`E203_PC_SIZE-1:0] pipe_flush_add_op2,
  `ifdef E203_TIMING_BOOST
  input [`E203_PC_-1:0] pipe_flush_pc,
  `endif

  input ifu_halt_req,
  output ifu_halt_ack,

  input oitf_empty,
  input [`E203_XLEN-1:0] rf2ifu_x1,
  input [`E203_XLEN-1:0] rf2ifu_rs1,
  input dec2ifu_rs1en,
  input dec2ifu_rden,
  input [`E203_RFIDX_WIDTH-1:0] dec2ifu_rdidx,
  input dec2ifu_mulhsu,
  input dec2ifu_div,
  input dec2ifu_rem,
  input dec2ifu_divu,
  input dec2ifu_remu,

  input clk,
  input rst_n
);

wire ifu_req_hsked = (ifu_req_valid & ifu_req_ready);

// the rst_flag
wire reset_flag_r;
sirv_gnrl_dffrs #(1) reset_flag_dffrs(1'b0, reset_flag_r, clk, rst_n);

// the reset_req
wire reset_req_r;
wire reset_req_set = (~reset_req_r) & reset_flag_r;
wire reset_req_clr = reset_req_r & ifu_req_hsked;
wire reset_req_ena = reset_req_set | reset_req_clr;
wire reset_req_nxt = reset_req_set | (~reset_req_clr);

sirv_gnrl_dfflr #(1) reset_req_dfflr(reset_req_ena, reset_req_nxt, reset_req_r, clk, rst_n);

wire ifu_reset_req = reset_req_r;

// the flush ack signal generation
wire dly_flush_set;
wire dly_flush_clr;
wire dly_fulsh_ena;
wire dly_flush_nxt;

wire dly_flush_r;
assign dly_flush_set = pipe_flush_req & (~ifu_req_hsked);
assign dly_flush_clr = dly_flush_r & ifu_req_hsked;
assign dly_fulsh_ena = dly_flush_set | dly_flush_clr;
assign dly_flush_nxt = dly_flush_set | (~dly_flush_clr);

sirv_gnrl_dfflr #(1) dly_flush_dfflr(dly_fulsh_ena, dly_flush_nxt, dly_flush_r, clk, rst_n);

wire dly_pipe_flush_req = dly_flush_r;
wire pipe_flush_req_real = pipe_flush_req | dly_pipe_flush_req;

wire prdt_taken;

wire minidec_rv32;

e203_ifu_mini_dec u_e203_ifu_mini_dec(
  .instr(ifu_ir_nxt),
  .dec_rs1en(minidec_rs1en),
  .dec_rs2en(minidec_rs2en),
  .dec_rs1idx(minidec_rs1idx),
  .dec_rs2idx(minidec_rs2idx),

  .dec_rv32(minidec_rv32),
  .dec_bjp(minidec_bjp),
  .dec_jal(minidec_jal),
  .dec_jalr(minidec_jalr),
  .dec_bxx(minidec_bxx),

  .dec_mulhsu(),
  .dec_mul(minidec_mul),
  .dec_div(minidec_div),
  .dec_rem(minidec_rem),
  .dec_divu(minidec_divu),
  .dec_remu(minidec_remu),

  .dec_jalr_rs1idx(minidec_jalr_rs1idx),
  .dec_bjp_imm(minidec_bjp_imm)
);

wire bpu_wait;
wire [`E203_PC_SIZE-1:0] prdt_pc_add_op1;
wire [`E203_PC_SIZE-1:0] prdt_pc_add_op2;

e203_ifu_simple_bpu u_e203_ifu_simple_bpu(
  .pc(pc_r),

  .dec_jal(minidec_jal),
  .dec_jalr(minidec_jalr),
  .dec_bxx(minidec_bxx),
  .dec_bjp_imm(minidec_bjp_imm),
  .dec_jalr_rs1idx(minidec_jalr_rs1idx),

  .dec_i_valid(ifu_rsp_valid),
  .ir_valid_clr(ir_valid_clr),

  .oitf_empty(oitf_empty),
  .ir_empty(ir_empty),
  .ir_rs1en(ir_rs1en),

  .jalr_rs1idx_cam_irrdidx(jalr_rs1idx_cam_irrdidx),

  .bpu_wait(bpu_wait),
  .prdt_taken(prdt_taken),
  .prdt_pc_add_op1(prdt_pc_add_op1),
  .prdt_pc_add_op2(prdt_pc_add_op2),

  .bpu2rf_rs1_ena(bpu2rf_rs1_ena),
  .rf2bpu_x1(rf2ifu_x1),
  .rf2bpu_rs1(rf2ifu_rs1),

  .clk(clk),
  .rst_n(rst_n)
);

// PC自增值，2(16位指令)或4(32位指令)
wire [2:0] pc_incr_ofst = minidec_rv32 ? 3'd4 : 3'd2;

wire [`E203_PC_SIZE-1:0] pc_nxt_pre;
wire [`E203_PC_SIZE-1:0] pc_nxt;

// 跳转取址
wire bjp_req = minidec_bjp & prdt_taken;

wire ifetch_replay_req;

// 加法器输入
// 如果是分支跳转指令，使用bpu产生的加法操作数1
// 如果是reset后取指，使用pc_rtvec
// 否则为顺序取址，使用当前pc值
wire [`E203_PC_SIZE-1:0] pc_add_op1 = 
                          `ifndef E203_TIMING_BOOST
                            pipe_flush_req ? pipe_flush_add_op1 :
                            dly_pipe_flush_req ? pc_r :
                          `endif
                            ifetch_replay_req ? pc_r :
                            bjp_req ? prdt_pc_add_op1 :
                            ifu_reset_req ? pc_rtvec : pc_r;

// 如果是分支跳转指令，使用bpu产生的加法操作数2
// 如果是reset后取指，加0
// 否则为顺序取址，使用pc自增值
wire [`E203_PC_SIZE-1:0] pc_add_op2 =
                          `ifndef E203_TIMING_BOOST
                            pipe_flush_req ? pipe_flush_add_op1 :
                            dly_pipe_flush_req ? `E203_PC_SIZE'b0 :
                          `endif
                            ifetch_replay_req ? `E203_PC_SIZE'b0 :
                            bjp_req ? prdt_pc_add_op2 :
                            ifu_reset_req ? `E203_PC_SIZE'b0 : pc_incr_ofst;

// 顺序取指令的信号：没有reset，没有flush，不是分支跳转的情况
assign ifu_req_seq = (~pipe_flush_req_real) & (~ifu_reset_req) & (~ifetch_replay_req) & (~bjp_req);
assign ifu_req_seq_rv32 = minidec_rv32;
assign ifu_req_last_pc = pc_r;

// 下一条待取指令的pc初值
assign pc_nxt_pre = pc_add_op1 + pc_add_op2;

// 如果EXU产生流水线冲刷，使用EXU送过来的pc值
// 否则使用前面计算出的pc初值
`ifndef E203_TIMING_BOOST
assign pc_nxt = {pc_nxt_pre[`E203_PC_SIZE-1:1], 1'b0};
`else{
assign pc_nxt = pipe_flush_req ? {pipe_flush_pc[`E203_PC_SIZE-1:1], 1'b0}
              : dly_pipe_flush_req ? {pc_r[`E203_PC_SIZE-1:1], 1'b0} : {pc_nxt_pre[`E203_PC_SIZE-1:1], 1'b0};
`endif

// 产生下一条待取指的pc值
sirv_gnrl_dfflr #(`E203_PC_SIZE) pc_dfflr(pc_ena, pc_nxt, pc_r, clk, rst_n);

assign ifetch_replay_req = 1'b0; // TODO why give zero
endmodule