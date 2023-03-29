`include "e203_defines.v"

module e203_exu_excp(
  output commit_trap,
  output core_wfi,
  output wfi_halt_ifu_req,
  output wfi_halt_exu_req,
  input wfi_halt_ifu_ack,
  input wfi_halt_exu_ack,

  input amo_wait,

  output alu_excp_i_ready,
  input alu_excp_i_valid,
  input alu_excp_i_ld,
  input alu_excp_i_stamo,
  input alu_excp_i_misalgn,
  input alu_excp_i_buserr,
  input alu_excp_i_ecall,
  input alu_excp_i_ebreak,
  input alu_excp_i_wfi,
  input alu_excp_i_ifu_misalgn,
  input alu_excp_i_ifu_buserr,
  input alu_excp_i_ifu_ilegl,
  input [`E203_ADDR_SIZE-1:0] alu_excp_i_badaddr,
  input [`E203_PC_SIZE-1:0] alu_excp_i_pc,
  input [`E203_INSTR_SIZE-1:0] alu_excp_i_instr,
  input alu_excp_i_pc_vld,

  output longp_excp_i_ready,
  input longp_excp_i_valid,
  input longp_excp_i_ld,
  input longp_excp_i_st,
  input longp_excp_i_buserr,
  input longp_excp_i_insterr,
  input [`E203_ADDR_SIZE-1:0] longp_excp_i_badaddr,
  input [`E203_PC_SIZE-1:0] longp_excp_i_pc,

  input excpirq_flush_ack,
  output excpirq_flush_req,
  output nonalu_excpirq_flush_req_raw,
  output [`E203_PC_SIZE-1:0] excpirq_flush_add_op1,
  output [`E203_PC_SIZE-1:0] excpirq_flush_add_op2,
`ifdef E203_TIMING_BOOST
  output [`E203_PC_SIZE-1:0] excpirq_flush_pc,
`endif

  input [`E203_XLEN-1:0] csr_mtvec_r,
  input cmt_dret_ena,
  input cmt_ena,

  output [`E203_ADDR_SIZE-1:0] cmt_badaddr,
  output [`E203_PC_SIZE-1:0] cmt_epc,
  output [`E203_XLEN-1:0] cmt_cause,
  output cmt_badaddr_ena,
  output cmt_epc_ena,
  output cmt_cause_ena,
  output cmt_status_ena,

  output [`E203_PC_SIZE-1:0] cmt_dpc,
  output cmt_dpc_ena,
  output [2:0]cmt_dcause,
  output cmt_dcause_ena,

  input dbg_irq_r,
  input [`E203_LIRQ_NUM-1:0] lcl_irq_r,
  input ext_irq_r,
  input sft_irq_r,
  input tmr_irq_r,

  input status_mie_r,
  input mtie_r,
  input msie_r,
  input meie_r,

  input dbg_mode,
  input dbg_halt_r,
  input dbg_step_r,
  input dbg_ebreakm_r,

  input oitf_empty,

  input u_mode,
  input s_mode,
  input h_mode,
  input m_mode,

  output excp_active,

  input clk,
  input rst_n
);

endmodule