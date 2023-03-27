`include "e203_defines.v"

module e203_exu_alu_rglr(
  input alu_i_valid,
  output alu_i_ready,

  input [`E203_XLEN-1:0] alu_i_rs1,
  input [`E203_XLEN-1:0] alu_i_rs2,
  input [`E203_XLEN-1:0] alu_i_imm,
  input [`E203_PC_SIZE-1:0] alu_i_pc,
  input [`E203_DECINFO_ALU_WIDTH-1:0] alu_i_info,

  output alu_o_valid,
  input alu_o_ready,
  output [`E203_XLEN-1:0] alu_o_wbck_wdat,
  output alu_o_wbck_err,
  output alu_o_cmt_ecall,
  output alu_o_cmt_ebreak,
  output alu_o_cmt_wfi,

  output alu_req_alu_add,
  output alu_req_alu_sub,
  output alu_req_alu_xor,
  output alu_req_alu_sll,
  output alu_req_alu_srl,
  output alu_req_alu_sra,
  output alu_req_alu_or,
  output alu_req_alu_and,
  output alu_req_alu_slt,
  output alu_req_alu_sltu,
  output alu_req_alu_lui,
  output [`E203_XLEN-1:0] alu_req_alu_op1,
  output [`E203_XLEN-1:0] alu_req_alu_op2,

  input [`E203_XLEN-1:0] alu_req_alu_res,

  input clk,
  input rst_n
);
endmodule