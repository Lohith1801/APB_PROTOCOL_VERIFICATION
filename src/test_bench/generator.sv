class generator;
	
	//handle declaration
	drv_transaction drv_tx;
	mailbox #(drv_transaction) mbx_gen2drv;

	//CONSTRUCTOR and local handle connectivity with the enviroment handle
	function new(mailbox #(drv_transaction) mbx_gen2drv);
		this.mbx_gen2drv = mbx_gen2drv;
		drv_tx = new();
	endfunction

	// run/start task for generator
	task run;

		//------------------------------------Generator Working----------------------------------------
		repeat(`TX_COUNT) begin

			//Randomization PASS condition
			assert(drv_tx.randomize()) begin
				mbx_gen2drv.put(drv_tx.copy());
				$display("@%0t [GEN]: Packet generated mailboxed to Driver (bridge)",$time);
			end

			//Randomization FAIL condition
			else begin
				$display("@%0t [GEN]: Randomization FAILED!!",$time);
			end
		end
	endtask
	
endclass	

