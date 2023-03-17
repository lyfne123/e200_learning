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
  output dec_misalgn,
  output dec_buserr,
  output dec_ilegl, // 译码后发现本指令是个非法指令

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

// 是32位指令还是16位指令
wire rv32 = (~(i_instr[4:2] == 3'b111)) & opcode_1_0_11;

// 取出32位指令的关键编码段
wire [4:0] rv32_rd = rv32_instr[11:7];
wire [2:0] rv32_func3 = rv32_instr[14:12];
wire [4:0] rv32_rs1 = rv32_instr[19:15];
wire [4:0] rv32_rs2 = rv32_instr[24:20];
wire [6:0] rv32_func7 = rv32_instr[31:25];

// 取出16位指令的关键编码段
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

wire rv32_rs1_x31 = (rv32_rs1 == 5'b11111);
wire rv32_rs2_x31 = (rv32_rs2 == 5'b11111);
wire rv32_rd_x31 = (rv32_rd == 5'b11111);

// 32位指令的指令类型译码
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

// 16位指令的指令类型译码
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

`ifndef E203_HAS_FPU
wire rv16_flw = 1'b0;
wire rv16_fld = 1'b0;
wire rv16_fsw = 1'b0;
wire rv16_fsd = 1'b0;
wire rv16_fldsp = 1'b0;
wire rv16_flwsp = 1'b0;
wire rv16_fsdsp = 1'b0;
wire rv16_fswsp = 1'b0;
`endif

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

wire rv16_subxororand = rv16_miscalu & (rv16_instr[12:10] == 3'b011);
wire rv16_sub = rv16_subxororand & (rv16_instr[6:5] == 2'b00);
wire rv16_xor = rv16_subxororand & (rv16_instr[6:5] == 2'b01);
wire rv16_or = rv16_subxororand & (rv16_instr[6:5] == 2'b10);
wire rv16_and = rv16_subxororand & (rv16_instr[6:5] == 2'b11);

wire rv16_jr = rv16_jalr_mv_add & (~rv16_instr[12]) & (~rv16_rs1_x0) & rv16_rs2_x0;
wire rv16_mv = rv16_jalr_mv_add & (~rv16_instr[12]) & (~rv16_rd_x0) & (~rv16_rs2_x0);
wire rv16_ebreak = rv16_jalr_mv_add & rv16_instr[12] & rv16_rd_x0 & rv16_rs2_x0;
wire rv16_jalr = rv16_jalr_mv_add & rv16_instr[12] & (~rv16_rs1_x0) & rv16_rs2_x0;
wire rv16_add = rv16_jalr_mv_add & rv16_instr[12] & (~rv16_rd_x0) & (~rv16_rs2_x0);

wire rv32_beq = rv32_branch & rv32_func3_000;
wire rv32_bne = rv32_branch & rv32_func3_001;
wire rv32_blt = rv32_branch & rv32_func3_100;
wire rv32_bgt = rv32_branch & rv32_func3_101;
wire rv32_bltu = rv32_branch & rv32_func3_110;
wire rv32_bgtu = rv32_branch & rv32_func3_111;

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
// 生成BJP单元所需的信息总线。BJP单元是ALU的子单元
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

// 生成Regular ALU单元所需的信息总线。Regular ALU为ALU的子单元
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

// 生成CSR单元所需的信息总线。CSR为ALU的子单元
wire csr_op = rv32_csr;
wire [`E203_DECINFO_CSR_WIDTH-1:0] csr_info_bus;

assign rv32_fence = rv32_miscmem & rv32_func3_000;
assign rv32_fence_i = rv32_miscmem & rv32_func3_001;

assign rv32_fence_fencei = rv32_miscmem;

// 生成乘除法单元所需的信息总线
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

// 生成AGU单元所需的信息总线。AGU单元是ALU的一个子单元，用于处理AMO，Load和Store指令
wire amoldst_op = rv32_amo | rv32_load | rv32_store | rv16_lw | rv16_sw | (rv16_lwsp & (~rv16_lwsp_ilgl)) | rv16_swsp;
wire [`E203_DECINFO_AGU_WIDTH-1:0] agu_info_bus;

wire rv32_all0s_ilgl = rv32_func7_0000000 &
                       rv32_rs1_x0 &
                       rv32_rs2_x0 &
                       rv32_func3_000 &
                       rv32_rd_x0 &
                       opcode_6_5_00 &
                       opcode_4_2_000 &
                       (opcode[1:0] == 2'b00);

wire rv32_all1s_ilgl = rv32_func7_1111111 &
                       rv32_rs1_x31 &
                       rv32_rs2_x31 &
                       rv32_func3_111 &
                       rv32_rd_x31 &
                       opcode_6_5_11 &
                       opcode_4_2_111 &
                       (opcode[1:0] == 2'b11);

wire rv16_all0s_ilgl = rv16_func3_000 &
                       rv32_func3_000 &
                       rv32_rd_x0 &
                       opcode_6_5_00 &
                       opcode_4_2_000 &
                       (opcode[1:0] == 2'b00);

wire rv16_all1s_ilgl = rv16_func3_111 &
                       rv32_func3_111 &
                       rv32_rd_x31 &
                       opcode_6_5_11 &
                       opcode_4_2_111 &
                       (opcode[1:0] == 2'b11);

wire rv_all0s1s_ilgl = rv32 ? (rv32_all0s_ilgl | rv32_all1s_ilgl) :
                              (rv16_all0s_ilgl | rv16_all1s_ilgl);

// 是否需要读寄存器操作数1，读寄存器操作数2，是否需要写结果寄存器
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

// 32位指令的不同立即数格式
wire [31:0] rv32_i_imm = {{20{rv32_instr[31]}}, rv32_instr[31:20]};
wire [31:0] rv32_s_imm = {{20{rv32_instr[31]}}, rv32_instr[31:25], rv32_instr[11:7]};
wire [31:0] rv32_b_imm = {{19{rv32_instr[31]}}, rv32_instr[31], rv32_instr[7], rv32_instr[30:25], rv32_instr[11:8], 1'b0};
wire [31:0] rv32_u_imm = {rv32_instr[31:12], 12'b0};
wire [31:0] rv32_j_imm = {{11{rv32_instr[31]}}, rv32_instr[31], rv32_instr[19:12], rv32_instr[20], rv32_instr[30:21], 1'b0};

wire rv32_imm_sel_i = rv32_op_imm | rv32_jalr | rv32_load;
wire rv32_imm_sel_jalr = rv32_jalr;
wire [31:0] rv32_jalr_imm = rv32_i_imm;

wire rv32_imm_sel_u = rv32_lui | rv32_auipc;

wire rv32_imm_sel_j = rv32_jal;
wire rv32_imm_sel_jal = rv32_jal;
wire [31:0] rv32_jal_imm = rv32_j_imm;

wire rv32_imm_sel_b = rv32_branch;
wire rv32_imm_sel_bxx = rv32_branch;
wire [31:0] rv32_bxx_imm = rv32_b_imm;

wire rv32_imm_sel_s = rv32_store;

// 16位指令的不同立即数格式
wire rv16_imm_sel_cis = rv16_lwsp;
wire [31:0] rv16_cis_imm = {24'b0, rv16_instr[3:2], rv16_instr[12], rv16_instr[6:4], 2'b0};
wire [31:0] rv16_cis_d_imm = {23'b0, rv16_instr[4:2], rv16_instr[12], rv16_instr[6:5], 3'b0};

wire rv16_imm_sel_cili = rv16_li | rv16_addi | rv16_slli | rv16_srai | rv16_srli | rv16_andi;
wire [31:0] rv16_cili_imm = {{26{rv16_instr[12]}}, rv16_instr[12], rv16_instr[6:2]};

wire rv16_imm_sel_cilui = rv16_lui;
wire [31:0] rv16_cilui_imm = {{14{rv16_instr[12]}}, rv16_instr[12], rv16_instr[6:2], 12'b0};

wire rv16_imm_sel_ci16sp = rv16_addi16sp;
wire [31:0] rv16_ci16sp_imm = {{22{rv16_instr[12]}}, rv16_instr[12], rv16_instr[4], rv16_instr[3], rv16_instr[5], rv16_instr[2], rv16_instr[6], 4'b0};

wire rv16_imm_sel_css = rv16_swsp;
wire [31:0] rv16_css_imm = {24'b0, rv16_instr[8:7], rv16_instr[12:9], 2'b0};
wire [31:0] rv16_css_d_imm = {23'b0, rv16_instr[9:7], rv16_instr[12:10], 3'b0};

wire rv16_imm_sel_ciw = rv16_addi4spn;
wire [31:0] rv16_ciw_imm = {22'b0, rv16_instr[10:7], rv16_instr[12], rv16_instr[11], rv16_instr[5], rv16_instr[6], 2'b0};

wire rv16_imm_sel_cl = rv16_lw;
wire [31:0] rv16_cl_imm = {25'b0, rv16_instr[5], rv16_instr[12], rv16_instr[11], rv16_instr[10], rv16_instr[6], 2'b0};
wire [31:0] rv16_cl_d_imm = {24'b0, rv16_instr[6], rv16_instr[5], rv16_instr[12], rv16_instr[11], rv16_instr[10], 3'b0};

wire rv16_imm_sel_cs = rv16_sw;
wire [31:0] rv16_cs_imm = {25'b0, rv16_instr[5], rv16_instr[12], rv16_instr[11], rv16_instr[10], rv16_instr[6], 2'b0};
wire [31:0] rv16_cs_d_imm = {24'b0, rv16_instr[6], rv16_instr[5], rv16_instr[12], rv16_instr[11], rv16_instr[10], 3'b0};

wire rv16_imm_sel_cb = rv16_beqz | rv16_bnez;
wire [31:0] rv16_cb_imm = {{24{rv16_instr[12]}}, rv16_instr[6:5], rv16_instr[2], rv16_instr[11:10], rv16_instr[4:3], 1'b0};
wire [31:0] rv16_bxx_imm = rv16_cb_imm;

wire rv16_imm_sel_cj = rv16_j | rv16_jal;
wire [31:0] rv16_cj_imm = {{21{rv16_instr[12]}}, rv16_instr[8], rv16_instr[10:9], rv16_instr[6], rv16_instr[7], rv16_instr[2], rv16_instr[11], rv16_instr[5:3], 1'b0};
wire [31:0] rv16_jjal_imm = rv16_cj_imm;

wire [31:0] rv16_jrjalr_imm = 32'b0;

wire [31:0] rv32_load_fp_imm = rv32_i_imm;
wire [31:0] rv32_store_fp_imm = rv32_s_imm;
// 最终32位指令立即数
wire [31:0] rv32_imm = ({32{rv32_imm_sel_i}} & rv32_i_imm) |
                       ({32{rv32_imm_sel_s}} & rv32_s_imm) |
                       ({32{rv32_imm_sel_b}} & rv32_b_imm) |
                       ({32{rv32_imm_sel_u}} & rv32_u_imm) |
                       ({32{rv32_imm_sel_j}} & rv32_j_imm);

wire rv32_need_imm = rv32_imm_sel_i |
                     rv32_imm_sel_s |
                     rv32_imm_sel_b |
                     rv32_imm_sel_u |
                     rv32_imm_sel_j;

// 最终16位指令立即数
wire [31:0] rv16_imm = ({32{rv16_imm_sel_cis}} & rv16_cis_imm) |
                       ({32{rv16_imm_sel_cili}} & rv16_cili_imm) |
                       ({32{rv16_imm_sel_cilui}} & rv16_cilui_imm) |
                       ({32{rv16_imm_sel_ci16sp}} & rv16_ci16sp_imm) |
                       ({32{rv16_imm_sel_css}} & rv16_css_imm) |
                       ({32{rv16_imm_sel_ciw}} & rv16_ciw_imm) |
                       ({32{rv16_imm_sel_cl}} & rv16_cl_imm) |
                       ({32{rv16_imm_sel_cs}} & rv16_cs_imm) |
                       ({32{rv16_imm_sel_cb}} & rv16_cb_imm) |
                       ({32{rv16_imm_sel_cj}} & rv16_cj_imm);

wire rv16_need_imm = rv16_imm_sel_cis |
                     rv16_imm_sel_cili |
                     rv16_imm_sel_cilui |
                     rv16_imm_sel_ci16sp |
                     rv16_imm_sel_css |
                     rv16_imm_sel_ciw |
                     rv16_imm_sel_cl |
                     rv16_imm_sel_cs |
                     rv16_imm_sel_cb |
                     rv16_imm_sel_cj;

assign need_imm = rv32 ? rv32_need_imm : rv16_need_imm;

// 生成最终立即数
assign dec_imm = rv32 ? rv32_imm : rv16_imm;
assign dec_pc = i_pc;

// 根据不同的指令分组，将它们的信息总线复用到一个统一的输出信号上
assign dec_info = ({`E203_DECINFO_WIDTH{alu_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_ALU_WIDTH{1'b0}}, alu_info_bus})
                | ({`E203_DECINFO_WIDTH{amoldst_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_AGU_WIDTH{1'b0}}, agu_info_bus})
                | ({`E203_DECINFO_WIDTH{bjp_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_BJP_WIDTH{1'b0}}, bjp_info_bus})
                | ({`E203_DECINFO_WIDTH{csr_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_CSR_WIDTH{1'b0}}, csr_info_bus})
                | ({`E203_DECINFO_WIDTH{muldiv_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_CSR_WIDTH{1'b0}}, muldiv_info_bus}); // TODO: why use CSR_WIDTH

wire legl_ops = alu_op | amoldst_op | bjp_op | csr_op | muldiv_op;

wire rv16_format_cr = rv16_jalr_mv_add;
wire rv16_format_ci = rv16_lwsp | rv16_flwsp | rv16_fldsp | rv16_li | rv16_lui_addi16sp | rv16_addi | rv16_slli;
wire rv16_format_css = rv16_swsp | rv16_fswsp | rv16_fsdsp;
wire rv16_format_ciw = rv16_addi4spn;
wire rv16_format_cl = rv16_lw | rv16_flw | rv16_fld;
wire rv16_format_cs = rv16_sw | rv16_fsw | rv16_fsd | rv16_subxororand;
wire rv16_format_cb = rv16_beqz | rv16_bnez | rv16_srli | rv16_srai | rv16_andi;
wire rv16_format_cj = rv16_j | rv16_jal;

wire rv16_need_cr_rs1 = rv16_format_ci & 1'b1;
wire rv16_need_cr_rs2 = rv16_format_ci & 1'b1;
wire rv16_need_cr_rd = rv16_format_ci & 1'b1;
wire [`E203_RFIDX_WIDTH-1:0] rv16_cr_rs1 = rv16_mv ? `E203_RFIDX_WIDTH'd0 : rv16_rs1[`E203_RFIDX_WIDTH-1:0];
wire [`E203_RFIDX_WIDTH-1:0] rv16_cr_rs2 = rv16_rs2[`E203_RFIDX_WIDTH-1:0];
wire [`E203_RFIDX_WIDTH-1:0] rv16_cr_rd = (rv16_jalr | rv16_jr) ? {{`E203_RFIDX_WIDTH-1{1'b0}}, rv16_instr[12]} : rv16_rd[`E203_RFIDX_WIDTH-1:0];

wire rv16_need_ci_rs1 = rv16_format_ci & 1'b1;
wire rv16_need_ci_rs2 = rv16_format_ci & 1'b0;
wire rv16_need_ci_rd = rv16_format_ci & 1'b1;
wire [`E203_RFIDX_WIDTH-1:0] rv16_ci_rs1 = (rv16_lwsp | rv16_flwsp | rv16_fldsp) ? `E203_RFIDX_WIDTH'd2 :
                                           (rv16_li | rv16_lui) ? `E203_RFIDX_WIDTH'd0 : rv16_rs1[`E203_RFIDX_WIDTH-1:0];
wire [`E203_RFIDX_WIDTH-1:0] rv16_ci_rs2 = `E203_RFIDX_WIDTH'd0;
wire [`E203_RFIDX_WIDTH-1:0] rv16_ci_rd = rv16_rd[`E203_RFIDX_WIDTH-1:0];

wire rv16_need_css_rs1 = rv16_format_css & 1'b1;
wire rv16_need_css_rs2 = rv16_format_css & 1'b1;
wire rv16_need_css_rd = rv16_format_css & 1'b0;
wire [`E203_RFIDX_WIDTH-1:0] rv16_css_rs1 = `E203_RFIDX_WIDTH'd2;
wire [`E203_RFIDX_WIDTH-1:0] rv16_css_rs2 = rv16_rs2[`E203_RFIDX_WIDTH-1:0];
wire [`E203_RFIDX_WIDTH-1:0] rv16_css_rd = `E203_RFIDX_WIDTH'd0;

wire rv16_need_ciw_rss1 = rv16_format_ciw & 1'b1;
wire rv16_need_ciw_rss2 = rv16_format_ciw & 1'b0;
wire rv16_need_ciw_rdd = rv16_format_ciw & 1'b1;
wire [`E203_RFIDX_WIDTH-1:0] rv16_ciw_rss1 = `E203_RFIDX_WIDTH'd2;
wire [`E203_RFIDX_WIDTH-1:0] rv16_ciw_rss2 = `E203_RFIDX_WIDTH'd0;
wire [`E203_RFIDX_WIDTH-1:0] rv16_ciw_rdd = rv16_rdd[`E203_RFIDX_WIDTH-1:0];

wire rv16_need_cl_rss1 = rv16_format_cl & 1'b1;
wire rv16_need_cl_rss2 = rv16_format_cl & 1'b0;
wire rv16_need_cl_rdd = rv16_format_cl & 1'b1;
wire [`E203_RFIDX_WIDTH-1:0] rv16_cl_rss1 = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
wire [`E203_RFIDX_WIDTH-1:0] rv16_cl_rss2 = `E203_RFIDX_WIDTH'd0;
wire [`E203_RFIDX_WIDTH-1:0] rv16_cl_rdd = rv16_rdd[`E203_RFIDX_WIDTH-1:0];

wire rv16_need_cs_rss1 = rv16_format_cs & 1'b1;
wire rv16_need_cs_rss2 = rv16_format_cs & 1'b1;
wire rv16_need_cs_rdd = rv16_format_cs & rv16_subxororand;
wire [`E203_RFIDX_WIDTH-1:0] rv16_cs_rss1 = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
wire [`E203_RFIDX_WIDTH-1:0] rv16_cs_rss2 = rv16_rss2[`E203_RFIDX_WIDTH-1:0];
wire [`E203_RFIDX_WIDTH-1:0] rv16_cs_rdd = rv16_rss1[`E203_RFIDX_WIDTH-1:0];

wire rv16_need_cb_rss1 = rv16_format_cb & 1'b1;
wire rv16_need_cb_rss2 = rv16_format_cb & (rv16_beqz | rv16_bnez);
wire rv16_need_cb_rdd = rv16_format_cb & (~(rv16_beqz | rv16_bnez));
wire [`E203_RFIDX_WIDTH-1:0] rv16_cb_rss1 = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
wire [`E203_RFIDX_WIDTH-1:0] rv16_cb_rss2 = `E203_RFIDX_WIDTH'd0;
wire [`E203_RFIDX_WIDTH-1:0] rv16_cb_rdd = rv16_rss1[`E203_RFIDX_WIDTH-1:0];

wire rv16_need_cj_rss1 = rv16_format_cj & 1'b0;
wire rv16_need_cj_rss2 = rv16_format_cj & 1'b0;
wire rv16_need_cj_rdd = rv16_format_cj & 1'b1;
wire [`E203_RFIDX_WIDTH-1:0] rv16_cj_rss1 = `E203_RFIDX_WIDTH'd0;
wire [`E203_RFIDX_WIDTH-1:0] rv16_cj_rss2 = `E203_RFIDX_WIDTH'd0;
wire [`E203_RFIDX_WIDTH-1:0] rv16_cj_rdd = rv16_j ? `E203_RFIDX_WIDTH'd0 : `E203_RFIDX_WIDTH'd1;

wire rv16_need_rs1 = rv16_need_cr_rs1 | rv16_need_ci_rs1 | rv16_need_css_rs1;
wire rv16_need_rs2 = rv16_need_cr_rs2 | rv16_need_ci_rs2 | rv16_need_css_rs2;
wire rv16_need_rd = rv16_need_cr_rd | rv16_need_ci_rd | rv16_need_css_rd;

wire rv16_need_rss1 = rv16_need_ciw_rss1 | rv16_need_cl_rss1 | rv16_need_cs_rss1 | rv16_need_cb_rss1 | rv16_need_cj_rss1;
wire rv16_need_rss2 = rv16_need_ciw_rss2 | rv16_need_cl_rss2 | rv16_need_cs_rss2 | rv16_need_cb_rss2 | rv16_need_cj_rss2;
wire rv16_need_rdd = rv16_need_ciw_rdd | rv16_need_cl_rdd | rv16_need_cs_rdd | rv16_need_cb_rdd | rv16_need_cj_rdd;

wire rv16_rs1en = (rv16_need_rs1 | rv16_need_rss1);
wire rv16_rs2en = (rv16_need_rs2 | rv16_need_rss2);
wire rv16_rden = (rv16_need_rd | rv16_need_rdd);

wire [`E203_RFIDX_WIDTH-1:0] rv16_rs1idx;
wire [`E203_RFIDX_WIDTH-1:0] rv16_rs2idx;
wire [`E203_RFIDX_WIDTH-1:0] rv16_rdidx;

assign rv16_rs1idx = ({`E203_RFIDX_WIDTH{rv16_need_cr_rs1}} & rv16_cr_rs1) |
                     ({`E203_RFIDX_WIDTH{rv16_need_ci_rs1}} & rv16_ci_rs1) |
                     ({`E203_RFIDX_WIDTH{rv16_need_css_rs1}} & rv16_css_rs1) |
                     ({`E203_RFIDX_WIDTH{rv16_need_ciw_rss1}} & rv16_ciw_rss1) |
                     ({`E203_RFIDX_WIDTH{rv16_need_cl_rss1}} & rv16_cl_rss1) |
                     ({`E203_RFIDX_WIDTH{rv16_need_cs_rss1}} & rv16_cs_rss1) |
                     ({`E203_RFIDX_WIDTH{rv16_need_cb_rss1}} & rv16_cb_rss1) |
                     ({`E203_RFIDX_WIDTH{rv16_need_cj_rss1}} & rv16_cj_rss1);

assign rv16_rs2idx = ({`E203_RFIDX_WIDTH{rv16_need_cr_rs2}} & rv16_cr_rs2) |
                     ({`E203_RFIDX_WIDTH{rv16_need_ci_rs2}} & rv16_ci_rs2) |
                     ({`E203_RFIDX_WIDTH{rv16_need_css_rs2}} & rv16_css_rs2) |
                     ({`E203_RFIDX_WIDTH{rv16_need_ciw_rss2}} & rv16_ciw_rss2) |
                     ({`E203_RFIDX_WIDTH{rv16_need_cl_rss2}} & rv16_cl_rss2) |
                     ({`E203_RFIDX_WIDTH{rv16_need_cs_rss2}} & rv16_cs_rss2) |
                     ({`E203_RFIDX_WIDTH{rv16_need_cb_rss2}} & rv16_cb_rss2) |
                     ({`E203_RFIDX_WIDTH{rv16_need_cj_rss2}} & rv16_cj_rss2);

assign rv16_rdidx = ({`E203_RFIDX_WIDTH{rv16_need_cr_rd}} & rv16_cr_rd) |
                    ({`E203_RFIDX_WIDTH{rv16_need_ci_rd}} & rv16_ci_rd) |
                    ({`E203_RFIDX_WIDTH{rv16_need_css_rd}} & rv16_css_rd) |
                    ({`E203_RFIDX_WIDTH{rv16_need_ciw_rdd}} & rv16_ciw_rdd) |
                    ({`E203_RFIDX_WIDTH{rv16_need_cl_rdd}} & rv16_cl_rdd) |
                    ({`E203_RFIDX_WIDTH{rv16_need_cs_rdd}} & rv16_cs_rdd) |
                    ({`E203_RFIDX_WIDTH{rv16_need_cb_rdd}} & rv16_cb_rdd) |
                    ({`E203_RFIDX_WIDTH{rv16_need_cj_rdd}} & rv16_cj_rdd);

// 生成最终的操作数寄存器索引
assign dec_rs1idx = rv32 ? rv32_rs1[`E203_RFIDX_WIDTH-1:0] : rv16_rs1idx;
assign dec_rs2idx = rv32 ? rv32_rs2[`E203_RFIDX_WIDTH-1:0] : rv16_rs2idx;
assign dec_rdidx = rv32 ? rv32_rd[`E203_RFIDX_WIDTH-1:0] : rv16_rdidx;

assign dec_rs1en = rv32 ? rv32_need_rs1 : (rv16_rs1en & (~(rv16_rs1idx == `E203_RFIDX_WIDTH'b0)));
assign dec_rs2en = rv32 ? rv32_need_rs2 : (rv16_rs2en & (~(rv16_rs1idx == `E203_RFIDX_WIDTH'b0)));
assign dec_rdwen = rv32 ? rv32_need_rd : (rv16_rden & (~(rv16_rdidx == `E203_RFIDX_WIDTH'b0)));

assign dec_rs1x0 = (dec_rs1idx == `E203_RFIDX_WIDTH'b0);
assign dec_rs2x0 = (dec_rs2idx == `E203_RFIDX_WIDTH'b0);

wire rv_index_ilgl;
`ifdef E203_RFREG_NUM_IS_4
assign rv_index_ilgl = (|dec_rs1idx[`E203_RFIDX_WIDTH-1:2]) |
                       (|dec_rs2idx[`E203_RFIDX_WIDTH-1:2]) |
                       (|dec_rdidx[`E203_RFIDX_WIDTH-1:2]);
`endif
`ifdef E203_RFREG_NUM_IS_8
assign rv_index_ilgl = (|dec_rs1idx[`E203_RFIDX_WIDTH-1:3]) |
                       (|dec_rs2idx[`E203_RFIDX_WIDTH-1:3]) |
                       (|dec_rdidx[`E203_RFIDX_WIDTH-1:3]);
`endif
`ifdef E203_RFREG_NUM_IS_16
assign rv_index_ilgl = (|dec_rs1idx[`E203_RFIDX_WIDTH-1:4]) |
                       (|dec_rs2idx[`E203_RFIDX_WIDTH-1:4]) |
                       (|dec_rdidx[`E203_RFIDX_WIDTH-1:4]);
`endif
`ifdef E203_RFREG_NUM_IS_32
assign rv_index_ilgl = 1'b0;
`endif

assign dec_rv32 = rv32;

assign dec_bjp_imm = ({32{rv16_jal | rv16_j}} & rv16_jjal_imm) |
                     ({32{rv16_jalr_mv_add}} & rv16_jrjalr_imm) |
                     ({32{rv16_beqz | rv16_bnez}} & rv16_bxx_imm) |
                     ({32{rv32_jal}} & rv32_jal_imm) |
                     ({32{rv32_jalr}} & rv32_jalr_imm) |
                     ({32{rv32_branch}} & rv32_bxx_imm);

assign dec_jalr_rs1idx = rv32 ? rv32_rs1[`E203_RFIDX_WIDTH-1:0] : rv16_rs1[`E203_RFIDX_WIDTH-1:0];

assign dec_misalgn = i_misalgn;
assign dec_buserr = i_buserr;

// 译码出非法指令
assign dec_ilegl = rv_all0s1s_ilgl |
                   rv_index_ilgl |
                   rv16_addi16sp_ilgl |
                   rv16_addi4spn_ilgl |
                   rv16_li_lui_ilgl |
                   rv16_sxxi_shamt_ilgl |
                   rv32_sxxi_shamt_ilgl |
                   rv32_dret_ilgl |
                   rv16_lwsp_ilgl |
                   (~legl_ops);

endmodule