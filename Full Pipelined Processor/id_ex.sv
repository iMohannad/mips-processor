module id_ex (
  input clk,
  input stall,
  input [31:0] pc_if_id,
  input [5:0] opcode,
  input aluSrc,
  input wr_en_reg,
  input [4:0] wr_num,
  input dm_rw,
  input [4:0] rs,
  input [4:0] rt,
  input [1:0] dm_access_sz,
  input [31:0] rd0_data,
  input [31:0] rd1_data,
  input [15:0] imm,
  input [4:0] shift_amount,
  input [5:0] func,
  input flush,
  output reg [4:0] rs_id_ex,
  output reg [4:0] rt_id_ex,
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
  );

  always @ (posedge clk) begin
    if(flush) begin
      opcode_id_ex <= 0;
      rs_id_ex <= 0;
      rt_id_ex <= 0;
      aluSrc_id_ex <= 0;
      wr_en_reg_id_ex <= 0;
      dm_rw_id_ex <= dm_rw;
      dm_access_sz_id_ex <= 0;
      rd0_data_id_ex <= 0;
      rd1_data_id_ex <= 0;
      imm_id_ex <= 0;
      shift_amount_id_ex <= 0;
      func_id_ex <= 0;
      pc_id_ex <= 0;
      wr_num_id_ex <= 0;
    // end else if(stall) begin
    //   opcode_id_ex <= opcode_id_ex;
    //   rs_id_ex <= rs_id_ex;
    //   rt_id_ex <= rt_id_ex;
    //   aluSrc_id_ex <= aluSrc_id_ex;
    //   wr_en_reg_id_ex <= wr_en_reg_id_ex;
    //   dm_rw_id_ex <= dm_rw_id_ex;
    //   dm_access_sz_id_ex <= dm_access_sz_id_ex;
    //   rd0_data_id_ex <= rd0_data_id_ex;
    //   rd1_data_id_ex <= rd1_data_id_ex;
    //   imm_id_ex <= imm_id_ex;
    //   shift_amount_id_ex <= shift_amount_id_ex;
    //   func_id_ex <= func_id_ex;
    //   pc_id_ex <= pc_id_ex;
    //   wr_num_id_ex <= wr_num_id_ex;
    end else begin
      opcode_id_ex <= opcode;
      rs_id_ex <= rs;
      rt_id_ex <= rt;
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
    end
  end
endmodule // id_ex
