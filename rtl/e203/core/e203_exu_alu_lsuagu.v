`include "e203_defines.v"

module e203_exu_alu_lsuagu(
  input agu_i_valid,
  output agu_i_ready,

  input [`E203_XLEN-1:0] agu_i_rs1,
  input [`E203_XLEN-1:0] agu_i_rs2,
  input [`E203_XLEN-1:0] agu_i_imm,
  input [`E203_DECINFO_AGU_WIDTH-1:0] agu_i_info,
  input [`E203_ITAG_WIDTH-1:0] agu_i_itag,

  output agu_i_longpipe,

  input flush_req,
  input flush_pulse,

  output amo_wait,
  input oitf_empty,

  output agu_o_valid,
  input agu_o_ready,
  output [`E203_XLEN-1:0] agu_o_wbck_wdat,
  output agu_o_wbck_err,
  output agu_o_cmt_misalgn,
  output agu_o_cmt_ld,
  output agu_o_cmt_stamo,
  output agu_o_cmt_buserr,
  output [`E203_ADDR_SIZE-1:0] agu_o_cmt_badaddr,

  output agu_icb_cmd_valid,
  input agu_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0] agu_icb_cmd_addr,
  output agu_icb_cmd_read,
  output [`E203_XLEN-1:0] agu_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0] agu_icb_cmd_wmask,
  output agu_icb_cmd_back2agu,
  output agu_icb_cmd_lock,
  output agu_icb_cmd_excl,
  output [1:0] agu_icb_cmd_size,
  output [`E203_ITAG_WIDTH-1:0] agu_icb_cmd_itag,
  output agu_icb_cmd_usign,

  input agu_icb_rsp_valid,
  output agu_icb_rsp_ready,
  input agu_icb_rsp_err,
  input agu_icb_rsp_excl_ok,
  input [`E203_XLEN-1:0] agu_icb_rsp_rdata,

  output [`E203_XLEN-1:0] agu_req_alu_op1,
  output [`E203_XLEN-1:0] agu_req_alu_op2,
  output agu_req_alu_swap,
  output agu_req_alu_add,
  output agu_req_alu_and,
  output agu_req_alu_or,
  output agu_req_alu_xor,
  output agu_req_alu_max,
  output agu_req_alu_min,
  output agu_req_alu_maxu,
  output agu_req_alu_minu,
  input [`E203_XLEN-1:0] agu_req_alu_res,

  output agu_sbf_0_ena,
  output [`E203_XLEN-1:0] agu_sbf_0_nxt,
  input [`E203_XLEN-1:0] agu_sbf_0_r,

  output agu_sbf_1_ena,
  output [`E203_XLEN-1:0] agu_sbf_1_nxt,
  input [`E203_XLEN-1:0] agu_sbf_1_r,

  input clk,
  input rst_n
);
endmodule