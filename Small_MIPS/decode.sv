module decode(
  input [31:0] instruction,
  output wire [5:0] opcode,
  output wire [4:0] rs,
  output wire [4:0] rt,
  output wire [4:0] rd,
  output wire [4:0] shift_amount,
  output wire [5:0] func,
  output wire [15:0] imm
  );

assign opcode = instruction[31:26];
assign rs = instruction[25:21];
assign rt = instruction[20:16];
assign rd = instruction[15:11];
assign shift_amount = instruction[10:6];
assign func = instruction[5:0];
assign imm = instruction[15:0];

endmodule
