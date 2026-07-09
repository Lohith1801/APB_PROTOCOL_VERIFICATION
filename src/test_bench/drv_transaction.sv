`include"defines.svh"
class drv_transaction;
	rand logic transfer;
	rand logic write_read;
	rand logic [`ADDR_WIDTH-1:0]addr_in;
	rand logic [`ADDR_WIDTH-1:0]wdata_in;
	rand logic [(`ADDR_WIDTH/8)-1:0]strb_in;
	logic transfer_done;
	logic [`ADDR_WIDTH-1:0]rdata_out;
	logic error;


	function drv_transaction copy();
		copy = new();
		copy.transfer = this.transfer;
		copy.write_read = this.write_read;
		copy.addr_in = this.addr_in;
		copy.wdata_in = this.wdata_in;
		copy.transfer_done = this.transfer_done;
		copy.rdata_out = this.rdata_out;
		copy.error = this.error;
		return copy;
	endfunction
endclass


