module pipe
#(
    parameter integer D_W = 8,
    parameter integer pipes = 10
)
(
    input                     clk,
    input                     rst,
    input   wire    [D_W-1:0]  in_p,
    output  wire    [D_W-1:0]  out_p
);

reg [D_W-1:0]    regs    [pipes-1:0];

always@(posedge clk)
begin
    if (rst)
    begin
        regs[0] <= 0;
    end
    else
    begin
        regs[0] <= in_p;
    end
end

assign  out_p = regs[pipes-1]; 

genvar x;
    for (x=1;x<pipes;x=x+1)
    begin
        always@(posedge clk)
        begin
            if(rst)
            begin
                regs[x] <= 0;
            end
            else
            begin
                regs[x] <= regs[x-1];
            end
        end
    end

endmodule
