module if_id (
  input [31:0] clk,
  input [31:0] IR,
  input [31:0] pc_out,
  output reg [31:0] pc_if_id,
  output reg [31:0] IR_if_id
  );

  always @ (posedge clk ) begin
    pc_if_id <= pc_out;
    IR_if_id <= IR;
  end

endmodule // if_id
