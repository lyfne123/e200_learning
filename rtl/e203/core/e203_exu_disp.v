`include "e203_defines.v"

module e203_exu_disp(
  input wfi_halt_exu_req,
  output wfi_halt_exu_ack,

  input oitf_empty,
  input amo_wait,

  input disp_i_valid,
  output disp_i_ready,

  input disp_i_rs1x0,
  input disp_i_rs2x0,
  input disp_i_rs1en,
  input disp_i_rs2en,
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rs1idx,
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rs2idx,
  input [`E203_XLEN-1:0] disp_i_rs1,
  input [`E203_XLEN-1:0] disp_i_rs2,
  input disp_i_rdwen,
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rdidx,
  input [`E203_DECINFO_WIDTH-1:0] disp_i_info,
  input [`E203_XLEN-1:0] disp_i_imm,
  input [`E203_PC_SIZE-1:0] disp_i_pc,
  input disp_i_misalgn,
  input disp_i_buserr,
  input disp_i_ilegl,

  output disp_o_alu_valid,
  input disp_o_alu_ready,

  input disp_o_alu_longpipe,

  output [`E203_XLEN-1:0] disp_o_alu_rs1,
  output [`E203_XLEN-1:0] disp_o_alu_rs2,
  output disp_o_alu_rdwen,
  output [`E203_RFIDX_WIDTH-1:0] disp_o_alu_rdidx,
  output [`E203_DECINFO_WIDTH-1:0] disp_o_alu_info,
  output [`E203_XLEN-1:0] disp_o_alu_imm,
  output [`E203_PC_SIZE-1:0] disp_o_alu_pc,
  output [`E203_ITAG_WIDTH-1:0] disp_o_alu_itag,
  output disp_o_alu_misalgn,
  output disp_o_alu_buserr,
  output disp_o_alu_ilegl,

  input oitfrd_match_disprs1,
  input oitfrd_match_disprs2,
  input oitfrd_match_disprs3,
  input oitfrd_match_disprd,
  input [`E203_ITAG_WIDTH-1:0] disp_oitf_ptr,

  output disp_oitf_ena,
  input disp_oitf_ready,

  output disp_oitf_rs1en,
  output disp_oitf_rs2en,
  output disp_oitf_rs3en,
  output disp_oitf_rdwen,

  output [`E203_RFIDX_WIDTH-1:0] disp_oitf_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] disp_oitf_rs2idx,
  output [`E203_RFIDX_WIDTH-1:0] disp_oitf_rs3idx,
  output [`E203_RFIDX_WIDTH-1:0] disp_oitf_rdidx,

  output [`E203_PC_SIZE-1:0] disp_oitf_pc,

  input clk,
  input rst_n
);

wire [`E203_DECINFO_GRP_WIDTH-1:0] disp_i_info_grp = disp_i_info[`E203_DECINFO_GRP];

wire disp_csr = (disp_i_info_grp == `E203_DECINFO_GRP_CSR);

wire disp_alu_longp_prdt = (disp_i_info_grp == `E203_DECINFO_GRP_AGU);

wire disp_alu_longp_real = disp_o_alu_longpipe;

wire disp_fence_fencei = (disp_i_info_grp == `E203_DECINFO_GRP_BJP) &
                         (disp_i_info[`E203_DECINFO_BJP_FENCE] | disp_i_info[`E203_DECINFO_BJP_FENCEI]);

// 将指令派遣给ALU的接口采用valid-ready模式的握手信号
wire disp_i_valid_pos;
wire disp_i_ready_pos = disp_o_alu_ready;
assign disp_o_alu_valid = disp_i_valid_pos;

// 任一源操作数产生RAW相关性，则该指令和前序长指令存在RAW相关性
wire raw_dep = oitfrd_match_disprs1 | oitfrd_match_disprs2 | oitfrd_match_disprs3;
// 存在WAW相关性
wire waw_dep = oitfrd_match_disprd;

// RAW和WAW都需要阻塞派遣点
wire dep = raw_dep | waw_dep;

assign wfi_halt_exu_ack = oitf_empty & (~amo_wait);

// 派遣条件信号
// 如果当前派遣指令需要访问csr寄存器改变其值，必须等待oitf为空，即所有长指令都已执行完毕后才可
// 如果当前派遣指令属于fence和fence.i指令，必须等待oitf为空，即保证fence和fence.i之前的指令都执行完毕
// 如果已交付了一条wfi指令，则必须立即阻塞派遣点，不让后续的指令派遣，从而尽快让处理器进入wfi休眠模式
// 如果发生了数据相关性，则阻塞派遣点
// 如果当前派遣的是长指令，必须等待oitf有空
wire disp_condition = (disp_csr ? oitf_empty : 1'b1) &
                      (disp_fence_fencei ? oitf_empty : 1'b1) &
                      (~wfi_halt_exu_req) &
                      (~dep) &
                      (disp_alu_longp_prdt ? disp_oitf_ready : 1'b1);

// 只有满足派遣条件时，才会发生派遣
assign disp_i_valid_pos = disp_condition & disp_i_valid;
assign disp_i_ready = disp_condition & disp_i_valid_pos;

wire [`E203_XLEN-1:0] disp_i_rs1_msked = disp_i_rs1 & {`E203_XLEN{~disp_i_rs1x0}};
wire [`E203_XLEN-1:0] disp_i_rs2_msked = disp_i_rs2 & {`E203_XLEN{~disp_i_rs2x0}};

// 派遣操作数和指令信息
assign disp_o_alu_rs1 = disp_i_rs1_msked;
assign disp_o_alu_rs2 = disp_i_rs2_msked;
assign disp_o_alu_rdwen = disp_i_rdwen; // 是否写回结果寄存器
assign disp_o_alu_rdidx = disp_i_rdidx; // 写回的结果寄存器索引
assign disp_o_alu_info = disp_i_info; // 指令信息

// 在派遣点产生oitf分配表项的使能信号
// 如果当前派遣的指令为一个长指令，则产生此使能信号
assign disp_oitf_ena = disp_o_alu_valid & disp_o_alu_ready & disp_alu_longp_real;

assign disp_o_alu_imm = disp_i_imm; // 指令使用的立即数
assign disp_o_alu_pc = disp_i_pc; // 指令pc
assign disp_o_alu_itag = disp_oitf_ptr;
assign disp_o_alu_misalgn = disp_i_misalgn; // 发生非对齐错误
assign disp_o_alu_buserr = disp_i_buserr; // 发生存储器访问错误
assign disp_o_alu_ilegl = disp_i_ilegl; // 发生非法指令错误

assign disp_oitf_rs1en = disp_i_rs1en;
assign disp_oitf_rs2en = disp_i_rs2en;
assign disp_oitf_rs3en = 1'b0;
assign disp_oitf_rdwen = disp_i_rdwen;

assign disp_oitf_rs1idx = disp_i_rs1idx;
assign disp_oitf_rs2idx = disp_i_rs2idx;
assign disp_oitf_rs3idx = `E203_RFIDX_WIDTH'b0;
assign disp_oitf_rdidx = disp_i_rdidx;

endmodule