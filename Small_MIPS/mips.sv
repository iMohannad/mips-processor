/*
 * li       001001
 * sw       101011
 * lw       100011
 * mv       000000
 * ADDIU    001001
 * AddU     000000
 */

module mips (
    input clk,
    input reset,
    output [31:0] instr_addr,
    output [31:0] instr_in,
    output [31:0] data_addr,
    output [31:0] data_in,
    output data_rd_wr,
    output [31:0] data_out
);

`include "params.sv"


parameter [31:0] pc_init = 0;
parameter [31:0] sp_init = 0;
parameter [31:0] ra_init = 0;

//Counter to count the stages and do a specific stages
logic [2:0] counter = 0;

// pc variables
logic [31:0] pc_in;
logic [31:0] pc_out;  //goes to instruction memory
logic [31:0] next_pc; //pc_in + 4


// instruction memory variables
logic im_rw = 1;  //always 1 because we always read from instruction memory
logic [1:0] im_access_sz = sz_word;
logic busy_inst_mm;
reg [31:0] instruction; //the instruction address from inst_memory

assign instr_in = instruction;
assign instr_addr = pc_out;

//decoder variables
logic [4:0] rs;
logic [4:0] rt;
logic [4:0] rd;
logic [4:0] shift_amount;
logic [5:0] func;
logic [15:0] imm;
logic [5:0] opcode;

//regfile variables
logic [31:0] wr_data_reg; //the data which will be written on target register
logic [31:0] rd0_data; //the data coming out from rt
logic [31:0] rd1_data; //the data coming out from rd
wire [4:0] wr_num;  //the register number in writeback stage

//Alu Variables
logic [31:0] data_out_alu;  //data coming out from alu
wire [31:0] op2;
logic aluSrc;
//two registers which saves op1 and op2 repectively to make alu run in 3rd cycle
logic [31:0] A, B;
//logic [31:0] data_alu_reg; //register to hold the data coming out from alu

//DM Variables
logic [31:0] data_out_mem;  //the output from data memory
logic busy_data_mm;  //a signal indicates if the data memory is busy
wire memToReg;  //either takes the data from memory or from ALU in write back stage
wire dm_rw;


//Assigning output for testbench
assign data_addr = data_out_alu;
assign data_in = A;
assign data_out = data_out_mem;
//to assign the output of memory writing to a pin in the processor - used in testbench
assign data_rd_wr = dm_rw;


pc pc(.clk(clk), .reset(reset), .pc_in(pc_in), .pc_out(pc_out), .next_pc(next_pc));



memory inst_memory(.clk(clk), .addr(pc_out), .data_in(pc_out), .access_size(im_access_sz), .rd_wr(im_rw),
  .enable(~reset), .data_out(instruction), .busy(busy_inst_mm));



decode decoder(.instruction(instruction), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd),
  .shift_amount(shift_amount), .func(func), .imm(imm));


//enable writing on register file
wire wr_en_reg = (opcode != 6'b101011 && counter == 4) ? 1 : 0;


assign aluSrc = opcode[3] | opcode[5];

/* wr_num is the register we are writing back into in regFile.
 * if it's load instruction, the write back register is rt
 * otherwise, it should be rd
 */
 assign wr_num = ((opcode == 6'b001001) | (opcode == 6'b100011) | aluSrc) ? rt : rd;


regfile #(.sp_init(mem_start+mem_depth), .ra_init(0))
  regs(.clk(clk), .reset(reset), .wr_num(wr_num), .wr_data(wr_data_reg), .wr_en(wr_en_reg),
  .rd0_num(rs), .rd0_data(rd0_data), .rd1_num(rt), .rd1_data(rd1_data));


//mux to decide which input should go to ALU.
assign  op2 = aluSrc ? {{16{imm[15]}}, imm[15:0]} : rd1_data;



alu alu(.op1(A), .op2(B), .opcode(opcode), .ar_op(func), .shift_amount(shift_amount), .data_out_alu(data_out_alu));


//dm_rw sets to 0 (writing) in case of store word only.
//counter is checked to avoid wriing previous or subsequent instructions
assign dm_rw = (opcode == 6'b101011 && counter == 3) ? 0 : 1;


memory data_memory(.clk(clk), .addr(data_out_alu), .data_in(rd1_data), .access_size(im_access_sz), .rd_wr(dm_rw),
  .enable(~reset), .data_out(data_out_mem), .busy(busy_data_mm));


//only if load we take data from memory
assign memToReg = (opcode == 6'b100011) ? 1 : 0;

always @ ( * ) begin
  if(memToReg) wr_data_reg = data_out_mem;
  else wr_data_reg = data_out_alu;
end




/* Control Unit */
always @ (posedge clk) begin
  if (reset) begin
    pc_in <= mem_start;
    counter <= 0;

  end
  else begin
    case (counter)
      0: begin
        counter <= counter + 1;
      end
      1: begin
        //Save the output of regFile in two registers in order to have it next cycle
        A <= rd0_data;
        B <= op2;
        counter <= counter + 1;
      end
      2: begin
        counter <= counter + 1;
      end
      3: begin
        //in case of jump, assign PC the output of rs register
        /* It's defined here because PC_in wil take one full cycle to be assigned
         * and then, PC block will take 1 cycle to get the next pc_out which will
         * be the input of the instruction memory
         */
        if(rs == 5'b11111 && func == 6'b001000) begin
          pc_in <= A;
        end else begin
          pc_in <= next_pc;
        end
        counter <= counter + 1;
      end
      4: begin
        counter <= 0;
      end

    endcase
  end //else statement
end //always

endmodule
