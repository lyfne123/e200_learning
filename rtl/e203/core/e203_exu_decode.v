`include "e203_defines.v"

module e203_exu_decode(
  input [`E203_INSTR_SIZE-1:0] i_instr, // 指令
  input [`E203_PC_SIZE-1:0] i_pc, // pc值
  input i_prdt_taken,
  input i_misalgn, // 非对齐异常
  input i_buserr, // 取指存储器访问错误
  input i_muldiv_b2b,
  input dbg_mode,

  output dec_rs1x0, // 源操作数1的寄存器索引为x0
  output dec_rs2x0, // 源操作数2的寄存器索引为x0
  output dec_rs1en, // 该指令需要读取源操作数1
  output dec_rs2en, // 该指令需要读取源操作数2
  output dec_rdwen, // 该指令需要读取结果操作数
  output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx, // 该指令源操作数1的寄存器索引
  output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx, // 该指令源操作数2的寄存器索引
  output [`E203_RFIDX_WIDTH-1:0] dec_rdidx, // 该指令结果的寄存器索引
  output [`E203_DECINFO_WIDTH-1:0] dec_info, // 其他信息，打包成一组宽信号
  output [`E203_XLEN-1:0] dec_imm, // 该指令使用的立即数
  output [`E203_PC_SIZE-1:0] dec_pc,
  output dec_misalgn, // 译码后发现本指令是个非法指令
  output dec_buserr,
  output dec_ilegl,

  output dec_mulhsu,
  output dec_mul,
  output dec_div,
  output dec_rem,
  output dec_divu,
  output dec_remu,

  output dec_rv32,
  output dec_bjp,
  output dec_jal,
  output dec_jalr,
  output dec_bxx,

  output [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,
  output [`E203_XLEN-1:0] dec_bjp_imm
);

wire [31:0] rv32_instr = i_instr;
wire [15:0] rv16_instr = i_instr[15:0];

wire [6:0] opcode = rv32_instr[6:0];

wire opcode_1_0_00 = (opcode[1:0] == 2'b00);
wire opcode_1_0_01 = (opcode[1:0] == 2'b01);
wire opcode_1_0_10 = (opcode[1:0] == 2'b10);
wire opcode_1_0_11 = (opcode[1:0] == 2'b11);

wire rv32 = (~(i_instr[4:2] == 3'b111)) & opcode_1_0_11;

wire [4:0] rv32_rd = rv32_instr[11:7];
wire [2:0] rv32_func3 = rv32_instr[14:12];
wire [4:0] rv32_rs1 = rv32_instr[19:15];
wire [4:0] rv32_rs2 = rv32_instr[24:20];
wire [6:0] rv32_func7 = rv32_instr[31:25];

wire [4:0] rv16_rd = rv32_rd;
wire [4:0] rv16_rs1 = rv16_rd;
wire [4:0] rv16_rs2 = rv32_instr[6:2];

wire [4:0] rv16_rdd = {2'b01, rv32_instr[4:2]};
wire [4:0] rv16_rss1 = {2'b01, rv32_instr[9:7]};
wire [4:0] rv16_rss2 = rv16_rdd;

wire [2:0] rv16_func3 = rv32_instr[15:13];

wire opcode_4_2_000 = (opcode[4:2] == 3'b000);
wire opcode_4_2_001 = (opcode[4:2] == 3'b001);
wire opcode_4_2_010 = (opcode[4:2] == 3'b010);
wire opcode_4_2_011 = (opcode[4:2] == 3'b011);
wire opcode_4_2_100 = (opcode[4:2] == 3'b100);
wire opcode_4_2_101 = (opcode[4:2] == 3'b101);
wire opcode_4_2_110 = (opcode[4:2] == 3'b110);
wire opcode_4_2_111 = (opcode[4:2] == 3'b111);

wire opcode_6_5_00 = (opcode[6:5] == 2'b00);
wire opcode_6_5_01 = (opcode[6:5] == 2'b01);
wire opcode_6_5_10 = (opcode[6:5] == 2'b10);
wire opcode_6_5_11 = (opcode[6:5] == 2'b11);

wire rv32_func3_000 = (rv32_func3 == 3'b000);
wire rv32_func3_001 = (rv32_func3 == 3'b001);
wire rv32_func3_010 = (rv32_func3 == 3'b010);
wire rv32_func3_011 = (rv32_func3 == 3'b011);
wire rv32_func3_100 = (rv32_func3 == 3'b100);
wire rv32_func3_101 = (rv32_func3 == 3'b101);
wire rv32_func3_110 = (rv32_func3 == 3'b110);
wire rv32_func3_111 = (rv32_func3 == 3'b111);

wire rv16_func3_000 = (rv16_func3 == 3'b000);
wire rv16_func3_001 = (rv16_func3 == 3'b001);
wire rv16_func3_010 = (rv16_func3 == 3'b010);
wire rv16_func3_011 = (rv16_func3 == 3'b011);
wire rv16_func3_100 = (rv16_func3 == 3'b100);
wire rv16_func3_101 = (rv16_func3 == 3'b101);
wire rv16_func3_110 = (rv16_func3 == 3'b110);
wire rv16_func3_111 = (rv16_func3 == 3'b111);

wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000);
wire rv32_func7_0100000 = (rv32_func7 == 7'b0100000);
wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001);
wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101);
wire rv32_func7_0001001 = (rv32_func7 == 7'b0001001);
wire rv32_func7_0001101 = (rv32_func7 == 7'b0001101);
wire rv32_func7_0010101 = (rv32_func7 == 7'b0010101);
wire rv32_func7_0100001 = (rv32_func7 == 7'b0100001);
wire rv32_func7_0010001 = (rv32_func7 == 7'b0010001);
wire rv32_func7_0101101 = (rv32_func7 == 7'b0101101);
wire rv32_func7_1111111 = (rv32_func7 == 7'b1111111);
wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100);
wire rv32_func7_0001000 = (rv32_func7 == 7'b0001000);
wire rv32_func7_0001100 = (rv32_func7 == 7'b0001100);
wire rv32_func7_0101100 = (rv32_func7 == 7'b0101100);
wire rv32_func7_0010000 = (rv32_func7 == 7'b0010000);
wire rv32_func7_0010100 = (rv32_func7 == 7'b0010100);
wire rv32_func7_1100000 = (rv32_func7 == 7'b1100000);
wire rv32_func7_1110000 = (rv32_func7 == 7'b1110000);
wire rv32_func7_1010000 = (rv32_func7 == 7'b1010000);
wire rv32_func7_1101000 = (rv32_func7 == 7'b1101000);
wire rv32_func7_1111000 = (rv32_func7 == 7'b1111000);
wire rv32_func7_1010001 = (rv32_func7 == 7'b1010001);
wire rv32_func7_1110001 = (rv32_func7 == 7'b1110001);
wire rv32_func7_1100001 = (rv32_func7 == 7'b1100001);
wire rv32_func7_1101001 = (rv32_func7 == 7'b1101001);

wire rv32_rs1_x0 = (rv32_rs1 == 5'b00000);
wire rv32_rs2_x0 = (rv32_rs2 == 5'b00000);
wire rv32_rs2_x1 = (rv32_rs2 == 5'b00001);
wire rv32_rd_x0 = (rv32_rd == 5'b00000);
wire rv32_rd_x2 = (rv32_rd == 5'b00010);

wire rv16_rs1_x0 = (rv16_rs1 == 5'b00000);
wire rv16_rs2_x0 = (rv16_rs2 == 5'b00000);
wire rv16_rd_x0 = (rv16_rd == 5'b00000);
wire rv16_rd_x2 = (rv16_rd == 5'b00010);

wire rv32_load = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11;
wire rv32_store = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11;
wire rv32_madd = opcode_6_5_10 & opcode_4_2_000 & opcode_1_0_11;
wire rv32_branch = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11;

wire rv32_load_fp = opcode_6_5_00 & opcode_4_2_001 & opcode_1_0_11;
wire rv32_store_fp = opcode_6_5_01 & opcode_4_2_001 & opcode_1_0_11;
wire rv32_msub = opcode_6_5_10 & opcode_4_2_001 & opcode_1_0_11;
wire rv32_jalr = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11;

wire rv32_custom0 = opcode_6_5_00 & opcode_4_2_010 & opcode_1_0_11;
wire rv32_custom1 = opcode_6_5_01 & opcode_4_2_010 & opcode_1_0_11;
wire rv32_msub = opcode_6_5_10 & opcode_4_2_010 & opcode_1_0_11;
wire rv32_jalr = opcode_6_5_11 & opcode_4_2_010 & opcode_1_0_11;

wire rv32_miscmem = opcode_6_5_00 & opcode_4_2_011 & opcode_1_0_11;
`ifdef E203_SUPPORT_AMO
wire rv32_amo = opcode_6_5_01 & opcode_4_2_011 & opcode_1_0_11;
`endif
`ifndef E203_SUPPORT_AMO
wire rv32_amo = 1'b0;
`endif
wire rv32_nmadd = opcode_6_5_10 & opcode_4_2_011 & opcode_1_0_11;
wire rv32_jal = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11;

wire rv32_op_imm = opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11;
wire rv32_op = opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11;
wire rv32_op_fp = opcode_6_5_10 & opcode_4_2_100 & opcode_1_0_11;
wire rv32_system = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11;

wire rv32_auipc = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11;
wire rv32_lui = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11;
wire rv32_resved1 = opcode_6_5_10 & opcode_4_2_101 & opcode_1_0_11;
wire rv32_resved2 = opcode_6_5_11 & opcode_4_2_101 & opcode_1_0_11;

wire rv32_op_imm_32 = opcode_6_5_00 & opcode_4_2_110 & opcode_1_0_11;
wire rv32_op_32 = opcode_6_5_01 & opcode_4_2_110 & opcode_1_0_11;
wire rv32_custom2 = opcode_6_5_10 & opcode_4_2_110 & opcode_1_0_11;
wire rv32_custom3 = opcode_6_5_11 & opcode_4_2_110 & opcode_1_0_11;

wire rv16_addi4spn = opcode_1_0_00 & rv16_func3_000;
wire rv16_lw = opcode_1_0_00 & rv16_func3_010;
wire rv16_sw = opcode_1_0_00 & rv16_func3_110;

wire rv16_addi = opcode_1_0_01 & rv16_func3_000;
wire rv16_jal = opcode_1_0_01 & rv16_func3_001;
wire rv16_li = opcode_1_0_01 & rv16_func3_010;
wire rv16_lui_addi16sp = opcode_1_0_01 & rv16_func3_011;
wire rv16_miscalu = opcode_1_0_01 & rv16_func3_100;
wire rv16_j = opcode_1_0_01 & rv16_func3_101;
wire rv16_beqz = opcode_1_0_01 & rv16_func3_110;
wire rv16_bnez = opcode_1_0_01 & rv16_func3_111;

wire rv16_slli = opcode_1_0_10 & rv16_func3_000;
wire rv16_lwsp = opcode_1_0_10 & rv16_func3_010;
wire rv16_jalr_mv_add = opcode_1_0_10 & rv16_func3_100;
wire rv16_swsp = opcode_1_0_10 & rv16_func3_110;

wire rv16_lwsp_ilgl = rv16_lwsp & rv16_rd_x0;

wire rv16_nop = rv16_addi & (~rv16_instr[12]) & rv16_rd_x0 &rv16_rs2_x0;

wire rv16_srli = rv16_miscalu & (rv16_instr[11:10] == 2'b00);
wire rv16_srai = rv16_miscalu & (rv16_instr[11:10] == 2'b01);
wire rv16_andi = rv16_miscalu & (rv16_instr[11:10] == 2'b10);

wire rv16_instr_12_is0 = (rv16_instr[12] == 1'b0);
wire rv16_instr_6_2_is0s = (rv16_instr[6:2] == 5'b0);

wire rv16_sxxi_shamt_legl = rv16_instr_12_is0 & (~rv16_instr_6_2_is0s);
wire rv16_sxxi_shamt_ilgl = (rv16_slli | rv16_srli | rv16_srai) & (~rv16_sxxi_shamt_legl);

wire rv32_mret = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0011_0000_0010);
wire rv32_dret = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0111_1011_0010);
wire rv32_wfi = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0001_0000_0101);

wire rv16_addi16sp = rv16_lui_addi16sp & rv32_rd_x2;
wire rv16_lui = rv16_lui_addi16sp & (~rv32_rd_x0) & (~rv32_rd_x2);

wire rv16_li_ilgl = rv16_li & rv16_rd_x0;
wire rv16_lui_ilgl = rv16_lui & (rv16_rd_x0 | rv16_rd_x2 | (rv16_instr_6_2_is0s & rv16_instr_12_is0));

wire rv16_li_lui_ilgl = rv16_li_ilgl | rv16_lui_ilgl;

wire rv16_addi4spn_ilgl = rv16_addi4spn & rv16_instr_12_is0 & rv16_rd_x0 & opcode_6_5_00;
wire rv16_addi16sp_ilgl = rv16_addi16sp & rv16_instr_12_is0 &rv16_instr_6_2_is0s;

wire rv16_jr = rv16_jalr_mv_add & (~rv16_instr[12]) & (~rv16_rs1_x0) & rv16_rs2_x0;
wire rv16_mv = rv16_jalr_mv_add & (~rv16_instr[12]) & (~rv16_rd_x0) & (~rv16_rs2_x0);
wire rv16_ebreak = rv16_jalr_mv_add & rv16_instr[12] & rv16_rd_x0 & rv16_rs2_x0;
wire rv16_jalr = rv16_jalr_mv_add & rv16_instr[12] & (~rv16_rs1_x0) & rv16_rs2_x0;
wire rv16_add = rv16_jalr_mv_add & rv16_instr[12] & (~rv16_rd_x0) & (~rv16_rs2_x0);

wire rv32_ecall = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0000_0000_0000);
wire rv32_ebreak = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0000_0000_0001);
wire rv32_mret = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0011_0000_0010);
wire rv32_dret = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0111_1011_0010);
wire rv32_wfi = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0001_0000_0101);

wire rv32_csrrw = rv32_system & rv32_func3_001;
wire rv32_csrrs = rv32_system & rv32_func3_010;
wire rv32_csrrc = rv32_system & rv32_func3_011;
wire rv32_csrrwi = rv32_system & rv32_func3_101;
wire rv32_csrrsi = rv32_system & rv32_func3_110;
wire rv32_csrrci = rv32_system & rv32_func3_111;

wire rv32_dret_ilgl = rv32_dret & (~dbg_mode);

wire rv32_ecall_ebreak_ret_wfi = rv32_system & rv32_func3_000;
wire rv32_csr = rv32_system & (~rv32_func3_000);

assign dec_jal = rv32_jal | rv16_jal | rv16_j;
assign dec_jalr = rv32_jalr | rv16_jalr | rv16_jr;
assign dec_bxx = rv32_branch | rv16_beqz | rv16_bnez;
assign dec_bjp = dec_jal | dec_jalr | dec_bxx;

wire rv32_fence;
wire rv32_fencei;
wire rv32_fence_fencei;
wire bjp_op = dec_bjp | rv32_mret | (rv32_dret & (~rv32_dret_ilgl)) | rv32_fence_fencei;

wire [`E203_DECINFO_BJP_WIDTH-1:0] bjp_info_bus;

wire rv32_addi = rv32_op_imm & rv32_func3_000;
wire rv32_slti = rv32_op_imm & rv32_func3_010;
wire rv32_sltiu = rv32_op_imm & rv32_func3_011;
wire rv32_xori = rv32_op_imm & rv32_func3_100;
wire rv32_ori = rv32_op_imm & rv32_func3_110;
wire rv32_andi = rv32_op_imm & rv32_func3_111;

wire rv32_slli = rv32_op_imm & rv32_func3_001 & (rv32_instr[31:26] == 6'b000000);
wire rv32_srli = rv32_op_imm & rv32_func3_101 & (rv32_instr[31:26] == 6'b000000);
wire rv32_srai = rv32_op_imm & rv32_func3_101 & (rv32_instr[31:26] == 6'b010000);

wire rv32_sxxi_shamt_legl = (rv32_instr[25] == 1'b0);
wire rv32_sxxi_shamt_ilgl = (rv32_slli | rv32_srli | rv32_srai) & (~rv32_sxxi_shamt_legl);

wire rv32_add = rv32_op & rv32_func3_000 & rv32_func7_0000000;
wire rv32_sub = rv32_op & rv32_func3_000 & rv32_func7_0100000;
wire rv32_sll = rv32_op & rv32_func3_001 & rv32_func7_0000000;
wire rv32_slt = rv32_op & rv32_func3_010 & rv32_func7_0000000;
wire rv32_sltu = rv32_op & rv32_func3_011 & rv32_func7_0000000;
wire rv32_xor = rv32_op & rv32_func3_100 & rv32_func7_0000000;
wire rv32_srl = rv32_op & rv32_func3_101 & rv32_func7_0000000;
wire rv32_sra = rv32_op & rv32_func3_101 & rv32_func7_0100000;
wire rv32_or = rv32_op & rv32_func3_110 & rv32_func7_0000000;
wire rv32_and = rv32_op & rv32_func3_111 & rv32_func7_0000000;

wire rv32_nop = rv32_addi & rv32_rs1_x0 & rv32_rd_x0 & (~(|rv32_instr[31:20]));

wire ecall_ebreak = rv32_ecall | rv32_ebreak | rv16_ebreak;

wire alu_op = (~rv32_sxxi_shamt_ilgl) & (~rv16_sxxi_shamt_ilgl)
            & (~rv16_li_lui_ilgl) & (~rv16_addi4spn_ilgl) & (~rv16_addi16sp_ilgl)
            & (rv32_op_imm
            | rv32_op & (~rv32_func7_0000001)
            | rv32_auipc
            | rv32_lui
            | rv16_addi4spn
            | rv16_addi
            | rv16_lui_addi16sp
            | rv16_li
            | rv16_mv
            | rv16_slli
            | rv16_miscalu
            | rv16_add
            | rv16_nop
            | rv32_nop
            | rv32_wfi
            | ecall_ebreak);
wire need_imm;
wire [`E203_DECINFO_ALU_WIDTH-1:0] alu_info_bus;

wire csr_op = rv32_csr;
wire [`E203_DECINFO_CSR_WIDTH-1:0] csr_info_bus;

assign rv32_fence = rv32_miscmem & rv32_func3_000;
assign rv32_fence_i = rv32_miscmem & rv32_func3_001;

assign rv32_fence_fencei = rv32_miscmem;

`ifdef E203_SUPPORT_MULDIV
wire muldiv_op = rv32_op & rv32_func7_0000001;
`endif
`ifndef E203_SUPPORT_MULDIV
wire muldiv_op = 1'b0;
`endif

wire [`E203_DECINFO_MULDIV_WIDTH-1:0] muldiv_info_bus;

`ifdef E203_SUPPORT_AMO
wire rv32_lr_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00010);
`endif
`ifndef E203_SUPPORT_AMO
wire rv32_lr_w = 1'b0;
`endif

wire amoldst_op = rv32_amo | rv32_load | rv32_store | rv16_lw | rv16_sw | (rv16_lwsp & (~rv16_lwsp_ilgl)) | rv16_swsp;
wire [`E203_DECINFO_AGU_WIDTH-1:0] agu_info_bus;

wire rv32_need_rd = (~rv32_rd_x0) & ((~rv32_branch) &
                                     (~rv32_store) &
                                     (~rv32_fence_fencei) &
                                     (~rv32_ecall_ebreak_ret_wfi));

wire rv32_need_rs1 = (~rv32_rs1_x0) & ((~rv32_lui) &
                                       (~rv32_auipc) &
                                       (~rv32_jal) &
                                       (~rv32_fence_fencei) &
                                       (~rv32_ecall_ebreak_ret_wfi) &
                                       (~rv32_csrrwi) &
                                       (~rv32_csrrsi) &
                                       (~rv32_csrrci));

wire rv32_need_rs2 = (~rv32_rs2_x0) & (rv32_branch |
                                       rv32_store |
                                       rv32_op |
                                       (rv32_amo & (~rv32_lr_w)));

assign dec_info = ({`E203_DECINFO_WIDTH{alu_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_ALU_WIDTH{1'b0}}, alu_info_bus})
                | ({`E203_DECINFO_WIDTH{amoldst_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_AGU_WIDTH{1'b0}}, agu_info_bus})
                | ({`E203_DECINFO_WIDTH{bjp_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_BJP_WIDTH{1'b0}}, bjp_info_bus})
                | ({`E203_DECINFO_WIDTH{csr_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_CSR_WIDTH{1'b0}}, csr_info_bus})
                | ({`E203_DECINFO_WIDTH{muldiv_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_CSR_WIDTH{1'b0}}, muldiv_info_bus}); // TODO: why use CSR_WIDTH

endmodule