module id_ex (
  input clk,
  input [31:0] pc_if_id,
  input [5:0] opcode,
  input aluSrc,
  input wr_en_reg,
  input [4:0] wr_num,
  input dm_rw,
  input [1:0] dm_access_sz,
  input [31:0] rd0_data,
  input [31:0] rd1_data,
  input [15:0] imm,
  input [4:0] shift_amount,
  input [5:0] func,
  input [4:0] rs,
  //input [31:0] next_pc_if_id,
  output reg [4:0] rs_id_ex,
  output reg [5:0] opcode_id_ex,
  output reg aluSrc_id_ex,
  output reg wr_en_reg_id_ex,
  output reg [4:0] wr_num_id_ex,
  output reg dm_rw_id_ex,
  output reg [1:0] dm_access_sz_id_ex,
  output reg [31:0] rd0_data_id_ex,
  output reg [31:0] rd1_data_id_ex,
  output reg [15:0] imm_id_ex,
  output reg [4:0] shift_amount_id_ex,
  output reg [5:0] func_id_ex,
  output reg [31:0] pc_id_ex
  //output reg [31:0] next_pc_id_ex
  );

  always @ (posedge clk) begin
    opcode_id_ex <= opcode;
    aluSrc_id_ex <= aluSrc;
    wr_en_reg_id_ex <= wr_en_reg;
    dm_rw_id_ex <= dm_rw;
    dm_access_sz_id_ex <= dm_access_sz;
    rd0_data_id_ex <= rd0_data;
    rd1_data_id_ex <= rd1_data;
    imm_id_ex <= imm;
    shift_amount_id_ex <= shift_amount;
    func_id_ex <= func;
    pc_id_ex <= pc_if_id;
    wr_num_id_ex <= wr_num;

  //  next_pc_id_ex <= next_pc_if_id;
  end
endmodule // id_ex
