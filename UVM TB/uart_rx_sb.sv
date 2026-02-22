`uvm_analysis_imp_decl(_MON_IN)
`uvm_analysis_imp_decl(_MON_OUT)
class uart_rx_scoreboard #(parameter DATA_WIDTH = 8)extends uvm_scoreboard;
uvm_analysis_imp_MON_IN #(seq_item, uart_rx_scoreboard) item_collect_export_in;
uvm_analysis_imp_MON_OUT #(seq_item, uart_rx_scoreboard) item_collect_export_out;
seq_item item_in[$],item_out[$];
`uvm_component_utils(uart_rx_scoreboard)

function new(string name = "uart_rx_scoreboard", uvm_component parent = null);
	super.new(name, parent);
	item_collect_export_in = new("item_collect_export_in", this);
	item_collect_export_out = new("item_collect_export_out", this);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

function void write_MON_IN(seq_item req);
	item_in.push_back(req);
endfunction
 
function void write_MON_OUT(seq_item req);
	item_out.push_back(req); //valid = 1
endfunction


int cnt_crr,cnt_err; // counter for correct and incorrect outputs
//FOR EXPECTED OUTPUT 
bit  [(DATA_WIDTH+2)-1:0]  parity_out_exp; //[9:0], bit_9=stop_bit, bit_8=parity_bit,bits_[7:0]= data 
bit  [(DATA_WIDTH+1)-1:0]  non_parity_out_exp; //[8:0], bit_8=stop_bit, bits_[7:0]= data  
bit  [DATA_WIDTH-1:0]  out_exp;  
bit  valid_bit_exp;
bit  parity_bit_exp;
bit  parity_err_exp;
bit  end_bit_exp;
bit  framing_err_exp;
//FOR ACUTAL OUPUT
bit  [DATA_WIDTH-1:0]  out_tmp; 
bit framing_err;
bit valid_bit;
bit parity_bit;

bit done_processing = 0;	//used to detect that scoreboard processing finished or not to end the phase 


virtual task run_phase (uvm_phase phase);
seq_item sb_item;
forever begin
	rx_scoreboard(sb_item);
	
	$display("----------------------------------------------------------------------------------------------------------");
end
endtask

virtual task rx_scoreboard(seq_item sb_item);
	int DATA_WIDTH_OUTPUT;
	wait(item_in.size>0);
	
	done_processing = 1'b0; // to provide end phase function to complete the scoreboard functionlity 
	$display("----------------------------------------------------------------------------------------------------------");
	
	sb_item = item_in.pop_front();
	DATA_WIDTH_OUTPUT = sb_item.parity_en? (DATA_WIDTH+2) : (DATA_WIDTH+1); // check that output will be 11 bits or 10 bits according to parity enable
	for (int i=0; i<DATA_WIDTH_OUTPUT; i++) begin
		if(sb_item.parity_en) begin
			`uvm_info(get_type_name(), $sformatf(" serial input data is %b at bit count=%0d",sb_item.rx_in_s,(i+1'b1)), UVM_MEDIUM)
			parity_out_exp = {sb_item.rx_in_s , parity_out_exp[(DATA_WIDTH+2)-1:1]}; // bit_9=stop_bit, bit_8=parity_bit,bits_[7:0]= data 
			out_exp = parity_out_exp[7:0];
			parity_bit_exp = parity_out_exp[8];
			end_bit_exp = parity_out_exp[9];
		end 

		else begin
			non_parity_out_exp = {sb_item.rx_in_s , non_parity_out_exp[8:1]}; // bit_8=stop_bit, bits_[7:0]= data 
			out_exp = non_parity_out_exp[7:0];
			end_bit_exp = non_parity_out_exp[8];
			`uvm_info(get_type_name(), $sformatf(" serial input data is %b at bit count=%0d",sb_item.rx_in_s,(i+1'b1)), UVM_MEDIUM)

		end
		
		if(sb_item.bit_count != DATA_WIDTH_OUTPUT) begin // to avoid waiting extra transaction
			wait(item_in.size>0);
			sb_item = item_in.pop_front();
		end
	end 	

	//PARITY CHECK
	if(sb_item.parity_en) begin
	if(sb_item.parity_type) begin 
		if (parity_bit_exp == odd_parity_check(out_exp))
			parity_err_exp = 1'b0;
		else 
			parity_err_exp = 1'b1;
	end 
	
	else begin 
		if (parity_bit_exp == even_parity_check(out_exp))
			parity_err_exp = 1'b0;
		else 
			parity_err_exp = 1'b1;
	end 
	end 
	
	//END POINT CHECK (FRAMING ERROR)
	if (end_bit_exp)
		framing_err_exp = 1'b0;
	else 
		framing_err_exp = 1'b1;
		
	//DATA VALID CHECK 
	if(parity_err_exp || framing_err_exp)
		valid_bit_exp = 1'b0;
	else 
		valid_bit_exp = 1'b1;
		`uvm_info(get_type_name(), $sformatf(" EXPECTED data is = %b @valid = %b,end bit=%b,parity=%d ", out_exp, valid_bit_exp, end_bit_exp,parity_bit_exp),UVM_MEDIUM)

		
	wait(item_out.size>0);
	sb_item = item_out.pop_front();
	
	out_tmp = sb_item.rx_out_p;
	parity_bit= sb_item.parity_err;
	framing_err= sb_item.framing_err;
	valid_bit= sb_item.rx_out_v;
	
	// CALCULATE SUCCESSFUL AND FAILED TRANSACTIONS
	if ({out_exp,framing_err_exp,valid_bit_exp,parity_err_exp} != {out_tmp,framing_err,valid_bit,parity_bit}) begin
		cnt_err++;
		`uvm_error(get_type_name(), $sformatf("Incorrect output, EXPECTED:: data is = %b @valid = %b, ACUTAL:: data is = %b @valid = %b, ", out_exp, valid_bit_exp, out_tmp,valid_bit))
		`uvm_info(get_type_name(), $sformatf("FLAGS, EXPECTED:: parity_err is = %b and framing_err is = %b, ACUTAL:: parity_err is = %b and framing_err is = %b, ", parity_err_exp, framing_err_exp, parity_bit, framing_err),UVM_MEDIUM)
	end
	else begin
		cnt_crr++;
		`uvm_info(get_type_name(), $sformatf("Correct output, EXPECTED:: data is = %b @valid = %b, ACUTAL:: data is = %b @valid = %b, ", out_exp, valid_bit_exp, out_tmp,valid_bit),UVM_MEDIUM)
		`uvm_info(get_type_name(), $sformatf("FLAGS, EXPECTED:: parity_err is = %b and framing_err is = %b, ACUTAL:: parity_err is = %b and framing_err is = %b, ", parity_err_exp, framing_err_exp, parity_bit, framing_err),UVM_MEDIUM)
	end
		
		
	done_processing = 1'b1;
endtask 

function bit odd_parity_check(bit [DATA_WIDTH-1:0] x);
bit out;
out = ~(^x);
return out;
endfunction

function bit even_parity_check(bit [DATA_WIDTH-1:0] x);
bit out;
out = (^x);
return out;
endfunction

virtual function void phase_ready_to_end(uvm_phase phase);
	if (!done_processing) begin
      `uvm_info(get_type_name(), "Scoreboard not done yet, delaying phase end...", UVM_MEDIUM)
      phase.raise_objection(this, "Waiting for scoreboard to finish...");

      fork	begin
          // Wait for processing to complete
          wait (done_processing == 1);
          `uvm_info(get_type_name(), "Scoreboard done, dropping objection", UVM_MEDIUM)
          phase.drop_objection(this, "Scoreboard finished processing");
	  end
      join_none
    end
endfunction

	
//REPORT PHASE
function void report_phase(uvm_phase phase);
	super.report_phase(phase);
	`uvm_info("Report_Phase", $sformatf("Successful checks: %0d", cnt_crr), UVM_LOW)
	`uvm_info("Report_Phase", $sformatf("Unsuccessful checks: %0d", cnt_err), UVM_LOW)
endfunction
endclass