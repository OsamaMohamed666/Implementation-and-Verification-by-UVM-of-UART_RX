module par_chk #(parameter DATA_WIDTH =8) (
  
  input               clk,
  input               rst,
  input               parity_type,
  input               en,
  input               sampled_bit,
  input     [DATA_WIDTH-1:0]     P_DATA,
  output reg          par_err  
  
  );
  
  wire odd_par , even_par;
  wire [1:0] par_chk_typ;
  
  always@(posedge clk or negedge rst)
   begin
    if(!rst)
	 begin
	  par_err<=0;
	 end

	else 
	 begin
	    case(par_chk_typ)
		 2'b10 : begin
		          if (even_par == sampled_bit)
				    par_err<=0;
				  else
				    par_err<=1;
				 end
		 2'b11 : begin 
		          if(odd_par == sampled_bit)
				    par_err<=0;
				  else
				    par_err<=1;
				 end
		         
		endcase 
   end
  end 

   
  assign par_chk_typ = {en,parity_type};
  assign even_par = ^P_DATA;
  assign odd_par = ~^P_DATA;

endmodule 
