class monitor;
	mon_transaction slv_tx;
	mailbox #(slv_transaction) mbx_mon2src;
	virtual mon_interface v_sinf;

	function new(mailbox #(slv_transaction) mbx_mon2src, virtual slave_interface v_sinf);
		this.mbx_mon2src = mbx_mon2src;
		this.v_sinf = v_sinf;
	endfunction

	bit [`DATA_WIDTH-1:0]dummy_data = 32'hABCD;

	task run;
		forever begin
			mbx_mon2src.PADDR = v_sinf.PADDR;
			mbx_mon2src.PWDATA = v_sinf.PWDATA;
			mbx_mon2src.PSTRB = v_sinf.PSTRB;
			mbx_mon2src.PSEL = v_sinf.PSEL;
			mbx_mon2src.PENABLE = v_sinf.PENABLE;
			mbx_mon2src.PWRITE = v_sinf.PWRITE;

			if(v_sinf.PSEL && v_sinf.PENABLE) begin





