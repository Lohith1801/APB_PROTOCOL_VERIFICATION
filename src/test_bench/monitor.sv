`include"mon_transaction.sv"
typedef enum {IDEAL, SETUP, ACCESS}ABP_STATES;
typedef enum {IDEAL_TEST, ERROR_ASSERT_IN_BETWEEN_TX}slave_tests; 
class monitor;
	
	//enumerations
	ABP_STATES state;
	slave_tests slv_test;

	//handle declarations
	mon_transaction mon_tx;
	mailbox #(mon_transaction) mbx_mon2src mon_tx;
	virtual mon_interface v_minf;

	//CONSTRUCTOR and local handle connectivity with external handles
	function new(mailbox #(mon_transaction) mbx_mon2src, virtual mon_interface v_minf);
		this.mbx_mon2src = mbx_mon2src;
		this.v_minf = v_minf;
	endfunction

	//dummy PRDATA for each read call 
	bit [`DATA_WIDTH-1:0]dummy_data = 32'hABCD;

	// run/start function for monitor
	task run;
		forever begin

			//checking connectivity withe local handles
			if(mbx_mon2src == null)
				$fatal("[MON]: MAILBOX mbx_mon2src IS NOT CONNECTED!!!");
			if(v_sinf == null)
				$fatal("[MON]: VIRTUAL INTERFACE v_minf IS NOT CONNECTED!!!");

			
			
			//------------------------------------------------MONITOR Working-------------------------------------------------------
			
			//Ideal outputs
			v_minf.PREADY = 0;
			v_minf.PSLVERR = 0;
			v_minf.PRDATA = 0;
			
			
			//at PCLK active edge
			@(v_sinf.cb2mon);
			$display("@%0t [MON]: Extracting pin level signals and converting them to mon_transaction packet",$time);
			
			mon_tx.PADDR = v_minf.PADDR;
			mon_tx.PSTRB = v_minf.PSTRB;
			mon_tx.PSEL = v_minf.PSEL;
			mon_tx.PENABLE = v_minf.PENABLE;
			mon_tx.PWRITE = v_minf.PWRITE;
			
			
			//MASTER present state
			if(!v_minf.PSEL && !v_minf.PENABLE)
				state = IDEAL;

			else if(v_minf.PSEL && !v_minf.PENABLE)
				state = SETUP;

			else if(v_minf.PSEL && v_minf.PENABLE)
				state = ACCESS;

			$display("@%0t [MON]: MASTER is in %s state..",$time,state.name());
v_minf.PSLVERR = 0;
			
			//Set output logic based on states
			case(slv_tests)
				
				//IDEAL working of a APB SLAVE
				IDEAL_TEST: case(state)
					IDEAL: begin
						v_minf.PREADY = 0;
						v_minf.PSLVERR = 0;
					end

					SETUP: begin
						if(mon_tx.PWRITE)
						mon_tx.PWDATA = v_minf.PWDATA;
					end

					ACCESS:begin		
						v_minf.PREADY = 1;
				
						//checking for address bound
						if(v_minf.PADDR <= `ADDR_BOUND_MAX && v_minf.PADDR >= `ADDR_BOUND_MIN) begin
							v_minf.PSLVERR = 1;
							if(!mon_tx.PWRITE) begin
								v_minf.PRDATA = dummy_data;
							end
						end
						else begin
							v_minf.PSLVERR = 0;
						end
					end
				endcase
					
				//ASSERTING PSLVERR before ACCESS
				ERROR_ASSERT_IN_BETWEEN_TX:case(state)
								IDEAL: begin
                                                                        v_minf.PREADY = 0;
                                                                        v_minf.PSLVERR = 0;
                                                                end

                                                                SETUP: begin
                                                                        v_minf.PSLVERR = 1;
                                                                        if(mon_tx.PWRITE)
                                                                                mon_tx.PWDATA = v_minf.PWDATA;
                                                                end

                                                                ACCESS:begin
                                                                        v_minf.PREADY = 1;

                                                                        //checking for address bound
                                                                        if(v_minf.PADDR <= `ADDR_BOUND_MAX && v_minf.PADDR >= `ADDR_BOUND_MIN) begin
                                                                                v_minf.PSLVERR = 1;
                                                                                if(!mon_tx.PWRITE) begin
                                                                                        v_minf.PRDATA = dummy_data;
                                                                                end
                                                                        end
                                                                        else begin
                                                                                v_minf.PSLVERR = 0;
                                                                        end
                                                                end
				endcase
                                
				
			endcase

	endtask
endclass


					      		      





