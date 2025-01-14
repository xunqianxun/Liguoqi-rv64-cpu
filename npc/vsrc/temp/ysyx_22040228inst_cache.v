/************************************************************
Author:LiGuoqi
Name:inst_cache.v
Function:write instraction cache
************************************************************/
`include "ysyx_22040228defines.v"
`include "ysyx_22040228defines_axi4.v"
`include "ysyx_22040228TEG_CC.v"
//`include "S011HD1P_X32Y2D128_BW.v"
`include "ysyx_22040228cache_defines.v"

`define ysyx22040228_I_IDLE    6'b000001
`define ysyx22040228_I_MISSRL  6'b000010 //--> read chiplink can use burst
`define ysyx22040228_I_HIT     6'b000100
`define ysyx22040228_I_MISSRH  6'b001000 //--> read APB can't use burst
`define ysyx22040228_I_READ    6'b100000


module ysyx_22040228inst_cache (
    input       wire                                         clk             ,
    input       wire                                         rst             ,
    input       wire          [63:0]                         inst_addr       ,
    input       wire                                         inst_ready      ,
    input       wire                                         core_stall      ,
    input       wire                                         inst_fence      ,
    output      reg           [31:0]                         inst_data       ,
    output      reg                                          inst_valid      ,

    output      wire                                         cache_read_ena  ,
    output      wire          [63:0]                         cache_addr      ,
    input       wire          [63:0]                         cache_in_data   ,
    input       wire                                         cache_in_valid  ,

    output      wire                                         CE              ,
    output      wire                                         w_data_ena      ,
    output      wire          [127:0]                        w_strb_ram      ,
    output      wire          [5:0]                          icache_index    ,
    output      wire          [127:0]                        w_data_ram      ,
    input       wire          [127:0]                        data_out                     
);

    // froce define for verdi
    reg          read_ok_    ;
    reg          read_ok     ;
    wire   [`ysyx22040228_TEG_WITH]  oteg_ata_o    ;
    wire                             oteg_valid_o  ;
    wire   [`ysyx22040228_TEG_WITH]  tteg_ata_o    ;
    wire                             tteg_valid_o  ;
    //wire  [127:0] data_out ;
    reg  [2:0]  i_counter1 [`ysyx22040228_CACHE_DATA_W];
    reg  [2:0]  i_counter2 [`ysyx22040228_CACHE_DATA_W];
    reg         inst_hit_ok ;
    reg         write_i_ok  ; 
    reg         write_m_ok  ;
    // froce define for verdi

    wire   icache_if_shankhand   ;
    assign icache_if_shankhand = inst_ready && ~inst_valid  ;

    wire [`ysyx22040228_TEG_WITH]   icache_tag    =   inst_addr[31:9 ];
    /*wire [`ysyx22040228_INDEX_WITH] */assign icache_index  =   inst_addr[ 8:3 ];


    reg  [5:0]  state_inst     ;
    reg  [5:0]  state_inst_nxt ;
    reg  [6:0]  fence_counter  ;
    always @(posedge clk) begin
        if(rst == `ysyx22040228_RSTENA) begin
            fence_counter <= 7'h0 ; 
        end 
        else if(inst_fence)begin
            if(fence_counter >= 64)
                fence_counter <= fence_counter;
            else 
                fence_counter <= fence_counter+1;
        end 
        else begin
            fence_counter <= 7'h0 ; 
        end 
    end

    always @(posedge clk) begin
        if(rst == `ysyx22040228_RSTENA) begin
            state_inst <= `ysyx22040228_I_IDLE;
        end 
        else begin
            state_inst <= state_inst_nxt    ;
        end 
    end

    always @(*) begin 
        if(rst == `ysyx22040228_RSTENA) begin
            state_inst_nxt       =  `ysyx22040228_I_IDLE ;
        end 
        else begin 
            case (state_inst)
               `ysyx22040228_I_IDLE : begin
                   if(icache_if_shankhand)
                        state_inst_nxt = `ysyx22040228_I_READ;
                   else 
                        state_inst_nxt = `ysyx22040228_I_IDLE;  
               end 
               `ysyx22040228_I_READ  : begin
                   if((read_ok) && (((oteg_ata_o == icache_tag) && (oteg_valid_o == `ysyx22040228_ABLE)) || ((tteg_ata_o == icache_tag) && (tteg_valid_o == `ysyx22040228_ABLE))))
                        state_inst_nxt = `ysyx22040228_I_HIT;
                   else if(read_ok && ~((inst_addr >= `ysyx22040228_APB_START) && (inst_addr <= `ysyx22040228_APB_END)))
                        state_inst_nxt = `ysyx22040228_I_MISSRL;
                   else if(read_ok && ((inst_addr >= `ysyx22040228_APB_START) && (inst_addr <= `ysyx22040228_APB_END)))
                        state_inst_nxt = `ysyx22040228_I_MISSRH;
                   else
                        state_inst_nxt = `ysyx22040228_I_READ ;
               end 
               `ysyx22040228_I_HIT : begin
                   if(inst_hit_ok)
                        state_inst_nxt = `ysyx22040228_I_IDLE;
                   else 
                        state_inst_nxt = `ysyx22040228_I_HIT;
               end 
               `ysyx22040228_I_MISSRL : begin
                   if(write_i_ok)
                        state_inst_nxt = `ysyx22040228_I_READ ;
                   else 
                        state_inst_nxt = `ysyx22040228_I_MISSRL;  
               end 
               `ysyx22040228_I_MISSRH : begin
                   if(write_m_ok)
                        state_inst_nxt = `ysyx22040228_I_READ ;
                   else 
                        state_inst_nxt = `ysyx22040228_I_MISSRH;  
               end 
                default: begin
                  state_inst_nxt       =  `ysyx22040228_I_IDLE ;
                end 
            endcase 
        end 
    end 

    // reg          read_ok_    ;
    // reg          read_ok     ;
    always @(*) begin
        if(rst == `ysyx22040228_RSTENA) begin
            read_ok_ = `ysyx22040228_ENABLE  ;
        end 
        else if(state_inst == `ysyx22040228_I_READ) begin
            read_ok_ = `ysyx22040228_ABLE    ;
        end 
        else begin
            read_ok_ = `ysyx22040228_ENABLE  ;
        end 
    end
    always @(posedge clk) begin
        if(rst == `ysyx22040228_RSTENA) begin
            read_ok <= `ysyx22040228_ENABLE  ;
        end 
        else begin
            read_ok <= read_ok_;
        end 
    end

    // reg         inst_hit_ok ;
    always @(*) begin
        if(rst == `ysyx22040228_RSTENA) begin
            inst_data    = 32'b0                   ;
            inst_hit_ok  = `ysyx22040228_ENABLE    ;
            inst_valid   = `ysyx22040228_ENABLE    ;
        end 
        else if(state_inst == `ysyx22040228_I_HIT) begin
            if(core_stall == `ysyx22040228_ABLE) begin
                inst_data = 32'b0 ;
                inst_hit_ok = `ysyx22040228_ENABLE;
                inst_valid  = `ysyx22040228_ENABLE;
            end 
            else if((oteg_ata_o == icache_tag) && (oteg_valid_o == `ysyx22040228_ABLE) && (inst_addr[2] == `ysyx22040228_ABLE))begin
                inst_data =    data_out[63:32]      ;
                inst_hit_ok  = `ysyx22040228_ABLE  ;
                inst_valid   = `ysyx22040228_ABLE;
            end 
            else if((oteg_ata_o == icache_tag) && (oteg_valid_o == `ysyx22040228_ABLE) && (inst_addr[2] == `ysyx22040228_ENABLE))begin
                inst_data =    data_out[31:0 ]      ;
                inst_hit_ok  = `ysyx22040228_ABLE  ;
                inst_valid   = `ysyx22040228_ABLE;
            end
            else if((tteg_ata_o == icache_tag) && (tteg_valid_o == `ysyx22040228_ABLE) && (inst_addr[2] == `ysyx22040228_ABLE))begin
                inst_data = data_out[127:96]      ;
                inst_hit_ok  = `ysyx22040228_ABLE  ;
                inst_valid   = `ysyx22040228_ABLE;
            end 
            else /*if((tteg_ata_o == icache_tag) && (tteg_valid_o == `ysyx22040228_ABLE) && (inst_addr[2] == `ysyx22040228_ABLE))*/begin
                inst_data = data_out[95:64]      ;
                inst_hit_ok  = `ysyx22040228_ABLE  ;
                inst_valid   = `ysyx22040228_ABLE;
            end
        end 
        else begin  
            inst_data  = 32'h0                         ;
          inst_hit_ok  = `ysyx22040228_ENABLE          ; 
          inst_valid   = `ysyx22040228_ENABLE          ;   
        end 
    end


    reg   [127:0]   miss_data ;
    reg             miss_ena_l;
    reg   [127:0]   miss_strb_l;
    // reg             write_i_ok;  

    wire             cahce_miss_ena ;
    wire   [63:0]    cache_miss_addr ;
    assign           cahce_miss_ena = ((state_inst ==  `ysyx22040228_I_MISSRL) && (~cache_in_valid)) ? `ysyx22040228_ABLE : `ysyx22040228_ENABLE ;
    assign           cache_miss_addr = ((state_inst ==  `ysyx22040228_I_MISSRL) && (~cache_in_valid)) ? {inst_addr[63:3],3'b0} : `ysyx22040228_ZEROWORD ;

    always @(*) begin
        if(rst == `ysyx22040228_RSTENA) begin
            miss_data =  128'h0  ;
            write_i_ok = `ysyx22040228_ENABLE ;
            miss_ena_l = `ysyx22040228_ENABLE ;
            miss_strb_l = `ysyx22040228_CACHE_STRBZ;
        end 
        else if((state_inst ==  `ysyx22040228_I_MISSRL) && (~cache_in_valid)) begin
            miss_data =  128'h0  ;
            write_i_ok = `ysyx22040228_ENABLE ;
            miss_ena_l = `ysyx22040228_ENABLE ;
            miss_strb_l = `ysyx22040228_CACHE_STRBZ;
        end 
        else if((state_inst ==  `ysyx22040228_I_MISSRL) && (cache_in_valid)) begin
            if(oteg_valid_o == `ysyx22040228_ENABLE) begin
                miss_strb_l = `ysyx22040228_CACHE_STRBL;
                miss_data      = {cache_in_data, cache_in_data}  ;
                write_i_ok     = `ysyx22040228_ABLE  ;
                miss_ena_l     = `ysyx22040228_ABLE  ;
            end 
            else if(tteg_valid_o == `ysyx22040228_ENABLE) begin
                miss_strb_l = `ysyx22040228_CACHE_STRBH;
                miss_data      = {cache_in_data, cache_in_data}  ;
                write_i_ok     = `ysyx22040228_ABLE  ;
                miss_ena_l     = `ysyx22040228_ABLE  ;
            end 
            else if(i_counter1[icache_index] >= i_counter2[icache_index])begin
                miss_strb_l = `ysyx22040228_CACHE_STRBL;
                miss_data      = {cache_in_data, cache_in_data}  ;
                write_i_ok     = `ysyx22040228_ABLE  ;
                miss_ena_l     = `ysyx22040228_ABLE  ;
            end   
            else /*if(i_counter1[icache_index] < i_counter2[icache_index])*/ begin
                miss_strb_l = `ysyx22040228_CACHE_STRBH;
                miss_data      = {cache_in_data, cache_in_data}  ;
                write_i_ok     = `ysyx22040228_ABLE  ;
                miss_ena_l     = `ysyx22040228_ABLE  ;
            end 
        end
        else begin
            miss_data      = `ysyx22040228_CACHE_STRBZ ;
            miss_ena_l     = `ysyx22040228_ENABLE ;
            miss_strb_l = `ysyx22040228_CACHE_STRBZ;
            write_i_ok     = `ysyx22040228_ENABLE   ;
        end 
    end

    reg   [1:0]     missr_counter ;
    reg   [1:0]     missr_counter_n;
    reg   [63:0]    temp_inst     ;
    reg   [127:0]   mism_data ;
    reg             mism_ena_l;
    reg   [127:0]   mism_strb_l;
    // reg             write_m_ok;  

    reg             cache_mism_ena ;
    reg   [63:0]    cahce_mism_addr ;
    always @(posedge clk) begin
        if(rst == `ysyx22040228_RSTENA)
            missr_counter <= 2'b00 ;
        else 
            missr_counter <= missr_counter_n ;
    end

    always @(posedge clk) begin
        if(rst == `ysyx22040228_RSTENA) 
            temp_inst <= 64'h0 ;
        else if(((state_inst ==  `ysyx22040228_I_MISSRH) && (cache_in_valid) && (missr_counter  == 2'b01)))
            temp_inst <= {cache_in_data[31:0], 32'h0} ;
        else if(((state_inst ==  `ysyx22040228_I_MISSRH) && (cache_in_valid) && (missr_counter  == 2'b11)))
            temp_inst <= 64'h0 ;
        else 
            temp_inst <= temp_inst ;
    end

    always @(*) begin
        if(rst == `ysyx22040228_RSTENA) begin
            cache_mism_ena = `ysyx22040228_ENABLE;
            cahce_mism_addr = `ysyx22040228_ZEROWORD ;
            missr_counter_n  = 2'b00               ;
            write_m_ok     = `ysyx22040228_ENABLE   ;
            mism_ena_l     = `ysyx22040228_ENABLE ;
            mism_strb_l = `ysyx22040228_CACHE_STRBZ;
            mism_data   = 128'h0                  ;
        end 
        else if((state_inst ==  `ysyx22040228_I_MISSRH) && (~cache_in_valid)) begin
            if(missr_counter <= 2'b01) begin
                cache_mism_ena = `ysyx22040228_ABLE      ;
                cahce_mism_addr = {inst_addr[63:3], 1'b1, 2'b0};
                missr_counter_n  = 2'b01                 ;
                mism_data   = 128'h0                  ;
                mism_strb_l = `ysyx22040228_CACHE_STRBZ;
                mism_ena_l  = `ysyx22040228_ENABLE     ;
                write_m_ok  = `ysyx22040228_ENABLE     ;
            end 
            else begin
                cache_mism_ena = `ysyx22040228_ABLE    ;
                cahce_mism_addr = {inst_addr[63:3], 1'b0, 2'b0};
                missr_counter_n  = 2'b11                 ;
                mism_data   = 128'h0                  ;
                mism_strb_l = `ysyx22040228_CACHE_STRBZ;
                mism_ena_l  = `ysyx22040228_ENABLE     ;
                write_m_ok  = `ysyx22040228_ENABLE     ;
            end 
        end 
        else if((state_inst ==  `ysyx22040228_I_MISSRH) && (cache_in_valid) && (missr_counter  == 2'b01)) begin
            cache_mism_ena = `ysyx22040228_ABLE    ;
            mism_data   = 128'h0                  ;
            cahce_mism_addr = {inst_addr[63:3], 1'b0, 2'b0};
            missr_counter_n  = 2'b11                 ;
            mism_strb_l = `ysyx22040228_CACHE_STRBZ;
            mism_ena_l  = `ysyx22040228_ENABLE     ;
            write_m_ok  = `ysyx22040228_ENABLE     ;
        end 
        else if((state_inst ==  `ysyx22040228_I_MISSRH) && (cache_in_valid) && (missr_counter  == 2'b11)) begin
            if(oteg_valid_o == `ysyx22040228_ENABLE) begin
                cahce_mism_addr = 64'h0                ;
                mism_strb_l = `ysyx22040228_CACHE_STRBL;
                missr_counter_n  = 2'b00               ;
                mism_data      = {temp_inst[63:32], cache_in_data[31:0], temp_inst[63:32], cache_in_data[31:0]};
                cache_mism_ena = `ysyx22040228_ENABLE;
                write_m_ok     = `ysyx22040228_ABLE  ;
                mism_ena_l     = `ysyx22040228_ABLE  ;
            end 
            else if(tteg_valid_o == `ysyx22040228_ENABLE) begin
                cahce_mism_addr = 64'h0                ;
                mism_strb_l = `ysyx22040228_CACHE_STRBH;
                missr_counter_n  = 2'b00               ;
                mism_data      = {temp_inst[63:32], cache_in_data[31:0], temp_inst[63:32], cache_in_data[31:0]};
                cache_mism_ena = `ysyx22040228_ENABLE;
                write_m_ok     = `ysyx22040228_ABLE  ;
                mism_ena_l     = `ysyx22040228_ABLE  ;
            end 
            else if(i_counter1[icache_index] >= i_counter2[icache_index])begin
                cahce_mism_addr = 64'h0                ;
                mism_strb_l = `ysyx22040228_CACHE_STRBL;
                missr_counter_n  = 2'b00               ;
                mism_data      = {temp_inst[63:32], cache_in_data[31:0], temp_inst[63:32], cache_in_data[31:0]};
                cache_mism_ena = `ysyx22040228_ENABLE;
                write_m_ok     = `ysyx22040228_ABLE  ;
                mism_ena_l     = `ysyx22040228_ABLE  ;
            end   
            else /*if(i_counter1[icache_index] < i_counter2[icache_index])*/ begin
                cahce_mism_addr = 64'h0                ;
                mism_strb_l = `ysyx22040228_CACHE_STRBH;
                missr_counter_n  = 2'b00               ;
                mism_data      = {temp_inst[63:32], cache_in_data[31:0], temp_inst[63:32], cache_in_data[31:0]};
                cache_mism_ena = `ysyx22040228_ENABLE;
                write_m_ok     = `ysyx22040228_ABLE  ;
                mism_ena_l     = `ysyx22040228_ABLE  ;
            end 
        end
        else begin
            cahce_mism_addr = 64'h0                ;
            cache_mism_ena  = `ysyx22040228_ENABLE ;
            missr_counter_n  = 2'b00               ;
            mism_data      = `ysyx22040228_CACHE_STRBZ ;
            mism_ena_l     = `ysyx22040228_ENABLE ;
            mism_strb_l = `ysyx22040228_CACHE_STRBZ;
            write_m_ok     = `ysyx22040228_ENABLE   ;
        end
    end

    wire                             oteg_ena_i    ;
    assign                           oteg_ena_i  =  inst_fence                                                                                ? `ysyx22040228_ABLE : 
                                                    ((state_inst ==  `ysyx22040228_I_MISSRL) && ((miss_strb_l == `ysyx22040228_CACHE_STRBL))) ? `ysyx22040228_ABLE :
                                                    ((state_inst ==  `ysyx22040228_I_MISSRH) && ((mism_strb_l == `ysyx22040228_CACHE_STRBL))) ? `ysyx22040228_ABLE :
                                                                                                                                              `ysyx22040228_ENABLE ;
    wire                             oteg_valid_i  ;
    assign                           oteg_valid_i = inst_fence ? `ysyx22040228_ENABLE : `ysyx22040228_ABLE ;
    wire         [22:0]              oteg_data_i   ;
    assign                           oteg_data_i  = inst_fence ? 23'h0 : icache_tag ;
    wire         [5:0]               oteg_addr_i   ; 
    assign                           oteg_addr_i  = inst_fence ? fence_counter[5:0] : icache_index ;    
    // wire   [`ysyx22040228_TEG_WITH]  oteg_ata_o    ;
    // wire                             oteg_valid_o  ;
    ysyx_22040228TEG_CC TEG_ICACHEO(
        .clk         (clk          ),
        .rst         (rst          ),
        .addr_i      (oteg_addr_i  ),
        .teg_i       (oteg_data_i  ),
        .teg_valid   (oteg_valid_i ),
        .teg_ena     (oteg_ena_i   ), 
        .data_o      (oteg_ata_o   ),
        .data_valid  (oteg_valid_o )
    );

    wire                             tteg_ena_i    ; 
    assign                           tteg_ena_i  =  inst_fence                                                                                ? `ysyx22040228_ABLE : 
                                                    ((state_inst ==  `ysyx22040228_I_MISSRL) && ((miss_strb_l == `ysyx22040228_CACHE_STRBH))) ? `ysyx22040228_ABLE :
                                                    ((state_inst ==  `ysyx22040228_I_MISSRH) && ((mism_strb_l == `ysyx22040228_CACHE_STRBH))) ? `ysyx22040228_ABLE :
                                                                                                                                              `ysyx22040228_ENABLE ;
    wire                             tteg_valid_i  ;
    assign                           tteg_valid_i = inst_fence ? `ysyx22040228_ENABLE : `ysyx22040228_ABLE ;
    wire         [22:0]              tteg_data_i   ;
    assign                           tteg_data_i  = inst_fence ? 23'h0 : icache_tag ;
    wire         [5:0]               tteg_addr_i   ; 
    assign                           tteg_addr_i  = inst_fence ? fence_counter[5:0] : icache_index ;
    // wire   [`ysyx22040228_TEG_WITH]  tteg_ata_o    ;
    // wire                             tteg_valid_o  ;
    ysyx_22040228TEG_CC TEG_ICACHET(
        .clk         (clk          ),
        .rst         (rst          ),
        .addr_i      (tteg_addr_i  ),
        .teg_i       (tteg_data_i  ),
        .teg_valid   (tteg_valid_i ),
        .teg_ena     (tteg_ena_i   ),
        .data_o      (tteg_ata_o   ),
        .data_valid  (tteg_valid_o )
    );

    //-------------------------------ram data---------------------------------//
    // wire  [127:0] data_out ;
    /*wire*/   assign       CE = 1'b0 ;
    //wire  [127:0] w_strb_ram;
    assign        w_strb_ram = (state_inst ==  `ysyx22040228_I_MISSRL) ? miss_strb_l :
                               (state_inst ==  `ysyx22040228_I_MISSRH) ? mism_strb_l :
                                                          `ysyx22040228_CACHE_STRBZ  ;
    //wire  [127:0] w_data_ram;
    assign        w_data_ram = (state_inst ==  `ysyx22040228_I_MISSRL) ? miss_data :
                               (state_inst ==  `ysyx22040228_I_MISSRH) ? mism_data :
                                                          `ysyx22040228_CACHE_STRBZ;
    //wire          w_data_ena;
    assign        w_data_ena = (state_inst ==  `ysyx22040228_I_MISSRL) ? miss_ena_l :
                               (state_inst ==  `ysyx22040228_I_MISSRH) ? mism_ena_l :
                                                               `ysyx22040228_ENABLE ;
    // S011HD1P_X32Y2D128_BW REM_ICACHE (
    //     .Q           (data_out     ) ,
    //     .CLK         (clk          ) ,
    //     .CEN         (CE           ) ,
    //     .WEN         ( ~w_data_ena ) ,
    //     .BWEN        ( ~w_strb_ram ) ,
    //     .A           (icache_index ) ,
    //     .D           (w_data_ram   )
    // );


    //--------------------------------------bit code---------------------------//
    // reg  [2:0]  i_counter1 [`ysyx22040228_CACHE_DATA_W];
    // reg  [2:0]  i_counter2 [`ysyx22040228_CACHE_DATA_W];
    integer i ;

    always @(posedge clk) begin
        if(rst == `ysyx22040228_RSTENA) begin
		    for(i = 0;i<64;i=i+1) begin
			   i_counter1[i][2:0] <= 3'd0;
               i_counter2[i][2:0] <= 3'd0;
		    end
        end 
        if(((state_inst == `ysyx22040228_I_HIT) && ((oteg_ata_o == icache_tag) && (oteg_valid_o == `ysyx22040228_ABLE))) || ((miss_strb_l == `ysyx22040228_CACHE_STRBL) | (mism_strb_l == `ysyx22040228_CACHE_STRBL)))
            i_counter1[icache_index] <= 3'b0 ;
        if(((state_inst == `ysyx22040228_I_HIT) && ((tteg_ata_o == icache_tag) && (tteg_valid_o == `ysyx22040228_ABLE))) || ((miss_strb_l == `ysyx22040228_CACHE_STRBH) | (mism_strb_l == `ysyx22040228_CACHE_STRBH)))
            i_counter2[icache_index] <= 3'b0 ;
        if(icache_if_shankhand && inst_valid) begin
		    for(i = 0;i<64;i=i+1) begin
			   i_counter1[i][2:0] <= (i_counter1[i] == 3'd7) ? 3'd7 : i_counter1[i][2:0] + 1'b1;
               i_counter2[i][2:0] <= (i_counter2[i] == 3'd7) ? 3'd7 : i_counter2[i][2:0] + 1'b1;
		    end
        end 
	end

    assign cache_read_ena = (state_inst ==  `ysyx22040228_I_MISSRL) ? cahce_miss_ena : 
                            (state_inst ==  `ysyx22040228_I_MISSRH) ? cache_mism_ena :
                                                                 `ysyx22040228_ENABLE;
    assign cache_addr     = (state_inst ==  `ysyx22040228_I_MISSRL) ? cache_miss_addr : 
                            (state_inst ==  `ysyx22040228_I_MISSRH) ? cahce_mism_addr :
                                                                `ysyx22040228_ZEROWORD;


endmodule   
