`include "e203_defines.v"

module e203_exu_branchslv(
  input cmt_i_valid,
  output cmt_i_ready,
  input cmt_i_rv32,
  input cmt_i_dret,
  input cmt_i_mret,
  input cmt_i_fencei,
  input cmt_i_bjp,
  input cmt_i_bjp_prdt,
  input cmt_i_bjp_rslv,
  input [`E203_PC_SIZE-1:0] cmt_i_pc,
  input [`E203_XLEN-1:0] cmt_i_imm,

  input [`E203_PC_SIZE-1:0] csr_epc_r,
  input [`E203_PC_SIZE-1:0] csr_dpc_r,

  input nonalu_excpirq_flush_req_raw,
  input brchmis_flush_ack,
  output brchmis_flush_req,
  output [`E203_PC_SIZE-1:0] brchmis_flush_add_op1,
  output [`E203_PC_SIZE-1:0] brchmis_flush_add_op2,
`ifdef E203_TIMING_BOOST
  output [`E203_PC_SIZE-1:0] brchmis_flush_pc,
`endif

  output cmt_mret_ena,
  output cmt_dret_ena,
  output cmt_fencei_ena,

  input clk,
  input rst_n
);

wire brchmis_flush_ack_pre;
wire brchmis_flush_req_pre;

assign brchmis_flush_req = brchmis_flush_req_pre & (~nonalu_excpirq_flush_req_raw);
assign brchmis_flush_ack_pre = brchmis_flush_ack & (~nonalu_excpirq_flush_req_raw);

wire brchmis_need_flush = ((cmt_i_bjp & (cmt_i_bjp_prdt ^ cmt_i_bjp_rslv)) |
                           cmt_i_fencei | cmt_i_mret | cmt_i_dret);

wire cmt_i_is_branch = cmt_i_bjp | cmt_i_fencei | cmt_i_mret | cmt_i_dret;

assign brchmis_flush_req_pre = cmt_i_valid & brchmis_need_flush;

assign brchmis_flush_add_op1 = cmt_i_dret ? csr_dpc_r : cmt_i_mret ? csr_epc_r : cmt_i_pc;
assign brchmis_flush_add_op2 = cmt_i_dret ? `E203_PC_SIZE'b0 : cmt_i_mret ? `E203_PC_SIZE'b0 :
                                (cmt_i_fencei | cmt_i_bjp_prdt) ? (cmt_i_rv32 ? `E203_PC_SIZE'd4 : `E203_PC_SIZE'd2) :
                                  cmt_i_imm[`E203_PC_SIZE-1:0];

`ifdef E203_TIMING_BOOST
assign brchmis_flush_pc = (cmt_i_fencei | (cmt_i_bjp & cmt_i_bjp_prdt)) ? (cmt_i_pc + (cmt_i_rv32 ? `E203_PC_SIZE'd4 : `E203_PC_SIZE'd2)) :
                            (cmt_i_bjp & (~cmt_i_bjp_prdt)) ? (cmt_i_pc + cmt_i_imm[`E203_PC_SIZE-1:0]) :
                              cmt_i_dret ? csr_dpc_r : csr_epc_r;
`endif

wire brchmis_flush_hsked = brchmis_flush_req & brchmis_flush_ack;
assign cmt_mret_ena = cmt_i_mret & brchmis_flush_hsked;
assign cmt_dret_ena = cmt_i_dret & brchmis_flush_hsked;
assign cmt_fencei_ena = cmt_i_fencei & brchmis_flush_hsked;

assign cmt_i_ready = (~cmt_i_is_branch) | ((brchmis_need_flush ? brchmis_flush_ack_pre : 1'b1) & (~nonalu_excpirq_flush_req_raw));

endmodule