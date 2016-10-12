module processor {
    input clk,
    input reset,
    input [31:0] instr_addr,
    input instr_in,
    input [31:0] data_addr,
    input [31:0] data_in,
    input data_rd_wr,
    output [31:0] data_out
};

`include "params.sv"


parameter [31:0] pc_init = 0;
parameter [31:0] sp_init = 0;
parameter [31:0] ra_init = 0;
