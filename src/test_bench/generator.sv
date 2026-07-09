`include"drv_transaction.sv"
class generator;
	drv_transaction drv_tx;
	mailbox #(drv_transaction) mbx_gen2drv;
	function new(mailbox #(drv_transaction) mbx_gen2drv);
		this.mbx_gen2drv = mbx_gen2drv;
		drv_tx = new();
	endfunction

	task run;
		repeat(10) begin
			assert(drv_tx.randomize()) begin
				mbx_gen2drv.put(drv_tx.copy());
				$display("[GEN]: Packet generated mailboxed to Driver (bridge)");
			end
			else begin
				$display("[GEN]: Randomization FAILED!!");
			end
		end
	endtask
	
endclass	

