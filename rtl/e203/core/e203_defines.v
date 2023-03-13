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