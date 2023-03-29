`include "e203_defines.v"

module e203_exc_commit(
  output commit_mret,
  output commit_trap,
  output core_wfi,
  output nonflush_cmt_ena,

  output excp_active,

  input amo_wait,

  output wfi_halt_ifu_req,
  output wfi_halt_exu_req,
  input wfi_halt_ifu_ack,
  input wfi_halt_exu_ack,

  input dbg_irq_r,
  input [`E203_LIRQ_NUM-1:0] lcl_irq_r,
  input ext_irq_r,
  input sft_irq_r,
  input tmr_irq_r,
  input [`E203_EVT_NUM-1:0] evt_r,

  input status_mie_r,
  input mtie_r,
  input msie_r,
  input meie_r,

  input alu_cmt_i_valid,
  output alu_cmt_i_ready,
  input [`E203_PC_SIZE-1:0] alu_cmt_i_pc,
  input [`E203_INSTR_SIZE-1:0] alu_cmt_i_instr,
  input alu_cmt_i_pc_vld,
  input [`E203_XLEN-1:0] alu_cmt_i_imm,
  input alu_cmt_i_rv32,

  input alu_cmt_i_bjp,
  input alu_cmt_i_wfi,
  input alu_cmt_i_fencei,
  input alu_cmt_i_mret,
  input alu_cmt_i_dret,
  input alu_cmt_i_ecall,
  input alu_cmt_i_ebreak,
  input alu_cmt_i_ifu_misalgn,
  input alu_cmt_i_ifu_buserr,
  input alu_cmt_i_ifu_ilegl,
  input alu_cmt_i_bjp_prdt,
  input alu_cmt_i_bjp_rslv,

  input alu_cmt_i_misalgn,
  input alu_cmt_i_ld,
  input alu_cmt_i_stamo,
  input alu_cmt_i_buserr,
  input [`E203_ADDR_SIZE-1:0] alu_cmt_i_badaddr,

  output [`E203_ADDR_SIZE-1:0] cmt_badaddr,
  output cmt_badaddr_ena,
  output [`E203_PC_SIZE-1:0] cmt_epc,
  output cmt_epc_ena,
  output [`E203_XLEN-1:0] cmt_cause,
  output cmt_cause_ena,
  output cmt_instret_ena,
  output cmt_status_ena,

  output [`E203_PC_SIZE-1:0] cmt_dpc,
  output cmt_dpc_ena,
  output [2:0] cmt_dcause,
  output cmt_dcause_ena,

  output cmt_mret_ena,

  input [`E203_PC_SIZE-1:0] csr_epc_r,
  input [`E203_PC_SIZE-1:0] csr_dpc_r,
  input [`E203_XLEN-1:0] csr_mtvec_r,

  input dbg_mode,
  input dbg_halt_r,
  input dbg_step_r,
  input dbg_ebreakm_r,

  input oitf_empty,

  input u_mode,
  input s_mode,
  input h_mode,
  input m_mode,

  output longp_excp_i_ready,
  input longp_excp_i_valid,
  input longp_excp_i_ld,
  input longp_excp_i_st,
  input longp_excp_i_buserr,
  input [`E203_ADDR_SIZE-1:0] longp_excp_i_badaddr,
  input longp_excp_i_insterr,
  input [`E203_PC_SIZE-1:0] longp_excp_i_pc,

  output flush_pulse,
  output flush_req,

  input pipe_flush_ack,
  output pipe_flush_req,
  output [`E203_PC_SIZE-1:0] pipe_flush_add_op1,
  output [`E203_PC_SIZE-1:0] pipe_flush_add_op2,
`ifdef E203_TIMING_BOOST
  output [`E203_PC_SIZE-1:0] pipe_flush_pc,
`endif

  input clk,
  input rst_n
);

endmodule