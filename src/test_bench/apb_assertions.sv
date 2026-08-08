module apb_assertions(
	input bit PCLK, PRESETn, 
	input bit transfer, write_read, 
	input bit [`ADDR_WIDTH-1:0]addr_in, 
	input bit[`DATA_WIDTH-1:0]wdata_in, 
	input bit [(`DATA_WIDTH/8)-1:0]strb_in, 
	input bit transfer_done,
       	input bit [`DATA_WIDTH-1:0]rdata_out,
	input bit error,
	input bit [`ADDR_WIDTH-1:0]PADDR,
       	input bit [`DATA_WIDTH-1:0]PWDATA,
	input bit [(`DATA_WIDTH/8)-1:0]PSTRB,
	input bit PSEL, PENABLE, PWRITE, PREADY, PSLVERR,
	input bit [`DATA_WIDTH-1:0]PRDATA	
);

	bit  all_pass = 1;
	bit RESET_assert_test;
	always@(negedge PRESETn) begin
		assert((PADDR==0) && (PWDATA==0) && (PSTRB == 0) && !PSEL && !PENABLE && !PWRITE)
		else begin
			RESET_assert_test = 1;
		end
	end
	bit after_pready;		
	property after_pready_test;
		@(posedge PCLK)
		(PREADY && transfer) |=> PSEL;
	endproperty	
	bit after_pready1;
	property after_pready1_test;
		@(posedge PCLK)
		(PREADY && !transfer) |=> !PSEL;
	endproperty

	bit transfer_initiate_test;
	property transfer_initiate;
		@(posedge PCLK)
		$rose(transfer)|=> PSEL ##1 PENABLE;
	endproperty
	assert property(transfer_initiate)
	else begin
		transfer_initiate_test = 1;
	end


	bit stable_signals_at_setup_test;
	property stable_signals;
		@(posedge PCLK)
		(PSEL && PENABLE)|-> ($stable(PADDR) && $stable(PWDATA) && $stable(PSTRB));
	endproperty

	assert property(stable_signals)
	else begin
		stable_signals_at_setup_test = 1;
	end

	bit trasnfer_done_assert_test;
	property trasnfer_done_assert;
		@(posedge PCLK)
	        (PREADY)|=> transfer_done;
	endproperty

	assert property(trasnfer_done_assert)
        else begin
		trasnfer_done_assert_test = 1;
	end

	assert property(after_pready1_test)
	else 
		after_pready1 = 1;

	assert property(after_pready_test)
	else 
		after_pready = 1;


	task assertion_report();
		$display("--------------------------------------------------------------------ASSERTION REPORT--------------------------------------------------------------------");

		if(RESET_assert_test) begin
			$display("[ASR] :PRESETn assertion failed!!!");
			all_pass = 0;
		end
		if(transfer_initiate_test) begin
	       		$display("[ASR] :transfer_initiate_test assertion failed!!!");
			all_pass = 0;
		end

		if(stable_signals_at_setup_test) begin
			$display("[ASR] :stable_signals_at_setup_test assertion failed!!!");
			all_pass = 0;
		end

		if(trasnfer_done_assert_test) begin
			$display("[ASR] :trasnfer_done_assert_test assertion failed!!!");
			all_pass = 0;
		end
		
		if(after_pready) begin
			$display("[ASR] : Wrong state after preday and transfer assert!!!");
			all_pass = 0;
		end

		if(after_pready1) begin
			$display("[ASR] : Wrong state after preday assert!!!");
			all_pass = 0;
		end

		if(all_pass) begin
			$display("[ASR] : all the assertions are passing!!");
		end
	endtask
endmodule	




			

