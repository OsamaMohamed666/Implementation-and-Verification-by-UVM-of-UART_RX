`include "uart_rx_package.sv"
class uart_rx_test extends uvm_test;
uart_rx_env env;
base_seq even_par_seq, odd_par_seq, non_par_seq;
uart_rx_config cfg;

`uvm_component_utils(uart_rx_test)

function new(string name = "uart_rx_test", uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	env = uart_rx_env::type_id::create("env", this);
	cfg = uart_rx_config::type_id::create("cfg");
	cfg.parity_en = 1'b1;  // Initially enabled
	cfg.parity_type = 1'b0;    // Initially even parity
	cfg.prescale = 5'b01000;
	if (!uvm_config_db#(virtual uart_rx_intf)::get(this, "", "vif", cfg.vif))
      `uvm_fatal(get_type_name(), "Failed to get vif from config DB")
    // Store config object in config_db
      uvm_config_db#(uart_rx_config)::set(null, "*", "uart_rx_cfg", cfg);
endfunction

task run_phase(uvm_phase phase);
	phase.raise_objection(this);
	//  stimuls with EVEN parity 
	even_par_seq = base_seq::type_id::create("even_par_seq");
	`uvm_info(get_type_name(), "STARTING TEST WITH PARITY_TYPE = 0 (EVEN)", UVM_MEDIUM)
	even_par_seq.no_stimuls =200;
	even_par_seq.start(env.agt.seqr);
	wait (even_par_seq.req1.bit_count==0); //wait untill total transaction is done
	
	$display("----------------------------------------------------------------------------------------------------------");
	$display("----------------------------------------------------------------------------------------------------------");
	
	// stimuls with odd parity 
	odd_par_seq = base_seq::type_id::create("odd_par_seq");
	`uvm_info(get_type_name(), "STARTING TEST WITH PARITY_TYPE = 1 (ODD)", UVM_MEDIUM)
	cfg.parity_type = 1'b1; 	
	odd_par_seq.no_stimuls =300;
	odd_par_seq.start(env.agt.seqr);
	
	wait (odd_par_seq.req1.bit_count==0); //wait untill total transaction is done 

	$display("----------------------------------------------------------------------------------------------------------");
	$display("----------------------------------------------------------------------------------------------------------");
	
	// stimuls without  parity 
	non_par_seq = base_seq::type_id::create("non_par_seq");
	cfg.parity_en = 1'b0; 
	`uvm_info(get_type_name(), "STARTING TEST WITHOUT PARITY", UVM_MEDIUM)
	non_par_seq.no_stimuls =150;
	non_par_seq.start(env.agt.seqr);
	
	phase.drop_objection(this);
endtask

//END OF ELABORATION PHASE
virtual function void end_of_elaboration();
uvm_top.print_topology();
endfunction

//REPORT PHASE 
virtual function void report_phase(uvm_phase phase);
	uvm_report_server svr;
	super.report_phase(phase);
 
	svr = uvm_report_server::get_server();
	if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
		`uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
		`uvm_info("Report_Phase", "----TEST FAIL----", UVM_NONE)
    	`uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
	end
	else begin
		`uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
		`uvm_info("Report_Phase", "---- TEST PASS ----", UVM_NONE)
		`uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
	end
endfunction 
endclass
