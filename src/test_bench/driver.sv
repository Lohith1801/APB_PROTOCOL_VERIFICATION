
class driver;

	//static var to count the number of transactions sent 
	static int count;


	//Handle declarations
	drv_transaction drv_tx;
	mailbox #(drv_transaction) mbx_gen2drv;
	mailbox #(drv_transaction) mbx_drv2scr;
	virtual bridge_interface.DRV v_binf;

	covergroup cg;
		cp_write_read: coverpoint drv_tx.write_read;
		cp_addr_in: coverpoint drv_tx.addr_in{
			bins addr_in_arr[] = {[0:15]};
		}
		
		cross cp_write_read,cp_addr_in;
		cp_strb_in: coverpoint drv_tx.strb_in{
			bins strb_in_arr[] = {[0:15]};
		}
	endgroup

        //Constructor Function and local handle connectivity to env handles

	function new(mailbox #(drv_transaction) mbx_gen2drv, mailbox #(drv_transaction) mbx_drv2scr, virtual bridge_interface v_binf);
		this.mbx_gen2drv = mbx_gen2drv;
		this.v_binf = v_binf;
		this.mbx_drv2scr = mbx_drv2scr;
		cg = new();
	endfunction

	//Driver start or run task
	task run;
		forever begin
			//cheking for the connectivity of local handles
			if(mbx_gen2drv == null) 
				$fatal("@%0t [DRV]: MAILBOX mbx_gen2drv IS NOT CONNECTED",$time);
			if(mbx_drv2scr == null)
				$fatal("@%0t [DRV]: MAILBOX mbx_gen2scr IS NOT CONNECTED",$time);
			if(v_binf == null)
				$fatal("@%0t [DRV]: VIRTUAL INTERFACE v_binf IS NOT CONNECTED",$time);

			

			// ----------------------------------------Driver working-----------------------------------------------
			$display("@%0t [DRV]: Waiting for drv_transaction...",$time);
			mbx_gen2drv.get(drv_tx);
			$display("@%0t [DRV]: Got drv_transaction from mbx_gen2drv",$time);
			
			//at PCLK active edge
			@(v_binf.cb2drv);

			//PRESETn assert condition
			if(!v_binf.PRESETn) begin
				$display("@%0t [DRV]: PRESETn is asserted",$time);

				//driving ideal value(0) to the DUT input ports
				v_binf.cb2drv.transfer <= 0;
				v_binf.cb2drv.write_read <= 0;
				v_binf.cb2drv.addr_in <= 0;
				v_binf.cb2drv.wdata_in <= 0;
				v_binf.cb2drv.strb_in <= 0;

			end

			//PRESETn deassert condition
			else begin
				$display("@%0t [DRV]: Driving the drv_transaction packet to DUT",$time);
				count++;
				drv_tx.print("APB TRANSACTION",count); 
									
				//driving transaction pack as pin level signals to DUT
					v_binf.cb2drv.transfer <= 1;
					v_binf.cb2drv.write_read <= drv_tx.write_read;
					v_binf.cb2drv.addr_in <= drv_tx.addr_in;
					v_binf.cb2drv.wdata_in <= drv_tx.wdata_in;
					v_binf.cb2drv.strb_in <= drv_tx.strb_in;
					cg.sample();
			end
			mbx_drv2scr.put(drv_tx);	
			//Watch Dog timer logic to wait dor transfer_done
			fork 
				begin
					wait(v_binf.cb2drv.transfer_done || (!v_binf.PRESETn) );
				end

				begin
					repeat(25) begin
						@(v_binf.cb2drv);
					end
					$fatal("@%0t [DRV]: transfer_done IS NOT ASSERTED BY DUT afetr drv_transaction been sent",$time);
				end
			join_any
			disable fork; 
			
			//End the driver task when number of transactions reaches maximum count TX_COUNT
			if(count == `TX_COUNT)
				return;


		end
	endtask
endclass	

			
