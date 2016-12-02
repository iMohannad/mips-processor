module ex_mm (
  input clk,
  input [31:0] data_out_alu,
  input [31:0] rd1_data_id_ex,
  input [1:0] dm_access_sz_id_ex,
  input dm_rw_id_ex,
  input [31:0] pc_id_ex,
  input wr_en_reg_id_ex,
  input [4:0] wr_num_id_ex,
  input [5:0] opcode_id_ex,
  output reg [31:0] data_out_alu_ex_mm,
  output reg [31:0] rd1_data_ex_mm,
  output reg [1:0] dm_access_sz_ex_mm,
  output reg dm_rw_ex_mm,
  output reg [31:0] pc_ex_mm,
  output reg wr_en_reg_ex_mm,
  output reg [4:0] wr_num_ex_mm,
  output reg [5:0] opcode_ex_mm
  );

  always @ (posedge clk) begin
    data_out_alu_ex_mm <= data_out_alu;
    rd1_data_ex_mm <= rd1_data_id_ex;
    dm_access_sz_ex_mm <= dm_access_sz_id_ex;
    dm_rw_ex_mm <= dm_rw_id_ex;
    pc_ex_mm <= pc_id_ex;
    wr_en_reg_ex_mm <= wr_en_reg_id_ex;
    wr_num_ex_mm <= wr_num_id_ex;
    opcode_ex_mm <= opcode_id_ex;
  end

endmodule // ex_mm
