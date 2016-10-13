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


// pc variables
logic [31:0] pc_in;
logic [31:0] pc_out;  //goes to instruction memory
/*it's pc_out+1 which should be an input to a mux to decide in case of jump or branch*/
logic [31:0] next_pc;

pc pc(.clk(clk), .reset(reset), .pc_in(pc_in), .pc_out(pc_out), .next_pc(next_pc));

// instruction memory variables
logic im_rw = 1;  //always 1 because we always read from instruction memory
logic [1:0] im_access_sz = sz_word;
logic busy_inst_mm;
logic [31:0] instruction; //the instruction address from inst_memory

memory inst_memory(.clk(clk), .addr(pc), .data_in(pc_out), .access_size(sz_word), .rd_wr(im_rw),
  .enable(~reset), .data_out(instruction), .busy(busy_inst_mm));

//decoder variables
logic [4:0] rs;
logic [4:0] rt;
logic [4:0] rd;
logic [4:0] shift_amount;
logic [5:0] func;
logic [15:0] imm;

decode decoder(.instruction(instruction), .rs(rs), .rt(rt), .rd(rd),
  .shift_amount(shift_amount), .func(func), .imm(imm));


//regfile variables
logic [4:0] target_reg; //the target register if we are writing on regFile
logic [31:0] wr_data_reg; //the data which will be written on target register
logic wr_en_reg; //to enable writing on regfile
logic [31:0] rd0_data; //the data coming out from rt
logic [31:0] rd1_data; //the data coming out from rd

regfile regfile(.clk(clk), .wr_num(target_reg), .wr_data(wr_data_reg), .wr_en(wr_en_reg),
  .rd0_num(rd), .rd0_data(rd0_data), .rd1_num(rt), .rd1_data(rd1_data));




logic dm_rw = 1;  //need to be implemented
logic [31:0] data_out_mem;  //the output from data memory
logic busy_data_mm;  //a signal indicates if the data memory is busy

memory data_memory(.clk(clk), .addr(pc), .data_in(data_in), .access_size(sz_word), .rd_wr(im_rw),
  .enable(~reset), .data_out(data_out), .busy(busy_data_mm));


endmodule
