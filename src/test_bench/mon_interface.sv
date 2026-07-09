`include"defines.svh"
interface mon_interface(input bit PCLK, PRESETn);
	logic [`ADDR_WIDTH-1:0]PADDR;
        logic [`DATA_WIDTH-1:0]PWDATA;
        logic [`DATA_WIDTH-1:0]PRDATA;
        logic [(`DATA_WIDTH/8)-1:0]PSTRB;
        logic PREADY;
        logic PSLVERR;
        logic PSEL;
        logic PENABLE;
        logic PWRITE;

	clocking cb2mon @(posedge PCLK);
		default input #0 output #0;
		input PADDR, PWDATA, PSTRB, PSEL, PENABLE, PWRITE;
		output PREADY, PSLVERR, PRDATA;
	endclocking

	modport MON(clocking cb2mon, PRESETn);
endinterface

