module pe
#(
	parameter   D_W  = 8,
	parameter   i   = 1,
	parameter   j = 1
)
(
	input   wire                    clk,
	input   wire                    rst,
	input   wire                    init,
	input   wire     [D_W-1:0]       in_a,
	input   wire     [D_W-1:0]       in_b,
	output  wire     [D_W-1:0]       out_b,
	output  wire     [D_W-1:0]       out_a,

	input   wire     [2*D_W-1:0]   in_data,
	input   wire                    in_valid,
	output  reg      [2*D_W-1:0]   out_data,
	output  reg                    out_valid
);

reg [D_W-1:0] a_tmp;
reg [D_W-1:0] b_tmp;
reg [(2*D_W)-1:0] out_tmp;
reg [(2*D_W)-1:0] out_stage;//intermediate register to store output values from previous PE
reg out_stagevalid;//intermediate register to store valid signals from previous PE 
reg init_tmp;
//reg prev_valid;
reg data_rsrv;
              
		always @(posedge clk) begin
                	if(rst==1) begin
		  	a_tmp<=0;
		  	b_tmp<=0;
		  	out_tmp<=0;   		 	
			out_valid<=0;
		 	out_data<=0;
     		 	out_stage<=0;
		 	out_stagevalid<=0;
			data_rsrv<=0;
                	end
			else begin
                		if(init==1) begin
	    	  		out_tmp<=in_a*in_b;
   		  		end
	 	 		else begin
                		out_tmp<=out_tmp+(in_a*in_b);
		  		end
                  		a_tmp<=in_a;
                  		b_tmp<=in_b;
				if(init==1&&in_valid==1) begin
					out_stage<=in_data;
					out_stagevalid<=in_valid;
					out_data<=out_tmp;
					out_valid<=init;
					data_rsrv<=1;
				end
				
				else if(data_rsrv==1)begin
					out_data<=out_stage;
					out_valid<=out_stagevalid;
					data_rsrv<=0;
					if(in_valid==1)begin
						data_rsrv<=1;;
						out_stage<=in_data;
						out_stagevalid<=in_valid;
					end
						
				end
				else if(init==1 &&in_valid==0) begin
					out_data<=out_tmp;
					out_valid<=init;
				end
				else begin
					out_data<=in_data;
					out_valid<=in_valid;
				end
					
				
					

		

			end
		end
		assign out_a=a_tmp;
		assign out_b=b_tmp;
endmodule
