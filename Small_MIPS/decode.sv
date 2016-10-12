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

assign {opcode, rs, rt, td, shift_amount, func} = instruction;
assign imm = instruction[15:0];
