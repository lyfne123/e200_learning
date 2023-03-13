`include "../e203_defines.v"

module e203_ifu_mini_dec(
  input [`E203_INSTR_SIZE-1:0] instr,

  output dec_rs1en,
  output dec_rs2en,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx,

  output dec_mulhsu,
  output dec_mul,
  output dec_div,
  output dec_rem,
  output dec_divu,
  output dec_remu,

  output dec_rv32, // 是16位还是32位指令
  output dec_bjp, // 是普通指令还是跳转指令
  output dec_jal, // 是不是jal指令
  output dec_jalr, // 是不是jalr指令
  output dec_bxx, // 是不是bxx指令(beq, bne...)
  output [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,
  output [`E203_XLEN-1:0] dec_bjp_imm
);

// 不相关的输入接0，输出悬空，让综合器进行优化
e203_exu_decode u_e203_exu_decode(
  .i_instr(instr),
  .i_pc(`E203_PC_SIZE'b0),
  .i_prdt_taken(1'b0),
  .i_muldiv_b2b(1'b0),

  .i_misalgn(1'b0),
  .i_buserr(1'b0),
  .dbg_mode(1'b0),

  .dec_misalgn(),
  .dec_buserr(),
  .dec_ilegl(),

  .dec_rs1x0(),
  .dec_rs2x0(),
  .dec_rs1en(dec_rs1en),
  .dec_rs2en(dec_rs2en),
  .dec_rdwen(),
  .dec_rs1idx(dec_rs1idx),
  .dec_rs2idx(dec_rs2idx),
  .dec_rdidx(),
  .dec_info(),
  .dec_imm(),
  .dec_pc(),

  .dec_mulhsu(dec_mulhsu),
  .dec_mul(dec_mul),
  .dec_div(dec_div),
  .dec_rem(dec_rem),
  .dec_divu(dec_divu),
  .dec_remu(dec_remu),

  .dec_rv32(dec_rv32),
  .dec_bjp(dec_bjp),
  .dec_jal(dec_jal),
  .dec_jalr(dec_jalr),
  .dec_bxx(dec_bxx),

  .dec_jalr_rs1idx(dec_jalr_rs1idx),
  .dec_bjp_imm(dec_bjp_imm)
);

endmodule