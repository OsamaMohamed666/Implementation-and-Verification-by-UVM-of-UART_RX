class uart_rx_driver extends uvm_driver#(seq_item);
`uvm_component_utils(uart_rx_driver)
uart_rx_config cfg;
virtual uart_rx_intf vif;

function new(string name = "uart_rx_driver", uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db#(uart_rx_config)::get(this, "", "uart_rx_cfg", cfg))
      `uvm_fatal(get_type_name(), "Failed to get uart_rx_cfg from config DB")

endfunction

function void connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	vif = cfg.vif;
endfunction 
task reset_inputs();
	`uvm_info(get_type_name(), "Resetting input signals", UVM_LOW)
	vif.rx_in_s <=1;
endtask 

task run_phase (uvm_phase phase);
	reset_inputs();
	@ (posedge vif.rst_n);
	forever begin
		seq_item_port.get_next_item(req);
		// CONFIGUERED SIGNALS
		req.parity_en <= cfg.parity_en;
		req.parity_type <= cfg.parity_type;
		req.prescale <= cfg.prescale;
		//DRIVING SIGNALS
		vif.parity_en <= req.parity_en;
		vif.parity_type <= req.parity_type;
		vif.prescale <= req.prescale;
		rx_drive();
		seq_item_port.item_done();
	end
endtask

task rx_drive();
	@(posedge vif.tx_clk) 
	//DRIVING INPUTS
		vif.rx_in_s <= req.rx_in_s;
	//DRIVING OUTPUTS
		req.rx_out_v <= vif.rx_out_v ;
		req.rx_out_p <= vif.rx_out_p;

endtask 
endclass

