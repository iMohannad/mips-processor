module mips (
    input clk,
    input reset,
    output reg [31:0] instr_addr,
    output reg [31:0] instr_in,
    output reg [31:0] data_addr,
    output reg [31:0] data_in,
    output  data_rd_wr,
    output reg [31:0] data_out
);

`include "params.sv"


parameter [31:0] pc_init = 0;
parameter [31:0] sp_init = 0;
parameter [31:0] ra_init = 0;


// pc variables
//logic [31:0] pc_in;
logic [31:0] pc_out;  //goes to instruction memory
/*it's pc_out+1 which should be an input to a mux to decide in case of jump or branch*/
logic [31:0] next_pc; //pc_in + 4

/*always @(posedge clk) begin
  if (reset) begin
    next_pc <= mem_start;
  end
end*/



pc pc(.clk(clk), .reset(reset), .pc_in(next_pc), .pc_out(pc_out), .next_pc(next_pc));

// instruction memory variables
logic im_rw = 1;  //always 1 because we always read from instruction memory
logic [1:0] im_access_sz = sz_word;
logic busy_inst_mm;
logic [31:0] instruction; //the instruction address from inst_memory

always @ (posedge clk) begin
  instr_in = pc_out;
  instr_addr = pc_out;
end



memory inst_memory(.clk(clk), .addr(pc_out), .data_in(pc_out), .access_size(2'b01), .rd_wr(im_rw),
  .enable(~reset), .data_out(instruction), .busy(busy_inst_mm));

//decoder variables
logic [4:0] rs;
logic [4:0] rt;
logic [4:0] rd;
logic [4:0] shift_amount;
logic [5:0] func;
logic [15:0] imm;
logic [5:0] opcode;
decode decoder(.instruction(instruction), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd),
  .shift_amount(shift_amount), .func(func), .imm(imm));


//regfile variables
logic [31:0] wr_data_reg; //the data which will be written on target register
logic wr_en_reg = (opcode = 6'b101011 | ((opcode == 0) && (func == 6'b001000)) | opcode == 6'b001001) ? 1 : 0; //to enable writing on regfile
logic [31:0] rd0_data; //the data coming out from rt
logic [31:0] rd1_data; //the data coming out from rd
logic [4:0] wr_num;

always @ ( * ) begin
  if((opcode == 6'b001001) | (opcode == 6'b100011)) wr_num <= rt;
  else wr_num <= rd;
end

regfile #(.sp_init(mem_start+mem_depth), .ra_init(0))
  regs(.clk(clk), .reset(reset), .wr_num(wr_num), .wr_data(wr_data_reg), .wr_en(wr_en_reg),
  .rd0_num(rs), .rd0_data(rd0_data), .rd1_num(rt), .rd1_data(rd1_data));

logic [31:0] data_out_alu;
wire [31:0] op1;
logic [31:0] op2;


logic aluSrc = opcode[3];

//assign  op2 = aluSrc ? rd1_data :  {{16{imm[15]}}, imm[15:0]} ;
always @ ( * ) begin
  if(aluSrc) op2 <= {{16{imm[15]}}, imm[15:0]};
  else op2 <= rd1_data;
end


alu alu(.op1(rd0_data), .op2(op2), .opcode(opcode), .ar_op(func), .shift_amount(shift_amount), .data_out(data_out_alu));


logic dm_rw;
always @ ( * ) begin
  if(opcode == 6'b101011) dm_rw <= 0;
  else dm_rw <= 1;
end

logic [31:0] data_out_mem;  //the output from data memory
logic busy_data_mm;  //a signal indicates if the data memory is busy
logic memToReg;

always @ ( * ) begin
  if(opcode == 6'b001001) memToReg <= 1;
  else memToReg <= 0;
end

assign data_rd_wr = dm_rw;

always @ ( * ) begin
  if(memToReg) wr_data_reg <= data_out_alu;
  else wr_data_reg <= data_out_mem;
end
//assign wr_data_reg = memToReg ? data_out_mem : data_out_alu;



memory data_memory(.clk(clk), .addr(data_out_alu), .data_in(rd1_data), .access_size(2'b01), .rd_wr(dm_rw),
  .enable(~reset), .data_out(data_out_mem), .busy(busy_data_mm));

  always @ (posedge clk) begin
    data_addr <= data_out_alu;
    data_in <= rd1_data;
    data_out <= data_out_mem;
  end

endmodule
