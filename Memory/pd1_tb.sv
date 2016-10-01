/* tb_SimpleAdd
 * Loads SimpleAdd.x and tests reads and writes of single words and bytes.
 */
module tb_SimpleAdd;
	`include "mips.sv"
	logic clk, read, busy, en;
	logic [31:0] addr, din, dout;
	logic [1:0] size;

    memory #(.mem_file("SimpleAdd.x"), .mem_depth(2**20)) mem(.clk(clk),
		.addr(addr), .data_in(din), .data_out(dout),
		.access_size(size), .rd_wr(read), .busy(busy), .enable(en));

    initial $monitor("time %3d, addr %8h, data %8h, en %1b",
		$time, addr, dout, en);
 
    initial begin
        clk = 1; forever #5 clk = ~clk;
    end

    initial begin
        addr <= 32'h80020000; size <= sz_word; read <= 1; en <= 0;
		#10 en <= 1;
		#10 addr <= addr + 4;
		#10 read <= 0; din <= 32'haaaaaaaa;
		#10 read <= 1;
		#10 size <= sz_byte; read <= 0; din <= 32'hxxxxxx00;
		#10 addr <= addr + 1; din <= 32'hxxxxxx11;
		#10 addr <= addr + 1; din <= 32'hxxxxxx22;
		#10 addr <= addr + 1; din <= 32'hxxxxxx33;
		#10 read <= 1; size <= sz_word; addr <= addr - 3;
		#10 size <= sz_byte;
		#10 addr <= addr + 3;
		#20 $stop; //$finish if using iverilog
    end

    //initial $dumpvars(0, tb_SimpleAdd); // for iverilog+gtkwave

endmodule


/* tb_BubbleSort
 * Loads BubbleSort.x and tests multi-word reads and writes.
 */
module tb_BubbleSort;
	`include "mips.sv"
	logic clk, read, busy, en;
	logic [31:0] addr, din, dout;
	logic [1:0] size;

    memory #(.mem_file("BubbleSort.x"), .mem_depth(2**20)) mem(.clk(clk),
		.addr(addr), .data_in(din), .data_out(dout),
		.access_size(size), .rd_wr(read), .busy(busy), .enable(en));

    initial $monitor("time %3d, addr %8h, data %8h, busy %1b",
		$time, addr, dout, busy);
 
    initial begin
        clk = 1; forever #5 clk = ~clk;
    end

    initial begin
        addr <= 32'h80020000; size <= sz_4word; read <= 1; en <= 0;
		#10 en <= 1;
		#40 size <= sz_8word; read <= 0; din <= 32'haaaaaaaa;
		#10 din <= 32'hbbbbbbbb;
		#10 din <= 32'hcccccccc;
		#10 din <= 32'hdddddddd;
		#10 din <= 32'heeeeeeee;
		#10 din <= 32'hffffffff;
		#10 din <= 32'h00000000;
		#10 din <= 32'h11111111;
		#10 read <= 1;
		#90 $stop;
    end

    //initial $dumpvars(0, tb_BubbleSort); // for iverilog+gtkwave
	
endmodule
