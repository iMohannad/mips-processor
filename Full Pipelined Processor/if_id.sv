module if_id (
  input clk,
  input [31:0] IR,
  input [31:0] pc_out,
  //input [31:0] next_pc,
  //output reg [31:0] next_pc_if_id,
  output reg [31:0] pc_if_id,
  output reg [31:0] IR_if_id
  );


  assign IR_if_id = IR;
  always @ (posedge clk ) begin
    pc_if_id <= pc_out;
    //IR_if_id <= IR;
  //  next_pc_if_id <= next_pc;
  end

endmodule // if_id
