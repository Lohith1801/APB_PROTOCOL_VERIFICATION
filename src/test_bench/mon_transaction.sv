class mon_transaction;
	
	//monitor input
	bit [`ADDR_WIDTH-1:0]PADDR;
	bit [`DATA_WIDTH-1:0]PWDATA;
	bit [(`DATA_WIDTH/8)-1:0]PSTRB;
	logic PSEL;
	logic PENABLE;
	logic PWRITE;

	//monitor output
	bit PREADY;
	bit PSLVERR;
	bit [`DATA_WIDTH-1:0]PRDATA;

	//Transaction INFO
	function void info(string test_type, string MASTER_state, int count);
		$display("@%0t [MON]---------------------SLAVE TRANSACTION %d---------------------",$time,count);
		$display("SLV_TEST_TYPE: %s",test_type);
		$display("MASTER stateL %s",MASTER_state);

		$display("=====Handshaking Signals=====");
		$display("PSEL = %b",PSEL);
		$display("PENABLE = %b",PENABLE);
		$display("PREADY = %b",PREADY);

		$display("=========DATA Signals========");
		$display("PADDR = %d",PADDR);
		$display("PRDATA = %d",PRDATA);
		$display("PSTRB = %d",PSTRB);
		$display("PWDATA = %d",PWDATA);

		$display();
	endfunction
		
				
	//transaction copy function
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
