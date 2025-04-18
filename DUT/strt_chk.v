module strt_chk(
  
  input            clk,
  input            rst,
  input            en,
  input            sampled_bit,
  output  reg      strt_glitch

  );
  
  always @ (posedge clk or negedge rst)
    begin
	   if(!rst)
	    strt_glitch<=0;
	   else
	    begin
	      if (en)
		   begin
		    case(sampled_bit)
			 1'b0 : begin
			          strt_glitch<=0;
					end  
			 1'b1 : begin	
                      strt_glitch<=1;
					end  
			endcase
		   end
        end			
	end	
	
	
endmodule 	
