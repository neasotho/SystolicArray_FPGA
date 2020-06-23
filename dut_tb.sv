module dut_tb
#(
    parameter D_W = 8,
    parameter N = 5,
    parameter M = 5
)
();

reg                                 clk=1'b0;
reg     [1:0]                       rst;

reg                              rd_en_m0=0;
reg                              rd_en_m1=0;
wire    [N-1:0]                  rd_en_m0_pipe;
wire    [N-1:0]                  rd_en_m1_pipe;
wire    [$clog2((M*M)/N)-1:0]    rd_addr_m0 [N-1:0];
wire    [$clog2((M*M)/N)-1:0]    rd_addr_m1 [N-1:0];
wire    [$clog2(M)-1:0]          column_m0;
wire    [$clog2(M/N)-1:0]        row_m0;
wire    [$clog2(M/N)-1:0]        column_m1;
wire    [$clog2(M)-1:0]          row_m1;
reg     [(N*D_W)-1:0]            m0 ;
reg     [(N*D_W)-1:0]            m1 ;
reg     [D_W-1:0]                m0_pipe    [N-1:0];
reg     [D_W-1:0]                m1_pipe    [N-1:0];
wire    [2*D_W-1:0]              m2    [N-1:0];
reg     [2*D_W-1:0]              mem2       [0:M*M-1];

reg     [D_W-1:0]                mem0       [0:(M*M)-1];
reg     [D_W-1:0]                mem1       [0:(M*M)-1];

initial begin
    $readmemh("m0.mem", mem0);
end
initial begin
    $readmemh("m1.mem", mem1);
end

always@(posedge clk)
begin
    if (rst[0])
    begin
        rd_en_m0 <= 0;
        rd_en_m1 <= 0;
    end
    else
    begin
        rd_en_m0 <= 1;
        rd_en_m1 <= 1;
    end
end

mem_read_m0
#
(
    .D_W    (D_W),
    .N      (N),
    .M      (M)
)
mem_read_m0_inst
(
    .clk           (clk),
    .row            (row_m0),
    .column         (column_m0),
    .rd_en          (~rst[0]),
    .rd_addr_bram   (rd_addr_m0),
    .rd_en_bram     (rd_en_m0_pipe)     
);
mem_read_m1
#
(
    .D_W    (D_W),
    .N      (N),
    .M      (M)
)
mem_read_m1_inst
(
    .clk           (clk),
    .row            (row_m1),
    .column         (column_m1),
    .rd_en          (~rst[0]),

    .rd_addr_bram   (rd_addr_m1),
    .rd_en_bram     (rd_en_m1_pipe)     
);

genvar x;

for(x=0;x<N;x=x+1)
begin
    always@(posedge clk)
    begin
        if (rst[0]==1'b0)
        begin
            if (rd_en_m0_pipe[x])
            begin
                m0_pipe[x]  <= mem0[((x*M*M)/N) + rd_addr_m0[x]];
            end
            else
            begin
                m0_pipe[x]  <= 0;
            end
        end
        else
        begin
            m0_pipe[x]  <= 0;
        end
    end
end
for(x=0;x<N;x=x+1)
begin
    always@(posedge clk)
    begin
        if (rst[0]==1'b0)
        begin
            if (rd_en_m1_pipe[x])
            begin
                m1_pipe[x]  <= mem1[((x*M*M)/N) + rd_addr_m1[x]];
            end
            else
            begin
                m0_pipe[x]  <= 0;
            end
        end
        else
        begin
            m1_pipe[x]  <= 0;
        end
    end
end

wire    [N-1:0] init_pe_pipe  [N-1:0];
reg enable_row_count_m0 = 0;
wire [N-1:0]   valid_m2    ;

systolic 
#(
    .D_W     (D_W),
    .N      (N),
    .M      (M)
)
systolic_dut 
(
    .clk            (clk)   , 
    .rst            (rst[0]) ,
    .enable_row_count_m0    (enable_row_count_m0),
    .column_m0      (column_m0),
    .column_m1      (column_m1),
    .row_m0         (row_m0),
    .row_m1         (row_m1),
    .m0             (m0_pipe)    , 
    .m1             (m1_pipe),     
    .m2             (m2) ,
    .valid_m2       (valid_m2)  
);

always #0.5 clk = ~clk;

initial
begin
    $timeformat(-9, 2, " ns", 20);
    rst = 2'b11;
end

always @(posedge clk) begin
	rst <= rst>>1;
end

reg [31:0]  counter_finish = 0;

reg                    [2:0]             rst_pe = 2'b00;
always@(posedge clk)
begin
	if(rst[0]) begin
		rst_pe <= 1'b0;
	end else begin
		if (column_m0==M-1)
		begin
			rst_pe <= 2'b01;
		end
		else
		begin
			rst_pe <= rst_pe >> 1;
		end
	end
end

genvar y;
for (x=0;x<N;x=x+1)
begin
    for (y=0;y<N;y=y+1)
    begin
        pipe
        #(
         .D_W(1),
         .pipes(x+y+1)
        )
        pipe_inst_rst
        (
         .clk    (clk),
         .rst    (),
         .in_p   (rst_pe[0]),
         .out_p  (init_pe_pipe[x][y])
        );
    end
end

reg init = 0;

always@(posedge clk)
begin
	if(rst[0]) begin
		counter_finish <= 0;
	end else if (init_pe_pipe[N-1][N-1])
	begin
		counter_finish <= counter_finish + 1;
	end
end

reg [31:0]  patch =1;

always@(posedge clk)
begin
	if(rst[0]) begin
		enable_row_count_m0 <= 1'b0;
		patch <= 1;
	end else begin
		if (enable_row_count_m0 == 1'b1)
		begin
			enable_row_count_m0 <= 1'b0;
		end

		else if (column_m0 == M-2 && patch == (M/N))
		begin
			patch <= 1;
			enable_row_count_m0 <= ~enable_row_count_m0;
		end

		else if (column_m0 == M-2)
		begin
			patch <= patch + 1 ;
		end
	end
end


reg [$clog2((M*M)/N):0]   addr    [N-1:0];

for (x=0;x<N;x=x+1)
begin
    always@(posedge clk)
    begin
        if (rst[0]==1'b1)
        begin
            addr[x] <= 0;
        end

        else if (valid_m2[x]==1'b1 && rst[0]==1'b0)
        begin
            mem2[(M*M*x)/N+addr[x]] <= m2[x];
            addr[x] <= addr[x] + 1;
        end
    end
end

always@(posedge clk)
begin
    if (addr[N-1]==((M*M)/N))
    begin
        $writememh("m2.mem", mem2);
        $finish;
    end
end

initial begin
        $dumpfile("lab4.vcd");
        $dumpvars(0,dut_tb);
end


genvar idx;
for(idx=0;idx<N;idx=idx+1)  begin
	initial $dumpvars(0,dut_tb.m2[idx]);
end

endmodule
