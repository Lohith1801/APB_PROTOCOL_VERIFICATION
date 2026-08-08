class environment;
	mailbox #(drv_transaction) mbx_gen2drv;
	mailbox #(drv_transaction) mbx_drv2scr;
	mailbox #(mon_transaction) mbx_mon2scr;
	virtual bridge_interface.DRV v_binf;
	virtual mon_interface.MON v_minf;
	generator gen;
	driver drv;
	monitor mon;
	scoreboard scr;
	function new(virtual bridge_interface.DRV v_binf, virtual mon_interface.MON v_minf);
		this.v_binf = v_binf;
		this.v_minf = v_minf;
	endfunction
	
	task build;
		mbx_gen2drv = new();
		mbx_drv2scr = new();
		mbx_mon2scr = new();
		gen = new(mbx_gen2drv);
		drv = new(mbx_gen2drv,mbx_drv2scr, v_binf);
		mon = new(mbx_mon2scr, v_minf);
		scr = new(mbx_drv2scr, mbx_mon2scr);

		mon.slv_tests = IDEAL_TEST;	
	endtask

	task run();
		fork
			gen.run();
			drv.run();
			mon.run();
		join
		scr.run();
		scr.report();
	endtask

endclass

