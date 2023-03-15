`include "e203_defines.v"

module e203_ifu_simple_bpu(
  input [`E203_PC_SIZE-1:0] pc,

  input dec_jal,
  input dec_jalr,
  input dec_bxx,
  input [`E203_XLEN-1:0] dec_bjp_imm,
  input [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,

  input oitf_empty,
  input ir_empty,
  input ir_rs1en,
  input jalr_rs1idx_cam_irrdidx,

  output bpu_wait,
  output prdt_taken,
  output [`E203_PC_SIZE-1:0] prdt_pc_add_op1,
  output [`E203_PC_SIZE-1:0] prdt_pc_add_op2,

  input dec_i_valid,

  output bpu2rf_rs1_ena,
  input ir_valid_clr,
  input [`E203_XLEN-1:0] rf2bpu_x1,
  input [`E203_XLEN-1:0] rf2bpu_rs1,

  input clk,
  input rst_n
);
// 如果偏移量为负数(最高位为1)，则为向后调整，预测为需要跳转
assign prdt_taken = (dec_jal | dec_jalr | (dec_bxx & dec_bjp_imm[`E203_XLEN-1]));

// 判定rs1的索引号是x0
wire dec_jalr_rs1x0 = (dec_jalr_rs1idx == `E203_RFIDX_WIDTH'd0);
// 判定rs1的索引号是x1，可进行加速
wire dec_jalr_rs1x1 = (dec_jalr_rs1idx == `E203_RFIDX_WIDTH'd1);
// 判定rs1的索引号是xn
wire dec_jalr_rs1xn = (~dec_jalr_rs1x0) & (~dec_jalr_rs1x1);

// 判断x1是否可能与EXU中的指令存在潜在的RAW。1. OITF不为空；2. 处于IR寄存器中的指令写回目标寄存器为x1
wire jalr_rs1x1_dep = dec_i_valid & dec_jalr & dec_jalr_rs1x1 & ((~oitf_empty) | (jalr_rs1idx_cam_irrdidx));
// 判断xn是否可能与EXU中的指令存在潜在的RAW。1. OITF不为空；2. IR寄存器中存在指令
wire jalr_rs1xn_dep = dec_i_valid & dec_jalr & dec_jalr_rs1xn & ((~oitf_empty) | (~ir_empty));

wire jalr_rs1xn_dep_ir_clr = (jalr_rs1xn_dep & oitf_empty & (~ir_empty)) & (ir_valid_clr | (~ir_rs1en));

wire rs1xn_rdrf_r;

// TODO: 未理解
// 征用regfile的第一个读端口读取xn的值，需要判断该端口是否空闲
// 如果没有资源冲突和数据冲突，则将该端口的使能置高
wire rs1xn_rdrf_set = (~rs1xn_rdrf_r) & dec_i_valid & dec_jalr & dec_jalr_rs1xn & ((~jalr_rs1xn_dep) | jalr_rs1xn_dep_ir_clr);
wire rs1xn_rdrf_clr = rs1xn_rdrf_r;
wire rs1xn_rdrf_ena = rs1xn_rdrf_set | rs1xn_rdrf_clr;
wire rs1xn_rdrf_nxt = rs1xn_rdrf_set | (~rs1xn_rdrf_clr);

sirv_gnrl_dfflr #(1) rs1xn_rdrf_dfflrs(rs1xn_rdrf_ena, rs1xn_rdrf_nxt, rs1xn_rdrf_r, clk, rst_n);

// 生成征用第一个读端口的使能信号，该信号加载和IR寄存器位于同一级的rs1索引寄存器，以读取regfile
assign bpu2rf_rs1_ena = rs1xn_rdrf_set;

// 如果存在x1的RAW，就将bpu_wait拉高，阻止IFU生成下一个PC
// 如果存在xn的RAW，以及征用读端口的时候，都要拉高
assign bpu_wait = jalr_rs1x1_dep | jalr_rs1xn_dep | rs1xn_rdrf_set;

// 加法操作数1
// 如果是bxx指令，使用其本身的pc
// 如果是jal指令，使用其本身的pc
// 如果是jalr指令，且rs1为x0，使用常数0
// 如果时jalr指令，且rs1为x1，使用从regfile中连线出来的x1
// 如果时jalr指令，且rs1为xn，使用从regfile的读端口读出来的xn
assign prdt_pc_add_op1 = (dec_bxx | dec_jal) ? pc[`E203_PC_SIZE-1:0]
                       : (dec_jalr & dec_jalr_rs1x0) ? `E203_PC_SIZE'b0
                       : (dec_jalr & dec_jalr_rs1x1) ? rf2bpu_x1[`E203_PC_SIZE-1:0]
                       : rf2bpu_rs1[`E203_PC_SIZE-1:0];

// 加法操作数2，立即数偏移量
assign prdt_pc_add_op2 = dec_bjp_imm[`E203_PC_SIZE-1:0];

endmodule