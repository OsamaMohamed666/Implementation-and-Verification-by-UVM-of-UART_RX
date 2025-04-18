module edge_bit_counter(
 
 input              clk,
 input              rst,
 input              en,
 output reg [3:0]   bit_count,
 output reg [2:0]   edge_count
 
);

wire         counter_max;
 
always @(posedge clk or negedge rst)
  begin
    if(!rst)
	 begin
	  edge_count<=0;
	  bit_count<=0;
	 end
    else if(en && !counter_max)
	 begin
		edge_count <= edge_count+ 4'b0001;
	 end
	else if(en && counter_max)
	 begin
	    edge_count <=0;
	    bit_count <=  bit_count + 1;
	 end
	else
	 begin
	    edge_count<=0;
	    bit_count<=0;
	 end
	end
	
	
assign counter_max = ( edge_count == 3'b111)? 1'b1:1'b0;

endmodule
	
		
	
   
   
   
