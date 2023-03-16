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

`define E203_DECINFO_ALU_WIDTH 32 // TODO: should be modified

`define E203_DECINFO_AGU_WIDTH 32 // TODO: should be modified

`define E203_DECINFO_BJP_WIDTH 32 // TODO: should be modified

`define E203_DECINFO_CSR_WIDTH 32 // TODO: should be modified

`define E203_DECINFO_MULDIV_WIDTH 32 // TODO: should be modified

`define E203_DECINFO_WIDTH 32 // TODO: should be modified

`define E203_INSTR_SIZE 32