`include "e203_defines.v"

`ifdef E203_SUPPORT_MULDIV
module e203_exu_alu_muldiv(
  input mdv_nob2b,

  input muldiv_i_valid,
  output muldiv_i_ready,

  input [`E203_XLEN-1:0] muldiv_i_rs1,
  input [`E203_XLEN-1:0] muldiv_i_rs2,
  input [`E203_XLEN-1:0] muldiv_i_imm,
  input [`E203_DECINFO_MULDIV_WIDTH-1:0] muldiv_i_info,
  input [`E203_ITAG_WIDTH-1:0] muldiv_i_itag,

  output muldiv_i_longpipe,

  input flush_pulse,

  output muldiv_o_valid,
  input muldiv_o_ready,
  output [`E203_XLEN-1:0] muldiv_o_wbck_wdat,
  output muldiv_o_wbck_err,

  output [`E203_MULDIV_ADDER_WIDTH-1:0] muldiv_req_alu_op1,
  output [`E203_MULDIV_ADDER_WIDTH-1:0] muldiv_req_alu_op2,
  output muldiv_req_alu_add,
  output muldiv_req_alu_sub,
  input [`E203_MULDIV_ADDER_WIDTH-1:0] muldiv_req_alu_res,

  output muldiv_sbf_0_ena,
  output [32:0] muldiv_sbf_0_nxt,
  input [32:0] muldiv_sbf_0_r,

  output muldiv_sbf_1_ena,
  output [32:0] muldiv_sbf_1_nxt,
  input [32:0] muldiv_sbf_1_r,

  input clk,
  input rst_n
);
endmodule
`endif
