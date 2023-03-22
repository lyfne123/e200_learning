`include "e203_defines.v"

module e203_exu_regfile(
  input [`E203_RFIDX_WIDTH-1:0] read_src1_idx,
  input [`E203_RFIDX_WIDTH-1:0] read_src2_idx,
  output [`E203_XLEN-1:0] read_src1_dat,
  output [`E203_XLEN-1:0] read_src2_dat,

  input wbck_dest_wen,
  input [`E203_RFIDX_WIDTH-1:0] wbck_dest_idx,
  input [`E203_XLEN-1:0] wbck_dest_dat,

  output [`E203_XLEN-1:0] x1_r,

  input test_mode,
  input clk,
  input rst_n
);

wire [`E203_XLEN-1:0] rf_r [`E203_RFREG_NUM-1:0];
wire [`E203_RFREG_NUM-1:0] rf_wen;

genvar i;
generate
  for (i = 0; i < `E203_RFREG_NUM; i = i + 1) begin: regfile
    if (i == 0) begin: rf0
      // x0无需实际厉害寄存器
      assign rf_wen[i] = 1'b0;
      assign rf_r[i] = `E203_XLEN'b0;
    end
    else begin: rfno0
      // 通过对写结果寄存器的索引号和寄存器好进行比较，产生写使能逻辑
      assign rf_wen[i] = wbck_dest_wen & (wbck_dest_idx == i);
      // 例化dff实现通用寄存器
      // 此处有明确的load-enable信号，综合工具会自动插入门控时钟以节省功耗
      sirv_gnrl_dffl #(`E203_XLEN) rf_dffl (rf_wen[i], wbck_dest_dat, rf_r[i], clk);
    end
  end
endgenerate

// 每个读端口都是一个多路并行选择器
assign read_src1_dat = rf_r[read_src1_idx];
assign read_src2_dat = rf_r[read_src2_idx];

assign x1_r = rf_r[1];

endmodule