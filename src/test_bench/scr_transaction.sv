`include"defines.svh"
class scr_transaction;
	//-----------Ports connected to BRIDGE--------------

	//inputs
	bit transfer;
	bit write_read;
	bit [`ADDR_WIDTH-1:0] addr_in;
	bit [`ADDR_WIDTH-1:0] wdata_in;
	bit [(`DATA_WIDTH/8)-1:0] strb_in;
	
	//outputs
	bit transfer_done;
	bit  [`ADDR_WIDTH-1:0] rdata_out;
	bit error;

	//------------Ports connected to SLAVE--------------
	//inputs
	bit PREADY;
	bit PSLVERR;
	bit [`DATA_WIDTH-1:0]PRDATA;

	//outputs
	bit [`ADDR_WIDTH-1:0]PADDR;
	bit [`DATA_WIDTH-1:0]PWDATA;
	bit [(`DATA_WIDTH/8)-1:0]PSTRB;
	bit PSEL;
	bit PENABLE;
	bit PWRITE;

endclass

