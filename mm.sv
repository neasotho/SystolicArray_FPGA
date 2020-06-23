`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2019 12:36:40
// Design Name: 
// Module Name: top_mm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mm
    #
    (
        parameter   M   = 15,
        parameter   N   = 3,
        parameter   D_W = 8
    )
    (
    input                   mm_clk,
    input                   mm_rst_n,
    
    input           [31:0]  s_axis_s2mm_tdata,
    input           [3:0]   s_axis_s2mm_tkeep,
    input                   s_axis_s2mm_tlast,
    output  wire            s_axis_s2mm_tready,
    input                   s_axis_s2mm_tvalid,

    output  wire    [31:0]  m_axis_mm2s_tdata,
    output  wire    [3:0]   m_axis_mm2s_tkeep,
    output  reg             m_axis_mm2s_tlast,
    input                   m_axis_mm2s_tready,
    output  wire            m_axis_mm2s_tvalid
    );
    
    wire    rst;
    assign  rst = ~mm_rst_n;
    wire    clk;
    assign  clk = ~mm_clk;
 

    reg [$clog2(2*M*M)-1:0]     write_addr;
    
    always@(posedge clk)
    begin
        if(rst)
        begin
            write_addr  <= 0;
        end
        else if (s_axis_s2mm_tready && s_axis_s2mm_tvalid)
        begin
            write_addr  <= write_addr + 1;
        end
    end
    
    (*mark_debug="true"*)reg [$clog2(2*M*M)-1:0]     reg_banked_write_addr_m0   [N-1:0];
    (*mark_debug="true"*)reg                         reg_banked_valid_m0        [N-1:0];
    (*mark_debug="true"*)reg                         reg_banked_ready_m0        [N-1:0];
    (*mark_debug="true"*)reg [D_W-1:0]               reg_banked_data_m0         [N-1:0];
    
    (*mark_debug="true"*)wire    [D_W-1:0]               m0_bram         [N-1:0];
    (*mark_debug="true"*)wire    [$clog2((M*M)/N)-1:0]   rd_addr_m0_bram [N-1:0];
    (*mark_debug="true"*)wire    [N-1:0]                 rd_en_m0_bram;
    (*mark_debug="true"*)wire    [N-1:0]                 activate_m0;
    
    genvar x;
    for(x = 0; x < N ; x = x +1)
    begin
        assign  activate_m0[x] = ( x*((M*M)/N) <= reg_banked_write_addr_m0[x] && reg_banked_write_addr_m0[x] < (x+1)*((M*M)/N) ) ? 1 : 0;
        blk_mem_gen_0 read_bram_m0 
        (
            .clka             (clk                                              ),// 
            .ena              (activate_m0[x]                                   ),//    
            .wea              (reg_banked_valid_m0[x]                           ),// 
            .addra            (reg_banked_write_addr_m0[x] - ((x*M*M)/N)        ),// 
            .dina             ({{32-D_W{1'b0}} ,reg_banked_data_m0[x]}          ),// 
            .douta            (), 
            
            .clkb             (clk                                      ),// 
            .enb              (rd_en_m0_bram[x]                         ),// 
            .web              (1'b0                                     ),//
            .addrb            (rd_addr_m0_bram[x]                       ),// 
            .dinb             (0                                        ),// 
            .doutb            (m0_bram[x]                               )// 
        );
        
        if (x==0)
        begin
            always@(posedge clk)
            begin
                reg_banked_write_addr_m0[x]<= write_addr;
                reg_banked_valid_m0[x]     <= s_axis_s2mm_tvalid;
                reg_banked_ready_m0[x]     <= s_axis_s2mm_tready;
                reg_banked_data_m0[x]      <= s_axis_s2mm_tdata;
            end   
        end
        else
        begin
            always@(posedge clk)
            begin
                reg_banked_write_addr_m0[x]<= reg_banked_write_addr_m0[x-1];
                reg_banked_valid_m0[x]     <= reg_banked_valid_m0[x-1];
                reg_banked_ready_m0[x]     <= reg_banked_ready_m0[x-1];
                reg_banked_data_m0[x]      <= reg_banked_data_m0[x-1];
            end   
        end
    end
    
    
    (*mark_debug="true"*)reg [$clog2(2*M*M)-1:0]     reg_banked_write_addr_m1   [N-1:0];
    (*mark_debug="true"*)reg                         reg_banked_valid_m1        [N-1:0];
    (*mark_debug="true"*)reg                         reg_banked_ready_m1        [N-1:0];
    (*mark_debug="true"*)reg [D_W-1:0]               reg_banked_data_m1         [N-1:0];
    
    (*mark_debug="true"*)wire    [D_W-1:0]               m1_bram         [N-1:0];
    (*mark_debug="true"*)wire    [$clog2((M*M)/N)-1:0]   rd_addr_m1_bram [N-1:0];
    (*mark_debug="true"*)wire    [N-1:0]                 rd_en_m1_bram;
    (*mark_debug="true"*)wire    [N-1:0]                 activate_m1;
    
    for(x = 0; x < N ; x = x +1)
    begin
        assign  activate_m1[x] = ( x*((M*M)/N) + (M*M) <= reg_banked_write_addr_m1[x] && reg_banked_write_addr_m1[x] < (x+1)*((M*M)/N)  + (M*M ) ) ? 1 : 0;
        blk_mem_gen_0 read_bram_m1
        (
            .clka             (clk                                              ),// 
            .ena              (activate_m1[x]                                   ),//    
            .wea              (reg_banked_valid_m1[x]                           ),// 
            .addra            (reg_banked_write_addr_m1[x] - ((x*M*M)/N) - M*M  ),// 
            .dina             ({{32-D_W{1'b0}} ,reg_banked_data_m1[x]}          ),// 
            .douta           (), 
            
            .clkb             (clk                                      ),// 
            .enb              (rd_en_m1_bram[x]                         ),// 
            .web              (1'b0                                     ),//
            .addrb            (rd_addr_m1_bram[x]                       ),// 
            .dinb             (0                                        ),// 
            .doutb            (m1_bram[x]                               )// 
        );
        
        if (x==0)
        begin
            always@(posedge clk)
            begin
                reg_banked_write_addr_m1[x]<= reg_banked_write_addr_m0[N-1];
                reg_banked_valid_m1[x]     <= reg_banked_valid_m0[N-1];
                reg_banked_ready_m1[x]     <= reg_banked_ready_m0[N-1];
                reg_banked_data_m1[x]      <= reg_banked_data_m0[N-1];
            end   
        end
        else
        begin
            always@(posedge clk)
            begin
                reg_banked_write_addr_m1[x]<= reg_banked_write_addr_m1[x-1];
                reg_banked_valid_m1[x]     <= reg_banked_valid_m1[x-1];
                reg_banked_ready_m1[x]     <= reg_banked_ready_m1[x-1];
                reg_banked_data_m1[x]      <= reg_banked_data_m1[x-1];
            end   
        end
    end
    
        
    (*mark_debug="true"*)wire    [$clog2(M/N)-1:0]       row_m0;
    (*mark_debug="true"*)wire    [$clog2(M)-1:0]         column_m0;
    (*mark_debug="true"*)reg                             start_multiply;
    
    always@(posedge clk)
    begin
        if(rst)
        begin
            start_multiply  <= 0;
        end
        if (reg_banked_write_addr_m1[N-1] == 2*M*M - 1)
        begin
            start_multiply  <= 1;
        end
    end 
    assign      s_axis_s2mm_tready = ~start_multiply;
    
    mem_read_m0
    #
    (
        .D_W    (D_W),
        .N      (N),
        .M      (M)
    )
    mem_read_m0_inst
    (
        .clk             (clk                       ),//
        .row             (row_m0                    ),
        .column          (column_m0                 ),//
        .rd_en           (~(rst) & start_multiply   ),//
        .rd_addr_bram    (rd_addr_m0_bram),       //
        .rd_en_bram      (rd_en_m0_bram)          //
    );
    
    (*mark_debug="true"*)wire    [$clog2(M)-1:0]       row_m1;
    (*mark_debug="true"*)wire    [$clog2(M/N)-1:0]     column_m1;
   
    mem_read_m1
    #
    (
        .D_W    (D_W),
        .N      (N),
        .M      (M)
    )
    mem_read_m1_inst
    (
        .clk             (clk                       ),//
        .row             (row_m1                    ),
        .column          (column_m1                 ),//
        .rd_en           (~(rst) & start_multiply   ),//
        .rd_addr_bram    (rd_addr_m1_bram),       //
        .rd_en_bram      (rd_en_m1_bram)          //
    );
    
     (*mark_debug="true"*)reg                        done_multiply;
     reg    done_multiply_reg;
     reg    done_multiply_reg_reg;
     (*mark_debug="true"*)reg    [$clog2(M*M)-1:0]   read_addr;
     
     always@(posedge clk)
     begin
        if(rst)
        begin
            read_addr   <= 0;        
        end
        else if (done_multiply && m_axis_mm2s_tready)
        begin
            read_addr   <= read_addr + 1;
        end
        
     end
     
     
   
    (*mark_debug="true"*)wire    [$clog2((M*M)/N)-1:0]   wr_addr_m2_bram [N-1:0];
    (*mark_debug="true"*)wire    [N-1:0]                 wr_en_m2_bram;
    (*mark_debug="true"*)wire    [(2*D_W)-1:0]           wr_data_m2_bram [N-1:0];
    (*mark_debug="true"*)wire    [N-1:0]                 activate_m2;
    (*mark_debug="true"*)reg    [N-1:0]                  activate_m2_reg;
    
    (*mark_debug="true"*)wire    [2*D_W-1:0]             m2_PORTA_dout  [N-1:0];
    
    (*mark_debug="true"*)reg [2*D_W-1:0]         reg_banked_data_m2  [N-1:0];
    (*mark_debug="true"*)reg [$clog2(M*M)-1:0]   reg_banked_read_addr_m2  [N-1:0];
    
    (*mark_debug="true"*)reg [N-1:0]   reg_banked_valid_m2;
    
    
    for (x=0;x<N;x=x+1)
    begin
        assign activate_m2[x] = ( x*((M*M)/N) <= reg_banked_read_addr_m2[x] && reg_banked_read_addr_m2[x] < (x+1)*((M*M)/N) ) ? 1 : 0;
        blk_mem_gen_0 write_bram_m2 (
            .clka             (clk                                      ),// 
            .ena              (activate_m2[x]                           ),// 
            .wea              (0                                        ),// 
            .addra            (reg_banked_read_addr_m2[x] -((x*M*M)/N)  ),// 
            .dina             (                                         ),// 
            .douta            (m2_PORTA_dout[x]                         ), 
            
            .clkb             (clk                  ),// 
            .enb              (wr_en_m2_bram[x]     ),// 
            .web              (1'b1                 ),//
            .addrb            (wr_addr_m2_bram[x]   ),// 
            .dinb             (wr_data_m2_bram[x]   ),// 
            .doutb            (                     ) // 
        );
        if (x==0)
        begin
            always@(posedge clk)
            begin
                reg_banked_data_m2[x]       <= m2_PORTA_dout[x];
                reg_banked_read_addr_m2[x]  <= read_addr;
                reg_banked_valid_m2[x]      <= done_multiply_reg_reg; 
            end
        end
        else
        begin
            always@(posedge clk)
            begin
                reg_banked_data_m2[x]       <= ( activate_m2_reg[x] ==1 ) ? m2_PORTA_dout[x] : reg_banked_data_m2[x-1];
                reg_banked_read_addr_m2[x]  <= reg_banked_read_addr_m2[x-1];
                reg_banked_valid_m2[x]         <= reg_banked_valid_m2[x-1]; 
            end
        end
        always@(posedge clk)
        begin
            activate_m2_reg[x]  <= activate_m2[x];
        end
    end
       
    (*mark_debug="true"*)wire    [N-1:0]                 valid_m2;
    (*mark_debug="true"*)wire    [(2*D_W)-1:0]           data_m2 [N-1:0];
    
    mem_write
    #
    (
        .D_W     (2*D_W),
        .N       (N),
        .M       (M)
    )
    mem_write_m2
    (
        .clk            (clk                    ),//
        .rst            (rst | done_multiply    ),//
        .in_valid       (valid_m2               ),//
        .in_data        (data_m2                ),//
        .wr_addr_bram   (wr_addr_m2_bram        ),//
        .wr_data_bram   (wr_data_m2_bram        ),//
        .wr_en_bram     (wr_en_m2_bram          ) //
    );
    
    reg [31:0]  patch = 1;
    reg         enable_row_count_m0 = 0;
    
    systolic
    #
    (
        .D_W    (D_W),
        .N      (N),
        .M      (M)
    )
    systolic_inst
    (
        .clk                    (clk),                  //
        .rst                    (rst | ~start_multiply), //
        .enable_row_count_m0    (enable_row_count_m0),  //
        .column_m0              (column_m0),            //
        .row_m0                 (row_m0),               //
        .column_m1              (column_m1),            //
        .row_m1                 (row_m1),               //
        .m0                     (m0_bram),              //
        .m1                     (m1_bram),              //
        .m2                     (data_m2),              //
        .valid_m2               (valid_m2)              //
    );
    
    always@(posedge clk)
    begin
        if(rst) 
        begin
            enable_row_count_m0 <= 1'b0;
            patch <= 1;
        end 
        else 
        begin
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
    

    always@(posedge clk)
    begin
        if(rst)
        begin
            done_multiply       <= 0;
            done_multiply_reg   <= 0;
        end
        else
        begin
            done_multiply_reg   <= done_multiply;
            done_multiply_reg_reg   <= done_multiply_reg;
            if (wr_addr_m2_bram[N-1] == (M*M)/N-1)
            begin
                done_multiply   <= 1;
            end           
            /*else if (read_addr == M*M -1 )
            begin
                done_multiply   <= 0;
            end*/
        end
    end

    reg last_beat;
    reg done = 0;
    always@(posedge clk)
    begin
        last_beat           <= (reg_banked_read_addr_m2[N-1] == (M*M)-1) ? 1 : 0;
        m_axis_mm2s_tlast   <= last_beat;
        if (m_axis_mm2s_tlast == 1)
        begin
            done    <= 1;
        end
    end
     assign m_axis_mm2s_tdata   = reg_banked_data_m2[N-1];
     assign m_axis_mm2s_tkeep   = 4'b1111;
     assign m_axis_mm2s_tvalid  = reg_banked_valid_m2[N-1] && ~done; 

    
    endmodule
