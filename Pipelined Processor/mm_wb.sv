module mm_wb (
  input clk,
  input [31:0] data_out_mem,
  input [5:0] opcode_ex_mm,
  input [31:0] pc_ex_mm,
  input [31:0] data_out_alu_ex_mm,
  output reg [31:0] data_out_mem_wb,
  output reg [5:0] opcode_mm_wb,
  output reg [31:0] pc_mm_wb,
  output reg [31:0] data_out_alu_wb
  );

  assign data_out_mem_wb = data_out_mem;
  always @ (posedge clk) begin
    opcode_mm_wb <= opcode_ex_mm;
    pc_mm_wb <= pc_ex_mm;
    data_out_alu_wb <= data_out_alu_ex_mm;
  end

endmodule // mm_wb
