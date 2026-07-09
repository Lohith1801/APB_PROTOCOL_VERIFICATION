`include"defines.svh"
class mon_transaction;
	logic [`ADDR_WIDTH-1:0]PADDR;
	logic [`DATA_WIDTH-1:0]PWDATA;
	logic [`DATA_WIDTH-1:0]PRDATA;
	logic [(`DATA_WIDTH/8)-1:0]PSTRB;
	logic PREADY;
	logic PSLVERR;
	logic PSEL;
        logic PENABLE;
        logic PWRITE;



	function mon_transaction copy();
		copy = new();
		copy.PADDR = this.PADDR;
		copy.PWDATA = this.PWDATA;
		copy.PRDATA = this.PRDATA;
		copy.PSTRB = this.PSTRB;
		copy.PREADY = this.PREADY;
		copy.PSLVERR = this.PSLVERR;
		copy.PSEL = this.PSEL;
		copy.PENABLE = this.PENABLE;
		copy.PWRITE = this.PWRITE;
		return copy;
	endfunction

endclass
