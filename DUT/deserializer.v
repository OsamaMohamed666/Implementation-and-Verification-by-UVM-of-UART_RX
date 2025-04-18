module deserializer #(parameter DATA_WIDTH =8) (

 input             clk,
 input             rst,
 input             sampled_bit,
 input             en,
 input		[2:0]  edge_count,
 output reg [DATA_WIDTH-1:0]  P_DATA

 );

 always @(posedge clk or negedge rst)
  begin
   if(!rst)
     P_DATA <=0;
   else 
    if (en && (edge_count == 3'b111))
        begin 
		   P_DATA<={sampled_bit,P_DATA[7:1]};
	    end
  end
 
 endmodule
  
		   
