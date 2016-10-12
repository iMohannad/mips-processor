module alu(
  input signed [31:0] op1,
  input signed [31:0] op2,
  input [5:0] ar_op,
  input [5:0] shift_amount,
  output reg [31:0] data_out
  );
