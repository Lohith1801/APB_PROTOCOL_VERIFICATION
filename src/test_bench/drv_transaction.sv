`include "defines.svh"

typedef enum {READ, WRITE, RANDOM} APB_operation;
typedef enum {LOW, HIGH} address_range;
typedef enum {ALL_CHANGE, NO_CHANGE, RAND_CHANGE, ALTERNATE} strbyte_range;

class drv_transaction;
        //enumerations
        rand strbyte_range strb_range;
        rand address_range addr_in_range;
        rand APB_operation operation;

        //inputs
        rand bit transfer;
        rand bit write_read;
        rand bit [`ADDR_WIDTH-1:0] addr_in;
        rand bit [`ADDR_WIDTH-1:0] wdata_in;
        rand bit [(`DATA_WIDTH/8)-1:0] strb_in;   

        //outputs
        logic transfer_done;
        logic [`ADDR_WIDTH-1:0] rdata_out;
        logic error;

        //QUEUE to store addr_in
        static int Q[$];

        //constraint to set unique addr_in for each randomization
        constraint set_unq_addr_in {
                !(addr_in inside {Q});
        }
	
	//constraint to set tranfer with higher probability of 1
        constraint set_transfer {
                transfer dist { 1 := 65, 0 := 35 };
        }

	//constraint for APB operations
        constraint set_operation {
                (operation == READ)   -> write_read == 0;
                (operation == WRITE)  -> write_read == 1;
                (operation == RANDOM) -> write_read dist {1 := 65, 0 := 35};
        }

	//constraint to set address range
        constraint set_addr_in_range {
                (addr_in_range == LOW)  -> addr_in inside {[0 : (2**(`ADDR_WIDTH))/2 - 1]};
                (addr_in_range == HIGH) -> addr_in inside {[(2**(`ADDR_WIDTH))/2 : (2**(`ADDR_WIDTH))-1]};
        }

	//constraint to set strb_in with 4 options 
        constraint set_strb_range {
                (strb_range == ALL_CHANGE)  -> strb_in == {(`DATA_WIDTH/8){1'b1}};
                (strb_range == NO_CHANGE)   -> strb_in == {(`DATA_WIDTH/8){1'b0}};
                (strb_range == RAND_CHANGE) -> strb_in inside {[1 : {(`DATA_WIDTH/8){1'b1}} - 1]};
                (strb_range == ALTERNATE)   -> strb_in == {(`DATA_WIDTH/8){2'b10}};
        }

	//post randomization function with Q updation 
        function void post_randomize();
                Q.push_back(addr_in);
                if (Q.size() == `ADDR_COUNT) begin   
                        Q.delete();
                end
        endfunction


        function void print(string str = "APB TRANSACTION",int count);
                $display("----------BRIDGE TRANSACTION  %d ----------",count);
                $display("OPERATION: %s", operation.name());
                $display("ADDRESS RANGE: %s", addr_in_range.name());
                $display("[DRV_tx]: transfer = %0b write_read = %0b addr_in = %0d wdata_in = %0d strb_in = %0d",
                          transfer, write_read, addr_in, wdata_in, strb_in);
        endfunction

        function drv_transaction copy();
                copy = new();
                copy.strb_range     = this.strb_range;
                copy.addr_in_range  = this.addr_in_range;
                copy.operation      = this.operation;
                copy.transfer       = this.transfer;
                copy.write_read     = this.write_read;
                copy.addr_in        = this.addr_in;
                copy.wdata_in       = this.wdata_in;
                copy.strb_in        = this.strb_in;
                copy.transfer_done  = this.transfer_done;
                copy.rdata_out      = this.rdata_out;
                copy.error          = this.error;
                return copy;
        endfunction
endclass
