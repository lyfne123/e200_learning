`include "e203_defines.v"

module e203_exu_alu(
  // dispatch和alu之间采用valid-ready模式的握手信号
  input i_valid,
  output i_ready,

  output i_longpipe,

  `ifdef E203_HAS_CSR_EAI
  `ifndef E203_HAS_EAI
  input eai_xs_off,
  `endif
  output eai_csr_valid,
  input eai_csr_ready,
  output [31:0] eai_csr_addr,
  output eai_csr_wr,
  output [31:0] eai_csr_wdata,
  input [31:0] eai_csr_rdata,
  `endif

  output amo_wait,
  input oitf_empty,

  input [`E203_ITAG_WIDTH-1:0] i_itag,
  input [`E203_XLEN-1:0] i_rs1,
  input [`E203_XLEN-1:0] i_rs2,
  input [`E203_XLEN-1:0] i_imm,
  input [`E203_DECINFO_WIDTH-1:0] i_info,
  input [`E203_PC_SIZE-1:0] i_pc,
  input [`E203_INSTR_SIZE-1:0] i_instr,
  input i_pc_vld,
  input [`E203_RFIDX_WIDTH-1:0] i_rdidx,
  input i_rdwen,
  input i_ilegl,
  input i_buserr,
  input i_misalgn,

  input flush_req,
  input flush_pulse,

  output cmt_o_valid,
  input cmt_o_ready,
  output cmt_o_pc_vld,
  output [`E203_PC_SIZE-1:0] cmt_o_pc,
  output [`E203_INSTR_SIZE-1:0] cmt_o_instr,
  output [`E203_XLEN-1:0] cmt_o_imm,

  output cmt_o_rv32,
  output cmt_o_bjp,
  output cmt_o_mret,
  output cmt_o_dret,
  output cmt_o_ecall,
  output cmt_o_ebreak,
  output cmt_o_fencei,
  output cmt_o_wfi,
  output cmt_o_ifu_misalgn,
  output cmt_o_ifu_buserr,
  output cmt_o_ifu_ilegl,
  output cmt_o_bjp_prdt,
  output cmt_o_bjp_rslv,
  output cmt_o_misalgn,
  output cmt_o_ld,
  output cmt_o_stamo,
  output cmt_o_buserr,
  output [`E203_ADDR_SIZE-1:0] cmt_o_badaddr,

  output wbck_o_valid,
  input wbck_o_ready,
  output [`E203_XLEN-1:0] wbck_o_wdat,
  output [`E203_RFIDX_WIDTH-1:0] wbck_o_rdidx,

  input mdv_nob2b,

  output csr_ena,
  output csr_wr_en,
  output csr_rd_en,
  output [11:0] csr_idx,

  input nonflush_cmt_ena,
  input csr_access_ilgl,
  input [`E203_XLEN-1:0] read_csr_dat,
  output [`E203_XLEN-1:0] wbck_csr_dat,

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
input [`E203_XLEN-1:0] agu_icb_rsp_rdata,

input clk,
input rst_n
);

// 对于发生取指异常的指令，单独列为一种类型，无需被具体执行
wire ifu_excp_op = i_ilegl | i_buserr | i_misalgn;
// 通过decode模块中的分组信息(info_bus)，判断需要什么单元执行此指令
// alu中包括6个功能子单元
// 普通alu计算(regular-alu)：逻辑运算，加减法，移位等指令
// 访存地址生成(agu)：负责load，store和A扩展指令的地址生成
// 分支预测解析(bjp)：负责branch和jump指令的解析和执行
// csr读写控制(cst-ctrl)：负责csr指令的执行
// 多周期乘除法器(mdv)：负责乘除法指令的执行
wire alu_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_ALU);
wire agu_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_AGU);
wire bjp_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_BJP);
wire csr_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_CSR);
`ifdef E203_SUPPORT_SHARE_MULDIV
wire mdv_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_MULDIV);
`endif

// 根据不同的指令分组指示信号，将对应子单元的输入valid置高，选择对应子单元的ready信号作为反馈给上游
// 派遣模块的ready握手信号
`ifdef E203_SUPPORT_SHARE_MULDIV
wire mdv_i_valid = i_valid & mdv_op;
`endif
wire agu_i_valid = i_valid & agu_op;
wire alu_i_valid = i_valid & alu_op;
wire bjp_i_valid = i_valid & bjp_op;
wire csr_i_valid = i_valid & csr_op;
wire ifu_excp_i_valid = i_valid & ifu_excp_op;

`ifdef E203_SUPPORT_SHARE_MULDIV
wire mdv_i_ready;
`endif
wire agu_i_ready;
wire alu_i_ready;
wire bjp_i_ready;
wire csr_i_ready;
wire ifu_excp_i_ready;

// 本质上是使用and or实现的并行多路选择器
assign i_ready = (agu_i_ready & agu_op) |
                `ifdef E203_SUPPORT_SHARE_MULDIV
                 (mdv_i_ready & mdv_op) |
                `endif
                 (alu_i_ready & alu_op) |
                 (ifu_excp_i_ready & ifu_excp_op) |
                 (bjp_i_ready & bjp_op) |
                 (csr_i_ready & csr_op);

wire agu_i_longpipe;
`ifdef E203_SUPPORT_SHARE_MULDIV
wire mdv_i_longpipe;
`endif

assign i_longpipe = (agu_i_longpipe & agu_op)
                    `ifdef E203_SUPPORT_SHARE_MULDIV
                    | (mdv_i_longpipe & mdv_op)
                    `endif
                    ;

wire csr_o_valid;
wire csr_o_ready;
wire [`E203_XLEN-1:0] csr_o_wbck_wdat;
wire csr_o_wbck_err;

// 为了节省动态功耗，采用逻辑门控的方式，增加一级与门，对与子单元输入的信号与分组指示
// 信号进行与操作，那么在无需使用该子单元时，其输入信号就都是0，从而降低动态翻转功耗
wire [`E203_XLEN-1:0] csr_i_rs1 = {`E203_XLEN{csr_op}} & i_rs1;
wire [`E203_XLEN-1:0] csr_i_rs2 = {`E203_XLEN{csr_op}} & i_rs2;
wire [`E203_XLEN-1:0] csr_i_imm = {`E203_XLEN{csr_op}} & i_imm;
wire [`E203_XLEN-1:0] csr_i_info = {`E203_XLEN{csr_op}} & i_info;
wire csr_i_rdwen = csr_op & i_rdwen;

`ifndef E203_HAS_EAI
wire eai_o_cmt_wr_reg;
wire csr_sel_eai;
`endif

e203_exu_alu_csrctrl u_e203_exu_alu_csrctrl(
`ifdef E203_HAS_CSR_EAI
  .csr_sel_eai(csr_sel_eai),
  .eai_xs_off(eai_xs_off),
  .eai_csr_valid(eai_csr_valid),
  .eai_csr_ready(eai_csr_ready),
  .eai_csr_addr(eai_csr_addr),
  .eai_csr_wr(eai_csr_wr),
  .eai_csr_wdata(eai_csr_wdata),
  .eai_csr_rdata(eai_csr_rdata),
`endif
  .csr_access_ilgl(csr_access_ilgl),

  .csr_i_valid(csr_i_valid),
  .csr_i_ready(csr_i_ready),

  .csr_i_rs1(csr_i_rs1),
  .csr_i_info(csr_i_info[`E203_DECINFO_CSR_WIDTH-1:0]),
  .csr_i_rdwen(csr_i_rdwen),

  .csr_ena(csr_ena),
  .csr_idx(csr_idx),
  .csr_rd_en(csr_rd_en),
  .csr_wr_en(csr_wr_en),
  .read_csr_dat(read_csr_dat),
  .wbck_csr_dat(wbck_csr_dat),

  .csr_o_valid(csr_o_valid),
  .csr_o_ready(csr_o_ready),
  .csr_o_wbck_wdat(csr_o_wbck_wdat),
  .csr_o_wbck_err(csr_o_wbck_err),

  .clk(clk),
  .rst_n(rst_n)
);

wire bjp_o_valid;
wire bjp_o_ready;
wire [`E203_XLEN-1:0] bjp_o_wbck_wdat;
wire bjp_o_wbck_err;
wire bjp_o_cmt_bjp;
wire bjp_o_cmt_mret;
wire bjp_o_cmt_dret;
wire bjp_o_cmt_fencei;
wire bjp_o_cmt_prdt;
wire bjp_o_cmt_rslv;

wire [`E203_XLEN-1:0] bjp_req_alu_op1;
wire [`E203_XLEN-1:0] bjp_req_alu_op2;
wire bjp_req_alu_cmp_eq;
wire bjp_req_alu_cmp_ne;
wire bjp_req_alu_cmp_lt;
wire bjp_req_alu_cmp_gt;
wire bjp_req_alu_cmp_ltu;
wire bjp_req_alu_cmp_gtu;
wire bjp_req_alu_add;
wire bjp_req_alu_cmp_res;
wire [`E203_XLEN-1:0] bjp_req_alu_add_res;

wire [`E203_XLEN-1:0] bjp_i_rs1 = {`E203_XLEN{bjp_op}} & i_rs1;
wire [`E203_XLEN-1:0] bjp_i_rs2 = {`E203_XLEN{bjp_op}} & i_rs2;
wire [`E203_XLEN-1:0] bjp_i_imm = {`E203_XLEN{bjp_op}} & i_imm;
wire [`E203_DECINFO_WIDTH-1:0] bjp_i_info = {`E203_DECINFO_WIDTH{bjp_op}} & i_info;
wire [`E203_PC_SIZE-1:0] bjp_i_pc = {`E203_PC_SIZE{bjp_op}} & i_pc;

e203_exu_alu_bjp u_e203_exu_alu_bjp(
  .bjp_i_valid(bjp_i_valid),
  .bjp_i_ready(bjp_i_ready),
  .bjp_i_rs1(bjp_i_rs1),
  .bjp_i_rs2(bjp_i_rs2),
  .bjp_i_info(bjp_i_info[`E203_DECINFO_BJP_WIDTH-1:0]),
  .bjp_i_imm(bjp_i_imm),
  .bjp_i_pc(bjp_i_pc),

  .bjp_o_valid(bjp_o_valid),
  .bjp_o_ready(bjp_o_ready),
  .bjp_o_wbck_wdat(bjp_o_wbck_wdat),
  .bjp_o_wbck_err(bjp_o_wbck_err),

  .bjp_o_cmt_bjp(bjp_o_cmt_bjp),
  .bjp_o_cmt_mret(bjp_o_cmt_mret),
  .bjp_o_cmt_dret(bjp_o_cmt_dret),
  .bjp_o_cmt_fencei(bjp_o_cmt_fencei),
  .bjp_o_cmt_prdt(bjp_o_cmt_prdt),
  .bjp_o_cmt_rslv(bjp_o_cmt_rslv),

  .bjp_req_alu_op1(bjp_req_alu_op1),
  .bjp_req_alu_op2(bjp_req_alu_op2),
  .bjp_req_alu_cmp_eq(bjp_req_alu_cmp_eq),
  .bjp_req_alu_cmp_ne(bjp_req_alu_cmp_ne),
  .bjp_req_alu_cmp_lt(bjp_req_alu_cmp_lt),
  .bjp_req_alu_cmp_gt(bjp_req_alu_cmp_gt),
  .bjp_req_alu_cmp_ltu(bjp_req_alu_cmp_ltu),
  .bjp_req_alu_cmp_gtu(bjp_req_alu_cmp_gtu),
  .bjp_req_alu_add(bjp_req_alu_add),
  .bjp_req_alu_cmp_res(bjp_req_alu_cmp_res),
  .bjp_req_alu_add_res(bjp_req_alu_add_res),

  .clk(clk),
  .rst_n(rst_n)
);

wire agu_o_valid;
wire agu_o_ready;

wire [`E203_XLEN-1:0] agu_o_wbck_wdat;
wire agu_o_wbck_err;

wire agu_o_cmt_misalgn;
wire agu_o_cmt_ld;
wire agu_o_cmt_stamo;
wire agu_o_cmt_buserr;
wire [`E203_ADDR_SIZE-1:0] agu_o_cmt_badaddr;

wire [`E203_XLEN-1:0] agu_req_alu_op1;
wire [`E203_XLEN-1:0] agu_req_alu_op2;
wire agu_req_alu_swap;
wire agu_req_alu_add;
wire agu_req_alu_and;
wire agu_req_alu_or;
wire agu_req_alu_xor;
wire agu_req_alu_max;
wire agu_req_alu_min;
wire agu_req_alu_maxu;
wire agu_req_alu_minu;
wire [`E203_XLEN-1:0] agu_req_alu_res;

wire agu_sbf_0_ena;
wire [`E203_XLEN-1:0] agu_sbf_0_nxt;
wire [`E203_XLEN-1:0] agu_sbf_0_r;
wire agu_sbf_1_ena;
wire [`E203_XLEN-1:0] agu_sbf_1_nxt;
wire [`E203_XLEN-1:0] agu_sbf_1_r;

wire [`E203_XLEN-1:0] agu_i_rs1 = {`E203_XLEN{agu_op}} & i_rs1;
wire [`E203_XLEN-1:0] agu_i_rs2 = {`E203_XLEN{agu_op}} & i_rs2;
wire [`E203_XLEN-1:0] agu_i_imm = {`E203_XLEN{agu_op}} & i_imm;
wire [`E203_DECINFO_WIDTH-1:0] agu_i_info = {`E203_DECINFO_WIDTH{agu_op}} & i_info;
wire [`E203_PC_SIZE-1:0] agu_i_itag = {`E203_PC_SIZE{agu_op}} & i_itag;

e203_exu_alu_lsuagu u_e203_exu_alu_lsuagu(
  .agu_i_valid(agu_i_valid),
  .agu_i_ready(agu_i_ready),
  .agu_i_rs1(agu_i_rs1),
  .agu_i_rs2(agu_i_rs2),
  .agu_i_imm(agu_i_imm),
  .agu_i_info(agu_i_info[`E203_DECINFO_AGU_WIDTH-1:0]),
  .agu_i_longpipe(agu_i_longpipe),
  .agu_i_itag(agu_i_itag),

  .flush_pulse(flush_pulse),
  .flush_req(flush_req),
  .amo_wait(amo_wait),
  .oitf_empty(oitf_empty),

  .agu_o_valid(agu_o_valid),
  .agu_o_ready(agu_o_ready),
  .agu_o_wbck_wdat(agu_o_wbck_wdat),
  .agu_o_wbck_err(agu_o_wbck_err),
  .agu_o_cmt_misalgn(agu_o_cmt_misalgn),
  .agu_o_cmt_ld(agu_o_cmt_ld),
  .agu_o_cmt_stamo(agu_o_cmt_stamo),
  .agu_o_cmt_buserr(agu_o_cmt_buserr),
  .agu_o_cmt_badaddr(agu_o_cmt_badaddr),

  .agu_icb_cmd_valid(agu_icb_cmd_valid),
  .agu_icb_cmd_ready(agu_icb_cmd_ready),
  .agu_icb_cmd_addr(agu_icb_cmd_addr),
  .agu_icb_cmd_read(agu_icb_cmd_read),
  .agu_icb_cmd_wdata(agu_icb_cmd_wdata),
  .agu_icb_cmd_wmask(agu_icb_cmd_wmask),
  .agu_icb_cmd_lock(agu_icb_cmd_lock),
  .agu_icb_cmd_excl(agu_icb_cmd_excl),
  .agu_icb_cmd_size(agu_icb_cmd_size),
  .agu_icb_cmd_back2agu(agu_icb_cmd_back2agu),
  .agu_icb_cmd_usign(agu_icb_cmd_usign),
  .agu_icb_cmd_itag(agu_icb_cmd_itag),

  .agu_icb_rsp_valid(agu_icb_rsp_valid),
  .agu_icb_rsp_ready(agu_icb_rsp_ready),
  .agu_icb_rsp_err(agu_icb_rsp_err),
  .agu_icb_rsp_excl_ok(agu_icb_rsp_excl_ok),
  .agu_icb_rsp_rdata(agu_icb_rsp_rdata),

  .agu_req_alu_op1(agu_req_alu_op1),
  .agu_req_alu_op2(agu_req_alu_op2),
  .agu_req_alu_swap(agu_req_alu_swap),
  .agu_req_alu_add(agu_req_alu_add),
  .agu_req_alu_and(agu_req_alu_and),
  .agu_req_alu_or(agu_req_alu_or),
  .agu_req_alu_xor(agu_req_alu_xor),
  .agu_req_alu_max(agu_req_alu_max),
  .agu_req_alu_min(agu_req_alu_min),
  .agu_req_alu_maxu(agu_req_alu_maxu),
  .agu_req_alu_minu(agu_req_alu_minu),
  .agu_req_alu_res(agu_req_alu_res),

  .agu_sbf_0_ena(agu_sbf_0_ena),
  .agu_sbf_0_nxt(agu_sbf_0_nxt),
  .agu_sbf_0_r(agu_sbf_0_r),

  .agu_sbf_1_ena(agu_sbf_1_ena),
  .agu_sbf_1_nxt(agu_sbf_1_nxt),
  .agu_sbf_1_r(agu_sbf_1_r),

  .clk(clk),
  .rst_n(rst_n)
);

wire alu_o_valid;
wire alu_o_ready;
wire [`E203_XLEN-1:0] alu_o_wbck_wdat;
wire alu_o_wbck_err;
wire alu_o_cmt_ecall;
wire alu_o_cmt_ebreak;
wire alu_o_cmt_wfi;

wire alu_req_alu_add;
wire alu_req_alu_sub;
wire alu_req_alu_xor;
wire alu_req_alu_sll;
wire alu_req_alu_srl;
wire alu_req_alu_sra;
wire alu_req_alu_or;
wire alu_req_alu_and;
wire alu_req_alu_slt;
wire alu_req_alu_sltu;
wire alu_req_alu_lui;
wire [`E203_XLEN-1:0] alu_req_alu_op1;
wire [`E203_XLEN-1:0] alu_req_alu_op2;
wire [`E203_XLEN-1:0] alu_req_alu_res;

wire [`E203_XLEN-1:0] alu_i_rs1 = {`E203_XLEN{alu_op}} & i_rs1;
wire [`E203_XLEN-1:0] alu_i_rs2 = {`E203_XLEN{alu_op}} & i_rs2;
wire [`E203_XLEN-1:0] alu_i_imm = {`E203_XLEN{alu_op}} & i_imm;
wire [`E203_DECINFO_WIDTH-1:0] alu_i_info = {`E203_DECINFO_WIDTH{alu_op}} & i_info;
wire [`E203_PC_SIZE-1:0] alu_i_pc = {`E203_PC_SIZE{alu_op}} & i_pc;

e203_exu_alu_rglr u_e203_exu_alu_rglr(
  .alu_i_valid(alu_i_valid),
  .alu_i_ready(alu_i_ready),
  .alu_i_rs1(alu_i_rs1),
  .alu_i_rs2(alu_i_rs2),
  .alu_i_info(alu_i_info),
  .alu_i_imm(alu_i_imm),
  .alu_i_pc(alu_i_pc),

  .alu_o_valid(alu_o_valid),
  .alu_o_ready(alu_o_ready),
  .alu_o_wbck_wdat(alu_o_wbck_wdat),
  .alu_o_wbck_err(alu_o_wbck_err),
  .alu_o_cmt_ecall(alu_o_cmt_ecall),
  .alu_o_cmt_ebreak(alu_o_cmt_ebreak),
  .alu_o_cmt_wfi(alu_o_cmt_wfi),

  .alu_req_alu_add(alu_req_alu_add),
  .alu_req_alu_sub(alu_req_alu_sub),
  .alu_req_alu_xor(alu_req_alu_xor),
  .alu_req_alu_sll(alu_req_alu_sll),
  .alu_req_alu_srl(alu_req_alu_srl),
  .alu_req_alu_sra(alu_req_alu_sra),
  .alu_req_alu_or(alu_req_alu_or),
  .alu_req_alu_and(alu_req_alu_and),
  .alu_req_alu_slt(alu_req_alu_slt),
  .alu_req_alu_sltu(alu_req_alu_sltu),
  .alu_req_alu_lui(alu_req_alu_lui),
  .alu_req_alu_op1(alu_req_alu_op1),
  .alu_req_alu_op2(alu_req_alu_op2),
  .alu_req_alu_res(alu_req_alu_res),

  .clk(clk),
  .rst_n(rst_n)
);

`ifdef E203_SUPPORT_SHARE_MULDIV
wire [`E203_XLEN-1:0] mdv_i_rs1 = {`E203_XLEN{mdv_op}} & i_rs1;
wire [`E203_XLEN-1:0] mdv_i_rs2 = {`E203_XLEN{mdv_op}} & i_rs2;
wire [`E203_XLEN-1:0] mdv_i_imm = {`E203_XLEN{mdv_op}} & i_imm;
wire [`E203_DECINFO_WIDTH-1:0] mdv_i_info = {`E203_DECINFO_WIDTH{mdv_op}} & i_info;
wire [`E203_PC_SIZE-1:0] mdv_i_itag = {`E203_PC_SIZE{mdv_op}} & i_itag;

wire mdv_o_valid;
wire mdv_o_ready;
wire [`E203_XLEN-1:0] mdv_o_wbck_wdat;
wire mdv_o_wbck_err;

wire [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op1;
wire [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op2;
wire muldiv_req_alu_add;
wire muldiv_req_alu_sub;
wire [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_res;

wire muldiv_sbf_0_ena;
wire [32:0] muldiv_sbf_0_nxt;
wire [32:0] muldiv_sbf_0_r;

wire muldiv_sbf_1_ena;
wire [32:0] muldiv_sbf_1_nxt;
wire [32:0] muldiv_sbf_1_r;

e203_exu_alu_muldiv u_e203_exu_alu_muldiv(
  .mdv_nob2b(mdv_nob2b),

  .muldiv_i_valid(mdv_i_valid),
  .muldiv_i_ready(mdv_i_ready),

  .muldiv_i_rs1(mdv_i_rs1),
  .muldiv_i_rs2(mdv_i_rs2),
  .muldiv_i_imm(mdv_i_imm),
  .muldiv_i_info(mdv_i_info[`E203_DECINFO_MULDIV_WIDTH-1:0]),
  .muldiv_i_longpipe(mdv_i_longpipe),
  .muldiv_i_itag(mdv_i_itag),

  .flush_pulse(flush_pulse),

  .muldiv_o_valid(mdv_o_valid),
  .muldiv_o_ready(mdv_o_ready),
  .muldiv_o_wbck_wdat(mdv_o_wbck_wdat),
  .muldiv_o_wbck_err(mdv_o_wbck_err),

  .muldiv_req_alu_op1(muldiv_req_alu_op1),
  .muldiv_req_alu_op2(muldiv_req_alu_op2),
  .muldiv_req_alu_add(muldiv_req_alu_add),
  .muldiv_req_alu_sub(muldiv_req_alu_sub),
  .muldiv_req_alu_res(muldiv_req_alu_res),

  .muldiv_sbf_0_ena(muldiv_sbf_0_ena),
  .muldiv_sbf_0_nxt(muldiv_sbf_0_nxt),
  .muldiv_sbf_0_r(muldiv_sbf_0_r),

  .muldiv_sbf_1_ena(muldiv_sbf_1_ena),
  .muldiv_sbf_1_nxt(muldiv_sbf_1_nxt),
  .muldiv_sbf_1_r(muldiv_sbf_1_r),

  .clk(clk),
  .rst_n(rst_n)
);
`endif

wire alu_req_alu = alu_op & i_rdwen;
`ifdef E203_SUPPORT_SHARE_MULDIV
wire muldiv_req_alu = mdv_op;
`endif
wire bjp_req_alu = bjp_op;
wire agu_req_alu= agu_op;

e203_exu_alu_dpath e203_exu_alu_dpath(
  .alu_req_alu(alu_req_alu),
  .alu_req_alu_add(alu_req_alu_add),
  .alu_req_alu_sub(alu_req_alu_sub),
  .alu_req_alu_xor(alu_req_alu_xor),
  .alu_req_alu_sll(alu_req_alu_sll),
  .alu_req_alu_srl(alu_req_alu_srl),
  .alu_req_alu_sra(alu_req_alu_sra),
  .alu_req_alu_or(alu_req_alu_or),
  .alu_req_alu_and(alu_req_alu_and),
  .alu_req_alu_slt(alu_req_alu_slt),
  .alu_req_alu_sltu(alu_req_alu_sltu),
  .alu_req_alu_lui(alu_req_alu_lui),
  .alu_req_alu_op1(alu_req_alu_op1),
  .alu_req_alu_op2(alu_req_alu_op2),
  .alu_req_alu_res(alu_req_alu_res),

  .bjp_req_alu(bjp_req_alu),
  .bjp_req_alu_op1(bjp_req_alu_op1),
  .bjp_req_alu_op2(bjp_req_alu_op2),
  .bjp_req_alu_cmp_eq(bjp_req_alu_cmp_eq),
  .bjp_req_alu_cmp_ne(bjp_req_alu_cmp_ne),
  .bjp_req_alu_cmp_lt(bjp_req_alu_cmp_lt),
  .bjp_req_alu_cmp_gt(bjp_req_alu_cmp_gt),
  .bjp_req_alu_cmp_ltu(bjp_req_alu_cmp_ltu),
  .bjp_req_alu_cmp_gtu(bjp_req_alu_cmp_gtu),
  .bjp_req_alu_add(bjp_req_alu_add),
  .bjp_req_alu_cmp_res(bjp_req_alu_cmp_res),
  .bjp_req_alu_add_res(bjp_req_alu_add_res),

  .agu_req_alu(agu_req_alu),
  .agu_req_alu_op1(agu_req_alu_op1),
  .agu_req_alu_op2(agu_req_alu_op2),
  .agu_req_alu_swap(agu_req_alu_swap),
  .agu_req_alu_add(agu_req_alu_add),
  .agu_req_alu_and(agu_req_alu_and),
  .agu_req_alu_or(agu_req_alu_or),
  .agu_req_alu_xor(agu_req_alu_xor),
  .agu_req_alu_max(agu_req_alu_max),
  .agu_req_alu_min(agu_req_alu_min),
  .agu_req_alu_maxu(agu_req_alu_maxu),
  .agu_req_alu_minu(agu_req_alu_minu),
  .agu_req_alu_res(agu_req_alu_res),

  .agu_sbf_0_ena(agu_sbf_0_ena),
  .agu_sbf_0_nxt(agu_sbf_0_nxt),
  .agu_sbf_0_r(agu_sbf_0_r),

  .agu_sbf_1_ena(agu_sbf_1_ena),
  .agu_sbf_1_nxt(agu_sbf_1_nxt),
  .agu_sbf_1_r(agu_sbf_1_r),

`ifdef E203_SUPPORT_SHARE_MULDIV
  .muldiv_req_alu(muldiv_req_alu),

  .muldiv_req_alu_op1(muldiv_req_alu_op1),
  .muldiv_req_alu_op2(muldiv_req_alu_op2),
  .muldiv_req_alu_add(muldiv_req_alu_add),
  .muldiv_req_alu_sub(muldiv_req_alu_sub),
  .muldiv_req_alu_res(muldiv_req_alu_res),

  .muldiv_sbf_0_ena(muldiv_sbf_0_ena),
  .muldiv_sbf_0_nxt(muldiv_sbf_0_nxt),
  .muldiv_sbf_0_r(muldiv_sbf_0_r),

  .muldiv_sbf_1_ena(muldiv_sbf_1_ena),
  .muldiv_sbf_1_nxt(muldiv_sbf_1_nxt),
  .muldiv_sbf_1_r(muldiv_sbf_1_r),
`endif

  .clk(clk),
  .rst_n(rst_n)
);

wire ifu_excp_o_valid;
wire ifu_excp_o_ready;
wire [`E203_XLEN-1:0] ifu_excp_o_wbck_wdat;
wire ifu_excp_o_wbck_err;

assign ifu_excp_i_ready = ifu_excp_o_ready;
assign ifu_excp_o_valid = ifu_excp_i_valid;
assign ifu_excp_o_wbck_wdat = `E203_XLEN'b0;
assign ifu_excp_o_wbck_err = 1'b1; // TODO: why always is 1

wire o_valid;
wire o_ready;

wire o_sel_ifu_excp = ifu_excp_op;
wire o_sel_alu = alu_op;
wire o_sel_bjp = bjp_op;
wire o_sel_csr = csr_op;
wire o_sel_agu = agu_op;
`ifdef E203_SUPPORT_SHARE_MULDIV
wire o_sel_mdv = mdv_op;
`endif

assign o_valid = (o_sel_alu & alu_o_valid) |
                 (o_sel_bjp & bjp_o_valid) |
                 (o_sel_csr & csr_o_valid) |
                 (o_sel_agu & agu_o_valid) |
                 `ifdef E203_SUPPORT_SHARE_MULDIV
                 (o_sel_mdv & mdv_o_valid) |
                 `endif
                 (o_sel_ifu_excp & ifu_excp_o_valid);

assign ifu_excp_o_ready = o_sel_ifu_excp & o_ready;
assign alu_o_ready = o_sel_alu & o_ready;
assign agu_o_ready = o_sel_agu & o_ready;
`ifdef E203_SUPPORT_SHARE_MULDIV
assign mdv_o_ready = o_sel_mdv & o_ready;
`endif
assign bjp_o_ready = o_sel_bjp & o_ready;
assign csr_o_ready = o_sel_csr & o_ready;

assign wbck_o_wdat = ({`E203_XLEN{o_sel_alu}} & alu_o_wbck_wdat) |
                    `ifdef E203_SUPPORT_SHARE_MULDIV
                     ({`E203_XLEN{o_sel_mdv}} & mdv_o_wbck_wdat) |
                    `endif
                     ({`E203_XLEN{o_sel_bjp}} & bjp_o_wbck_wdat) |
                     ({`E203_XLEN{o_sel_csr}} & csr_o_wbck_wdat) |
                     ({`E203_XLEN{o_sel_agu}} & agu_o_wbck_wdat) |
                     ({`E203_XLEN{o_sel_ifu_excp}} & ifu_excp_o_wbck_wdat);

assign wbck_o_rdidx = i_rdidx;

wire wbck_o_rdwen = i_rdwen;

wire wbck_o_err = ({1{o_sel_alu}} & alu_o_wbck_err) |
                  ({1{o_sel_bjp}} & bjp_o_wbck_err) |
                  `ifdef E203_SUPPORT_SHARE_MULDIV
                  ({1{o_sel_mdv}} & mdv_o_wbck_err) |
                  `endif
                  ({1{o_sel_csr}} & csr_o_wbck_err) |
                  ({1{o_sel_agu}} & agu_o_wbck_err) |
                  ({1{o_sel_ifu_excp}} & ifu_excp_o_wbck_err);

wire o_need_wbck = wbck_o_rdwen & (~i_longpipe) & (~wbck_o_err);
wire o_need_cmt = 1'b1;
assign o_ready = (o_need_cmt ? cmt_o_ready : 1'b1) &
                 (o_need_wbck ? wbck_o_ready : 1'b1);

assign wbck_o_valid = o_need_wbck & o_valid & (o_need_cmt ? cmt_o_ready : 1'b1);
assign cmt_o_valid = o_need_cmt & o_valid & (o_need_wbck ? wbck_o_ready : 1'b1);

assign cmt_o_instr = i_instr;
assign cmt_o_pc = i_pc;
assign cmt_o_imm = i_imm;
assign cmt_o_rv32 = i_info[`E203_DECINFO_RV32];

assign cmt_o_pc_vld = i_pc_vld;

assign cmt_o_misalgn = (o_sel_agu & agu_o_cmt_misalgn);
assign cmt_o_ld = (o_sel_agu & agu_o_cmt_ld);
assign cmt_o_badaddr = ({`E203_ADDR_SIZE{o_sel_agu}} & agu_o_cmt_badaddr);
assign cmt_o_buserr = o_sel_agu & agu_o_cmt_buserr;
assign cmt_o_stamo = o_sel_agu & agu_o_cmt_stamo;

assign cmt_o_bjp = o_sel_bjp & bjp_o_cmt_bjp;
assign cmt_o_mret = o_sel_bjp & bjp_o_cmt_mret;
assign cmt_o_dret = o_sel_bjp & bjp_o_cmt_dret;
assign cmt_o_bjp_prdt = o_sel_bjp & bjp_o_cmt_prdt;
assign cmt_o_bjp_rslv = o_sel_bjp & bjp_o_cmt_rslv;
assign cmt_o_fencei = o_sel_bjp & bjp_o_cmt_fencei;

assign cmt_o_ecall = o_sel_alu & alu_o_cmt_ecall;
assign cmt_o_ebreak = o_sel_alu & alu_o_cmt_ebreak;
assign cmt_o_wfi = o_sel_alu & alu_o_cmt_wfi;
assign cmt_o_ifu_misalgn = i_misalgn;
assign cmt_o_ifu_buserr = i_buserr;
assign cmt_o_ifu_ilegl = i_ilegl | (o_sel_csr & csr_access_ilgl);

endmodule