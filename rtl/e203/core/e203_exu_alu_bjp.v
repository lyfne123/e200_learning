`include "e203_defines.v"

module e203_exu_alu_bjp(
  input bjp_i_valid,
  output bjp_i_ready,

  input [`E203_XLEN-1:0] bjp_i_rs1,
  input [`E203_XLEN-1:0] bjp_i_rs2,
  input [`E203_XLEN-1:0] bjp_i_imm,
  input [`E203_PC_SIZE-1:0] bjp_i_pc,
  input [`E203_DECINFO_BJP_WIDTH-1:0] bjp_i_info,

  output bjp_o_valid,
  input bjp_o_ready,
  output [`E203_XLEN-1:0] bjp_o_wbck_wdat,
  output bjp_o_wbck_err,
  output bjp_o_cmt_bjp,
  output bjp_o_cmt_mret,
  output bjp_o_cmt_dret,
  output bjp_o_cmt_fencei,
  output bjp_o_cmt_prdt,
  output bjp_o_cmt_rslv,

  output [`E203_XLEN-1:0] bjp_req_alu_op1,
  output [`E203_XLEN-1:0] bjp_req_alu_op2,
  output bjp_req_alu_cmp_eq,
  output bjp_req_alu_cmp_ne,
  output bjp_req_alu_cmp_lt,
  output bjp_req_alu_cmp_gt,
  output bjp_req_alu_cmp_ltu,
  output bjp_req_alu_cmp_gtu,
  output bjp_req_alu_add,

  input bjp_req_alu_cmp_res,
  input [`E203_XLEN-1:0] bjp_req_alu_add_res,

  input clk,
  input rst_n
);
endmodule