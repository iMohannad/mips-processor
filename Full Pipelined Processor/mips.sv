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
    output [1:0] data_access_size,
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

parameter mem_variable = "SimpleIf.x";


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

//DM Variables
logic [31:0] data_out_mem;  //the output from data memory
logic busy_data_mm;  //a signal indicates if the data memory is busy
wire dm_rw;
logic [1:0] dm_access_sz;


//Pipeline Wires
//IF/ID
wire [31:0] pc_if_id;
wire [31:0] IR_if_id;

//ID/EX
wire [5:0] opcode_id_ex;
wire aluSrc_id_ex;
wire [15:0] imm_id_ex;
wire wr_en_reg_id_ex;
wire [4:0] wr_num_id_ex;
wire dm_rw_id_ex;
wire [1:0] dm_access_sz_id_ex;
wire [31:0] rd0_data_id_ex;
wire [31:0] rd1_data_id_ex;
wire [4:0] shift_amount_id_ex;
wire [5:0] func_id_ex;
wire [31:0] pc_id_ex;
wire [4:0] rs_id_ex;
wire [4:0] rt_id_ex;

//EX/MM
wire [5:0] opcode_ex_mm;
wire [31:0] data_out_alu_ex_mm;
wire [31:0] rd1_data_ex_mm;
wire [1:0] dm_access_sz_ex_mm;
wire dm_rw_ex_mm;
wire [31:0] pc_ex_mm;
wire wr_en_reg_ex_mm;
wire [4:0] wr_num_ex_mm;


//MM/WB
wire [31:0] data_out_mem_wb;
wire [5:0] opcode_mm_wb;
wire [31:0] pc_mm_wb;
wire [31:0] data_out_alu_wb;
wire [4:0] wr_num_mm_wb;
wire wr_en_reg_mm_wb;



//Assigning output for testbench
assign data_addr = data_out_alu;
assign data_in = rd1_data_ex_mm;
assign data_out = data_out_mem;
//to assign the output of memory writing to a pin in the processor - used in testbench
assign data_rd_wr = dm_rw;


logic stall = 0;
logic stalld = 0;
logic flushx = 0;
logic flushd = 0;
logic flushm = 0;


wire [1:0] forwardA = (wr_en_reg_ex_mm && (wr_num_ex_mm != 0) && (wr_num_ex_mm == rs_id_ex)) ? 2'b01 : (wr_en_reg_mm_wb && (wr_num_mm_wb != 0) && (wr_num_ex_mm != rs_id_ex) && (wr_num_mm_wb == rs_id_ex)) ? 2'b10 : 2'b00;
wire [1:0] forwardB = (wr_en_reg_ex_mm && (wr_num_ex_mm != 0) && (wr_num_ex_mm == rt_id_ex)) ? 2'b01 : (wr_en_reg_mm_wb && (wr_num_mm_wb != 0) && (wr_num_ex_mm != rs_id_ex) && (wr_num_mm_wb == rt_id_ex)) ? 2'b10 : 2'b00;


//************************************************************************************************//

pc pc(.clk(clk), .reset(reset), .pc_in(pc_in), .pc_out(pc_out), .next_pc(next_pc));



memory #(.mem_file(mem_variable))
  inst_memory(.clk(clk), .addr(pc_out), .data_in(pc_out), .access_size(im_access_sz), .rd_wr(im_rw),
  .enable(~reset), .data_out(instruction), .busy(busy_inst_mm));

wire [5:0] opcode_if = instruction[31:26];
wire [4:0] rs_if = instruction[25:21];
wire [4:0] rt_if = instruction[20:16];
wire [15:0] imm_if = instruction[15:0];


if_id if_id(.clk(clk), .stall(stalld), .flush(flushd), .IR(instruction), .pc_out(pc_out), .pc_if_id(pc_if_id), .IR_if_id(IR_if_id));

logic [31:0] IR_reg;

decode decoder(.instruction(IR_if_id), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd),
  .shift_amount(shift_amount), .func(func), .imm(imm));


//enable writing on register file
wire wr_en_reg = ((opcode != 6'b101011 & opcode != 000100 & opcode != 6'b000010 & opcode != 6'b000101 & opcode != 6'b101000)) ? 1 : 0;

//aluSrc decide which is the wright back register.
/* MUL Opcode 011100 will result in aluSrc = 1 which will select rt as the wrtie back register,
 * and since the result of MUL instruction should be written back in rd, I added a condition here
 */
assign aluSrc = (opcode == 6'b011100)? 0 : (opcode[3] | opcode[5]);

/* wr_num is the register we are writing back into in regFile.
 * if it's load instruction, the write back register is rt
 * otherwise, it should be rd
 */
 assign wr_num = (opcode == 6'b000011) ? 31 : (opcode == 6'b011100) ? rd : ((opcode == 6'b001001) | (opcode == 6'b100011) | (opcode == 6'b001010) | aluSrc) ? rt : rd;


regfile #(.sp_init(mem_start+mem_depth), .ra_init(0))
  regs(.clk(clk), .reset(reset), .wr_num(wr_num_mm_wb), .wr_data(wr_data_reg), .wr_en(wr_en_reg_mm_wb),
  .rd0_num(rs), .rd0_data(rd0_data), .rd1_num(rt), .rd1_data(rd1_data));

/* Added this part because I had a problem in case of two loads forward by a load hazard instruction
 * So, the first load will right back in the regfile at the same time the value rd0_data is forwarded
 * to EX stage, so, it doesn't get the right data. I had to manually inforce it to take the right data
 * in this case only
 */
logic [31:0] rd0_datax;
always @ ( * ) begin
  if (opcode_mm_wb == 6'b100011 && stalld == 1) begin
    rd0_datax <= wr_data_reg;
  end else  rd0_datax <= rd0_data;
end

  id_ex id_ex (.clk(clk), .stall(stall), .flush(flushx), .pc_if_id(pc_if_id), .opcode(opcode), .rs(rs), .rt(rt), .aluSrc(aluSrc), .wr_en_reg(wr_en_reg), .wr_num(wr_num), .dm_rw(dm_rw), .dm_access_sz(dm_access_sz),
    .rd0_data(rd0_datax), .rd1_data(rd1_data), .imm(imm), .shift_amount(shift_amount), .func(func), .opcode_id_ex(opcode_id_ex), .aluSrc_id_ex(aluSrc_id_ex),
    .wr_en_reg_id_ex(wr_en_reg_id_ex), .wr_num_id_ex(wr_num_id_ex), .dm_rw_id_ex(dm_rw_id_ex), .dm_access_sz_id_ex(dm_access_sz_id_ex), .rd0_data_id_ex(rd0_data_id_ex),
    .rd1_data_id_ex(rd1_data_id_ex), .imm_id_ex(imm_id_ex), .shift_amount_id_ex(shift_amount_id_ex), .func_id_ex(func_id_ex), .pc_id_ex(pc_id_ex), .rs_id_ex(rs_id_ex), .rt_id_ex(rt_id_ex));


logic [31:0] op1_reg;
logic [31:0] op2_reg;



//forwarding
always @ ( * ) begin
  case (forwardA)
    2'b00: op1_reg <= rd0_data_id_ex;
    2'b01: op1_reg <= data_out_alu_ex_mm;
    2'b10: op1_reg <= wr_data_reg;
    default: op1_reg <= rd0_data_id_ex;
  endcase
  case (forwardB)
    2'b00: op2_reg <= rd1_data_id_ex;
    2'b01: op2_reg <= data_out_alu_ex_mm;
    2'b10: op2_reg <= wr_data_reg;
    default: op2_reg <= rd1_data_id_ex;
  endcase
end


//mux to decide which input should go to ALU.
//if SLTI, take the immidiate. SLTI opcode = 001010
assign  op2 = (aluSrc_id_ex) ? {{16{imm_id_ex[15]}}, imm_id_ex[15:0]} : op2_reg;



alu alu(.op1(op1_reg), .op2(op2), .opcode(opcode_id_ex), .ar_op(func_id_ex), .shift_amount(shift_amount_id_ex), .data_out_alu(data_out_alu));


ex_mm ex_mm(.clk(clk), .data_out_alu(data_out_alu), .rd1_data_id_ex(op2_reg), .opcode_id_ex(opcode_id_ex), .dm_access_sz_id_ex(dm_access_sz_id_ex),
  .dm_rw_id_ex(dm_rw_id_ex), .pc_id_ex(pc_id_ex), .wr_en_reg_id_ex(wr_en_reg_id_ex), .wr_num_id_ex(wr_num_id_ex), .data_out_alu_ex_mm(data_out_alu_ex_mm),
  .rd1_data_ex_mm(rd1_data_ex_mm), .dm_access_sz_ex_mm(dm_access_sz_ex_mm), .dm_rw_ex_mm(dm_rw_ex_mm), .pc_ex_mm(pc_ex_mm),
  .wr_en_reg_ex_mm(wr_en_reg_ex_mm), .wr_num_ex_mm(wr_num_ex_mm), .opcode_ex_mm(opcode_ex_mm), .flushm(flushm));

//dm_rw sets to 0 (writing) in case of store word only.
//counter is checked to avoid wriing previous or subsequent instructions
assign dm_rw = ((opcode == 6'b101011 || opcode == 6'b101000)) ? 0 : 1;


//check if the command is lbu or sb
assign dm_access_sz = ((opcode == 6'b100100) | (opcode == 6'b101000)) ? 2'b00 : 2'b01;

memory #(.mem_file(mem_variable))
  data_memory(.clk(clk), .addr(data_out_alu_ex_mm), .data_in(rd1_data_ex_mm), .access_size(dm_access_sz_ex_mm), .rd_wr(dm_rw_ex_mm),
  .enable(~reset), .data_out(data_out_mem), .busy(busy_data_mm));



mm_wb mm_wb(.clk(clk), .data_out_mem(data_out_mem), .opcode_ex_mm(opcode_ex_mm), .pc_ex_mm(pc_ex_mm), .data_out_alu_ex_mm(data_out_alu_ex_mm),
  .data_out_mem_wb(data_out_mem_wb), .opcode_mm_wb(opcode_mm_wb), .pc_mm_wb(pc_mm_wb), .data_out_alu_wb(data_out_alu_wb), .wr_en_reg_ex_mm(wr_en_reg_ex_mm),
  .wr_en_reg_mm_wb(wr_en_reg_mm_wb), .wr_num_ex_mm(wr_num_ex_mm), .wr_num_mm_wb(wr_num_mm_wb));


//MUX to decide the data written back to regfile
always @ ( * ) begin
  if(opcode_mm_wb == 6'b100011) wr_data_reg = data_out_mem_wb; //in case of load
  else if(opcode_mm_wb == 6'b100100) wr_data_reg = data_out_mem_wb; //LBU
  else if (opcode_mm_wb == 6'b000011) wr_data_reg = pc_mm_wb + 4; //in case of JAL
  else wr_data_reg = data_out_alu_wb;
end

reg [1:0] counterx;

always @ ( * ) begin
  /*
   * IF the instruction in EX stage is a load and its destination register is the
   * same as one of the input registers of the instruction in ID stage, it does
   * the following:
   * 1) stall the IF and ID stages by stopping the cycle of PC.
   * 2) propoagte a NOOP to the EX stage.
   */
   if ((wr_num_id_ex == rs || wr_num_id_ex == rt) && (opcode_id_ex == 6'b100011)) begin
     stall = 1;
     flushx = 1;
     counterx = 1;

   end
end

/* Control Unit */
always @ (posedge clk) begin
  if (reset) begin
    pc_in <= mem_start;
    counter <= 0;
  end
  else begin

    //clear the flush
    if(flushd)  flushd = 0;
    if(flushx)  flushx = 0;
    if(flushm)  flushm = 0;
    //Hazard Detection
    if(stalld)  begin
      // if(counter == 0)  stalld = 0;
      // else  counter = counter - 1;
      stalld = 0;
    end

    //in case of jump, assign PC the output of rs register
    /* It's defined here because PC_in wil take one full cycle to be assigned
     * and then, PC block will take 1 cycle to get the next pc_out which will
     * be the input of the instruction memory
     */
    //Branch if equal to zero
    if (stall) begin
      // if(counterx == 0) stall = 0;
      // else begin
      //   counterx = counterx - 1;
        stall = 0;
        stalld = 1;
        counter = 1;
      //end
    end else if(opcode == 6'b000100) begin
      if(rd0_data == rd1_data) begin
        pc_in <= pc_if_id + 4 + {{14{imm[15]}},imm[15:0], 2'b00};
        stall <= 1;
        flushx <= 1;
        flushd <= 1;
      end
      else pc_in <= next_pc;
    end
    //Branch if not equal to zero
    else if(opcode == 6'b000101) begin
      if(rd0_data != rd1_data) begin
        pc_in <= pc_if_id + 4 + {{14{imm[15]}},imm[15:0], 2'b00};
        flushx <= 1;
        flushd <= 1;
      end
      else pc_in <= next_pc;
    end
    else if(opcode_if == 6'b000011 | opcode_if == 6'b000010) begin //jump instructions
      pc_in <= {pc_out[31:28], rs_if, rt_if, imm_if, 2'b00};
    end
    else if(rs == 5'b11111 && func == 6'b001000) begin //JR
      pc_in <= rd0_data;
    end else begin
      pc_in <= next_pc;
    end

  end //else statement
end //always

endmodule
