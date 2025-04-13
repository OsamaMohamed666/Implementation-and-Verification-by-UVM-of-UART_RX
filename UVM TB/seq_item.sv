class seq_item # (parameter DATA_WIDTH=8,PRESCALE_WIDTH = 5) extends uvm_sequence_item;
  
// HELPING INTERNAL SIGNAL
bit [3:0] bit_count;
// SIGNALS CONFIGURED IN CONFIG DB
 bit parity_en; 
 bit parity_type;
 bit [PRESCALE_WIDTH-1 : 0] prescale;
//INPUT 
rand bit		rx_in_s;
//OUTPUT
logic	parity_err;
logic	framing_err;
logic	rx_out_v;
logic [DATA_WIDTH-1 :0] rx_out_p;


function new(string name = "seq_item");
    super.new(name);
endfunction

// UTILITY AND FIELD MACROS 
`uvm_object_utils_begin(seq_item)  
	`uvm_field_int(rx_in_s,UVM_ALL_ON)
	`uvm_field_int(parity_en,UVM_ALL_ON)
	`uvm_field_int(parity_type,UVM_ALL_ON)
	`uvm_field_int(prescale,UVM_ALL_ON)
`uvm_object_utils_end 
	

//******************CONSTRAINTS****************
// Constraints are primarily directed toward generating valid frames, 
// as this verification environment is not focused on achieving coverage 
// due to the limited presence of functional coverage requirements.
 

constraint serial_input {parity_en -> rx_in_s;}
constraint serial_input1 {!parity_en -> !rx_in_s;}

static bit [3:0] bit_no;
rand bit frame [0:12];
constraint frame_structure{
		frame[0] ==1; //idle
		frame[1] ==1;  //idle
		frame[2] ==0; 
		frame[12] dist {1:=80, 0:=20}; // injecting framing error with low probability
}



function void post_randomize();
	bit_no++;
	if(parity_en)begin	
		if (bit_no == 13)
			bit_no = $urandom_range(1,2);
	end
	
	else begin 
		if(bit_no<2) // as frame now will be only 10 bits 
			bit_no=2;
		if (bit_no == 13)
			bit_no = $urandom_range(2,3);
			
		frame[3] = 0;
		frame[2] = 1; // start bit in unenabled parity
	end 
	rx_in_s = frame[bit_no];
	//$display("rx_in_s = %0b at bit num = %0d in frame is %0p @ %0t",rx_in_s,bit_no,frame,$time);
endfunction





endclass