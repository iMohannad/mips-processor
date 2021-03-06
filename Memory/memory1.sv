
module memory (
  input clk, 
  input [31:0] addr,
  input [31:0] data_in,
  input [1:0] access_size,
  input rd_wr,
  input enable,
  output reg [31:0] data_out,
  output busy);

`include "mips.sv"

/* Since the address starts from 80020000, we need to substract this offset 
 * from the address in order to access mem where the address starts at 0 
 * and the increment between every word in memory is 1. because each word
 * is stored in one cell.
 */
parameter offset = 'h80020000; 
reg [31:0] mem [0:mem_depth/4-1];

//populate the memory with mem_file
initial $readmemh(mem_file, mem);


reg [31:0] address;
reg[3:0] count = 0;
logic [31:0] pointer;  //the address for the memory cell after decrementing the offset
reg [1:0] byteaccess;  //for access specific bytes in a word


always @* begin
  byteaccess[1:0] = addr % 4; 
  pointer = (addr - offset) / 4;
end 

/* This block checks the access size is 4 or 8 words
 * Then set the counter to 4 or 8 depending on the access size 
 */
always @(posedge clk) begin
    if(enable) begin
      if(access_size == sz_4word && count == 0) begin
          count = 4;
          address = addr;  //"address" variable is going to be used in the case condition of 4/8 words
      end
      else if (access_size == sz_8word && count == 0) begin
          count = 8;
         address = addr;
      end
    end
end 


//set to '1' if memory is not available due work working on a multi-word read or write 
assign busy = (|count & enable);

always@(posedge clk) begin
  if(enable) begin
     if(rd_wr) begin
       case(access_size)
       /* in case of byte access, there will 4 options for every address given
        * Thus, byteaccess checks which byte needs to be read, then shift the byte
        * to the LSB in order to be read by data_out variable
        */
       sz_byte: begin 
         if(~busy) begin
           if(byteaccess == 0) data_out[7:0] <= mem[pointer] >> 24;
           else if(byteaccess == 1) data_out[7:0] <= mem[pointer] >> 16;
           else if(byteaccess == 2) data_out[7:0] <= mem[pointer] >> 8;
           else if(byteaccess == 3) data_out[7:0] <= mem[pointer];
           data_out[31:8] <= 'z;  //add z to the rest of the word.
         end
       end

       sz_word: if(~busy) data_out[31:0] <= mem[pointer];

       sz_4word: begin
         if(count > 0) begin 
            data_out[31:0] <= mem[address - offset];
            count <= count - 1;
            address <= address + 1;
         end
       end

       sz_8word: begin
         if(count > 0) begin 
            data_out[31:0] <= mem[address - offset];
            count <= count - 1;
            address <= address + 1;
         end
       end //end of if(rd_wt)
       endcase
     end else begin 
       case(access_size)
       sz_byte: begin
         if(~busy) begin
           if(byteaccess == 0)  mem[pointer] <= {data_in[7:0], mem[pointer][23:0]};
           else if(byteaccess == 1)  mem[pointer] <= {mem[pointer][31:24], data_in[7:0], mem[pointer ][15:0]};
           else if(byteaccess == 2) mem[pointer] <= {mem[pointer][31:16], data_in[7:0], mem[pointer][7:0]};
           else if(byteaccess == 3) mem[pointer] <= {mem[pointer][31:8], data_in[7:0]};
         end
       end

       sz_word: if(~busy) mem[pointer] <= data_in[31:0];

       sz_4word: begin
         if(count > 0) begin 
            mem[address - offset] <= data_in[31:0];
            count <= count - 1;
            address <= address + 1;
         end
       end

       sz_8word: begin
         if(count > 0) begin 
            mem[address - offset] <= data_in[31:0];
            count <= count - 1;
            address <= address + 1;
         end
       end
       endcase
     end //end of else (rd_wt)
  end else begin  //if enable is 0, output z
     data_out[31:0] <= 'hz;
  end
    
end //always

endmodule
