`inclide "e203_defines.v"

module e203_exu(
  output commit_mret,
  output commit_trap,
  output exu_active,
  output excp_active,

  output core_wfi
  output tm_stop
  output itcm_nohold,
  
  output core_cgstop,
  output tcm_cgstop,

  input [`E203_HART_ID_W-1:0] core_mhartid,
  input dbg_irq_r,
  input [`E203_LIRQ_NUM-1:0] lcl_irq_r,
  input [`E203_EVT_NUM-1:0] evt_r,
  input ext_irq_r,
  input sft_irq_r,
  input tmr_irq_r,

  output [`E203_PC_SIZE-1:0] cmt_dpc,
  output cmt_dpc_ena,
  output [2:0] cnt_dcause,
  output cmt_dcause_ena,

  output wr_dcsr_ena,
  output wr_dpc_ena,
  output wr_dscratch_ena,

  output [`E203_XLEN-1:0] wr_csr_nxt,

  input [`E203_XLEN-1:0] dcsr_r,
  input [`E203_PC_SIZE-1:0] dpc_r,
  input [`E203_XLEN-1:0] dscratch_r,

  input dbg_mode,
  input dbg_halt_r,
  input dbg_step_r,
  input dbg_ebreakm_r,
  input dbg_stopcycle,

  input i_valid,
  output i_ready,
  input [`E203_INSTR_SIZE-1:0] i_ir,
  input [`E203_PC_SIZE-1:0] i_pc,
  input i_pc_vld,
  input i_misalgn,
  input i_buserr,
  input i_prdt_taken,
  input i_muldiv_b2b,
  input [`E203_RFIDX_WIDTH-1:0] i_rs1idx,
  input [`E203_RFIDX_WIDTH-1:0] i_rs2idx,

  input pipe_flush_ack,
  output pipe_flush_req,
  output [`E203_PC_SIZE-1:0] pipe_flush_add_op1,
  output [`E203_PC_SIZE-1:0] pipe_flush_add_op2,
`ifdef E203_TIMING_BOOST
  output [`E203_PC_SIZE-1:0] pipe_flush_pc,
`endif

  input lsu_o_valid,
  output lsu_o_ready,
  input [`E203_XLEN-1:0] lsu_o_wbck_wdat,
  input [`E203_ITAG_WIDTH-1:0] lsu_o_wbck_itag,
  input lsu_o_wbck_err,
  input lsu_o_wbck_ld,
  input lsu_o_wbck_st,
  input [`E203_ADDR_SIZE-1:0] lsu_o_cmt_badaddr,
  input lus_o_cmt_buserr,

  output wfi_halt_ifu_req,
  input wfi_halt_ifu_ack,

  output oitf_empty,
  output [`E203_XLEN-1:0] rf2ifu_x1,
  output [`E203_XLEN-1:0] rf2ifu_rs1,
  output dec2ifu_rden,
  output dec2ifu_rs1en,
  output [`E203_RFIDX_WIDTH-1:0] dec2ifu_rdidx,
  output dec2ifu_mulhsu,
  output dec2ifu_div,
  output dec2ifu_rem,
  output dec2ifu_divu,
  output dec2ifu_remu,

  output agu_icb_cmd_valid,
  input agu_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0] agu_icb_cmd_addr,
  output agu_icb_cmd_read,
  output [`E203_XLEN-1:0] agu_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0] agu_icb_cmd_wmask,
  output agu_icb_cmd_lock,
  output agu_icb_cmd_excl,
  output [1:0] agu_icb_cmd_size,

  output agu_icb_cmd_back2agu,
  output agu_icb_cmd_usign,
  output [`E203_ITAG_WIDTH-1:0] agu_icb_cmd_itag,

  input agu_icb_rsp_valid,
  output agu_icb_rsp_ready,
  input agu_icb_rsp_err,
  input agu_icb_rsp_excl_ok,
  input [`E203_XLEN-1:0] aguicb_rsp_rdata,

`ifdef E203_HAS_CSR_EAI
  output eai_csr_valid,
  input eai_csr_ready,
  output [31:0] eai_csr_addr,
  output eai_csr_wr,
  output [31:0] eai_csr_wdata,
  input eai_csr_rdata,
`endif

  input test_mode,
  input cla_aon,
  input clk,
  input rst_n
);

wire [`E203_XLEN-1:0] rf_rs1;
wire [`E203_XLEN-1:0] rf_rs2;


endmodule