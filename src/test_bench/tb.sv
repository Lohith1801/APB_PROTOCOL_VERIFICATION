`include"bridge_interface.sv"
`include"mon_interface.sv"
`include"package.sv"
`include"dut.v"
`include"apb_assertions.sv"
module test_bench;
	import tb_pac::*;

	bit PCLK, PRESETn;
	bridge_interface binf(.PCLK(PCLK), .PRESETn(PRESETn));
	
	mon_interface minf(.PCLK(PCLK), .PRESETn(PRESETn));
	
	//DUT instanciation
	apb_master #(.ADDR_WIDTH(`ADDR_WIDTH), .DATA_WIDTH(`DATA_WIDTH)) dut(
	
        .PCLK(PCLK), .PRESETn(PRESETn), 
	.PADDR(minf.PADDR),
	.PSEL(minf.PSEL),
	.PENABLE(minf.PENABLE),
	.PWRITE(minf.PWRITE),
	.PWDATA(minf.PWDATA),
	.PSTRB(minf.PSTRB),
	.PRDATA(minf.PRDATA),
	.PREADY(minf.PREADY),
	.PSLVERR(minf.PSLVERR),

	.transfer(binf.transfer),
	.write_read(binf.write_read),
	.addr_in(binf.addr_in),
	.strb_in(binf.strb_in),
	.rdata_out(binf.rdata_out),
	.transfer_done(binf.transfer_done),
	.error(binf.error));	


	bind dut apb_assertions assertion (
			.PCLK(PCLK), .PRESETn(PRESETn),
		     	.PADDR(minf.PADDR),
		        .PSEL(minf.PSEL),
		        .PENABLE(minf.PENABLE),
		        .PWRITE(minf.PWRITE),
		        .PWDATA(minf.PWDATA),
		        .PSTRB(minf.PSTRB),
		        .PRDATA(minf.PRDATA),
		        .PREADY(minf.PREADY),
		        .PSLVERR(minf.PSLVERR),

		        .transfer(binf.transfer),
		        .write_read(binf.write_read),
		        .addr_in(binf.addr_in),
		        .strb_in(binf.strb_in),
		        .rdata_out(binf.rdata_out),
		        .transfer_done(binf.transfer_done),
		        .error(binf.error));

	
	initial begin
		forever #5 PCLK = ~PCLK;
	end
	test_rand t1 = new(binf, minf);
	initial begin
		PRESETn = 0;
		#10;
		PRESETn = 1;
		t1.run();
		dut.assertion.assertion_report();

		#300 $finish;
	end
endmodule


