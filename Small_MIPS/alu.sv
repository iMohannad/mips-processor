module alu(
  input unsigned [31:0] op1,
  input unsigned [31:0] op2,
  input [5:0] ar_op,
  input [5:0] shift_amount,
  output reg [31:0] data_out
  );

/* ADDIU  100001
   AddU   100001 Opcode 000000
   JR     001000 Opcode 000000
   LW     100011
   SW     101011
   NOP    000000
*/

always @ (op1 or op2 or ar_op or shift_amount) begin
  case(ar_op)
    2'b100001: data_out <= op1 + op2;
    2'b000000: data_out <= 0;
    2'b100011: data_out <= op1 + op2;
    2'b101011: data_out <= op1 + op2;
  endcase
end


endmodule
