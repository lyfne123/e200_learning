`include "e203_defines.v"

module e203_exu_alu_csrctrl(
  input csr_i_valid,
  output csr_i_ready,

  input [`E203_XLEN-1:0] csr_i_rs1,
  input [`E203_DECINFO_CSR_WIDTH-1:0] csr_i_info,
  input csr_i_rdwen,

  output csr_ena,
  output csr_wr_en,
  output csr_rd_en,
  output [11:0] csr_idx,

  input csr_access_ilgl,
  input [`E203_XLEN-1:0] read_csr_dat,
  output [`E203_XLEN-1:0] wbck_csr_dat,

  `ifdef E203_HAS_CSR_EAI
  output csr_sel_eai.
  input eai_xs_off,
  output eai_csr_valid,
  input eai_csr_ready,
  output [31:0] eai_csr_addr,
  output eai_csr_wr,
  output [31:0] eai_csr_wdata,
  input [31:0] eai_csr_rdata,
  `endif

  output csr_o_valid,
  input csr_o_ready,
  output [`E203_XLEN-1:0] csr_o_wbck_wdat,
  output csr_o_wbck_err,

  input clk,
  input rst_n
);
endmodule