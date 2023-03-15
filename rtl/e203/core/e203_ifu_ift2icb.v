`include "e203_defines.v"

module e203_ifu_ift2icb(
  input itcm_nohold,

  input ifu_req_valid,
  output ifu_req_ready,
  input [`E203_PC_SIZE-1:0] ifu_req_pc,
  input ifu_req_seq,
  input ifu_req_seq_rv32,
  input [`E203_PC_SIZE-1:0] ifu_req_last_pc,

  output ifu_rsp_valid,
  input ifu_rsp_ready,
  output ifu_rsp_err,
  output [32-1:0] ifu_rsp_instr,

  `ifdef E203_HAS_ITCM //{
    input [`E203_ADDR_SIZE-1:0] itcm_region_indic,
    output ifu2itcm_icb_cmd_valid,
    input ifu2itcm_icb_cmd_ready,
    output [`E203_ITCM_ADDR_WIDTH-1:0] ifu2itcm_icb_cmd_addr,

    input ifu2ictm_icb_rsp_valid,
    output ifu2ictm_icb_rsp_ready,
    input ifu2ictm_icb_rsp_err,
    input [`E203_ITCM_DATA_WIDTH-1:0] ifu2ictm_icb_rsp_rdata,

    input ifu2ictm_holdup,
    `endif//}

    `ifdef E203_HAS_MEM_ITF //{
      output ifu2biu_icb_cmd_valid,
      input ifu2biu_icb_cmd_ready,
      output [`E203_ADDR_SIZE-1:0] ifu2biu_icb_cmd_addr,

      input ifu2biu_icb_rsp_valid,
      output ifu2biu_icb_rsp_ready,
      input ifu2biu_icb_rsp_err,
      input [`E203_SYSTEM_DATA_WIDTH-1:0] ifu2biu_icb_rsp_rdata,
    `endif//}

    input clk,
    input rst_n
);

endmodule