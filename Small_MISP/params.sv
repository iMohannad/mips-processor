    parameter mem_file = "SimpleAdd.x";
	parameter [31:0] mem_start = 32'h80020000;
	parameter mem_depth = 2**20; // 1 MB
	parameter mem_delay=0;
	typedef enum { sz_byte, sz_word, sz_4word, sz_8word } mem_access_sizes;

