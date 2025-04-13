class uart_rx_monitor_out extends uvm_monitor;
`uvm_component_utils(uart_rx_monitor_out)
uvm_analysis_port #(seq_item) item_collect_port_out;
uart_rx_config cfg;
seq_item mon_out_item;
virtual uart_rx_intf vif;

function new(string name = "uart_rx_monitor_out", uvm_component parent = null);
	super.new(name, parent);
	item_collect_port_out = new("item_collect_port_out", this);
	mon_out_item = new();
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
		rx_monitor_out();
	end
endtask

task rx_monitor_out();
	@(negedge vif.tx_clk iff (vif.bit_count == 4'b1001))
		mon_out_item.bit_count = vif.bit_count;
		mon_out_item.rx_out_p = vif.rx_out_p;
		//`uvm_info(get_type_name(), $sformatf(" parallel data is %b  at bit count = %0d",mon_out_item.rx_out_p,mon_out_item.bit_count), UVM_MEDIUM)	
	
	if (cfg.parity_en) //if itsnot enabled it will not wait another cycle as now frame is 10 bits only
		@(negedge vif.tx_clk);
		
	mon_out_item.parity_err = vif.parity_err;

	@(negedge vif.rx_clk iff (vif.bit_count == 4'b0))
		mon_out_item.framing_err = vif.framing_err;
		mon_out_item.rx_out_v = vif.rx_out_v;
		//`uvm_info(get_type_name(), $sformatf(" parallel data is %b when valid = %b , p_err is %0b , framing_err is %0b at bit count = %0d",mon_out_item.rx_out_p,mon_out_item.rx_out_v,mon_out_item.parity_err,mon_out_item.framing_err,vif.bit_count), UVM_MEDIUM)	
		item_collect_port_out.write(mon_out_item);
	
		//$display("----------------------------------------------------------------------------------------------------------");
		

endtask


endclass

