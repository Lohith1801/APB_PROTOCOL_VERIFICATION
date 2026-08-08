class scoreboard;
	mailbox #(drv_transaction) mbx_drv2scr;
	mailbox #(mon_transaction) mbx_mon2scr;

	int PASS, FAIL;	
	drv_transaction drv_tx;
	mon_transaction out;
	drv_transaction exp_Q[$];
	mon_transaction out_Q[$];
	int count;

	function new(mailbox #(drv_transaction) mbx_drv2scr, mailbox #(mon_transaction) mbx_mon2scr);
		this.mbx_drv2scr = mbx_drv2scr;
		this.mbx_mon2scr = mbx_mon2scr;
	endfunction

	//---------------------------Reference model that mimics APB_ MASTER-----------------------------
	

	task data_match(drv_transaction drv_tx, mon_transaction out);
		if(drv_tx.addr_in == out.PADDR && drv_tx.wdata_in == out.PWDATA && drv_tx.strb_in == out.PSTRB) begin
			$display("[SCR]: PASS");
			PASS++;
		end
		else begin
			$display("[SCR] :FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			$display("expected data  PADDR= %d, PWRITE = %b, PWDATA = %d, PSTRB = %d",drv_tx.addr_in,drv_tx.write_read, drv_tx.wdata_in, drv_tx.strb_in); 
			$display("recived data  PADDR= %d, PWRITE = %b, PWDATA = %d, PSTRB = %d",out.PADDR,out.PWRITE, out.PWDATA, out.PSTRB);
			FAIL++;
		end
	endtask


	task reference_model(drv_transaction drv_tx, mon_transaction out);
		if(drv_tx.write_read == out.PWRITE) begin
			data_match(drv_tx, out);
		end
		else begin
			$display("[SCR] :FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			$display("expected data  PADDR= %d, PWRITE = %b, PWDATA = %d, PSTRB = %d",drv_tx.addr_in,drv_tx.write_read, drv_tx.wdata_in, drv_tx.strb_in);
			 $display("recived data  PADDR= %d, PWRITE = %b, PWDATA = %d, PSTRB = %d",out.PADDR,out.PWRITE, out.PWDATA, out.PSTRB);
			FAIL++;
		end
	endtask

	task run();
		for(int i=0;i<`TX_COUNT;i++) begin
				mbx_drv2scr.get(drv_tx);
				mbx_mon2scr.get(out);
				exp_Q.push_back(drv_tx);
				//if(i!= 0)
					out_Q.push_back(out);
		end
		for(int i=0;i<`TX_COUNT;i++) begin
			reference_model(exp_Q[i],out_Q[i]);
		end

	endtask


	task report();
		$display("--------------------------------------SIMUALTION REPORT-----------------------------------------");
		$display("PASS COUNT = %d",PASS);
		$display("FAIL COUNT = %d",FAIL);
		$display("PASS PERCENTAFE = %f",(100.0*(PASS)/(PASS +FAIL)));

	endtask

endclass


		
