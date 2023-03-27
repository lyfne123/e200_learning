`include "e203_defines.v"

// Outstanding Instructions Track FIFO
// 是一个FIFO，默认深度为2个表项
// 在流水线的派遣点，每派遣一个长指令，则在OITF中分配一个表项（Entry），该表项中存储该长指令的源操作数寄存器所有和结果寄存器索引
// 在流水线的写回点，每按顺序写回一个长指令后，将此指令在OITF中删除
module e203_exu_oitf(
  output dis_ready,

  input dis_ena,
  input ret_ena,

  output [`E203_ITAG_WIDTH-1:0] dis_ptr,
  output [`E203_ITAG_WIDTH-1:0] ret_ptr,

  output [`E203_RFIDX_WIDTH-1:0] ret_rdidx,
  output ret_rdwen,
  output ret_rdfpu,
  output [`E203_PC_SIZE-1:0] ret_pc,

  input disp_i_rs1en,
  input disp_i_rs2en,
  input disp_i_rs3en,
  input disp_i_rdwen,
  input disp_i_rs1fpu,
  input disp_i_rs2fpu,
  input disp_i_rs3fpu,
  input disp_i_rdfpu,
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rs1idx,
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rs2idx,
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rs3idx,
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rdidx,
  input [`E203_PC_SIZE-1:0] disp_i_pc,

  output oitfrd_match_disprs1,
  output oitfrd_match_disprs2,
  output oitfrd_match_disprs3,
  output oitfrd_match_disprd,

  output oitf_empty,
  input clk,
  input rst_n
);

wire [`E203_OITF_DEPTH-1:0] vld_set;
wire [`E203_OITF_DEPTH-1:0] vld_clr;
wire [`E203_OITF_DEPTH-1:0] vld_ena;
wire [`E203_OITF_DEPTH-1:0] vld_nxt;
wire [`E203_OITF_DEPTH-1:0] vld_r;
wire [`E203_OITF_DEPTH-1:0] rdwen_r;
wire [`E203_OITF_DEPTH-1:0] rdfpu_r;
wire [`E203_RFIDX_WIDTH-1:0] rdidx_r[`E203_OITF_DEPTH-1:0];
wire [`E203_PC_SIZE-1:0] pc_r[`E203_OITF_DEPTH-1:0];

wire alc_ptr_ena = dis_ena;
wire ret_ptr_ena = ret_ena;

wire oitf_full;

wire [`E203_ITAG_WIDTH-1:0] alc_ptr_r;
wire [`E203_ITAG_WIDTH-1:0] ret_ptr_r;

generate
if(`E203_OITF_DEPTH > 1) begin: depth_gt1
  wire alc_ptr_flg_r;
  wire alc_ptr_flg_nxt = ~alc_ptr_flg_r;
  wire alc_ptr_flg_ena = (alc_ptr_r == ($unsigned(`E203_OITF_DEPTH-1))) & alc_ptr_ena;

  sirv_gnrl_dfflr #(1) alc_ptr_flg_dfflrs(alc_ptr_flg_ena, alc_ptr_flg_nxt, alc_ptr_flg_r, clk, rst_n);

  wire [`E203_ITAG_WIDTH-1:0] alc_ptr_nxt;

  assign alc_ptr_nxt = alc_ptr_flg_ena ? `E203_ITAG_WIDTH'b0 : (alc_ptr_r + 1'b1);

  sirv_gnrl_dfflr #(`E203_ITAG_WIDTH) alu_ptr_dfflrs(alc_ptr_ena, alc_ptr_nxt, alc_ptr_r, clk, rst_n);

  wire ret_ptr_flg_r;
  wire ret_ptr_flg_nxt = ~ret_ptr_flg_r;
  wire ret_ptr_flg_ena = (ret_ptr_r == ($unsigned(`E203_OITF_DEPTH-1))) & ret_ptr_ena;

  sirv_gnrl_dfflr #(1) ret_ptr_flg_dfflrs(ret_ptr_flg_ena, ret_ptr_flg_nxt, ret_ptr_flg_r, clk, rst_n);

  wire [`E203_ITAG_WIDTH-1:0] ret_ptr_nxt;

  assign ret_ptr_nxt = ret_ptr_flg_ena ? `E203_ITAG_WIDTH'b0 : (ret_ptr_r + 1'b1);

  sirv_gnrl_dfflr #(`E203_ITAG_WIDTH) ret_ptr_dfflrs(ret_ptr_ena, ret_ptr_nxt, ret_ptr_r, clk, rst_n);

  assign oitf_empty = (ret_ptr_r == alc_ptr_r) & (ret_ptr_flg_r == alc_ptr_flg_r);
  assign oitf_full = (ret_ptr_r == alc_ptr_r) & (~(ret_ptr_flg_r == alc_ptr_flg_r));
end
else begin: depth_eq1
  assign alc_ptr_r = 1'b0;
  assign ret_ptr_r = 1'b0;
  assign oitf_empty = ~vld_r[0];
  assign oitf_full = vld_r[0];
end
endgenerate

assign ret_ptr = ret_ptr_r;
assign dis_ptr = alc_ptr_r;

assign dis_ready = (~oitf_full);

wire [`E203_OITF_DEPTH-1:0] rd_match_rs1idx;
wire [`E203_OITF_DEPTH-1:0] rd_match_rs2idx;
wire [`E203_OITF_DEPTH-1:0] rd_match_rs3idx;
wire [`E203_OITF_DEPTH-1:0] rd_match_rdidx;

genvar i;
generate
  for (i = 0; i < `E203_OITF_DEPTH; i = i + 1) begin: oitf_entries
    assign vld_set[i] = alc_ptr_ena & (alc_ptr_r == i);
    assign vld_clr[i] = ret_ptr_ena & (ret_ptr_r == i);
    assign vld_ena[i] = vld_set[i] | vld_clr[i];
    assign vld_nxt[i] = vld_set[i] | (~vld_clr[i]);

    sirv_gnrl_dfflr #(1) vld_dfflrs(vld_ena[i], vld_nxt[i], vld_r[i], clk, rst_n);

    sirv_gnrl_dffl #(`E203_RFIDX_WIDTH) rdidx_dfflrs(vld_set[i], disp_i_rdidx, rdidx_r[i], clk);
    sirv_gnrl_dffl #(`E203_PC_SIZE) pc_dfflrs(vld_set[i], disp_i_pc, pc_r[i], clk);
    sirv_gnrl_dffl #(1) rdwen_dfflrs(vld_set[i], disp_i_rdwen, rdwen_r[i], clk);
    sirv_gnrl_dffl #(1) rdfpu_dfflrs(vld_set[i], disp_i_rdfpu, rdfpu_r[i], clk);

    assign rd_match_rs1idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs1en & (rdfpu_r[i] == disp_i_rs1fpu) & (rdidx_r[i] == disp_i_rs1idx);
    assign rd_match_rs2idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs2en & (rdfpu_r[i] == disp_i_rs2fpu) & (rdidx_r[i] == disp_i_rs2idx);
    assign rd_match_rs2idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs3en & (rdfpu_r[i] == disp_i_rs3fpu) & (rdidx_r[i] == disp_i_rs3idx);
    assign rd_match_rdidx[i] = vld_r[i] & rdwen_r[i] & disp_i_rdwen & (rdfpu_r[i] == disp_i_rdfpu) & (rdidx_r[i] == disp_i_rdidx);
  end
endgenerate

assign oitfrd_match_disprs1 = |rd_match_rs1idx;
assign oitfrd_match_disprs2 = |rd_match_rs2idx;
assign oitfrd_match_disprs3 = |rd_match_rs3idx;
assign oitfrd_match_disprd = |rd_match_rdidx;

assign ret_rdidx = rdidx_r[ret_ptr];
assign ret_pc = pc_r[ret_ptr];
assign ret_rdwen = rdwen_r[ret_ptr];
assign ret_rdfpu = rdfpu_r[ret_ptr];

endmodule