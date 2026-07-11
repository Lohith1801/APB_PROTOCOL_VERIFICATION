`include"defines.svh"
interface bridge_interface(input bit PCLK, input bit PRESETn);

	//DUT inputs
	logic transfer;
        logic write_read;
        logic [`ADDR_WIDTH-1:0]addr_in;
        logic [`DATA_WIDTH-1:0]wdata_in;
        logic [(`DATA_WIDTH/8)-1:0]strb_in;

	//DUT outputs
        logic transfer_done;
        logic [`DATA_WIDTH-1:0]rdata_out;
        logic error;
	
	//DRIVER clocking block
	clocking cb2drv @(posedge PCLK);
		default input #0 output #0;
		input transfer_done, rdata_out, error;
		output transfer, write_read, addr_in, wdata_in, strb_in;
	endclocking
	
	//Diver modport
	modport DRV(clocking cb2drv, PRESETn);
endinterface

