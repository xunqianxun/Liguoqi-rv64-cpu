/************************************************************
Author:LiGuoqi
Name:SocTOp.v
Function:top module of this soc
************************************************************/
/* verilator lint_off UNUSED */
/* verilator lint_off MODDUP */
/* verilator lint_off LATCH */
`include "arbitratem.v"
`include "inst_cache.v"
`include "data_cache.v"
`include "axi4crossbar.v"
`include "clint.v"
`include "rvcpu.v"
`include "defines_axi4.v"
`include "defines.v"
`include "uncache_mmio.v"
module ysyx_22040228 (
    input       wire                                         clk                  ,
    input       wire                                         rst                  ,



//     input       wire                                         io_interrput         ,
//    //-----------------------------AXI--------------------------------------------//
//    //----------------------write address cahnnel---------------------------------//
//     output      wire       [`ysyx22040228_ID_BUS]            out_axi_aw_id        ,
//     output      wire       [31:0]                            out_axi_aw_addr      ,
//     output      wire       [`ysyx22040228_LEN_BUS]           out_axi_aw_len       ,
//     output      wire       [`ysyx22040228_SIZE_BUS]          out_axi_aw_size      ,
//     output      wire       [`ysyx22040228_BURST_BUS]         out_axi_aw_burst     ,
//     output      wire       [`ysyx22040228_CACHE_BUS]         out_axi_aw_cache     ,
//     output      wire       [`ysyx22040228_PROT_BUS]          out_axi_aw_port      ,
//     output      wire       [`ysyx22040228_QOS_BUS]           out_axi_aw_qos       ,
//     output      wire                                         out_axi_aw_valid     ,
//     input       wire                                         out_axi_aw_ready     ,

//     //----------------------write data channel-----------------------------------//
//     output      wire       [`ysyx22040228_DATA_BUS]          out_axi_w_data       ,
//     output      wire       [`ysyx22040228_STRB_BUS]          out_axi_w_strb       ,
//     output      wire                                         out_axi_w_last       ,
//     output      wire                                         out_axi_w_valid      ,
//     input       wire                                         out_axi_w_ready      ,

//     //-----------------------write response channel------------------------------//
//     input       wire       [`ysyx22040228_ID_BUS]            out_axi_b_id         ,
//     input       wire       [`ysyx22040228_RESP_BUS]          out_axi_b_resp       ,
//     input       wire                                         out_axi_b_valid      ,
//     output      wire                                         out_axi_b_ready      ,

//     //------------------------read address channel-------------------------------//
//     output      wire       [`ysyx22040228_ID_BUS]            out_axi_ar_id        ,
//     output      wire       [31:0]                            out_axi_ar_addr      ,
//     output      wire       [`ysyx22040228_LEN_BUS]           out_axi_ar_len       ,
//     output      wire       [`ysyx22040228_SIZE_BUS]          out_axi_ar_size      ,
//     output      wire       [`ysyx22040228_BURST_BUS]         out_axi_ar_burst     ,
//     output      wire       [`ysyx22040228_CACHE_BUS]         out_axi_ar_cache     ,
//     output      wire       [`ysyx22040228_PROT_BUS]          out_axi_ar_prot      ,
//     output      wire       [`ysyx22040228_QOS_BUS]           out_axi_ar_qos       ,
//     output      wire                                         out_axi_ar_valid     ,
//     input       wire                                         out_axi_ar_ready     ,

//     //------------------------read data channel----------------------------------//
//     input       wire       [`ysyx22040228_ID_BUS]            out_axi_r_id         ,
//     input       wire       [`ysyx22040228_DATA_BUS]          out_axi_r_data       ,
//     input       wire       [`ysyx22040228_RESP_BUS]          out_axi_r_resp       ,
//     input       wire                                         out_axi_r_last       ,
//     input       wire                                         out_axi_r_valid      ,
//     output      wire                                         out_axi_r_ready      ,

//     output      wire                                         io_slave_awready,
//     input       wire                                         io_slave_awvalid,
//     input       wire       [`ysyx22040228_ID_BUS]            io_slave_awid,
//     input       wire       [31:0]                            io_slave_awaddr,
//     input       wire       [`ysyx22040228_LEN_BUS]           io_slave_awlen,
//     input       wire       [`ysyx22040228_SIZE_BUS]          io_slave_awsize,
//     input       wire       [`ysyx22040228_BURST_BUS]         io_slave_awburst,
//     output      wire                                         io_slave_wready,
//     input       wire                                         io_slave_wvalid,
//     input       wire       [`ysyx22040228_DATA_BUS]          io_slave_wdata,
//     input       wire       [`ysyx22040228_STRB_BUS]          io_slave_wstrb,
//     input       wire                                         io_slave_wlast,
//     input       wire                                         io_slave_bready,
//     output      wire                                         io_slave_bvalid, 
//     output      wire       [`ysyx22040228_ID_BUS]            io_slave_bid,
//     output      wire       [`ysyx22040228_RESP_BUS]          io_slave_bresp,
//     output      wire                                         io_slave_arready,
//     input       wire                                         io_slave_arvalid,
//     input       wire       [`ysyx22040228_ID_BUS]            io_slave_arid,
//     input       wire       [31:0]                            io_slave_araddr,
//     input       wire       [`ysyx22040228_LEN_BUS]           io_slave_arlen,
//     input       wire       [`ysyx22040228_SIZE_BUS]          io_slave_arsize,
//     input       wire       [`ysyx22040228_BURST_BUS]         io_slave_arburst,
//     input       wire                                         io_slave_rready,
//     output      wire                                         io_slave_rvalid,
//     output      wire       [`ysyx22040228_ID_BUS]            io_slave_rid,
//     output      wire       [`ysyx22040228_DATA_BUS]          io_slave_rdata,
//     output      wire       [`ysyx22040228_RESP_BUS]          io_slave_rresp,
//     output      wire                                         io_slave_rlast  

     output      wire       [`ysyx22040228_PCBUS]             out_slave_addr_ ,
     output      wire       [`ysyx22040228_DATABUS]           out_serial_data_,
     output      wire                                         out_serial_write_,
     output      wire                                         out_rtc_read_   ,
     input       wire       [`ysyx22040228_DATABUS]           in_rtc_data_    ,

     output      wire                                         read_ena_sign_   ,
     output      wire       [63:0]                            out_addr_outp   ,
     input       wire       [63:0]                            read_data_sign_  ,
     output      wire                                         out_write_ram_ena  ,
     output      wire       [63:0]                            out_write_ram_data ,
     output      wire       [63:0]                            out_write_ram_addr

);

    // assign io_slave_awready = 1'b0 ;
    // assign io_slave_wready  = 1'b0 ;
    // assign io_slave_bvalid  = 1'b0 ;
    // assign io_slave_bid     = 4'b0000;
    // assign io_slave_bresp   = 2'b00 ;
    // assign io_slave_arready = 1'b0 ;
    // assign io_slave_rvalid  = 1'b0 ;
    // assign io_slave_rid     = 4'b0000;
    // assign io_slave_rdata   = 64'h0 ;
    // assign io_slave_rresp   = 2'b00 ;
    // assign io_slave_rlast   = 1'b0  ;

    parameter SLAVE_NUM =  3 ;
    //-----------------------------wire about rvcpu------------------------------//
    wire aclk;
    assign aclk = clk ;

    wire  [63:0]    rvcpu_inst_addr  ;
    wire  [63:0]    rvcpu_data_addr  ;
    wire  [7:0 ]    rvcpu_wmask      ;
    wire  [63:0]    rvcpu_data_o     ;
    wire            rvcpu_we         ;
    wire            rvcpu_re         ;
    wire            cache_fnece      ;
    wire  [2:0]     rvcpu_we_type    ;
    wire  [2:0]     rvcpu_re_type    ;
    wire  [2:0]     rvcpu_inst_counter;
    wire            rvcpu_empty      ;

    wire  [63:0]    uncache_arb_data ;
    wire  [63:0]    uncache_arb_addr ;
    wire  [7:0]     uncache_arb_mask ;
    wire  [63:0]    uncache_arb_data_o;
    wire            uncache_arb_we   ;
    wire            uncache_arb_re   ;
    wire  [2:0]     uncahce_arb_size ;
    wire            uncache_arb_finish;
    wire  [63:0]    uncache_dc_data ;
    wire  [63:0]    uncache_dc_addr ;
    wire  [7:0]     uncache_dc_mask ;
    wire            uncache_dc_fence;
    wire  [63:0]    uncache_dc_data_o;
    wire            uncache_dc_we   ;
    wire            uncache_dc_re   ;
    wire            uncache_dc_finish;    

    wire  [127:0]   i_cache_inst_data;
    wire            i_cache_inst_valid;
    wire            i_cache_read_ena ;
    wire  [63:0]    i_cache_addr     ;  
    wire            i_cache_ready    ;
    wire            i_caceh_resp     ;
    wire            i_cache_canin    ;
    wire            i_cache_readyout ;
    wire  [255:0]   i_cache_pc       ;

    wire  [63:0]    d_cache_data_out ; 
    wire            d_cache_mem_finish;   
    wire  [63:0]    d_cache_out_addr ;
    wire  [63:0]    d_cache_out_data ;
    wire            d_cache_out_resp ;
    wire  [3:0]     d_cache_out_type ;  

    wire  [63:0]    arbitrate_d_data ;
    /* verilator lint_off UNOPTFLAT */
    wire            arbitrate_d_ok   ;
    /* verilator lint_on UNOPTFLAT */
    wire  [63:0]    arbitrate_i_data ;
    wire            arbitrate_i_ok   ;

    wire   time_init_sign            ;
    wire   interrupt_                ;
    assign interrupt_ = time_init_sign ;

    wire   [`ysyx22040228_ID_BUS]    t_axi_aw_id    ;
    wire   [`ysyx22040228_ADDR_BUS]  t_axi_aw_addr  ;
    wire   [`ysyx22040228_LEN_BUS]   t_axi_aw_len   ;
    wire   [`ysyx22040228_SIZE_BUS]  t_axi_aw_size  ;
    wire   [`ysyx22040228_BURST_BUS] t_axi_aw_burst ;
    wire   [`ysyx22040228_CACHE_BUS] t_axi_aw_cache ;
    wire   [`ysyx22040228_PROT_BUS]  t_axi_aw_port  ;
    wire   [`ysyx22040228_QOS_BUS]   t_axi_aw_qos   ;
    wire                             t_axi_aw_ready ;
    wire                             t_axi_aw_valid ;

    wire   [`ysyx22040228_DATA_BUS]  t_axi_w_data   ;
    wire   [`ysyx22040228_STRB_BUS]  t_axi_w_strb   ;
    wire                             t_axi_w_last   ;
    wire                             t_axi_w_valid  ;
    wire                             t_axi_w_ready  ;

    wire   [`ysyx22040228_ID_BUS]    t_axi_b_id     ;
    wire   [`ysyx22040228_RESP_BUS]  t_axi_b_resp   ;
    wire                             t_axi_b_valid  ;
    wire                             t_axi_b_ready  ;

    wire   [`ysyx22040228_ID_BUS]    t_axi_ar_id    ;
    wire   [`ysyx22040228_ADDR_BUS]  t_axi_ar_addr  ;
    wire   [`ysyx22040228_LEN_BUS]   t_axi_ar_len   ;
    wire   [`ysyx22040228_SIZE_BUS]  t_axi_ar_size  ;
    wire   [`ysyx22040228_BURST_BUS] t_axi_ar_burst ;
    wire   [`ysyx22040228_CACHE_BUS] t_axi_ar_cache ;
    wire   [`ysyx22040228_PROT_BUS]  t_axi_ar_prot  ;
    wire   [`ysyx22040228_QOS_BUS]   t_axi_ar_qos   ;
    wire                             t_axi_ar_valid ;
    wire                             t_axi_ar_ready ;
    wire   [`ysyx22040228_ID_BUS]    t_axi_r_id     ;
    wire   [`ysyx22040228_DATA_BUS]  t_axi_r_data   ;
    wire   [`ysyx22040228_RESP_BUS]  t_axi_r_resp   ;
    wire                             t_axi_r_last   ;
    wire                             t_axi_r_valid  ;
    wire                             t_axi_r_ready  ;
    

        wire          [4*SLAVE_NUM-1      : 0]              add_axi_aw_id      ;
    wire          [64*SLAVE_NUM-1     : 0]              add_axi_aw_addr    ;
    wire          [8*SLAVE_NUM-1      : 0]              add_axi_aw_len     ;
    wire          [3*SLAVE_NUM-1      : 0]              add_axi_aw_size    ;
    wire          [2*SLAVE_NUM-1      : 0]              add_axi_aw_burst   ;
    wire          [4*SLAVE_NUM-1      : 0]              add_axi_aw_cache   ;
    wire          [3*SLAVE_NUM-1      : 0]              add_axi_aw_prot    ;
    wire          [4*SLAVE_NUM-1      : 0]              add_axi_aw_qos     ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_aw_valid   ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_aw_ready   ;

    //wire          [4*SLAVE_NUM-1      : 0]              add_axi_w_id       ;
    wire          [64*SLAVE_NUM-1     : 0]              add_axi_w_data     ;
    wire          [8*SLAVE_NUM-1      : 0]              add_axi_w_strb     ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_w_last     ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_w_valid    ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_w_ready    ;

    wire          [4*SLAVE_NUM-1      : 0]              add_axi_b_id       ;
    wire          [2*SLAVE_NUM-1      : 0]              add_axi_b_resp     ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_b_valid    ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_b_ready    ;

    wire          [4*SLAVE_NUM-1      : 0]              add_axi_ar_id      ;
    wire          [64*SLAVE_NUM-1     : 0]              add_axi_ar_addr    ;
    wire          [8*SLAVE_NUM-1      : 0]              add_axi_ar_len     ;
    wire          [3*SLAVE_NUM-1      : 0]              add_axi_ar_size    ;
    wire          [2*SLAVE_NUM-1      : 0]              add_axi_ar_burst   ;
    wire          [4*SLAVE_NUM-1      : 0]              add_axi_ar_cache   ;
    wire          [3*SLAVE_NUM-1      : 0]              add_axi_ar_prot    ;
    wire          [4*SLAVE_NUM-1      : 0]              add_axi_ar_qos     ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_ar_valid   ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_ar_ready   ;

    wire          [4*SLAVE_NUM-1      : 0]              add_axi_r_id       ;
    wire          [64*SLAVE_NUM-1     : 0]              add_axi_r_data     ;
    wire          [2*SLAVE_NUM-1      : 0]              add_axi_r_resp     ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_r_last     ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_r_valid    ;
    wire          [1*SLAVE_NUM-1      : 0]              add_axi_r_ready    ;


    wire   [`ysyx22040228_ID_BUS]    soc_axi_aw_id    ;
    wire   [`ysyx22040228_ADDR_BUS]  soc_axi_aw_addr  ;
    wire   [`ysyx22040228_LEN_BUS]   soc_axi_aw_len   ;
    wire   [`ysyx22040228_SIZE_BUS]  soc_axi_aw_size  ;
    wire   [`ysyx22040228_BURST_BUS] soc_axi_aw_burst ;
    wire   [`ysyx22040228_CACHE_BUS] soc_axi_aw_cache ;
    wire   [`ysyx22040228_PROT_BUS]  soc_axi_aw_port  ;
    wire   [`ysyx22040228_QOS_BUS]   soc_axi_aw_qos   ;
    wire                             soc_axi_aw_ready ;
    wire                             soc_axi_aw_valid ;

    wire   [`ysyx22040228_DATA_BUS]  soc_axi_w_data   ;
    wire   [`ysyx22040228_STRB_BUS]  soc_axi_w_strb   ;
    wire                             soc_axi_w_last   ;
    wire                             soc_axi_w_valid  ;
    wire                             soc_axi_w_ready  ;

    wire   [`ysyx22040228_ID_BUS]    soc_axi_b_id     ;
    wire   [`ysyx22040228_RESP_BUS]  soc_axi_b_resp   ;
    wire                             soc_axi_b_valid  ;
    wire                             soc_axi_b_ready  ;

    wire   [`ysyx22040228_ID_BUS]    soc_axi_ar_id    ;
    wire   [`ysyx22040228_ADDR_BUS]  soc_axi_ar_addr  ;
    wire   [`ysyx22040228_LEN_BUS]   soc_axi_ar_len   ;
    wire   [`ysyx22040228_SIZE_BUS]  soc_axi_ar_size  ;
    wire   [`ysyx22040228_BURST_BUS] soc_axi_ar_burst ;
    wire   [`ysyx22040228_CACHE_BUS] soc_axi_ar_cache ;
    wire   [`ysyx22040228_PROT_BUS]  soc_axi_ar_prot  ;
    wire   [`ysyx22040228_QOS_BUS]   soc_axi_ar_qos   ;
    wire                             soc_axi_ar_valid ;
    wire                             soc_axi_ar_ready ;

    wire   [`ysyx22040228_ID_BUS]    soc_axi_r_id     ;
    wire   [`ysyx22040228_DATA_BUS]  soc_axi_r_data   ;
    wire   [`ysyx22040228_RESP_BUS]  soc_axi_r_resp   ;
    wire                             soc_axi_r_last   ;
    wire                             soc_axi_r_valid  ;
    wire                             soc_axi_r_ready  ;

    wire   [`ysyx22040228_ID_BUS]    tim_axi_aw_id    ;
    wire   [`ysyx22040228_ADDR_BUS]  tim_axi_aw_addr  ;
    wire   [`ysyx22040228_LEN_BUS]   tim_axi_aw_len   ;
    wire   [`ysyx22040228_SIZE_BUS]  tim_axi_aw_size  ;
    wire   [`ysyx22040228_BURST_BUS] tim_axi_aw_burst ;
    wire   [`ysyx22040228_CACHE_BUS] tim_axi_aw_cache ;
    /* verilator lint_off UNUSED */
    wire   [`ysyx22040228_PROT_BUS]  tim_axi_aw_port  ;
    wire   [`ysyx22040228_QOS_BUS]   tim_axi_aw_qos   ;
    wire                             tim_axi_aw_ready ;
    wire                             tim_axi_aw_valid ;

    wire   [`ysyx22040228_DATA_BUS]  tim_axi_w_data   ;
    wire   [`ysyx22040228_STRB_BUS]  tim_axi_w_strb   ;
    wire                             tim_axi_w_last   ;
    wire                             tim_axi_w_valid  ;
    wire                             tim_axi_w_ready  ;

    wire   [`ysyx22040228_ID_BUS]    tim_axi_b_id     ;
    wire   [`ysyx22040228_RESP_BUS]  tim_axi_b_resp   ;
    wire                             tim_axi_b_valid  ;
    wire                             tim_axi_b_ready  ;

    wire   [`ysyx22040228_ID_BUS]    tim_axi_ar_id    ;
    wire   [`ysyx22040228_ADDR_BUS]  tim_axi_ar_addr  ;
    wire   [`ysyx22040228_LEN_BUS]   tim_axi_ar_len   ;
    wire   [`ysyx22040228_SIZE_BUS]  tim_axi_ar_size  ;
    wire   [`ysyx22040228_BURST_BUS] tim_axi_ar_burst ;
    wire   [`ysyx22040228_CACHE_BUS] tim_axi_ar_cache ;
    wire   [`ysyx22040228_PROT_BUS]  tim_axi_ar_prot  ;
    wire   [`ysyx22040228_QOS_BUS]   tim_axi_ar_qos   ;
    wire                             tim_axi_ar_valid ;
    wire                             tim_axi_ar_ready ;

    wire   [`ysyx22040228_ID_BUS]    tim_axi_r_id     ;
    wire   [`ysyx22040228_DATA_BUS]  tim_axi_r_data   ;
    wire   [`ysyx22040228_RESP_BUS]  tim_axi_r_resp   ;
    wire                             tim_axi_r_last   ;
    wire                             tim_axi_r_valid  ;
    wire                             tim_axi_r_ready  ;
   /* verilator lint_off UNUSED */
   /* verilator lint_off UNDRIVEN */
    wire   [`ysyx22040228_ID_BUS]    io_axi_aw_id    ;
    wire   [`ysyx22040228_ADDR_BUS]  io_axi_aw_addr  ;
    wire   [`ysyx22040228_LEN_BUS]   io_axi_aw_len   ;
    wire   [`ysyx22040228_SIZE_BUS]  io_axi_aw_size  ;
    wire   [`ysyx22040228_BURST_BUS] io_axi_aw_burst ;
    wire   [`ysyx22040228_CACHE_BUS] io_axi_aw_cache ;
    wire   [`ysyx22040228_PROT_BUS]  io_axi_aw_port  ;
    wire   [`ysyx22040228_QOS_BUS]   io_axi_aw_qos   ;
    wire                             io_axi_aw_ready ;
    wire                             io_axi_aw_valid ;

    wire   [`ysyx22040228_DATA_BUS]  io_axi_w_data   ;
    wire   [`ysyx22040228_STRB_BUS]  io_axi_w_strb   ;
    wire                             io_axi_w_last   ;
    wire                             io_axi_w_valid  ;
    wire                             io_axi_w_ready  ;

    wire   [`ysyx22040228_ID_BUS]    io_axi_b_id     ;
    wire   [`ysyx22040228_RESP_BUS]  io_axi_b_resp   ;
    wire                             io_axi_b_valid  ;
    wire                             io_axi_b_ready  ;

    wire   [`ysyx22040228_ID_BUS]    io_axi_ar_id    ;
    wire   [`ysyx22040228_ADDR_BUS]  io_axi_ar_addr  ;
    wire   [`ysyx22040228_LEN_BUS]   io_axi_ar_len   ;
    wire   [`ysyx22040228_SIZE_BUS]  io_axi_ar_size  ;
    wire   [`ysyx22040228_BURST_BUS] io_axi_ar_burst ;
    wire   [`ysyx22040228_CACHE_BUS] io_axi_ar_cache ;
    wire   [`ysyx22040228_PROT_BUS]  io_axi_ar_prot  ;
    wire   [`ysyx22040228_QOS_BUS]   io_axi_ar_qos   ;
    wire                             io_axi_ar_valid ;
    wire                             io_axi_ar_ready ;

    wire   [`ysyx22040228_ID_BUS]    io_axi_r_id     ;
    wire   [`ysyx22040228_DATA_BUS]  io_axi_r_data   ;
    wire   [`ysyx22040228_RESP_BUS]  io_axi_r_resp   ;
    wire                             io_axi_r_last   ;
    wire                             io_axi_r_valid  ;
    wire                             io_axi_r_ready  ;

    assign  {soc_axi_aw_id     , tim_axi_aw_id     , io_axi_aw_id     }   =  add_axi_aw_id   ;
    assign  {soc_axi_aw_addr   , tim_axi_aw_addr   , io_axi_aw_addr   }   =  add_axi_aw_addr ;
    assign  {soc_axi_aw_len    , tim_axi_aw_len    , io_axi_aw_len    }   =  add_axi_aw_len  ;
    assign  {soc_axi_aw_size   , tim_axi_aw_size   , io_axi_aw_size   }   =  add_axi_aw_size ;
    assign  {soc_axi_aw_burst  , tim_axi_aw_burst  , io_axi_aw_burst  }   =  add_axi_aw_burst;
    assign  {soc_axi_aw_cache  , tim_axi_aw_cache  , io_axi_aw_cache  }   =  add_axi_aw_cache;
    assign  {soc_axi_aw_port   , tim_axi_aw_port   , io_axi_aw_port   }   =  add_axi_aw_prot ;
    assign  {soc_axi_aw_qos    , tim_axi_aw_qos    , io_axi_aw_qos    }   =  add_axi_aw_qos  ;
    assign  {soc_axi_aw_valid  , tim_axi_aw_valid  , io_axi_aw_valid  }   =  add_axi_aw_valid;
    assign  add_axi_aw_ready  =  {soc_axi_aw_ready  , tim_axi_aw_ready  , io_axi_aw_ready  } ;

    //assign      add_axi_w_id      =  {soc_axi_w_id      , tim_axi_w_id      , io_axi_w_id      } ;
    assign  {soc_axi_w_data    , tim_axi_w_data    , io_axi_w_data    }   =  add_axi_w_data  ;
    assign  {soc_axi_w_strb    , tim_axi_w_strb    , io_axi_w_strb    }   =  add_axi_w_strb  ;
    assign  {soc_axi_w_last    , tim_axi_w_last    , io_axi_w_last    }   =  add_axi_w_last  ;
    assign  {soc_axi_w_valid   , tim_axi_w_valid   , io_axi_w_valid   }   =  add_axi_w_valid ;
    assign  add_axi_w_ready   =  {soc_axi_w_ready   , tim_axi_w_ready   , io_axi_w_ready   } ;

    assign  add_axi_b_id      =  {soc_axi_b_id      , tim_axi_b_id      , io_axi_b_id      } ;
    assign  add_axi_b_resp    =  {soc_axi_b_resp    , tim_axi_b_resp    , io_axi_b_resp    } ;
    assign  add_axi_b_valid   =  {soc_axi_b_valid   , tim_axi_b_valid   , io_axi_b_valid   } ;
    assign  {soc_axi_b_ready   , tim_axi_b_ready   , io_axi_b_ready   }   =  add_axi_b_ready ;

    assign  {soc_axi_ar_id     , tim_axi_ar_id     , io_axi_ar_id     }   =  add_axi_ar_id   ;
    assign  {soc_axi_ar_addr   , tim_axi_ar_addr   , io_axi_ar_addr   }   =  add_axi_ar_addr ;
    assign  {soc_axi_ar_len    , tim_axi_ar_len    , io_axi_ar_len    }   =  add_axi_ar_len  ;
    assign  {soc_axi_ar_size   , tim_axi_ar_size   , io_axi_ar_size   }   =  add_axi_ar_size ;
    assign  {soc_axi_ar_burst  , tim_axi_ar_burst  , io_axi_ar_burst  }   =  add_axi_ar_burst;
    assign  {soc_axi_ar_cache  , tim_axi_ar_cache  , io_axi_ar_cache  }   =  add_axi_ar_cache;
    assign  {soc_axi_ar_prot   , tim_axi_ar_prot   , io_axi_ar_prot   }   =  add_axi_ar_prot ;
    assign  {soc_axi_ar_qos    , tim_axi_ar_qos    , io_axi_ar_qos    }   =  add_axi_ar_qos  ;
    assign  {soc_axi_ar_valid  , tim_axi_ar_valid  , io_axi_ar_valid  }   =  add_axi_ar_valid;
    assign  add_axi_ar_ready   = {soc_axi_ar_ready  , tim_axi_ar_ready  , io_axi_ar_ready  } ;

    assign  add_axi_r_id       = {soc_axi_r_id      , tim_axi_r_id      , io_axi_r_id      } ;
    assign  add_axi_r_data     = {soc_axi_r_data    , tim_axi_r_data    , io_axi_r_data    } ;
    assign  add_axi_r_resp     = {soc_axi_r_resp    , tim_axi_r_resp    , io_axi_r_resp    } ;
    assign  add_axi_r_last     = {soc_axi_r_last    , tim_axi_r_last    , io_axi_r_last    } ;
    assign  add_axi_r_valid    = {soc_axi_r_valid   , tim_axi_r_valid   , io_axi_r_valid   } ;
    assign  {soc_axi_r_ready   , tim_axi_r_ready   , io_axi_r_ready   }   =  add_axi_r_ready ;


    rvcpu rvcpu1 (
        .clk                 (aclk                ) ,
        .rst                 (rst                 ) ,
        
        .inst_addr           (rvcpu_inst_addr     ) ,
        .inst_counter        (rvcpu_inst_counter  ) ,
        .inst_ready          (i_cache_ready       ) ,
        .inst_data           (i_cache_inst_data   ) ,
        .inst_pc             (i_cache_pc          ) ,
        .cache_unready       (i_cache_inst_valid  ) ,
        .cache_data_ok       (i_cache_readyout    ) ,
        .issu_empty          (rvcpu_empty         ) ,

        .mem_addr_o          (rvcpu_data_addr     ) ,
        .mem_strb_o          (rvcpu_wmask         ) ,
        .mem_data_o          (rvcpu_data_o        ) ,
        .mem_data_i          (d_cache_data_out    ) ,
        .w_type_sel          (rvcpu_we_type       ) ,
        .write_ena           (rvcpu_we            ) ,
        .r_type_sel          (rvcpu_re_type       ) ,
        .read_ena            (rvcpu_re            ) ,
        .inst_fence          (cache_fnece         ) ,
        .mem_finish_i        (d_cache_mem_finish  ) ,

        .timer_initin        (interrupt_          )

    );

    wire [2:0] mmio_thing ;
    uncache_mmio uncache_mmio7(
        .mmio_sign           (mmio_thing          ) ,

        .core_addr           (rvcpu_data_addr     ) ,
        .core_data           (rvcpu_data_o        ) ,
        .core_mask           (rvcpu_wmask         ) ,
        .fence_in            (cache_fnece         ) ,
        .core_we_type        (rvcpu_we_type       ) ,
        .core_we             (rvcpu_we            ) ,
        .core_re_type        (rvcpu_re_type       ) ,
        .core_re             (rvcpu_re            ) ,
        .in_core_data        (d_cache_data_out    ) ,
        .in_core_finish      (d_cache_mem_finish  ) ,

        .arb_addr            (uncache_arb_addr    ) ,
        .arb_data            (uncache_arb_data    ) ,
        .arb_mask            (uncache_arb_mask    ) ,
        .arb_we              (uncache_arb_we      ) ,
        .arb_re              (uncache_arb_re      ) ,
        .arb_size_data       (uncahce_arb_size    ) ,
        .in_arb_data         (uncache_arb_data_o  ) ,
        .in_arb_finish       (uncache_arb_finish  ) ,

        .dcache_addr         (uncache_dc_addr     ) ,
        .dcache_data         (uncache_dc_data     ) ,
        .dcache_mask         (uncache_dc_mask     ) ,
        .dcache_fence        (uncache_dc_fence    ) ,
        .dcache_we           (uncache_dc_we       ) ,
        .dcache_re           (uncache_dc_re       ) ,
        .in_dcache_data      (uncache_dc_data_o   ) ,
        .in_dcache_finish    (uncache_dc_finish   )
    );

    inst_cache inst_cache2 (
        .clk                 (aclk                ) ,
        .rst                 (rst                 ) ,
        .inst_addr           (rvcpu_inst_addr     ) ,
        .inst_counter        (rvcpu_inst_counter  ) ,
        .inst_ready          (i_cache_ready       ) ,
        .issu_canin          (rvcpu_empty         ) ,
        .inst_fence          (uncache_dc_fence    ) ,
        .inst_data           (i_cache_inst_data   ) ,
        .inst_pc             (i_cache_pc          ) ,
        .inst_valid          (i_cache_inst_valid  ) ,
        .inst_readyout       (i_cache_readyout    ) ,

        .cache_read_ena      (i_cache_read_ena    ) ,
        .cache_addr          (i_cache_addr        ) ,
        .cache_in_data       (arbitrate_i_data    ) ,
        .cache_in_valid      (arbitrate_i_ok      )                       
);
    
    data_cache data_cache3 (
        .clk                 (aclk               ) ,
        .rst                 (rst                ) ,

        .mem_addr_i          (uncache_dc_addr    ) ,
        .mem_data_i          (uncache_dc_data    ) ,
        .mem_strb_i          (uncache_dc_mask    ) ,
        .mem_fence_i         (uncache_dc_fence   ) ,
        .mem_read_valid      (uncache_dc_re      ) ,
        .mem_write_valid     (uncache_dc_we      ) ,
        .mem_data_out        (uncache_dc_data_o  ) ,
        .mem_data_ready      (uncache_dc_finish  ) ,

        .in_dcache_data      (arbitrate_d_data   ) ,
        .in_dcache_ready     (arbitrate_d_ok     ) ,
        .out_dcache_addr     (d_cache_out_addr   ) ,
        .out_dcache_data     (d_cache_out_data   ) ,
        .out_dcache_type     (d_cache_out_type   )
    );

    arbitratem arbitratem4(
        .clk                 (aclk               ) ,
        .rst                 (rst                ) ,

        .d_cache_addr        (d_cache_out_addr   ) ,
        .d_cache_data        (d_cache_out_data   ) ,
        .d_cache_type        (d_cache_out_type   ) ,
        .d_cache_data_o      (arbitrate_d_data   ) ,
        .d_cache_valid_      (arbitrate_d_ok     ) ,

        .uncache_addr        (uncache_arb_addr   ) ,
        .uncache_data        (uncache_arb_data   ) ,
        .uncache_read_ena    (uncache_arb_re     ) ,
        .uncache_write_ena   (uncache_arb_we     ) ,
        .uncache_size_data   (uncahce_arb_size   ) ,
        .uncache_mask        (uncache_arb_mask   ) ,
        .uncahce_data_o      (uncache_arb_data_o ) ,
        .uncahce_valid_      (uncache_arb_finish ) ,

        .i_cache_addr        (i_cache_addr       ) ,
        .i_cache_ena         (i_cache_read_ena   ) ,
        .i_cache_data        (arbitrate_i_data   ) ,
        .i_cache_valid_      (arbitrate_i_ok     ) ,

        .axi_aw_id           (t_axi_aw_id        ) ,
        .axi_aw_addr         (t_axi_aw_addr      ) ,
        .axi_aw_len          (t_axi_aw_len       ) ,
        .axi_aw_size         (t_axi_aw_size      ) ,
        .axi_aw_burst        (t_axi_aw_burst     ) ,
        .axi_aw_cache        (t_axi_aw_cache     ) ,
        .axi_aw_port         (t_axi_aw_port      ) ,
        .axi_aw_qos          (t_axi_aw_qos       ) ,
        .axi_aw_valid        (t_axi_aw_valid     ) ,
        .axi_aw_ready        (t_axi_aw_ready     ) ,

        .axi_w_data          (t_axi_w_data       ) ,
        .axi_w_strb          (t_axi_w_strb       ) ,
        .axi_w_last          (t_axi_w_last       ) ,
        .axi_w_valid         (t_axi_w_valid      ) ,
        .axi_w_ready         (t_axi_w_ready      ) ,

        .axi_b_id            (t_axi_b_id         ) ,
        .axi_b_resp          (t_axi_b_resp       ) ,
        .axi_b_valid         (t_axi_b_valid      ) ,
        .axi_b_ready         (t_axi_b_ready      ) ,

        .axi_ar_id           (t_axi_ar_id        ) ,
        .axi_ar_addr         (t_axi_ar_addr      ) ,
        .axi_ar_len          (t_axi_ar_len       ) ,
        .axi_ar_size         (t_axi_ar_size      ) ,
        .axi_ar_burst        (t_axi_ar_burst     ) ,
        .axi_ar_cache        (t_axi_ar_cache     ) ,
        .axi_ar_prot         (t_axi_ar_prot      ) ,
        .axi_ar_qos          (t_axi_ar_qos       ) ,
        .axi_ar_valid        (t_axi_ar_valid     ) ,
        .axi_ar_ready        (t_axi_ar_ready     ) ,

        //------------------------read data channel----------------------------------//
        .axi_r_id            (t_axi_r_id         ) ,
        .axi_r_data          (t_axi_r_data       ) ,
        .axi_r_resp          (t_axi_r_resp       ) ,
        .axi_r_last          (t_axi_r_last       ) ,
        .axi_r_valid         (t_axi_r_valid      ) ,
        .axi_r_ready         (t_axi_r_ready      )  
    );    

    wire         read_ena_sign  ;
    wire [63:0]  addr_oup_sign   ;
    wire [63:0]  read_data_sign ;
    wire         write_ena_sign  ;
    wire [63:0]  write_addr_sign ;
    wire [63:0]  write_data_sign ;
    assign  read_ena_sign_    = read_ena_sign ;
    assign  out_addr_outp     = addr_oup_sign ;
    assign  read_data_sign   = read_data_sign_;
    assign  out_write_ram_ena = write_ena_sign;
    assign  out_write_ram_addr= write_addr_sign;
    assign  out_write_ram_data= write_data_sign;
    axi_mnq axi_mnq4(
        .clk                 (aclk                ) ,
        .rst                 (rst                ) ,

        .s_axi_aw_id         (soc_axi_aw_id      ) ,
        .s_axi_aw_addr       (soc_axi_aw_addr    ) ,
        .s_axi_aw_len        (soc_axi_aw_len     ) ,
        .s_axi_aw_size       (soc_axi_aw_size    ) ,
        .s_axi_aw_burst      (soc_axi_aw_burst   ) ,
        .s_axi_aw_cache      (soc_axi_aw_cache   ) ,
        .s_axi_aw_port       (soc_axi_aw_port    ) ,
        .s_axi_aw_qos        (soc_axi_aw_qos     ) ,
        .s_axi_aw_valid      (soc_axi_aw_valid   ) ,
        .s_axi_aw_ready      (soc_axi_aw_ready   ) ,

    //----------------------write data channel-----------------------------------//
        .s_axi_w_data        (soc_axi_w_data     ) ,
        .s_axi_w_strb        (soc_axi_w_strb     ) ,
        .s_axi_w_last        (soc_axi_w_last     ) ,
        .s_axi_w_valid       (soc_axi_w_valid    ) ,
        .s_axi_w_ready       (soc_axi_w_ready    ) ,

    //-----------------------write response channel------------------------------//
        .s_axi_b_id          (soc_axi_b_id       ) ,
        .s_axi_b_resp        (soc_axi_b_resp     ) ,
        .s_axi_b_valid       (soc_axi_b_valid    ) ,
        .s_axi_b_ready       (soc_axi_b_ready    ) ,

    //------------------------read address channel-------------------------------//
        .s_axi_ar_id         (soc_axi_ar_id      ) ,
        .s_axi_ar_addr       (soc_axi_ar_addr    ) ,
        .s_axi_ar_len        (soc_axi_ar_len     ) ,
        .s_axi_ar_size       (soc_axi_ar_size    ) ,
        .s_axi_ar_burst      (soc_axi_ar_burst   ) ,
        .s_axi_ar_cache      (soc_axi_ar_cache   ) ,
        .s_axi_ar_prot       (soc_axi_ar_prot    ) ,
        .s_axi_ar_qos        (soc_axi_ar_qos     ) ,
        .s_axi_ar_valid      (soc_axi_ar_valid   ) ,
        .s_axi_ar_ready      (soc_axi_ar_ready   ) ,

    //------------------------read data channel----------------------------------//
        .s_axi_r_id          (soc_axi_r_id       ) ,
        .s_axi_r_data        (soc_axi_r_data     ) ,
        .s_axi_r_resp        (soc_axi_r_resp     ) ,
        .s_axi_r_last        (soc_axi_r_last     ) ,
        .s_axi_r_valid       (soc_axi_r_valid    ) ,    
        .s_axi_r_ready       (soc_axi_r_ready    ) ,

        .mnq_read_ena        (read_ena_sign      ) ,
        .addr_oup            (addr_oup_sign      ) ,
        .mnq_data_in         (read_data_sign     ) ,
        .write_ram_ena       (write_ena_sign     ) ,
        .write_ram_data      (write_data_sign    ) ,
        .write_ram_addr      (write_addr_sign    )     
    );

    // assign out_axi_aw_id   = soc_axi_aw_id ;
    // assign out_axi_aw_addr = soc_axi_aw_addr[31:0];
    // assign out_axi_aw_len  = soc_axi_aw_len ;
    // assign out_axi_aw_size = soc_axi_aw_size;
    // assign out_axi_aw_burst = soc_axi_aw_burst;
    // assign out_axi_aw_cache = soc_axi_aw_cache;
    // assign out_axi_aw_port  = soc_axi_aw_port;
    // assign out_axi_aw_qos   = soc_axi_aw_qos ;
    // assign out_axi_aw_valid = soc_axi_aw_valid;
    // assign soc_axi_aw_ready = out_axi_aw_ready;

    // assign out_axi_w_data   = soc_axi_w_data ;
    // assign out_axi_w_strb   = soc_axi_w_strb ;
    // assign out_axi_w_last   = soc_axi_w_last ;
    // assign out_axi_w_valid  = soc_axi_w_valid;
    // assign soc_axi_w_ready  = out_axi_w_ready;

    // assign soc_axi_b_id     = out_axi_b_id   ;
    // assign soc_axi_b_resp   = out_axi_b_resp ;
    // assign soc_axi_b_valid  = out_axi_b_valid;
    // assign out_axi_b_ready  = soc_axi_b_ready;

    // assign out_axi_ar_id    = soc_axi_ar_id  ;
    // assign out_axi_ar_addr  = soc_axi_ar_addr[31:0];
    // assign out_axi_ar_len   = soc_axi_ar_len ;
    // assign out_axi_ar_size  = soc_axi_ar_size;
    // assign out_axi_ar_burst = soc_axi_ar_burst;
    // assign out_axi_ar_cache = soc_axi_ar_cache;
    // assign out_axi_ar_prot  = soc_axi_ar_prot;
    // assign out_axi_ar_qos   = soc_axi_ar_qos ;
    // assign out_axi_ar_valid = soc_axi_ar_valid;
    // assign soc_axi_ar_ready = out_axi_ar_ready;

    // assign soc_axi_r_data   = out_axi_r_data ;
    // assign soc_axi_r_id     = out_axi_r_id   ;
    // assign soc_axi_r_last   = out_axi_r_last ;
    // assign soc_axi_r_resp   = out_axi_r_resp ;
    // assign soc_axi_r_valid  = out_axi_r_valid;
    // assign out_axi_r_ready  = soc_axi_r_ready;



    wire   [2:0]   prot_chose_write;// = 3'b100 ;
    assign prot_chose_write = mmio_thing ;
    wire   [2:0]   prot_chose_read ;// = 3'b100 ;
    assign prot_chose_read = mmio_thing;
    axi4crossbar axi_crossbar  (
        .clk                 (aclk              ) ,
        .rst                 (rst               ) ,
        .prot_chose_write    (prot_chose_write  ) ,
        .prot_chose_read     (prot_chose_read   ) ,

        .master_axi_aw_id    (t_axi_aw_id       ) ,
        .master_axi_aw_addr  (t_axi_aw_addr     ) ,
        .master_axi_aw_len   (t_axi_aw_len      ) ,
        .master_axi_aw_size  (t_axi_aw_size     ) ,   
        .master_axi_aw_burst (t_axi_aw_burst    ) ,
        .master_axi_aw_cache (t_axi_aw_cache    ) ,
        .master_axi_aw_prot  (t_axi_aw_port     ) ,
        .master_axi_aw_qos   (t_axi_aw_qos      ) ,
        .master_axi_aw_valid (t_axi_aw_valid    ) ,
        .master_axi_aw_ready (t_axi_aw_ready    ) ,

        //.master_axi_w_id     (t_axi_w_id        ) ,
        .master_axi_w_data   (t_axi_w_data      ) ,
        .master_axi_w_strb   (t_axi_w_strb      ) ,
        .master_axi_w_last   (t_axi_w_last      ) ,
        .master_axi_w_valid  (t_axi_w_valid     ) ,
        .master_axi_w_ready  (t_axi_w_ready     ) ,

        .master_axi_b_id     (t_axi_b_id        ) ,
        .master_axi_b_resp   (t_axi_b_resp      ) ,
        .master_axi_b_ready  (t_axi_b_ready     ) ,
        .master_axi_b_valid  (t_axi_b_valid     ) ,

        .master_axi_ar_id    (t_axi_ar_id       ) ,
        .master_axi_ar_addr  (t_axi_ar_addr     ) ,
        .master_axi_ar_len   (t_axi_ar_len      ) ,
        .master_axi_ar_size  (t_axi_ar_size     ) ,
        .master_axi_ar_burst (t_axi_ar_burst    ) ,
        .master_axi_ar_cache (t_axi_ar_cache    ) ,
        .master_axi_ar_prot  (t_axi_ar_prot     ) ,
        .master_axi_ar_qos   (t_axi_ar_qos      ) ,
        .master_axi_ar_valid (t_axi_ar_valid    ) ,
        .master_axi_ar_ready (t_axi_ar_ready    ) ,

        .master_axi_r_id     (t_axi_r_id        ) ,
        .master_axi_r_data   (t_axi_r_data      ) ,
        .master_axi_r_resp   (t_axi_r_resp      ) ,
        .master_axi_r_last   (t_axi_r_last      ) ,
        .master_axi_r_valid  (t_axi_r_valid     ) ,
        .master_axi_r_ready  (t_axi_r_ready     ) ,

        .slave_axi_aw_id     (add_axi_aw_id     ) ,
        .slave_axi_aw_addr   (add_axi_aw_addr   ) ,
        .slave_axi_aw_len    (add_axi_aw_len    ) ,
        .slave_axi_aw_size   (add_axi_aw_size   ) ,
        .slave_axi_aw_burst  (add_axi_aw_burst  ) ,
        .slave_axi_aw_cache  (add_axi_aw_cache  ) ,
        .slave_axi_aw_prot   (add_axi_aw_prot   ) ,
        .slave_axi_aw_qos    (add_axi_aw_qos    ) ,
        .slave_axi_aw_valid  (add_axi_aw_valid  ) ,
        .slave_axi_aw_ready  (add_axi_aw_ready  ) ,

        //.slave_axi_w_id      (add_axi_w_id      ) ,
        .slave_axi_w_data    (add_axi_w_data    ) ,
        .slave_axi_w_strb    (add_axi_w_strb    ) ,
        .slave_axi_w_last    (add_axi_w_last    ) ,
        .slave_axi_w_valid   (add_axi_w_valid   ) ,
        .slave_axi_w_ready   (add_axi_w_ready   ) ,

        .slave_axi_b_id      (add_axi_b_id      ) ,
        .slave_axi_b_resp    (add_axi_b_resp    ) ,
        .slave_axi_b_valid   (add_axi_b_valid   ) ,
        .slave_axi_b_ready   (add_axi_b_ready   ) ,

        .slave_axi_ar_id     (add_axi_ar_id     ) ,
        .slave_axi_ar_addr   (add_axi_ar_addr   ) ,
        .slave_axi_ar_len    (add_axi_ar_len    ) ,
        .slave_axi_ar_size   (add_axi_ar_size   ) ,
        .slave_axi_ar_burst  (add_axi_ar_burst  ) ,
        .slave_axi_ar_cache  (add_axi_ar_cache  ) ,
        .slave_axi_ar_prot   (add_axi_ar_prot   ) ,
        .slave_axi_ar_qos    (add_axi_ar_qos    ) ,
        .slave_axi_ar_valid  (add_axi_ar_valid  ) ,
        .slave_axi_ar_ready  (add_axi_ar_ready  ) ,

        .slave_axi_r_id      (add_axi_r_id      ) ,
        .slave_axi_r_data    (add_axi_r_data    ) ,
        .slave_axi_r_resp    (add_axi_r_resp    ) ,
        .slave_axi_r_last    (add_axi_r_last    ) ,
        .slave_axi_r_valid   (add_axi_r_valid   ) ,
        .slave_axi_r_ready   (add_axi_r_ready   ) 
    );

    clint clint6 (
        .clk                 (aclk              ) ,
        .rst                 (rst               ) ,
        .time_interrupt      (time_init_sign    ) ,

        .time_axi_aw_id      (tim_axi_aw_id     ) , 
        .time_axi_aw_addr    (tim_axi_aw_addr   ) ,
        .time_axi_aw_len     (tim_axi_aw_len    ) ,
        .time_axi_aw_size    (tim_axi_aw_size   ) ,
        .time_axi_aw_burst   (tim_axi_aw_burst  ) ,
        .time_axi_aw_cache   (tim_axi_aw_cache  ) ,
        .time_axi_aw_prot    (tim_axi_aw_port   ) ,
        .time_axi_aw_qos     (tim_axi_aw_qos    ) ,
        .time_axi_aw_valid   (tim_axi_aw_valid  ) ,
        .time_axi_aw_ready   (tim_axi_aw_ready  ) , 

        .time_axi_w_data     (tim_axi_w_data    ) ,
        .time_axi_w_strb     (tim_axi_w_strb    ) ,
        .time_axi_w_last     (tim_axi_w_last    ) ,
        .time_axi_w_ready    (tim_axi_w_ready   ) ,
        .time_axi_w_valid    (tim_axi_w_valid   ) ,

    //write response channel
        .time_axi_b_id       (tim_axi_b_id      ) ,
        .time_axi_b_resp     (tim_axi_b_resp    ) ,
        .time_axi_b_valid    (tim_axi_b_valid   ) ,
        .time_axi_b_ready    (tim_axi_b_ready   ) ,

    //read address channel
        .time_axi_ar_id      (tim_axi_ar_id     ) ,
        .time_axi_ar_addr    (tim_axi_ar_addr   ) ,
        .time_axi_ar_len     (tim_axi_ar_len    ) ,
        .time_axi_ar_size    (tim_axi_ar_size   ) ,
        .time_axi_ar_burst   (tim_axi_ar_burst  ) ,
        .time_axi_ar_cache   (tim_axi_ar_cache  ) ,
        .time_axi_ar_prot    (tim_axi_ar_prot   ) ,
        .time_axi_ar_qos     (tim_axi_ar_qos    ) ,
        .time_axi_ar_valid   (tim_axi_ar_valid  ) ,
        .time_axi_ar_ready   (tim_axi_ar_ready  ) ,

    //read data channel
        .time_axi_r_id       (tim_axi_r_id      ) ,
        .time_axi_r_data     (tim_axi_r_data    ) ,
        .time_axi_r_resp     (tim_axi_r_resp    ) ,
        .time_axi_r_last     (tim_axi_r_last    ) ,
        .time_axi_r_valid    (tim_axi_r_valid   ) ,
        .time_axi_r_ready    (tim_axi_r_ready   ) 
    );

    io_slave_axi io_slave_axi9(
        .clk                 (aclk              ) ,
        .rst                 (rst               ) ,

        .ioe_axi_aw_id       (io_axi_aw_id      ) , 
        .ioe_axi_aw_addr     (io_axi_aw_addr    ) ,
        .ioe_axi_aw_len      (io_axi_aw_len     ) ,
        .ioe_axi_aw_size     (io_axi_aw_size    ) ,
        .ioe_axi_aw_burst    (io_axi_aw_burst   ) ,
        .ioe_axi_aw_cache    (io_axi_aw_cache   ) ,
        .ioe_axi_aw_prot     (io_axi_aw_port    ) ,
        .ioe_axi_aw_qos      (io_axi_aw_qos     ) ,
        .ioe_axi_aw_valid    (io_axi_aw_valid   ) ,
        .ioe_axi_aw_ready    (io_axi_aw_ready   ) , 

        .ioe_axi_w_data      (io_axi_w_data     ) ,
        .ioe_axi_w_strb      (io_axi_w_strb     ) ,
        .ioe_axi_w_last      (io_axi_w_last     ) ,
        .ioe_axi_w_valid     (io_axi_w_valid    ) ,
        .ioe_axi_w_ready     (io_axi_w_ready    ) ,

        .ioe_axi_b_id        (io_axi_b_id       ) ,
        .ioe_axi_b_resp      (io_axi_b_resp     ) ,
        .ioe_axi_b_valid     (io_axi_b_valid    ) ,
        .ioe_axi_b_ready     (io_axi_b_ready    ) ,

        .ioe_axi_ar_id       (io_axi_ar_id      ) ,
        .ioe_axi_ar_addr     (io_axi_ar_addr    ) ,
        .ioe_axi_ar_len      (io_axi_ar_len     ) ,
        .ioe_axi_ar_size     (io_axi_ar_size    ) ,
        .ioe_axi_ar_burst    (io_axi_ar_burst   ) ,
        .ioe_axi_ar_cache    (io_axi_ar_cache   ) ,
        .ioe_axi_ar_prot     (io_axi_ar_prot    ) ,
        .ioe_axi_ar_qos      (io_axi_ar_qos     ) ,
        .ioe_axi_ar_valid    (io_axi_ar_valid   ) ,
        .ioe_axi_ar_ready    (io_axi_ar_ready   ) ,

        .ioe_axi_r_id        (io_axi_r_id       ) ,
        .ioe_axi_r_data      (io_axi_r_data     ) ,
        .ioe_axi_r_resp      (io_axi_r_resp     ) ,
        .ioe_axi_r_last      (io_axi_r_last     ) ,
        .ioe_axi_r_valid     (io_axi_r_valid    ) ,
        .ioe_axi_r_ready     (io_axi_r_ready    ) ,

        .out_slave_addr      (out_slave_addr_   ) ,

        .out_serial_data     (out_serial_data_  ) ,
        .out_serial_write    (out_serial_write_ ) ,
        .in_rtc_data         (in_rtc_data_      ) ,
        .out_rtc_read        (out_rtc_read_     ) 
    );


endmodule

