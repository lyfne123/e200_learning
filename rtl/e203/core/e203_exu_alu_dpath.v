`include "e203_defines.v"

module e203_exu_alu_dpath(
  input alu_req_alu,

  input alu_req_alu_add,
  input alu_req_alu_sub,
  input alu_req_alu_xor,
  input alu_req_alu_sll,
  input alu_req_alu_srl,
  input alu_req_alu_sra,
  input alu_req_alu_or,
  input alu_req_alu_and,
  input alu_req_alu_slt,
  input alu_req_alu_sltu,
  input alu_req_alu_lui,
  input [`E203_XLEN-1:0] alu_req_alu_op1,
  input [`E203_XLEN-1:0] alu_req_alu_op2,

  output [`E203_XLEN-1:0] alu_req_alu_res,

  input bjp_req_alu,

  input [`E203_XLEN-1:0] bjp_req_alu_op1,
  input [`E203_XLEN-1:0] bjp_req_alu_op2,
  input bjp_req_alu_cmp_eq,
  input bjp_req_alu_cmp_ne,
  input bjp_req_alu_cmp_lt,
  input bjp_req_alu_cmp_gt,
  input bjp_req_alu_cmp_ltu,
  input bjp_req_alu_cmp_gtu,
  input bjp_req_alu_add,

  output bjp_req_alu_cmp_res,
  output [`E203_XLEN-1:0] bjp_req_alu_add_res,

  input agu_req_alu,

  input [`E203_XLEN-1:0] agu_req_alu_op1,
  input [`E203_XLEN-1:0] agu_req_alu_op2,
  input agu_req_alu_swap,
  input agu_req_alu_add,
  input agu_req_alu_and,
  input agu_req_alu_or,
  input agu_req_alu_xor,
  input agu_req_alu_max,
  input agu_req_alu_min,
  input agu_req_alu_maxu,
  input agu_req_alu_minu,

  output [`E203_XLEN-1:0] agu_req_alu_res,

  input agu_sbf_0_ena,
  input [`E203_XLEN-1:0] agu_sbf_0_nxt,
  output [`E203_XLEN-1:0] agu_sbf_0_r,

  input agu_sbf_1_ena,
  input [`E203_XLEN-1:0] agu_sbf_1_nxt,
  output [`E203_XLEN-1:0] agu_sbf_1_r,

`ifdef E203_SUPPORT_SHARE_MULDIV
  input muldiv_req_alu,

  input [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op1,
  input [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op2,
  input muldiv_req_alu_add,
  input muldiv_req_alu_sub,
  output [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_res,

  input muldiv_sbf_0_ena,
  input [32:0] muldiv_sbf_0_nxt,
  output [32:0] muldiv_sbf_0_r,

  input muldiv_sbf_1_ena,
  input [32:0] muldiv_sbf_1_nxt,
  output [32:0] muldiv_sbf_1_r,
`endif

  input clk,
  input rst_n
);
endmodule