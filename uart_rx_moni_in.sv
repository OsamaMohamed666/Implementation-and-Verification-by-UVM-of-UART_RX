class uart_rx_monitor_in extends uvm_monitor;
`uvm_component_utils(uart_rx_monitor_in)
uvm_analysis_port #(seq_item) item_collect_port;
uart_rx_config cfg;
seq_item mon_in_item;
virtual uart_rx_intf vif;

function new(string name = "uart_rx_monitor_in", uvm_component parent = null);
	super.new(name, parent);
	item_collect_port = new("item_collect_port", this);
	mon_in_item = new();
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(uart_rx_config) :: get(this, "", "uart_rx_cfg", cfg))
	`uvm_fatal(get_type_name(), "Failed to get uart_rx_cfg from config DB");
endfunction

function void connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	vif=cfg.vif;
endfunction  

task run_phase (uvm_phase phase);
	forever begin
		wait(vif.rst_n);
		mon_in_item.parity_type = cfg.parity_type;
		mon_in_item.parity_en = cfg.parity_en;
		mon_in_item.prescale = cfg.prescale;
		rx_monitor_in();
	end
endtask

task rx_monitor_in();
	// UART_RX only starts receiving when bit_count>0 , parallel data are started to be received
	@(negedge vif.tx_clk iff (vif.bit_count>4'b00)); 	
		mon_in_item.rx_in_s = vif.rx_in_s;
		mon_in_item.bit_count = vif.bit_count;
		`uvm_info(get_type_name(), $sformatf(" serial input data is %b at bit count=%0d",mon_in_item.rx_in_s,mon_in_item.bit_count), UVM_MEDIUM)
		item_collect_port.write(mon_in_item);
endtask


endclass
