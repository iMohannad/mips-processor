module if_id (
  input clk,
  input stall,
  input [31:0] IR,
  input [31:0] pc_out,
  input flush,
  //input [31:0] next_pc,
  //output reg [31:0] next_pc_if_id,
  output reg [31:0] pc_if_id,
  output reg [31:0] IR_if_id
  );


  assign IR_if_id = (flush) ? 0 : (stall) ? IR_if_id : IR;
  always @ (posedge clk ) begin
    if (flush)  pc_if_id <= 0;
    if (stall) pc_if_id <= pc_if_id;
    else    pc_if_id <= pc_out;
    //IR_if_id <= IR;
  //  next_pc_if_id <= next_pc;
  end

endmodule // if_id
