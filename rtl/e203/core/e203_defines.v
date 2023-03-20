`include "config.v"

`ifdef E203_CFG_ADDR_SIZE_IS_16
  `define E203_PC_SIZE 16
`endif
`ifdef E203_CFG_ADDR_SIZE_IS_24
  `define E203_PC_SIZE 24
`endif
`ifdef E203_CFG_ADDR_SIZE_IS_32
  `define E203_PC_SIZE 32
`endif

`define E203_INSTR_SIZE 32

`define E203_RFIDX_WIDTH 5

`define E203_XLEN 32

`define E203_DECINFO_GRP_WIDTH 3
`define E203_DECINFO_GRP_ALU `E203_DECINFO_GRP_WIDTH'd0
`define E203_DECINFO_GRP_AGU `E203_DECINFO_GRP_WIDTH'd1
`define E203_DECINFO_GRP_BJP `E203_DECINFO_GRP_WIDTH'd2
`define E203_DECINFO_GRP_CSR `E203_DECINFO_GRP_WIDTH'd3
`define E203_DECINFO_GRP_MULDIV `E203_DECINFO_GRP_WIDTH'd4
`define E203_DECINFO_GRP_EAI `E203_DECINFO_GRP_WIDTH'd5
`define E203_DECINFO_GRP_FPU `E203_DECINFO_GRP_WIDTH'd6

`define E203_DECINFO_GRP_LSB 0
`define E203_DECINFO_GRP_MSB (`E203_DECINFO_GRP_LSB + `E203_DECINFO_GRP_WIDTH - 1)
`define E203_DECINFO_GRP `E203_DECINFO_GRP_MSB:`E203_DECINFO_GRP_LSB
`define E203_DECINFO_RV32_LSB (`E203_DECINFO_GRP_MSB + 1)
`define E203_DECINFO_RV32_MSB (`E203_DECINFO_RV32_LSB + 1 - 1) // TODO: why +1 -1
`define E203_DECINFO_RV32 `E203_DECINFO_RV32_MSB:`E203_DECINFO_RV32_LSB

`define E203_DECINFO_SUBDECINFO_LSB (`E203_DECINFO_RV32_MSB + 1)

`define E203_DECINFO_ALU_ADD_LSB `E203_DECINFO_SUBDECINFO_LSB
`define E203_DECINFO_ALU_ADD_MSB (`E203_DECINFO_ALU_ADD_LSB + 1 - 1)
`define E203_DECINFO_ALU_ADD `E203_DECINFO_ALU_ADD_MSB:`E203_DECINFO_ALU_ADD_LSB

`define E203_DECINFO_ALU_SUB_LSB `E203_DECINFO_ALU_ADD_MSB + 1
`define E203_DECINFO_ALU_SUB_MSB (`E203_DECINFO_ALU_SUB_LSB + 1 - 1)
`define E203_DECINFO_ALU_SUB `E203_DECINFO_ALU_SUB_MSB:`E203_DECINFO_ALU_SUB_LSB

`define E203_DECINFO_ALU_XOR_LSB `E203_DECINFO_ALU_SUB_MSB + 1
`define E203_DECINFO_ALU_XOR_MSB (`E203_DECINFO_ALU_XOR_LSB + 1 - 1)
`define E203_DECINFO_ALU_XOR `E203_DECINFO_ALU_XOR_MSB:`E203_DECINFO_ALU_XOR_LSB

`define E203_DECINFO_ALU_SLL_LSB `E203_DECINFO_ALU_XOR_MSB + 1
`define E203_DECINFO_ALU_SLL_MSB (`E203_DECINFO_ALU_SLL_LSB + 1 - 1)
`define E203_DECINFO_ALU_SLL `E203_DECINFO_ALU_SLL_MSB:`E203_DECINFO_ALU_SLL_LSB

`define E203_DECINFO_ALU_SRL_LSB `E203_DECINFO_ALU_SLL_MSB + 1
`define E203_DECINFO_ALU_SRL_MSB (`E203_DECINFO_ALU_SRL_LSB + 1 - 1)
`define E203_DECINFO_ALU_SRL `E203_DECINFO_ALU_SRL_MSB:`E203_DECINFO_ALU_SRL_LSB

`define E203_DECINFO_ALU_SRA_LSB `E203_DECINFO_ALU_SRL_MSB + 1
`define E203_DECINFO_ALU_SRA_MSB (`E203_DECINFO_ALU_SRA_LSB + 1 - 1)
`define E203_DECINFO_ALU_SRA `E203_DECINFO_ALU_SRA_MSB:`E203_DECINFO_ALU_SRA_LSB

`define E203_DECINFO_ALU_OR_LSB `E203_DECINFO_ALU_SRA_MSB + 1
`define E203_DECINFO_ALU_OR_MSB (`E203_DECINFO_ALU_OR_LSB + 1 - 1)
`define E203_DECINFO_ALU_OR `E203_DECINFO_ALU_OR_MSB:`E203_DECINFO_ALU_OR_LSB

`define E203_DECINFO_ALU_AND_LSB `E203_DECINFO_ALU_OR_MSB + 1
`define E203_DECINFO_ALU_AND_MSB (`E203_DECINFO_ALU_AND_LSB + 1 - 1)
`define E203_DECINFO_ALU_AND `E203_DECINFO_ALU_AND_MSB:`E203_DECINFO_ALU_AND_LSB

`define E203_DECINFO_ALU_SLT_LSB `E203_DECINFO_ALU_AND_MSB + 1
`define E203_DECINFO_ALU_SLT_MSB (`E203_DECINFO_ALU_SLT_LSB + 1 - 1)
`define E203_DECINFO_ALU_SLT `E203_DECINFO_ALU_SLT_MSB:`E203_DECINFO_ALU_SLT_LSB

`define E203_DECINFO_ALU_SLTU_LSB `E203_DECINFO_ALU_SLT_MSB + 1
`define E203_DECINFO_ALU_SLTU_MSB (`E203_DECINFO_ALU_SLTU_LSB + 1 - 1)
`define E203_DECINFO_ALU_SLTU `E203_DECINFO_ALU_SLTU_MSB:`E203_DECINFO_ALU_SLTU_LSB

`define E203_DECINFO_ALU_LUI_LSB `E203_DECINFO_ALU_SLTU_MSB + 1
`define E203_DECINFO_ALU_LUI_MSB (`E203_DECINFO_ALU_LUI_LSB + 1 - 1)
`define E203_DECINFO_ALU_LUI `E203_DECINFO_ALU_LUI_MSB:`E203_DECINFO_ALU_LUI_LSB

`define E203_DECINFO_ALU_OP2IMM_LSB `E203_DECINFO_ALU_LUI_MSB + 1
`define E203_DECINFO_ALU_OP2IMM_MSB (`E203_DECINFO_ALU_OP2IMM_LSB + 1 - 1)
`define E203_DECINFO_ALU_OP2IMM `E203_DECINFO_ALU_OP2IMM_MSB:`E203_DECINFO_ALU_OP2IMM_LSB

`define E203_DECINFO_ALU_OP1PC_LSB `E203_DECINFO_ALU_OP2IMM_MSB + 1
`define E203_DECINFO_ALU_OP1PC_MSB (`E203_DECINFO_ALU_OP1PC_LSB + 1 - 1)
`define E203_DECINFO_ALU_OP1PC `E203_DECINFO_ALU_OP1PC_MSB:`E203_DECINFO_ALU_OP1PC_LSB

`define E203_DECINFO_ALU_NOP_LSB `E203_DECINFO_ALU_OP1PC_MSB + 1
`define E203_DECINFO_ALU_NOP_MSB (`E203_DECINFO_ALU_NOP_LSB + 1 - 1)
`define E203_DECINFO_ALU_NOP `E203_DECINFO_ALU_NOP_MSB:`E203_DECINFO_ALU_NOP_LSB

`define E203_DECINFO_ALU_ECAL_LSB `E203_DECINFO_ALU_NOP_MSB + 1
`define E203_DECINFO_ALU_ECAL_MSB (`E203_DECINFO_ALU_ECAL_LSB + 1 - 1)
`define E203_DECINFO_ALU_ECAL `E203_DECINFO_ALU_ECAL_MSB:`E203_DECINFO_ALU_ECAL_LSB

`define E203_DECINFO_ALU_EBRK_LSB `E203_DECINFO_ALU_ECAL_MSB + 1
`define E203_DECINFO_ALU_EBRK_MSB (`E203_DECINFO_ALU_EBRK_LSB + 1 - 1)
`define E203_DECINFO_ALU_EBRK `E203_DECINFO_ALU_EBRK_MSB:`E203_DECINFO_ALU_EBRK_LSB

`define E203_DECINFO_ALU_WFI_LSB `E203_DECINFO_ALU_EBRK_MSB + 1
`define E203_DECINFO_ALU_WFI_MSB (`E203_DECINFO_ALU_WFI_LSB + 1 - 1)
`define E203_DECINFO_ALU_WFI `E203_DECINFO_ALU_WFI_MSB:`E203_DECINFO_ALU_WFI_LSB

`define E203_DECINFO_ALU_WIDTH (`E203_DECINFO_ALU_WFI_MSB + 1)

`define E203_DECINFO_AGU_LOAD_LSB `E203_DECINFO_SUBDECINFO_LSB
`define E203_DECINFO_AGU_LOAD_MSB (`E203_DECINFO_AGU_LOAD_LSB + 1 - 1)
`define E203_DECINFO_AGU_LOAD `E203_DECINFO_AGU_LOAD_MSB:`E203_DECINFO_AGU_LOAD_LSB

`define E203_DECINFO_AGU_STORE_LSB `E203_DECINFO_AGU_LOAD_MSB + 1
`define E203_DECINFO_AGU_STORE_MSB (`E203_DECINFO_AGU_STORE_LSB + 1 - 1)
`define E203_DECINFO_AGU_STORE `E203_DECINFO_AGU_STORE_MSB:`E203_DECINFO_AGU_STORE_LSB

`define E203_DECINFO_AGU_SIZE_LSB `E203_DECINFO_AGU_STORE_MSB + 1
`define E203_DECINFO_AGU_SIZE_MSB (`E203_DECINFO_AGU_SIZE_LSB + 1 - 1)
`define E203_DECINFO_AGU_SIZE `E203_DECINFO_AGU_SIZE_MSB:`E203_DECINFO_AGU_SIZE_LSB

`define E203_DECINFO_AGU_USIGN_LSB `E203_DECINFO_AGU_SIZE_MSB + 1
`define E203_DECINFO_AGU_USIGN_MSB (`E203_DECINFO_AGU_USIGN_LSB + 1 - 1)
`define E203_DECINFO_AGU_USIGN `E203_DECINFO_AGU_USIGN_MSB:`E203_DECINFO_AGU_USIGN_LSB

`define E203_DECINFO_AGU_EXCL_LSB `E203_DECINFO_AGU_USIGN_MSB + 1
`define E203_DECINFO_AGU_EXCL_MSB (`E203_DECINFO_AGU_EXCL_LSB + 1 - 1)
`define E203_DECINFO_AGU_EXCL `E203_DECINFO_AGU_EXCL_MSB:`E203_DECINFO_AGU_EXCL_LSB

`define E203_DECINFO_AGU_AMO_LSB `E203_DECINFO_AGU_EXCL_MSB + 1
`define E203_DECINFO_AGU_AMO_MSB (`E203_DECINFO_AGU_AMO_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMO `E203_DECINFO_AGU_AMO_MSB:`E203_DECINFO_AGU_AMO_LSB

`define E203_DECINFO_AGU_AMOSWAP_LSB `E203_DECINFO_AGU_AMO_MSB + 1
`define E203_DECINFO_AGU_AMOSWAP_MSB (`E203_DECINFO_AGU_AMOSWAP_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMOSWAP `E203_DECINFO_AGU_AMOSWAP_MSB:`E203_DECINFO_AGU_AMOSWAP_LSB

`define E203_DECINFO_AGU_AMOADD_LSB `E203_DECINFO_AGU_AMOSWAP_MSB + 1
`define E203_DECINFO_AGU_AMOADD_MSB (`E203_DECINFO_AGU_AMOADD_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMOADD `E203_DECINFO_AGU_AMOADD_MSB:`E203_DECINFO_AGU_AMOADD_LSB

`define E203_DECINFO_AGU_AMOAND_LSB `E203_DECINFO_AGU_AMOADD_MSB + 1
`define E203_DECINFO_AGU_AMOAND_MSB (`E203_DECINFO_AGU_AMOAND_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMOAND `E203_DECINFO_AGU_AMOAND_MSB:`E203_DECINFO_AGU_AMOAND_LSB

`define E203_DECINFO_AGU_AMOOR_LSB `E203_DECINFO_AGU_AMOAND_MSB + 1
`define E203_DECINFO_AGU_AMOOR_MSB (`E203_DECINFO_AGU_AMOOR_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMOOR `E203_DECINFO_AGU_AMOOR_MSB:`E203_DECINFO_AGU_AMOOR_LSB

`define E203_DECINFO_AGU_AMOXOR_LSB `E203_DECINFO_AGU_AMOOR_MSB + 1
`define E203_DECINFO_AGU_AMOXOR_MSB (`E203_DECINFO_AGU_AMOXOR_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMOXOR `E203_DECINFO_AGU_AMOXOR_MSB:`E203_DECINFO_AGU_AMOXOR_LSB

`define E203_DECINFO_AGU_AMOMAX_LSB `E203_DECINFO_AGU_AMOXOR_MSB + 1
`define E203_DECINFO_AGU_AMOMAX_MSB (`E203_DECINFO_AGU_AMOMAX_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMOMAX `E203_DECINFO_AGU_AMOMAX_MSB:`E203_DECINFO_AGU_AMOMAX_LSB

`define E203_DECINFO_AGU_AMOMIN_LSB `E203_DECINFO_AGU_AMOMAX_MSB + 1
`define E203_DECINFO_AGU_AMOMIN_MSB (`E203_DECINFO_AGU_AMOMIN_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMOMIN `E203_DECINFO_AGU_AMOMIN_MSB:`E203_DECINFO_AGU_AMOMIN_LSB

`define E203_DECINFO_AGU_AMOMAXU_LSB `E203_DECINFO_AGU_AMOMIN_MSB + 1
`define E203_DECINFO_AGU_AMOMAXU_MSB (`E203_DECINFO_AGU_AMOMAXU_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMOMAXU `E203_DECINFO_AGU_AMOMAXU_MSB:`E203_DECINFO_AGU_AMOMAXU_LSB

`define E203_DECINFO_AGU_AMOMINU_LSB `E203_DECINFO_AGU_AMOMAXU_MSB + 1
`define E203_DECINFO_AGU_AMOMINU_MSB (`E203_DECINFO_AGU_AMOMINU_LSB + 1 - 1)
`define E203_DECINFO_AGU_AMOMINU `E203_DECINFO_AGU_AMOMINU_MSB:`E203_DECINFO_AGU_AMOMINU_LSB

`define E203_DECINFO_AGU_OP2IMM_LSB `E203_DECINFO_AGU_AMOMINU_MSB + 1
`define E203_DECINFO_AGU_OP2IMM_MSB (`E203_DECINFO_AGU_OP2IMM_LSB + 1 - 1)
`define E203_DECINFO_AGU_OP2IMM `E203_DECINFO_AGU_OP2IMM_MSB:`E203_DECINFO_AGU_OP2IMM_LSB

`define E203_DECINFO_AGU_WIDTH (`E203_DECINFO_AGU_OP2IMM_MSB + 1)

`define E203_DECINFO_BJP_JUMP_LSB `E203_DECINFO_SUBDECINFO_LSB
`define E203_DECINFO_BJP_JUMP_MSB (`E203_DECINFO_BJP_JUMP_LSB + 1 - 1)
`define E203_DECINFO_BJP_JUMP `E203_DECINFO_BJP_JUMP_MSB:`E203_DECINFO_BJP_JUMP_LSB

`define E203_DECINFO_BJP_BPRDT_LSB `E203_DECINFO_BJP_JUMP_MSB + 1
`define E203_DECINFO_BJP_BPRDT_MSB (`E203_DECINFO_BJP_BPRDT_LSB + 1 - 1)
`define E203_DECINFO_BJP_BPRDT `E203_DECINFO_BJP_BPRDT_MSB:`E203_DECINFO_BJP_BPRDT_LSB

`define E203_DECINFO_BJP_BEQ_LSB `E203_DECINFO_BJP_BPRDT_MSB + 1
`define E203_DECINFO_BJP_BEQ_MSB (`E203_DECINFO_BJP_BEQ_LSB + 1 - 1)
`define E203_DECINFO_BJP_BEQ `E203_DECINFO_BJP_BEQ_MSB:`E203_DECINFO_BJP_BEQ_LSB

`define E203_DECINFO_BJP_BNE_LSB `E203_DECINFO_BJP_BEQ_MSB + 1
`define E203_DECINFO_BJP_BNE_MSB (`E203_DECINFO_BJP_BNE_LSB + 1 - 1)
`define E203_DECINFO_BJP_BNE `E203_DECINFO_BJP_BNE_MSB:`E203_DECINFO_BJP_BNE_LSB

`define E203_DECINFO_BJP_BLT_LSB `E203_DECINFO_BJP_BNE_MSB + 1
`define E203_DECINFO_BJP_BLT_MSB (`E203_DECINFO_BJP_BLT_LSB + 1 - 1)
`define E203_DECINFO_BJP_BLT `E203_DECINFO_BJP_BLT_MSB:`E203_DECINFO_BJP_BLT_LSB

`define E203_DECINFO_BJP_BGT_LSB `E203_DECINFO_BJP_BLT_MSB + 1
`define E203_DECINFO_BJP_BGT_MSB (`E203_DECINFO_BJP_BGT_LSB + 1 - 1)
`define E203_DECINFO_BJP_BGT `E203_DECINFO_BJP_BGT_MSB:`E203_DECINFO_BJP_BGT_LSB

`define E203_DECINFO_BJP_BLTU_LSB `E203_DECINFO_BJP_BGT_MSB + 1
`define E203_DECINFO_BJP_BLTU_MSB (`E203_DECINFO_BJP_BLTU_LSB + 1 - 1)
`define E203_DECINFO_BJP_BLTU `E203_DECINFO_BJP_BLTU_MSB:`E203_DECINFO_BJP_BLTU_LSB

`define E203_DECINFO_BJP_BGTU_LSB `E203_DECINFO_BJP_BLTU_MSB + 1
`define E203_DECINFO_BJP_BGTU_MSB (`E203_DECINFO_BJP_BGTU_LSB + 1 - 1)
`define E203_DECINFO_BJP_BGTU `E203_DECINFO_BJP_BGTU_MSB:`E203_DECINFO_BJP_BGTU_LSB

`define E203_DECINFO_BJP_BXX_LSB `E203_DECINFO_BJP_BGTU_MSB + 1
`define E203_DECINFO_BJP_BXX_MSB (`E203_DECINFO_BJP_BXX_LSB + 1 - 1)
`define E203_DECINFO_BJP_BXX `E203_DECINFO_BJP_BXX_MSB:`E203_DECINFO_BJP_BXX_LSB

`define E203_DECINFO_BJP_MRET_LSB `E203_DECINFO_BJP_BXX_MSB + 1
`define E203_DECINFO_BJP_MRET_MSB (`E203_DECINFO_BJP_MRET_LSB + 1 - 1)
`define E203_DECINFO_BJP_MRET `E203_DECINFO_BJP_MRET_MSB:`E203_DECINFO_BJP_MRET_LSB

`define E203_DECINFO_BJP_DRET_LSB `E203_DECINFO_BJP_MRET_MSB + 1
`define E203_DECINFO_BJP_DRET_MSB (`E203_DECINFO_BJP_DRET_LSB + 1 - 1)
`define E203_DECINFO_BJP_DRET `E203_DECINFO_BJP_DRET_MSB:`E203_DECINFO_BJP_DRET_LSB

`define E203_DECINFO_BJP_FENCE_LSB `E203_DECINFO_BJP_DRET_MSB + 1
`define E203_DECINFO_BJP_FENCE_MSB (`E203_DECINFO_BJP_FENCE_LSB + 1 - 1)
`define E203_DECINFO_BJP_FENCE `E203_DECINFO_BJP_FENCE_MSB:`E203_DECINFO_BJP_FENCE_LSB

`define E203_DECINFO_BJP_FENCEI_LSB `E203_DECINFO_BJP_FENCE_MSB + 1
`define E203_DECINFO_BJP_FENCEI_MSB (`E203_DECINFO_BJP_FENCEI_LSB + 1 - 1)
`define E203_DECINFO_BJP_FENCEI `E203_DECINFO_BJP_FENCEI_MSB:`E203_DECINFO_BJP_FENCEI_LSB

`define E203_DECINFO_BJP_WIDTH (`E203_DECINFO_BJP_FENCEI_MSB + 1)

`define E203_DECINFO_CSR_CSRRW_LSB `E203_DECINFO_SUBDECINFO_LSB
`define E203_DECINFO_CSR_CSRRW_MSB (`E203_DECINFO_CSR_CSRRW_LSB + 1 - 1)
`define E203_DECINFO_CSR_CSRRW `E203_DECINFO_CSR_CSRRW_MSB:`E203_DECINFO_CSR_CSRRW_LSB

`define E203_DECINFO_CSR_CSRRS_LSB `E203_DECINFO_CSR_CSRRW_MSB + 1
`define E203_DECINFO_CSR_CSRRS_MSB (`E203_DECINFO_CSR_CSRRS_LSB + 1 - 1)
`define E203_DECINFO_CSR_CSRRS `E203_DECINFO_CSR_CSRRS_MSB:`E203_DECINFO_CSR_CSRRS_LSB

`define E203_DECINFO_CSR_CSRRC_LSB `E203_DECINFO_CSR_CSRRS_MSB + 1
`define E203_DECINFO_CSR_CSRRC_MSB (`E203_DECINFO_CSR_CSRRC_LSB + 1 - 1)
`define E203_DECINFO_CSR_CSRRC `E203_DECINFO_CSR_CSRRC_MSB:`E203_DECINFO_CSR_CSRRC_LSB

`define E203_DECINFO_CSR_RS1IMM_LSB `E203_DECINFO_CSR_CSRRC_MSB + 1
`define E203_DECINFO_CSR_RS1IMM_MSB (`E203_DECINFO_CSR_RS1IMM_LSB + 1 - 1)
`define E203_DECINFO_CSR_RS1IMM `E203_DECINFO_CSR_RS1IMM_MSB:`E203_DECINFO_CSR_RS1IMM_LSB

`define E203_DECINFO_CSR_ZIMMM_LSB `E203_DECINFO_CSR_RS1IMM_MSB + 1
`define E203_DECINFO_CSR_ZIMMM_MSB (`E203_DECINFO_CSR_ZIMMM_LSB + 1 - 1)
`define E203_DECINFO_CSR_ZIMMM `E203_DECINFO_CSR_ZIMMM_MSB:`E203_DECINFO_CSR_ZIMMM_LSB

`define E203_DECINFO_CSR_RS1IS0_LSB `E203_DECINFO_CSR_ZIMMM_MSB + 1
`define E203_DECINFO_CSR_RS1IS0_MSB (`E203_DECINFO_CSR_RS1IS0_LSB + 1 - 1)
`define E203_DECINFO_CSR_RS1IS0 `E203_DECINFO_CSR_RS1IS0_MSB:`E203_DECINFO_CSR_RS1IS0_LSB

`define E203_DECINFO_CSR_CSRIDX_LSB `E203_DECINFO_CSR_RS1IS0_MSB + 1
`define E203_DECINFO_CSR_CSRIDX_MSB (`E203_DECINFO_CSR_CSRIDX_LSB + 1 - 1)
`define E203_DECINFO_CSR_CSRIDX `E203_DECINFO_CSR_CSRIDX_MSB:`E203_DECINFO_CSR_CSRIDX_LSB

`define E203_DECINFO_CSR_WIDTH (`E203_DECINFO_CSR_CSRIDX_MSB + 1)

`define E203_DECINFO_MULDIV_MUL_LSB `E203_DECINFO_SUBDECINFO_LSB
`define E203_DECINFO_MULDIV_MUL_MSB (`E203_DECINFO_MULDIV_MUL_LSB + 1 - 1)
`define E203_DECINFO_MULDIV_MUL `E203_DECINFO_MULDIV_MUL_MSB:`E203_DECINFO_MULDIV_MUL_LSB

`define E203_DECINFO_MULDIV_MULH_LSB `E203_DECINFO_MULDIV_MUL_MSB + 1
`define E203_DECINFO_MULDIV_MULH_MSB (`E203_DECINFO_MULDIV_MULH_LSB + 1 - 1)
`define E203_DECINFO_MULDIV_MULH `E203_DECINFO_MULDIV_MULH_MSB:`E203_DECINFO_MULDIV_MULH_LSB

`define E203_DECINFO_MULDIV_MULHSU_LSB `E203_DECINFO_MULDIV_MULH_MSB + 1
`define E203_DECINFO_MULDIV_MULHSU_MSB (`E203_DECINFO_MULDIV_MULHSU_LSB + 1 - 1)
`define E203_DECINFO_MULDIV_MULHSU `E203_DECINFO_MULDIV_MULHSU_MSB:`E203_DECINFO_MULDIV_MULHSU_LSB

`define E203_DECINFO_MULDIV_MULHU_LSB `E203_DECINFO_MULDIV_MULHSU_MSB + 1
`define E203_DECINFO_MULDIV_MULHU_MSB (`E203_DECINFO_MULDIV_MULHU_LSB + 1 - 1)
`define E203_DECINFO_MULDIV_MULHU `E203_DECINFO_MULDIV_MULHU_MSB:`E203_DECINFO_MULDIV_MULHU_LSB

`define E203_DECINFO_MULDIV_DIV_LSB `E203_DECINFO_MULDIV_MULHU_MSB + 1
`define E203_DECINFO_MULDIV_DIV_MSB (`E203_DECINFO_MULDIV_DIV_LSB + 1 - 1)
`define E203_DECINFO_MULDIV_DIV `E203_DECINFO_MULDIV_DIV_MSB:`E203_DECINFO_MULDIV_DIV_LSB

`define E203_DECINFO_MULDIV_DIVU_LSB `E203_DECINFO_MULDIV_DIV_MSB + 1
`define E203_DECINFO_MULDIV_DIVU_MSB (`E203_DECINFO_MULDIV_DIVU_LSB + 1 - 1)
`define E203_DECINFO_MULDIV_DIVU `E203_DECINFO_MULDIV_DIVU_MSB:`E203_DECINFO_MULDIV_DIVU_LSB

`define E203_DECINFO_MULDIV_REM_LSB `E203_DECINFO_MULDIV_DIVU_MSB + 1
`define E203_DECINFO_MULDIV_REM_MSB (`E203_DECINFO_MULDIV_REM_LSB + 1 - 1)
`define E203_DECINFO_MULDIV_REM `E203_DECINFO_MULDIV_REM_MSB:`E203_DECINFO_MULDIV_REM_LSB

`define E203_DECINFO_MULDIV_REMU_LSB `E203_DECINFO_MULDIV_REM_MSB + 1
`define E203_DECINFO_MULDIV_REMU_MSB (`E203_DECINFO_MULDIV_REMU_LSB + 1 - 1)
`define E203_DECINFO_MULDIV_REMU `E203_DECINFO_MULDIV_REMU_MSB:`E203_DECINFO_MULDIV_REMU_LSB

`define E203_DECINFO_MULDIV_B2B_LSB `E203_DECINFO_MULDIV_REMU_MSB + 1
`define E203_DECINFO_MULDIV_B2B_MSB (`E203_DECINFO_MULDIV_B2B_LSB + 1 - 1)
`define E203_DECINFO_MULDIV_B2B `E203_DECINFO_MULDIV_B2B_MSB:`E203_DECINFO_MULDIV_B2B_LSB

`define E203_DECINFO_MULDIV_WIDTH (`E203_DECINFO_MULDIV_B2B_MSB + 1)

`define E203_DECINFO_WIDTH 32 // TODO: should be modified

`define E203_INSTR_SIZE 32