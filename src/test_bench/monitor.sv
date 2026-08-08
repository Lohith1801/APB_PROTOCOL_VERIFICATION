typedef enum {IDEAL, SETUP, ACCESS}ABP_STATES;
typedef enum {IDEAL_TEST, WAIT_STATES, ERROR_ASSERT_IN_BETWEEN_TX}slave_tests;
class monitor;

        //Tx count variable
        int count;
	int wait_cycles = 0;
        //enumerations
        ABP_STATES state;
        slave_tests slv_tests;

        //handle declarations
        mon_transaction mon_tx;
        mailbox #(mon_transaction) mbx_mon2src;
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
                        if(v_minf == null)
                                $fatal("[MON]: VIRTUAL INTERFACE v_minf IS NOT CONNECTED!!!");

                        //------------------------------------------------MONITOR Working-------------------------------------------------------

                        //at PCLK active edge
                        @(v_minf.cb2mon);

                        //PRESETn asserted condition
                        if(!v_minf.PRESETn) begin
                                $display("@%0t [MON]: PRESETn ASSERTED!!!!",$time);
                                v_minf.cb2mon.PREADY  <= 0;
                                v_minf.cb2mon.PSLVERR <= 0;
                                v_minf.cb2mon.PRDATA  <= 0;
                                wait_cycles           <= 0;
                        end

                        //PRESETn deasserted condition
                        else begin

                                // new transaction object
                                mon_tx = new();

                                $display("@%0t [MON]: Extracting pin level signals and converting them to mon_transaction packet",$time);
                                mon_tx.PADDR   = v_minf.cb2mon.PADDR;
                                mon_tx.PSTRB   = v_minf.cb2mon.PSTRB;
                                mon_tx.PSEL    = v_minf.cb2mon.PSEL;
                                mon_tx.PENABLE = v_minf.cb2mon.PENABLE;
                                mon_tx.PWRITE  = v_minf.cb2mon.PWRITE;

                                //MASTER present state
                                if(!v_minf.cb2mon.PSEL && !v_minf.cb2mon.PENABLE)
                                        state = IDEAL;

                                else if(v_minf.cb2mon.PSEL && !v_minf.cb2mon.PENABLE)
                                        state = SETUP;

                                else if(v_minf.cb2mon.PSEL && v_minf.cb2mon.PENABLE)
                                        state = ACCESS;

                                $display("@%0t [MON]: MASTER is in %s state..",$time,state.name());

                                //Set output logic based on states
                                case(slv_tests)

                                        //IDEAL working of a APB SLAVE
                                        IDEAL_TEST: begin
                                                if (state == SETUP) begin
                                                        if(v_minf.cb2mon.PWRITE)
                                                                mon_tx.PWDATA = v_minf.cb2mon.PWDATA;
                                                end 
                                                else if (state == ACCESS) begin
							v_minf.cb2mon.PREADY <= 1;
                                                        //checking for address bound
                                                        if(v_minf.cb2mon.PADDR <= `ADDR_BOUND_MAX && v_minf.cb2mon.PADDR >= `ADDR_BOUND_MIN) begin
                                                                v_minf.cb2mon.PSLVERR <= 1;
                                                        end
                                                        else begin
                                                                v_minf.cb2mon.PSLVERR <= 0;
                                                                if(!v_minf.cb2mon.PWRITE) begin
                                                                     v_minf.cb2mon.PRDATA <= dummy_data;
                                                                end
                                                        end
                                                end 
                                                else begin
                                                        v_minf.cb2mon.PREADY <= 0;
                                                        v_minf.cb2mon.PSLVERR <= 0;
                                                end
                                        end

                                        // WAIT states with 3CLK delays for PREADY
                                        WAIT_STATES: begin
                                                if (state == SETUP) begin
                                                        v_minf.cb2mon.PREADY <= 0;
                                                        wait_cycles <= 3;
                                                        if(v_minf.cb2mon.PWRITE)
                                                                mon_tx.PWDATA = v_minf.cb2mon.PWDATA;
                                                end 
                                                else if (state == ACCESS) begin
                                                        //PSLVERR condition for out of bound address (PADDR)
                                                        if(v_minf.cb2mon.PADDR <= `ADDR_BOUND_MAX && v_minf.cb2mon.PADDR >= `ADDR_BOUND_MIN) begin
                                                                v_minf.cb2mon.PSLVERR <= 1;
                                                                if(!v_minf.cb2mon.PWRITE) begin
                                                                        v_minf.cb2mon.PRDATA <= dummy_data;
                                                                end
                                                        end
                                                        //PSLVERR condition for Inbound address (PADDR)
                                                        else begin
                                                                v_minf.cb2mon.PSLVERR <= 0;
                                                        end

                                                        //ADDING WAIT for PREADY
                                                        if (wait_cycles > 1) begin
                                                                wait_cycles <= wait_cycles - 1;
                                                                v_minf.cb2mon.PREADY <= 0;
                                                        end else if (wait_cycles == 1) begin
                                                                wait_cycles <= 0;
                                                                v_minf.cb2mon.PREADY <= 1;
                                                        end
                                                end 
                                                else begin
                                                        v_minf.cb2mon.PREADY <= 0;
                                                end
                                        end

                                        //ASSERTING PSLVERR before ACCESS
                                        ERROR_ASSERT_IN_BETWEEN_TX: begin
                                                if (state == IDEAL) begin
                                                        v_minf.cb2mon.PREADY <= 0;
                                                        v_minf.cb2mon.PSLVERR <= 0;
                                                end
                                                else if (state == SETUP) begin
                                                        if(v_minf.cb2mon.PWRITE)
                                                                mon_tx.PWDATA <= v_minf.cb2mon.PWDATA;
                                                end
                                                else if (state == ACCESS) begin
                                                        v_minf.cb2mon.PREADY <= 1;
                                                        //checking for address bound
                                                        if(v_minf.cb2mon.PADDR <= `ADDR_BOUND_MAX && v_minf.cb2mon.PADDR >= `ADDR_BOUND_MIN) begin
                                                              v_minf.cb2mon.PSLVERR <= 1;
                                                                if(!v_minf.cb2mon.PWRITE) begin
                                                                        v_minf.cb2mon.PRDATA <= dummy_data;
                                                                end
                                                        end
                                                        else begin
                                                                v_minf.cb2mon.PSLVERR <= 0;
                                                        end
                                                end
                                        end
                                endcase

                                // Assigning slave outs to the transaction
                                mon_tx.PREADY   = v_minf.cb2mon.PREADY;
                                mon_tx.PSLVERR   = v_minf.cb2mon.PSLVERR;
                                mon_tx.PRDATA   = v_minf.cb2mon.PRDATA;

                                // Printing the transaction info.......
                                if (v_minf.cb2mon.PSEL && v_minf.cb2mon.PENABLE && v_minf.cb2mon.PREADY) begin

                                        if(count == 10)
                                                return;
                                        else begin
                                                if(state == ACCESS) begin
                                                        count ++;
							mon_tx.info(slv_tests.name(), state.name(), count);
							mbx_mon2src.put(mon_tx);			
                                                end
                                        end

                                end

                        end
                end
        endtask
endclass
