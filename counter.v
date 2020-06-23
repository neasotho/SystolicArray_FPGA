module counter
#(
    parameter   WIDTH   = 32,
    parameter   HEIGHT  = 32

)
(
    input   wire                            clk,
    input   wire                            rst,
    input   wire			                enable_row_count,
    output  reg     [$clog2(WIDTH)-1:0]     column_counter,
    output  reg     [$clog2(HEIGHT)-1:0]    row_counter

);

always@(posedge clk)
begin
	if (rst) begin
		column_counter  <= 0;
	end else begin
            if (column_counter == WIDTH-1)
            begin
                column_counter  <= 0;
            end
            else
            begin
    			column_counter  <= (column_counter + 1);
            end
	end
end

always@(posedge clk)
begin
	if (rst) begin
		row_counter <= 0;
	end else begin
		if (enable_row_count && column_counter == WIDTH-1) begin
            if (row_counter == HEIGHT-1)
            begin
                row_counter <= 0;
            end
            else
            begin
			    row_counter <= row_counter + 1;
            end
		end
	end
end

endmodule
