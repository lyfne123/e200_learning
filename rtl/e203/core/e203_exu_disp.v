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

wire disp_i_valid_pos;
wire disp_i_ready_pos = disp_o_alu_ready;
assign disp_o_alu_valid = disp_i_valid_pos;

wire raw_dep = oitfrd_match_disprs1 | oitfrd_match_disprs2 | oitfrd_match_disprs3;
wire waw_dep = oitfrd_match_disprd;

wire dep = raw_dep | waw_dep;

assign wfi_halt_exu_ack = oitf_empty & (~amo_wait);

wire disp_condition = (disp_csr ? oitf_empty : 1'b1) &
                      (disp_fence_fencei ? oitf_empty : 1'b1) &
                      (~wfi_halt_exu_req) &
                      (~dep) &
                      (disp_alu_longp_prdt ? disp_oitf_ready : 1'b1);

assign disp_i_valid_pos = disp_condition & disp_i_valid;
assign disp_i_ready = disp_condition & disp_i_valid_pos;

wire [`E203_XLEN-1:0] disp_i_rs1_msked = disp_i_rs1 & {`E203_XLEN{~disp_i_rs1x0}};
wire [`E203_XLEN-1:0] disp_i_rs2_msked = disp_i_rs2 & {`E203_XLEN{~disp_i_rs2x0}};

assign disp_o_alu_rs1 = disp_i_rs1_msked;
assign disp_o_alu_rs2 = disp_i_rs2_msked;
assign disp_o_alu_rdwen = disp_i_rdwen;
assign disp_o_alu_rdidx = disp_i_rdidx;
assign disp_o_alu_info = disp_i_info;

assign disp_oitf_ena = disp_o_alu_valid & disp_o_alu_ready & disp_alu_longp_real;

assign disp_o_alu_imm = disp_i_imm;
assign disp_o_alu_pc = disp_i_pc;
assign disp_o_alu_itag = disp_oitf_ptr;
assign disp_o_alu_misalgn = disp_i_misalgn;
assign disp_o_alu_buserr = disp_i_buserr;
assign disp_o_alu_ilegl = disp_i_ilegl;

assign disp_oitf_rs1en = disp_i_rs1en;
assign disp_oitf_rs2en = disp_i_rs2en;
assign disp_oitf_rs3en = 1'b0;
assign disp_oitf_rdwen = disp_i_rdwen;

assign disp_oitf_rs1idx = disp_i_rs1idx;
assign disp_oitf_rs2idx = disp_i_rs2idx;
assign disp_oitf_rs3idx = `E203_RFIDX_WIDTH'b0;
assign disp_oitf_rdidx = disp_i_rdidx;

endmodule