class base_seq extends uvm_sequence#(seq_item);
seq_item req1;
`uvm_object_utils(base_seq)
uart_rx_config cfg;  // Configuration object

function new (string name = "base_seq");
super.new(name);
endfunction

int no_stimuls =10; //default 100 repeats 
//bit i;
virtual task body();
  int valid_no_stimuls = 10*no_stimuls;
  if (!uvm_config_db#(uart_rx_config)::get(null, "*", "uart_rx_cfg", cfg)) begin
            `uvm_fatal("SEQ", "Failed to get uart_rx_config from uvm_config_db")
        end

		
	repeat (valid_no_stimuls) begin
	 //`uvm_do(req1);
		req1 = seq_item#(8,5)::type_id::create("req1");
		// Assign config values to seq item to randomize according to this configurations
		req1.parity_en = cfg.parity_en;
        req1.parity_type = cfg.parity_type;
		req1.prescale = cfg.prescale;
		
		start_item(req1);
		assert(req1.randomize()) else `uvm_fatal(get_type_name(),"Failed to randomize");
		finish_item(req1);
	end 
endtask
endclass