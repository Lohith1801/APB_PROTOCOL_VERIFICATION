`include"bridge_interface.sv"
`include"drv_transaction.sv"
class driver;
	drv_transaction drv_tx;
	mailbox #(drv_transaction) mbx_gen2drv;
	mailbox #(drv_transaction) mbx_drv2ref;
	virtual bridge_interface v_binf;
	function new(mailbox #(drv_transaction) mbx_gen2drv, virtual bridge_interface v_binf);
		this.mbx_gen2drv = mbx_gen2drv;
		this.v_binf = v_binf;
	endfunction

	task run;
		forever begin
			//reset deasset condition
			if(v_binf.PRESETn) begin
				@(v_binf.cb2drv);
				if(v_binf.transfer_done) begin
					
						mbx_gen2drv.get(drv_tx);
						fork
							begin
							v_binf.transfer <= 1'b1;
							v_binf.transfer <= #5 1'b0;
							end
							v_binf.write_read <= drv_tx.write_read; 
							v_binf.addr_in <= drv_tx.addr_in;
							v_binf.wdata_in <= drv_tx.wdata_in;
							v_binf.strb_in <= drv_tx.strb_in;
						join
					$display("[DRV]: Driving -| transfer = %b write_read = %b addr_in = %d wdata_in = %d strb_in = %b transfer_done = 1",transfer,write_read, addr_in, wdata_in, strb_in);
						
				end
				else begin
					drv_tx.rdata_out = v_binf.rdata_out;
					drv_tx.error = v_binf.error;
					$display("[DRV]: Recived -| rdata_out = %d error = %b transfer_done = 0",rdata_out,error);
				end
				mbx_drv2ref.put(drv_tx);
			end

			//reset assert condition
			else begin
				v_binf.transfer <= 'b0;
				v_binf.write_read <= 'b0;
				v_binf.addr_in <= 'b0;
 				v_binf.wdata_in <= 'b0;
				v_binf.strb_in <= 'b0;
			end
		end
	endtask

endclass



			
