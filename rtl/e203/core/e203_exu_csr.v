`include "e203_defines.v"

module e203_exu_csr(
  input nonflush_cmt_ena,
  output eai_xs_off,

  input csr_ena, // 来自ALU的CSR读写使能信号
  input csr_wr_en, // CSR写操作指示信号
  input csr_rd_en, // CSR读操作指示信号
  input [11:0] csr_idx, // CSR寄存器地址索引

  output csr_access_ilgl,
  output tm_stop,
  output core_cgstop,
  output tcm_cgstop,
  output itcm_cgstop,
  output mdv_nob2b,

  output [`E203_XLEN-1:0] read_csr_dat, // 读出数据
  input [`E203_XLEN-1:0] wbck_csr_dat, // 写入数据

  input [`E203_HART_ID_W-1:0] core_mhartid,
  input ext_irq_r,
  input sft_irq_r,
  input tmr_irq_r,

  output status_mie_r,
  output mtie_r,
  output msie_r,
  output meie_r,

  output wr_dcsr_ena,
  output wr_dpc_ena,
  output wr_dscratch_ena,

  input [`E203_XLEN-1:0] dcsr_r,
  input [`E203_PC_SIZE-1:0] dpc_r,
  input [`E203_XLEN-1:0] dscratch_r,

  output [`E203_XLEN-1:0] wr_csr_nxt,

  input dbg_mode,
  input dbg_stopcycle,

  output u_mode,
  output s_mode,
  output h_mode,
  output m_mode,

  input [`E203_ADDR_SIZE-1:0] cmt_badaddr,
  input cmt_badaddr_ena,
  input [`E203_PC_SIZE-1:0] cmt_epc,
  input cmt_epc_ena,
  input [`E203_XLEN-1:0] cmt_cause,
  input cmt_cause_ena,
  input cmt_status_ena,
  input cmt_instret_ena,

  input cmt_mret_ena,
  output[`E203_PC_SIZE-1:0] csr_epc_r,
  output[`E203_PC_SIZE-1:0] csr_dpc_r,
  output[`E203_XLEN-1:0] csr_mtvec_r,

  input clk_aon,
  input clk,
  input rst_n
);

assign csr_access_ilgl = 1'b0;

wire wbck_csr_wen = csr_wr_en & csr_ena & (~csr_access_ilgl);
wire read_csr_wen = csr_rd_en & csr_ena & (~csr_access_ilgl);

wire [1:0] priv_mode = u_mode ? 2'b00 :
                       s_mode ? 2'b01 :
                       h_mode ? 2'b10 :
                       m_mode ? 2'b11 : 2'b11;

wire sel_ustatus = (csr_idx == 12'h000);
wire sel_mstatus = (csr_idx == 12'h300);

wire rd_ustatus = sel_ustatus & csr_rd_en;
wire rd_mstatus = sel_mstatus & csr_rd_en;
wire wr_ustatus = sel_ustatus & csr_wr_en;
wire wr_mstatus = sel_mstatus & csr_wr_en;

wire status_mpie_r;

// MTVEC寄存器
wire sel_mtvec = (csr_idx == 12'h305);
wire rd_mtvec = csr_rd_en & sel_mtvec;
`ifdef E203_SUPPORT_MTVEC
wire wr_mtvec = sel_mtvec & csr_wr_en;
wire mtvec_ena = (wr_mtvec & wbck_csr_wen);
wire [`E203_XLEN-1:0] mtvec_r;
wire [`E203_XLEN-1:0] ntvec_nxt = wbck_csr_dat;
sirv_gnrl_dfflr #(`E203_XLEN) mtvec_dfflr(mtvec_ena, mtvec_nxt, mtvec_r, clk, rst_n);
wire [`E203_XLEN-1:0] csr_mtvec = mtvec_r;
`else
wire [`E203_XLEN-1:0] csr_mtvec = `E203_XLEN'b0;
`endif
assign csr_mtvec_r = csr_mtvec;

endmodule