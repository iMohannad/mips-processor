module tb_SimpleAdd;
	`include "params.sv"
	logic clk;
	logic reset;
	logic [1:0] im_access_sz = sz_word;

	// instruction memory
	logic im_rw = 1;
	logic [31:0] im_addr, im_dout;
	logic busy_inst_mm, busy_data_mm;
/*  memory imem(.clk(clk), .addr(im_addr), .data_out(im_dout),
		.access_size(im_access_sz), .rd_wr(im_rw), .enable(~reset), .busy(busy_inst_mm));
*/
	// data memory
	logic dm_rw;
	logic [31:0] dm_addr, dm_din, dm_dout;
	logic [1:0] dm_access_sz = sz_word;
	logic [2:0] stages;
  /*memory dmem(.clk(clk), .addr(dm_addr), .data_in(dm_din), .data_out(dm_dout),
		.access_size(dm_access_sz), .rd_wr(dm_rw), .enable(~reset), .busy(busy_data_mm));
*/
	mips #(.pc_init(mem_start), .sp_init(mem_start+mem_depth), .ra_init(0))
		proc(.clk(clk), .reset(reset),
		.instr_addr(im_addr), .instr_in(im_dout),
		.data_addr(dm_addr), .data_in(dm_dout), .data_out(dm_din),
		.data_rd_wr(dm_rw));

    //initial $monitor("time %3d, pc %8h, r2 %8h, r3 %8h", $time, im_addr,
		//tb_SimpleAdd.proc.regs.data[2], tb_SimpleAdd.proc.regs.data[3]);

    initial begin
        clk = 1; forever #5 clk = ~clk;
    end

	bit [31:0] test_pc [0:17];
	bit [31:0] num = 32'h80020000;
    initial begin
		for(int i=0; i<18;i++) begin
			test_pc[i] = num;
			num = num + 4;
		end
		/*test_pc[0] <= 32'h80020014;
		test_pc[1] <= 32'h8002001c;
		test_pc[2] <= 32'h80020028;
		test_pc[3] <= 32'h80020030;*/
		reset <= 1;
		#10 reset <= 0;

		for(int i=0; i<18; i++) begin
			wait(im_addr==test_pc[i])
    			$display("pc %8h, r2 %8h, r3 %8h", im_addr,
				tb_SimpleAdd.proc.regs.data[2], tb_SimpleAdd.proc.regs.data[3]);
		end

		wait(im_addr==0)
			#10 $stop; //$finish if using iverilog
    end

    //initial $dumpvars(0, tb_SimpleAdd); // for iverilog+gtkwave

endmodule
