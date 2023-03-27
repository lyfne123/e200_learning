`include "e203_defines.v"

// Outstanding Instructions Track FIFO
// 是一个FIFO，默认深度为2个表项
// 在流水线的派遣点，每派遣一个长指令，则在OITF中分配一个表项（Entry），该表项中存储该长指令的源操作数寄存器所有和结果寄存器索引
// 在流水线的写回点，每按顺序写回一个长指令后，将此指令在OITF中删除
module e203_exu_oitf(
  output dis_ready,

  input dis_ena, // 派遣一个长指令的使能信号，用于分配表项
  input ret_ena, // 写回一个长指令的使能信号，用于移除表项

  output [`E203_ITAG_WIDTH-1:0] dis_ptr,
  output [`E203_ITAG_WIDTH-1:0] ret_ptr,

  output [`E203_RFIDX_WIDTH-1:0] ret_rdidx,
  output ret_rdwen,
  output [`E203_PC_SIZE-1:0] ret_pc,

  input disp_i_rs1en, // 当前派遣指令是否需要读第一个源操作数寄存器
  input disp_i_rs2en, // 当前派遣指令是否需要读第二个源操作数寄存器
  input disp_i_rs3en, // 当前派遣指令是否需要读第三个源操作数寄存器，只有浮点指令才会使用
  input disp_i_rdwen, // 当前派遣指令是否需要写回结果寄存器
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rs1idx, // 当前派遣指令第一个源操作数寄存器的索引
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rs2idx, // 当前派遣指令第二个源操作数寄存器的索引
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rs3idx, // 当前派遣指令第三个源操作数寄存器的索引
  input [`E203_RFIDX_WIDTH-1:0] disp_i_rdidx, // 当前派遣指令结果数寄存器的索引
  input [`E203_PC_SIZE-1:0] disp_i_pc,

  output oitfrd_match_disprs1, // 派遣指令源操作数一和oitf表项中的结果寄存器相同
  output oitfrd_match_disprs2, // 派遣指令源操作数二和oitf表项中的结果寄存器相同
  output oitfrd_match_disprs3, // 派遣指令源操作数三和oitf表项中的结果寄存器相同
  output oitfrd_match_disprd, // 派遣指令结果寄存器和oitf表项中的结果寄存器相同

  output oitf_empty,
  input clk,
  input rst_n
);

wire [`E203_OITF_DEPTH-1:0] vld_set;
wire [`E203_OITF_DEPTH-1:0] vld_clr;
wire [`E203_OITF_DEPTH-1:0] vld_ena;
wire [`E203_OITF_DEPTH-1:0] vld_nxt;
wire [`E203_OITF_DEPTH-1:0] vld_r; // 各表项中是否存放了有效指令的指示信号
wire [`E203_OITF_DEPTH-1:0] rdwen_r; // 各表项中指令是否写回结果寄存器
wire [`E203_RFIDX_WIDTH-1:0] rdidx_r[`E203_OITF_DEPTH-1:0]; // 各表项中指令的结果寄存器索引
wire [`E203_PC_SIZE-1:0] pc_r[`E203_OITF_DEPTH-1:0]; // 各表项中指令的pc

wire alc_ptr_ena = dis_ena; // 派遣一个长指令的使能信号，作为写指针的使能信号
wire ret_ptr_ena = ret_ena; // 写回一个长指令的使能信号，作为读指针的使能信号

wire oitf_full;

wire [`E203_ITAG_WIDTH-1:0] alc_ptr_r;
wire [`E203_ITAG_WIDTH-1:0] ret_ptr_r;

generate
if(`E203_OITF_DEPTH > 1) begin: depth_gt1
  // 与常规的FIFO设计一样，为了方便维护空满标志，为写指针增加额外的一个标志位
  wire alc_ptr_flg_r;
  wire alc_ptr_flg_nxt = ~alc_ptr_flg_r;
  wire alc_ptr_flg_ena = (alc_ptr_r == ($unsigned(`E203_OITF_DEPTH-1))) & alc_ptr_ena;

  sirv_gnrl_dfflr #(1) alc_ptr_flg_dfflrs(alc_ptr_flg_ena, alc_ptr_flg_nxt, alc_ptr_flg_r, clk, rst_n);

  wire [`E203_ITAG_WIDTH-1:0] alc_ptr_nxt;

  // 每次分配一个表项，写指针自增1，如果达到了FIFO的深度值，写指针归零
  assign alc_ptr_nxt = alc_ptr_flg_ena ? `E203_ITAG_WIDTH'b0 : (alc_ptr_r + 1'b1);

  sirv_gnrl_dfflr #(`E203_ITAG_WIDTH) alu_ptr_dfflrs(alc_ptr_ena, alc_ptr_nxt, alc_ptr_r, clk, rst_n);

  // 与常规的FIFO设计一样，为了方便维护空满标志，为读指针增加额外的一个标志位
  wire ret_ptr_flg_r;
  wire ret_ptr_flg_nxt = ~ret_ptr_flg_r;
  wire ret_ptr_flg_ena = (ret_ptr_r == ($unsigned(`E203_OITF_DEPTH-1))) & ret_ptr_ena;

  sirv_gnrl_dfflr #(1) ret_ptr_flg_dfflrs(ret_ptr_flg_ena, ret_ptr_flg_nxt, ret_ptr_flg_r, clk, rst_n);

  wire [`E203_ITAG_WIDTH-1:0] ret_ptr_nxt;

  // 每次移除一个表项，读指针自增1，如果达到了FIFO的深度值，读指针归零
  assign ret_ptr_nxt = ret_ptr_flg_ena ? `E203_ITAG_WIDTH'b0 : (ret_ptr_r + 1'b1);

  sirv_gnrl_dfflr #(`E203_ITAG_WIDTH) ret_ptr_dfflrs(ret_ptr_ena, ret_ptr_nxt, ret_ptr_r, clk, rst_n);

  // 生成FIFO的空满标志
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
generate // 使用generate for实现FIFO的主体部分
  for (i = 0; i < `E203_OITF_DEPTH; i = i + 1) begin: oitf_entries
    // 每次分配一个表项时，且写指针与当前表项编号一样，则将该表项的有效信号置为高
    assign vld_set[i] = alc_ptr_ena & (alc_ptr_r == i);
    // 每次移除一个表项时，且读指针与当前表项编号一样，则将该表项的有效信号清为低
    assign vld_clr[i] = ret_ptr_ena & (ret_ptr_r == i);
    assign vld_ena[i] = vld_set[i] | vld_clr[i];
    assign vld_nxt[i] = vld_set[i] | (~vld_clr[i]);

    sirv_gnrl_dfflr #(1) vld_dfflrs(vld_ena[i], vld_nxt[i], vld_r[i], clk, rst_n);

    // 其他的表项信息，均可视为该表项的载荷，只需在表项分配时写入，在表项移除时无需清除，可节省动态功耗
    sirv_gnrl_dffl #(`E203_RFIDX_WIDTH) rdidx_dfflrs(vld_set[i], disp_i_rdidx, rdidx_r[i], clk); // 各表项中指令的结果寄存器索引
    sirv_gnrl_dffl #(`E203_PC_SIZE) pc_dfflrs(vld_set[i], disp_i_pc, pc_r[i], clk); // 各表项中指令的pc
    sirv_gnrl_dffl #(1) rdwen_dfflrs(vld_set[i], disp_i_rdwen, rdwen_r[i], clk); // 各表项中指令是否需要写回结果寄存器

    // 将正在派遣的指令的源操作数寄存器索引和各表项中的结果寄存器索引进行比较
    assign rd_match_rs1idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs1en & (rdidx_r[i] == disp_i_rs1idx);
    assign rd_match_rs2idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs2en & (rdidx_r[i] == disp_i_rs2idx);
    assign rd_match_rs2idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs3en & (rdidx_r[i] == disp_i_rs3idx);
    // 将正在派遣的指令的结果寄存器索引和各表项中的结果寄存器索引进行比较
    assign rd_match_rdidx[i] = vld_r[i] & rdwen_r[i] & disp_i_rdwen & (rdidx_r[i] == disp_i_rdidx);
  end
endgenerate

// 派遣指令的源操作数与表项中的结果寄存器存在相同，表示存在RAW相关性
assign oitfrd_match_disprs1 = |rd_match_rs1idx;
assign oitfrd_match_disprs2 = |rd_match_rs2idx;
assign oitfrd_match_disprs3 = |rd_match_rs3idx;
// 派遣指令的结果与表项中的结果寄存器存在相同，表示存在WAW相关性
assign oitfrd_match_disprd = |rd_match_rdidx;

assign ret_rdidx = rdidx_r[ret_ptr];
assign ret_pc = pc_r[ret_ptr];
assign ret_rdwen = rdwen_r[ret_ptr];

endmodule