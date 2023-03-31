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

wire irq_req_active;
wire nonalu_dbg_entry_req_raw;

assign excp_active = irq_req_active | nonalu_dbg_entry_req_raw;

wire wfi_req_hsked = (wfi_halt_ifu_req & wfi_halt_ifu_ack & wfi_halt_exu_req & wfi_halt_exu_ack);
wire wfi_flag_set = wfi_req_hsked;
wire wfi_irq_req;
wire dbg_entry_req;
wire wfi_flag_r;
wire wfi_flag_clr = (wfi_irq_req | dbg_entry_req);
wire wfi_flag_ena = wfi_flag_set | wfi_flag_clr;
wire wfi_flag_nxt = wfi_flag_set & (~wfi_flag_clr);
sirv_gnrl_dfflr #(1) wfi_flag_dfflr(wfi_flag_ena, wfi_flag_nxt, wfi_flag_r, clk, rst_n);
assign core_wfi = wfi_flag_r & (~wfi_flag_clr);

wire wfi_cmt_ena = alu_excp_i_wfi & cmt_ena;
wire wfi_halt_req_set = wfi_cmt_ena & (~dbg_mode);
wire wfi_halt_req_clr = wfi_flag_clr;
wire wfi_halt_req_ena = wfi_halt_req_set | wfi_halt_req_clr;
wire wfi_halt_req_nxt = wfi_halt_req_set & (~wfi_halt_req_clr);
wire wfi_halt_req_r;
sirv_gnrl_dfflr #(1) wfi_halt_req_dfflr(wfi_halt_req_ena, wfi_halt_req_nxt, wfi_halt_req_r, clk, rst_n);
assign wfi_halt_ifu_req = wfi_halt_req_r & (~wfi_halt_req_clr);

assign wfi_halt_exu_req = wfi_halt_req_r;

wire irq_req;
wire longp_need_flush;
wire alu_need_flush;
wire dbg_ebrk_req;
wire dbg_trig_req;

wire longp_excp_flush_req = longp_need_flush;
assign longp_excp_i_ready = excpirq_flush_ack;

wire dbg_entry_flush_req = dbg_entry_req & oitf_empty & alu_excp_i_pc_vld & (~longp_need_flush);
wire alu_excp_i_ready4dbg = (excpirq_flush_ack & oitf_empty & alu_excp_i_pc_vld & (~longp_need_flush));

wire irq_flush_req = irq_req & oitf_empty &alu_excp_i_pc_vld & (~dbg_entry_req) & (~longp_need_flush);

wire alu_excp_flush_req = alu_excp_i_valid & alu_need_flush & oitf_empty & (~irq_req) & (~dbg_entry_req) & (~longp_need_flush);

wire nonalu_dbg_entry_req;
wire alu_excp_i_ready4nondbg = alu_need_flush ? (excpirq_flush_ack & oitf_empty & (~irq_req) & (~nonalu_dbg_entry_req) & (~longp_need_flush)) :
                                                ((~irq_req) & (~nonalu_dbg_entry_req) & (~longp_need_flush));

wire alu_ebreakm_flush_req_novld;
wire alu_dbgtrig_flush_req_novld;
assign alu_excp_i_ready = (alu_ebreakm_flush_req_novld | alu_dbgtrig_flush_req_novld) ? alu_excp_i_ready4dbg : alu_excp_i_ready4nondbg;

assign excpirq_flush_req = longp_excp_flush_req | dbg_entry_flush_req | irq_flush_req | alu_excp_flush_req;
wire all_excp_flush_req = longp_excp_flush_req | alu_excp_flush_req;

assign nonalu_excpirq_flush_req_raw = longp_need_flush | nonalu_dbg_entry_req_raw | irq_req;

wire excpirq_taken_ena = excpirq_flush_req | excpirq_flush_ack;
assign commit_trap = excpirq_taken_ena;

wire excp_taken_ena = all_excp_flush_req & excpirq_taken_ena;
wire irq_taken_ena = irq_flush_req & excpirq_taken_ena;
wire dbg_entry_taken_ena = dbg_entry_flush_req & excpirq_taken_ena;

assign excpirq_flush_add_op1 = dbg_entry_flush_req ? `E203_PC_SIZE'h800 : (all_excp_flush_req & dbg_mode) ? `E203_PC_SIZE'h808: csr_mtvec_r;
assign excpirq_flush_add_op2 = dbg_entry_flush_req ? `E203_PC_SIZE'h0 : (all_excp_flush_req & dbg_mode) ? `E203_PC_SIZE'h0 : `E203_PC_SIZE'b0;
`ifdef E203_TIMING_BOOST
assign excpirq_flush_pc = dbg_entry_flush_req ? `E203_PC_SIZE'h800 : (all_excp_flush_req & dbg_mode) ? `E203_PC_SIZE'h808 : csr_mtvec_r;
`endif

assign longp_need_flush = longp_excp_i_valid;

wire step_req_r;
wire alu_ebreakm_flush_req;
wire alu_dbgtrig_flush_req;

wire dbg_step_req = step_req_r;
assign dbg_trig_req = alu_dbgtrig_flush_req & (~step_req_r);
assign dbg_ebrk_req = alu_ebreakm_flush_req & (~alu_dbgtrig_flush_req) & (~step_req_r);
wire dbg_irq_req = dbg_irq_r & (~alu_ebreakm_flush_req) & (~alu_dbgtrig_flush_req) & (~step_req_r);
wire nonalu_dbg_irq_req = dbg_irq_r & (~step_req_r);
wire dbg_halt_req = dbg_halt_r & (~dbg_irq_r) & (~alu_ebreakm_flush_req) & (~alu_dbgtrig_flush_req) & (~step_req_r) & (~dbg_step_r);
wire nonalu_dbg_halt_req = dbg_halt_r & (~dbg_irq_r) & (~step_req_r) & (~dbg_step_r);

wire step_req_set = (~dbg_mode) & dbg_step_r & cmt_ena & (~dbg_entry_taken_ena);
wire step_req_clr = dbg_entry_taken_ena;
wire step_req_ena = step_req_set | step_req_clr;
wire step_req_nxt = step_req_set | (~step_req_clr);
sirv_gnrl_dfflr #(1) step_req_dfflr(step_req_ena, step_req_nxt, step_req_r, clk, rst_n);

wire dbg_entry_mask = dbg_mode;
assign dbg_entry_req = (~dbg_entry_mask) & ((dbg_irq_req & (~amo_wait)) |
                                            (dbg_halt_req & (~amo_wait)) |
                                            dbg_step_req |
                                             (dbg_trig_req & (~amo_wait)) |
                                            dbg_ebrk_req);
assign nonalu_dbg_entry_req = (~dbg_entry_mask) & ((nonalu_dbg_irq_req & (~amo_wait)) |
                                                   (nonalu_dbg_halt_req & (~amo_wait)) |
                                                   dbg_step_req);
assign nonalu_dbg_entry_req_raw = (~dbg_entry_mask) & (dbg_irq_r | dbg_halt_r | step_req_r);

wire irq_mask = dbg_mode | dbg_step_r | (~status_mie_r) | amo_wait;
wire wfi_irq_mask = dbg_mode | dbg_step_r;
wire irq_req_raw = ((ext_irq_r & meie_r) |
                    (sft_irq_r & msie_r) |
                    (tmr_irq_r & mtie_r));
assign irq_req = (~irq_mask) & irq_req_raw;
assign wfi_irq_req = (~wfi_irq_mask) & irq_req_raw;

assign irq_req_active = wfi_flag_r ? wfi_irq_req : irq_req;

wire [`E203_XLEN-1:0] irq_cause;

assign irq_cause[31] = 1'b1;
assign irq_cause[30:4] = 27'b0;
assign irq_cause[3:0] = (sft_irq_r & msie_r) ? 4'd3 :
                        (tmr_irq_r & mtie_r) ? 4'd7 :
                        (ext_irq_r & meie_r) ? 4'd11 : 4'b0;

wire alu_excp_i_ebreak4excp = (alu_excp_i_ebreak & ((~dbg_ebreakm_r) | dbg_mode));

wire alu_excp_i_ebreak4dbg = alu_excp_i_ebreak & (~alu_need_flush) & dbg_ebreakm_r & (~dbg_mode);

assign alu_ebreakm_flush_req = alu_excp_i_valid & alu_excp_i_ebreak4dbg;
assign alu_ebreakm_flush_req_novld = alu_excp_i_ebreak4dbg;
`ifndef E203_SUPPORT_TRIGM
assign alu_dbgtrig_flush_req_novld = 1'b0;
assign alu_dbgtrig_flush_req = 1'b0;
`endif

assign alu_need_flush = (alu_excp_i_misalgn |
                         alu_excp_i_buserr |
                         alu_excp_i_ebreak4excp |
                         alu_excp_i_ecall |
                         alu_excp_i_ifu_misalgn |
                         alu_excp_i_ifu_buserr |
                         alu_excp_i_ifu_ilegl);

wire longp_excp_flush_req_ld = longp_excp_flush_req & longp_excp_i_ld;
wire longp_excp_flush_req_st = longp_excp_flush_req & longp_excp_i_st;

wire longp_excp_flush_req_insterr = longp_excp_flush_req & longp_excp_i_insterr;

wire alu_excp_flush_req_ld = alu_excp_flush_req & alu_excp_i_ld;
wire alu_excp_flush_req_stamo = alu_excp_flush_req & alu_excp_i_stamo;

wire alu_excp_flush_req_ebreak = (alu_excp_flush_req & alu_excp_i_ebreak4excp);
wire alu_excp_flush_req_ecall = (alu_excp_flush_req & alu_excp_i_ecall);
wire alu_excp_flush_req_ifu_misalgn = (alu_excp_flush_req & alu_excp_i_ifu_misalgn);
wire alu_excp_flush_req_ifu_buserr = (alu_excp_flush_req & alu_excp_i_ifu_buserr);
wire alu_excp_flush_req_ifu_ilegl = (alu_excp_flush_req & alu_excp_i_ifu_ilegl);

wire alu_excp_flush_req_ld_misalgn = (alu_excp_flush_req_ld & alu_excp_i_misalgn);
wire alu_excp_flush_req_ld_buserr = (alu_excp_flush_req_ld & alu_excp_i_buserr);
wire alu_excp_flush_req_stamo_misalgn = (alu_excp_flush_req_stamo & alu_excp_i_misalgn);
wire alu_excp_flush_req_stamo_buserr = (alu_excp_flush_req_stamo & alu_excp_i_buserr);
wire longp_excp_flush_req_ld_buserr = (longp_excp_flush_req_ld & longp_excp_i_buserr);
wire longp_excp_flush_req_st_buserr = (longp_excp_flush_req_st & longp_excp_i_buserr);

wire excp_flush_by_alu_agu = alu_excp_flush_req_ld_misalgn |
                             alu_excp_flush_req_ld_buserr |
                             alu_excp_flush_req_stamo_misalgn |
                             alu_excp_flush_req_stamo_buserr;

wire excp_flush_by_longp_ldst = longp_excp_flush_req_ld_buserr |
                                longp_excp_flush_req_st_buserr;

wire [`E203_XLEN-1:0] excp_cause;
assign excp_cause[31:5] = 27'b0;
assign excp_cause[4:0] = alu_excp_flush_req_ifu_misalgn ? 5'd0 :
                         alu_excp_flush_req_ifu_buserr ? 5'd1 :
                         alu_excp_flush_req_ifu_ilegl ? 5'd2 :
                         alu_excp_flush_req_ebreak ? 5'd3 :
                         alu_excp_flush_req_ld_misalgn ? 5'd4 :
                         (longp_excp_flush_req_ld_buserr | alu_excp_flush_req_ld_buserr) ? 5'd5 :
                         alu_excp_flush_req_stamo_misalgn ? 5'd6 :
                         (longp_excp_flush_req_st_buserr | alu_excp_flush_req_stamo_buserr) ? 5'd7 :
                         (alu_excp_flush_req_ecall & u_mode) ? 5'd8 :
                         (alu_excp_flush_req_ecall & s_mode) ? 5'd9 :
                         (alu_excp_flush_req_ecall & h_mode) ? 5'd10 :
                         (alu_excp_flush_req_ecall & m_mode) ? 5'd11 :
                         longp_excp_flush_req_insterr ? 5'd16 : 5'h1f;

wire excp_flush_req_ld_misalgn = alu_excp_flush_req_ld_misalgn;
wire excp_flush_req_ld_buserr = alu_excp_flush_req_ld_buserr | longp_excp_flush_req_ld_buserr;

wire cmt_badaddr_update = excpirq_flush_req;

assign cmt_badaddr = excp_flush_by_longp_ldst ? longp_excp_i_badaddr :
                     excp_flush_by_alu_agu ? alu_excp_i_badaddr :
                     (alu_excp_flush_req_ebreak | alu_excp_i_ifu_misalgn | alu_excp_flush_req_ifu_buserr) ? alu_excp_i_pc :
                     alu_excp_flush_req_ifu_ilegl ? alu_excp_i_instr : `E203_ADDR_SIZE'b0;

assign cmt_epc = longp_excp_i_valid ? longp_excp_i_pc : alu_excp_i_pc;

assign cmt_cause = excp_taken_ena ? excp_cause : irq_cause;

assign cmt_epc_ena = (~dbg_mode) & (excp_taken_ena | irq_taken_ena);
assign cmt_cause_ena = cmt_epc_ena;
assign cmt_status_ena = cmt_epc_ena;
assign cmt_badaddr_ena = cmt_epc_ena & cmt_badaddr_update;

assign cmt_dpc = alu_excp_i_pc;
assign cmt_dpc_ena = dbg_entry_taken_ena;

wire cmt_dcause_set = dbg_entry_taken_ena;
wire cmt_dcause_clr = cmt_dret_ena;
wire [2:0] set_dcause_nxt = dbg_trig_req ? 3'd2 :
                            dbg_ebrk_req ? 3'd1 :
                            dbg_irq_req ? 3'd3 :
                            dbg_step_req ? 3'd4 :
                            dbg_halt_req ? 3'd5 : 3'd0;

assign cmt_dcause_ena = cmt_dcause_set | cmt_dcause_clr;
assign cmt_dcause = cmt_dcause_set ? set_dcause_nxt : 3'd0;

endmodule