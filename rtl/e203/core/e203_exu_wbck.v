`include "e203_defines.v"

module e203_exu_wbck(
  input alu_wbck_i_valid,
  output alu_wbck_i_ready,
  input [`E203_XLEN-1:0] alu_wbck_i_wdat,
  input [`E203_RFIDX_WIDTH-1:0] alu_wbck_i_rdidx,

  input longp_wbck_i_valid,
  output longp_wbck_i_ready,
  input [`E203_FLEN-1:0] longp_wbck_i_wdat,
  input [4:0] longp_wbck_i_flags,
  input [`E203_RFIDX_WIDTH-1:0] longp_wbck_i_rdidx,

  output rf_wbck_o_ena,
  output [`E203_XLEN-1:0] rf_wbck_o_wdat,
  output [`E203_RFIDX_WIDTH-1:0] rf_wbck_o_rdidx,

  input clk,
  input rst_n
);

endmodule