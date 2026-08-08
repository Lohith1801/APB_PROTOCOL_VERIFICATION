class test;

	environment env;
	virtual bridge_interface.DRV v_binf;
	virtual mon_interface.MON v_minf;
	function new(virtual bridge_interface.DRV v_binf, virtual mon_interface.MON v_minf);
		this.v_binf = v_binf;
		this.v_minf = v_minf;
		env = new(v_binf, v_minf);
		env.build();
	endfunction

	virtual task run;
		env.run();
	endtask
endclass

class test_write extends test;
	function new(virtual bridge_interface.DRV v_binf, virtual mon_interface.MON v_minf);
		super.new(v_binf, v_minf);
	endfunction


	virtual task run;
		env.gen.drv_tx.operation = WRITE;
		env.run();
	endtask
endclass

class test_read extends test;
        function new(virtual bridge_interface.DRV v_binf, virtual mon_interface.MON v_minf);
                super.new(v_binf, v_minf);
        endfunction


        virtual task run;
                env.gen.drv_tx.operation = READ;
                env.run();
        endtask
endclass

class test_rand extends test;
 function new(virtual bridge_interface.DRV v_binf, virtual mon_interface.MON v_minf);
                super.new(v_binf, v_minf);
        endfunction


        virtual task run;
                env.gen.drv_tx.operation = RANDOM;
                env.run();
        endtask
endclass	


class test_regg extends test;
test_write t1;
test_read t2;
test_rand t3;

 function new(virtual bridge_interface.DRV v_binf, virtual mon_interface.MON v_minf);
                super.new(v_binf, v_minf);
		t1 = new(v_binf, v_minf);
		t2 = new(v_binf, v_minf);
		t3 = new(v_binf, v_minf);
		t1.env = env;
		t2.env = env;
		t3.env = env;
        endfunction


        virtual task run;
               	t1.run();
		t2.run();
		t3.run();
        endtask
endclass


	
		
