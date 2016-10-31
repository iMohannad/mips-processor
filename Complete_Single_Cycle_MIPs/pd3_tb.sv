// prints values of i and j and shows swapped values
module tb_BubbleSort;
	`include "params.sv"
	logic clk;
	logic reset;
	logic [1:0] im_access_sz = sz_word;

	// instruction memory
	logic im_rw = 1;
	logic [31:0] im_addr, im_dout;
    /*memory #(.mem_file("BubbleSort.x"))
		imem(.clk(clk), .addr(im_addr), .data_out(im_dout),
		.access_size(im_access_sz), .rd_wr(im_rw), .enable(~reset));*/

	// data memory
	logic dm_rw;
	logic [31:0] dm_addr, dm_din, dm_dout;
	logic [1:0] dm_access_sz;
    /*memory #(.mem_file("BubbleSort.x"))
		dmem(.clk(clk), .addr(dm_addr), .data_in(dm_din), .data_out(dm_dout),
		.access_size(dm_access_sz), .rd_wr(dm_rw), .enable(~reset));*/

	mips #(.pc_init(mem_start), .sp_init(mem_start+mem_depth), .ra_init(0))
		proc(.clk(clk), .reset(reset),
		.instr_addr(im_addr), .instr_in(im_dout),
		.data_addr(dm_addr), .data_in(dm_dout), .data_out(dm_din),
		.data_access_size(dm_access_sz),.data_rd_wr(dm_rw));

    //initial $monitor("time %3d, pc %8h, r2 %8h, r3 %8h", $time, im_addr,
		//tb_BubbleSort.proc.regs.data[2], tb_BubbleSort.proc.regs.data[3]);

    initial begin
        clk = 1; forever #5 clk = ~clk;
    end

    initial begin
        reset <= 1;
		#10 reset <= 0;

		/*
		wait(im_addr==32'h80020084)
   			$display("time %3d, pc %8h, a1 %8h, ra %8h", $time, im_addr,
				tb_BubbleSort.proc.regs.data[5],
				tb_BubbleSort.proc.regs.data[31]);
		*/

		forever wait(im_addr==32'h80020184 || im_addr==32'h80020168
				|| im_addr==32'h800200e8 || im_addr==0)
			if(im_addr==32'h80020184) begin
   				$write("\ni=%0d", tb_BubbleSort.proc.regs.data[3]);
				#100 ;
			end
			else if(im_addr==32'h80020168) begin
   				$write(" j=%0d", tb_BubbleSort.proc.regs.data[2]);
				#100 ;
			end
			else if(im_addr==32'h800200e8) begin
				wait(im_addr==32'h80020104)
   					$write(" [%0d,", tb_BubbleSort.proc.regs.data[2]);
				wait(im_addr==32'h80020130)
   					$write("%0d]", tb_BubbleSort.proc.regs.data[3]);
			end
			else begin
				$write("\n");
				#10 $stop; //$finish if using iverilog
			end
    end

    //initial $dumpvars(0, tb_BubbleSort); // for iverilog+gtkwave

endmodule


// prints out the return values from the factorial function
module tb_fact;
	`include "params.sv"
	logic clk;
	logic reset;
	logic [1:0] im_access_sz = sz_word;

	// instruction memory
	logic im_rw = 1;
	logic [31:0] im_addr, im_dout;
    /*memory #(.mem_file("fact.x"))
		imem(.clk(clk), .addr(im_addr), .data_out(im_dout),
		.access_size(im_access_sz), .rd_wr(im_rw), .enable(~reset));*/

	// data memory
	logic dm_rw;
	logic [31:0] dm_addr, dm_din, dm_dout;
	logic [1:0] dm_access_sz;
    /*memory #(.mem_file("fact.x"))
		dmem(.clk(clk), .addr(dm_addr), .data_in(dm_din), .data_out(dm_dout),
		.access_size(dm_access_sz), .rd_wr(dm_rw), .enable(~reset));*/

	mips #(.pc_init(mem_start), .sp_init(mem_start+mem_depth), .ra_init(0))
		proc(.clk(clk), .reset(reset),
		.instr_addr(im_addr), .instr_in(im_dout),
		.data_addr(dm_addr), .data_in(dm_dout), .data_out(dm_din),
		.data_access_size(dm_access_sz),.data_rd_wr(dm_rw));

    initial begin
        clk = 1; forever #5 clk = ~clk;
    end

    initial begin
        reset <= 1;
		#10 reset <= 0;

		forever wait(im_addr==32'h80020024 || im_addr==32'h80020028 ||
			im_addr==0)
			if(im_addr==32'h80020024) begin
   				$write("fact(%0d)=", tb_fact.proc.regs.data[4]);
				#100 ;
			end
			else if(im_addr==32'h80020028) begin
   				$display("%0d", tb_fact.proc.regs.data[2]);
				#100 ;
			end
			else begin
				#10 $stop; //$finish if using iverilog
			end
    end

    //initial $dumpvars(0, tb_fact); // for iverilog+gtkwave

endmodule


// prints out the number of vowels
module tb_CheckVowel;
	`include "params.sv"
	logic clk;
	logic reset;
	logic [1:0] im_access_sz = sz_word;

	// instruction memory
	logic im_rw = 1;
	logic [31:0] im_addr, im_dout;
    /*memory #(.mem_file("CheckVowel.x"))
		imem(.clk(clk), .addr(im_addr), .data_out(im_dout),
		.access_size(im_access_sz), .rd_wr(im_rw), .enable(~reset));*/

	// data memory
	logic dm_rw;
	logic [31:0] dm_addr, dm_din, dm_dout;
	logic [1:0] dm_access_sz;
    /*memory #(.mem_file("CheckVowel.x"))
		dmem(.clk(clk), .addr(dm_addr), .data_in(dm_din), .data_out(dm_dout),
		.access_size(dm_access_sz), .rd_wr(dm_rw), .enable(~reset));*/

	mips #(.mem_variable("CheckVowel.x"), .pc_init(mem_start), .sp_init(mem_start+mem_depth), .ra_init(0))
		proc(.clk(clk), .reset(reset),
		.instr_addr(im_addr), .instr_in(im_dout),
		.data_addr(dm_addr), .data_in(dm_dout), .data_out(dm_din),
		.data_access_size(dm_access_sz),.data_rd_wr(dm_rw));

    initial begin
        clk = 1; forever #5 clk = ~clk;
    end

    initial begin
        reset <= 1;
		#10 reset <= 0;

		forever wait(im_addr==32'h8002007c || im_addr==32'h80020164
				|| im_addr==0)
			if(im_addr==32'h8002007c) begin
   				$display("ch=%c", tb_CheckVowel.proc.regs.data[3]);
				#60 ;
			end
			else if(im_addr==32'h80020164) begin
   				#60 $display("# vowels=%1d", tb_CheckVowel.proc.regs.data[2]);
			end
			else begin
				#10 $stop; //$finish if using iverilog
			end
    end

    //initial $dumpvars(0, tb_CheckVowel); // for iverilog+gtkwave

endmodule


// prints out the value of c returned from main
module tb_SimpleIf;
	`include "params.sv"
	logic clk;
	logic reset;
	logic [1:0] im_access_sz = sz_word;

	// instruction memory
	logic im_rw = 1;
	logic [31:0] im_addr, im_dout;
    /*memory #(.mem_file("SimpleIf.x"))
		imem(.clk(clk), .addr(im_addr), .data_out(im_dout),
		.access_size(im_access_sz), .rd_wr(im_rw), .enable(~reset));*/

	// data memory
	logic dm_rw;
	logic [31:0] dm_addr, dm_din, dm_dout;
	logic [1:0] dm_access_sz;
    /*memory #(.mem_file("SimpleIf.x"))
		dmem(.clk(clk), .addr(dm_addr), .data_in(dm_din), .data_out(dm_dout),
		.access_size(dm_access_sz), .rd_wr(dm_rw), .enable(~reset));*/

	mips #(.mem_variable("SimpleIf.x"), .pc_init(mem_start), .sp_init(mem_start+mem_depth), .ra_init(0))
		proc(.clk(clk), .reset(reset),
		.instr_addr(im_addr), .instr_in(im_dout),
		.data_addr(dm_addr), .data_in(dm_dout), .data_out(dm_din),
		.data_access_size(dm_access_sz),.data_rd_wr(dm_rw));

    initial begin
        clk = 1; forever #5 clk = ~clk;
    end

    initial begin
        reset <= 1;
		#10 reset <= 0;

		wait(im_addr==32'h80020064)
   			#50 $display("c=%0d", tb_SimpleIf.proc.regs.data[2]);

		wait(im_addr==0)
			#10 $stop; //$finish if using iverilog
	end

    //initial $dumpvars(0, tb_SimpleIf); // for iverilog+gtkwave

endmodule


// prints the sum
module tb_SumArray;
	`include "params.sv"
	logic clk;
	logic reset;
	logic [1:0] im_access_sz = sz_word;

	// instruction memory
	logic im_rw = 1;
	logic [31:0] im_addr, im_dout;
    /*memory #(.mem_file("SumArray.x"))
		imem(.clk(clk), .addr(im_addr), .data_out(im_dout),
		.access_size(im_access_sz), .rd_wr(im_rw), .enable(~reset));*/

	// data memory
	logic dm_rw;
	logic [31:0] dm_addr, dm_din, dm_dout;
	logic [1:0] dm_access_sz;
    /*memory #(.mem_file("SumArray.x"))
		dmem(.clk(clk), .addr(dm_addr), .data_in(dm_din), .data_out(dm_dout),
		.access_size(dm_access_sz), .rd_wr(dm_rw), .enable(~reset));*/

	mips #(.mem_variable("SumArray.x"), .pc_init(mem_start), .sp_init(mem_start+mem_depth), .ra_init(0))
		proc(.clk(clk), .reset(reset),
		.instr_addr(im_addr), .instr_in(im_dout),
		.data_addr(dm_addr), .data_in(dm_dout), .data_out(dm_din),
		.data_access_size(dm_access_sz),.data_rd_wr(dm_rw));

    initial begin
        clk = 1; forever #5 clk = ~clk;
    end

    initial begin
        reset <= 1;
		#10 reset <= 0;

		wait(im_addr==32'h80020098)
   			#50 $display("c=%0d", tb_SumArray.proc.regs.data[2]);

		wait(im_addr==0)
			#10 $stop; //$finish if using iverilog
	end

    //initial $dumpvars(0, tb_SumArray); // for iverilog+gtkwave

endmodule


// shows the swapped values of a and b and the total
module tb_Swap;
	`include "params.sv"
	logic clk;
	logic reset;
	logic [1:0] im_access_sz = sz_word;

	// instruction memory
	logic im_rw = 1;
	logic [31:0] im_addr, im_dout;
    /*memory #(.mem_file("Swap.x"))
		imem(.clk(clk), .addr(im_addr), .data_out(im_dout),
		.access_size(im_access_sz), .rd_wr(im_rw), .enable(~reset));*/

	// data memory
	logic dm_rw;
	logic [31:0] dm_addr, dm_din, dm_dout;
	logic [1:0] dm_access_sz;
    /*memory #(.mem_file("Swap.x"))
		dmem(.clk(clk), .addr(dm_addr), .data_in(dm_din), .data_out(dm_dout),
		.access_size(dm_access_sz), .rd_wr(dm_rw), .enable(~reset));*/

	mips #(.mem_variable("Swap.x"), .pc_init(mem_start), .sp_init(mem_start+mem_depth), .ra_init(0))
		proc(.clk(clk), .reset(reset),
		.instr_addr(im_addr), .instr_in(im_dout),
		.data_addr(dm_addr), .data_in(dm_dout), .data_out(dm_din),
		.data_access_size(dm_access_sz),.data_rd_wr(dm_rw));

    initial begin
        clk = 1; forever #5 clk = ~clk;
    end

    initial begin
        reset <= 1;
		#10 reset <= 0;

		wait(im_addr==32'h80020060) begin
   			#50 $display("a=%0d, b=%0d", tb_Swap.proc.regs.data[3],
				tb_Swap.proc.regs.data[2]);
   			#50 $display("a+b=%0d", tb_Swap.proc.regs.data[2]);
		end

		wait(im_addr==0)
			#10 $stop; //$finish if using iverilog
	end

    //initial $dumpvars(0, tb_Swap); // for iverilog+gtkwave

endmodule
