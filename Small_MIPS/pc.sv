module pc (
  input clk,
  input reset,
  input [31:0] pc_in,
  output reg [31:0] pc_out,
  output reg [31:0] next_pc);

`include "params.sv"



always @ (posedge clk) begin
  if (reset) begin
    pc_out <= mem_start;
    next_pc <= mem_start+4;
  end
  else begin
    pc_out <= pc_in;
    next_pc <= pc_in + 4;
  end
end


endmodule // pc
