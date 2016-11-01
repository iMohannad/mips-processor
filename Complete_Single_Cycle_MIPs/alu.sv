module alu(
  input [31:0] op1,
  input [31:0] op2,
  input [5:0] opcode,
  input [5:0] ar_op,
  input [4:0] shift_amount,
  output reg [31:0] data_out_alu
  );

/* ADDIU  100001
   AddU   100001 Opcode 000000
   JR     001000 Opcode 000000
   LW     100011
   SW     101011
   NOP    000000
*/

always @ (op1 or op2 or ar_op or shift_amount) begin
  case (opcode)
    6'b001000: data_out_alu <= op1 + op2; //ADDIU
    6'b001001: data_out_alu <= op1 + op2; //AddU
    6'b101011: data_out_alu <= op1 + op2; //SW
    6'b100011: data_out_alu <= op1 + op2;
    6'b011100: data_out_alu <= op1 * op2; //MUL
    6'b001111: data_out_alu <= op2[15:0] << 16; //LUI
    6'b100100: data_out_alu <= op1 + op2; //lbu
    6'b101000: data_out_alu <= op1 + op2; //SB
    6'b001010: begin
      if (op1 < op2) data_out_alu <= 1;
      else data_out_alu <= 0;
    end
    default: begin

      case(ar_op)
        6'b100001: data_out_alu <= op1 + op2;
        6'b000000: begin
          if(op1 == 0) data_out_alu <= op2 << shift_amount;
          else data_out_alu <= 0;
        end
        6'b100011: data_out_alu <= op1 - op2;
        6'b101011: data_out_alu <= op1 + op2;
        6'b101010: begin
          if(op1 < op2) data_out_alu <= 1;
          else data_out_alu <= 0;
        end

      endcase
    end
  endcase

end


endmodule
