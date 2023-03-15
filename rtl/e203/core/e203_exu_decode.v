`include "e203_defines.v"

module e203_exu_decode(
  input [`E203_INSTR_SIZE-1:0] i_instr,
  input [`E203_PC_SIZE-1:0] i_pc,
  input i_prdt_taken,
  input i_misalgn,
  input i_buserr,
  input i_muldiv_b2b,
  input dbg_mode,

  output dec_rs1x0,
  output dec_rs2x0,
  output dec_rs1en,
  output dec_rs2en,
  output dec_rdwen,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_rdidx,
  output [`E203_DECINFO_WIDTH-1:0] dec_info,
  output [`E203_XLEN-1:0] dec_imm,
  output [`E203_PC_SIZE-1:0] dec_pc,
  output dec_misalgn,
  output dec_buserr,
  output dec_ilegl,

  output dec_mulhsu,
  output dec_mul,
  output dec_div,
  output dec_rem,
  output dec_divu,
  output dec_remu,

  output dec_rv32,
  output dec_bjp,
  output dec_jal,
  output dec_jalr,
  output dec_bxx,

  output [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,
  output [`E203_XLEN-1:0] dec_bjp_imm
);
endmodule