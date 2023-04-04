`include "e203_defines.v"

module e203_exu_wbck(
  // 单周期指令写回信号
  input alu_wbck_i_valid,
  output alu_wbck_i_ready,
  input [`E203_XLEN-1:0] alu_wbck_i_wdat, // 数据值
  input [`E203_RFIDX_WIDTH-1:0] alu_wbck_i_rdidx, // 寄存器索引

  // 长周期指令写回信号
  input longp_wbck_i_valid,
  output longp_wbck_i_ready,
  input [`E203_FLEN-1:0] longp_wbck_i_wdat, // 数据值
  input [4:0] longp_wbck_i_flags,
  input [`E203_RFIDX_WIDTH-1:0] longp_wbck_i_rdidx, // 寄存器索引

  output rf_wbck_o_ena,
  output [`E203_XLEN-1:0] rf_wbck_o_wdat,
  output [`E203_RFIDX_WIDTH-1:0] rf_wbck_o_rdidx,

  input clk,
  input rst_n
);

// 使用优先级仲裁，如果两种指令同时写回，长指令优先级高
wire wbck_ready4alu = (~longp_wbck_i_valid);
wire wbck_sel_alu = alu_wbck_i_valid & wbck_ready4alu;

wire wbck_ready4longp = 1'b1;
wire wbck_sel_longp = longp_wbck_i_valid & wbck_ready4longp;

wire rf_wbck_o_ready = 1'b1;

wire wbck_i_ready;
wire wbck_i_valid;
wire [`E203_FLEN-1:0] wbck_i_wdat;
wire [4:0] wbck_i_flags;
wire [`E203_RFIDX_WIDTH-1:0] wbck_i_rdidx;

assign alu_wbck_i_ready = wbck_ready4alu & wbck_i_ready;
assign longp_wbck_i_ready = wbck_ready4longp & wbck_i_ready;

assign wbck_i_valid = wbck_sel_alu ? alu_wbck_i_valid : longp_wbck_i_valid;
`ifdef E203_FLEN_IS_32
assign wbck_i_wdat = wbck_sel_alu ? alu_wbck_i_wdat : longp_wbck_i_wdat;
`else
assign wbck_i_wdat = wbck_sel_alu ? {{(`E203_FLEN - `E203_XLEN){1'b0}}, alu_wbck_i_wdat} : longp_wbck_i_wdat;
`endif
assign wbck_i_flags = wbck_sel_alu ? 5'b0 : longp_wbck_i_flags;
assign wbck_i_rdidx = wbck_sel_alu ? alu_wbck_i_rdidx : longp_wbck_i_rdidx;

assign wbck_i_ready = rf_wbck_o_ready;
wire rf_wbck_o_valid = wbck_i_valid;

wire wbck_o_ena = rf_wbck_o_valid & rf_wbck_o_ready;

assign rf_wbck_o_ena = wbck_o_ena;
assign rf_wbck_o_wdat = wbck_i_wdat[`E203_XLEN-1:0];
assign rf_wbck_o_rdidx = wbck_i_rdidx;

endmodule