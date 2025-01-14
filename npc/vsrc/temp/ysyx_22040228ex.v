/************************************************************
Author:LiGuoqi
Name:ex.v
Function:Instruction execution module and CSR is instantiated
************************************************************/
`include "ysyx_22040228csr.v"
`include "ysyx_22040228divider.v"
`include "ysyx_22040228multiplier.v"
`include "ysyx_22040228defines.v"
module ysyx_22040228ex (
    input         wire                                        clk               ,
    input         wire                                        rst               ,
    input         wire          [`ysyx22040228_PCBUS]         pc_i              ,
    input         wire          [`ysyx22040228_INSTBUS]       id_ex_inst        ,

    input         wire          [ 7:0]                        inst_type_i       ,
    input         wire          [ 7:0]                        inst_opcode_i     ,
    input         wire          [`ysyx22040228_REGBUS]        op1_i             ,
    input         wire          [`ysyx22040228_REGBUS]        op2_i             ,
    input         wire                                        rd_ena_i          ,
    input         wire          [`ysyx22040228_REGADDRBUS]    rd_addr_i         ,

    input         wire          [ 2:0]                        ls_sel_i          ,
    input         wire          [11:0]                        addr_offsel_i     ,

    //output 
    output        wire          [ 7:0]                        inst_type_o       ,
    output        wire                                        rd_ena_o          ,
    output        wire          [`ysyx22040228_REGADDRBUS]    rd_addr_o         ,
    output        wire          [`ysyx22040228_REGBUS]        rd_data_o         ,
    output        wire          [`ysyx22040228_PCBUS]         ex_pc_o           ,
    output        wire          [`ysyx22040228_INSTBUS]       ex_inst_o         ,

    output        wire          [ 2:0]                        ls_sel_o          ,
    output        wire          [`ysyx22040228_REGBUS]        ls_addr_o         ,
    output        wire                                        fence_ready       ,

    output        wire                                        ex_flush          ,
    output        wire                                        branch_pc_ena     ,
    output        wire          [`ysyx22040228_PCBUS]         branch_pc         ,
    
    //to ctrl
    output        wire                                       ex_stall_req      ,
    
    //to interrupt
    input         wire                                       timer_intr        ,
    input         wire                                       ex_stall          
    
);

assign ex_pc_o = (rst == `ysyx22040228_RSTENA) ? `ysyx22040228_ZEROWORD : pc_i ;
assign ex_inst_o = (rst == `ysyx22040228_RSTENA) ? 32'b0 : id_ex_inst ;
assign fence_ready = (inst_opcode_i == `INST_FENCE) ? 1'b1 : 1'b0 ;

reg      [`ysyx22040228_REGBUS]       exe_res   ;

//about slti slt
wire     [`ysyx22040228_REGBUS]  op2_i_mux   = ~op2_i + 64'd1     ;
wire     [`ysyx22040228_REGBUS]  op1_sub_op2 = op1_i  + op2_i_mux ;

//sbout addxx
wire     [`ysyx22040228_REGBUS]  op1_add_op2   = op1_i + op2_i ;
wire     [`ysyx22040228_REGBUS]  op1_addw_op2  = {{32{op1_add_op2[31]}},op1_add_op2[31:0]} ;

//about slt slti
wire     op1_ls_op2 = (op1_i[63] && ~op2_i[63]) || (~op1_i[63] && ~op2_i[63] && op1_sub_op2[63]) || (op1_i[63] && op2_i[63] && op1_sub_op2[63]) ;

//about srai sra
wire     [`ysyx22040228_REGBUS]  shift_res = ( {64{op1_i[63]}} << (7'd64 - {1'b0 , op2_i[5:0]})) | (op1_i >> op2_i[5:0]) ;
 
//about sllw srlw
wire     [31:0]      op1_sllw_op2  = op1_i[31:0] << op2_i[4:0]               ;
wire     [`ysyx22040228_REGBUS]  sllw_res      = {{32{op1_sllw_op2[31]}} , op1_sllw_op2} ;

//about srliw srlw
wire     [31:0]      op1_srlw_op2  = op1_i[31:0] >> op2_i[4:0]               ;
wire     [`ysyx22040228_REGBUS]  srlw_res      = {{32{op1_srlw_op2[31]}} , op1_srlw_op2} ;

//about sraiw sraw 
wire     [31:0]      op1_sraw_op2  = ( {32{op1_i[31]}} << (6'd32 - {1'b0,op2_i[4:0]})) | (op1_i[31:0] >> op2_i[4:0]) ;
wire     [`ysyx22040228_REGBUS]  sraw_res      = {{32{op1_sraw_op2[31]}},op1_sraw_op2}                                         ;

//about subw
wire     [31:0]      op1_subw_op2  = op1_i[31:0] - op2_i[31:0]             ;
wire     [`ysyx22040228_REGBUS]  subw_res      = {{32{op1_subw_op2[31]}},op1_subw_op2} ;

wire  [`ysyx22040228_REGBUS]    read_csr_data  ;
assign rd_data_o    = inst_type_i[0] ? op2_i : ((inst_type_i[7] && (inst_opcode_i != `INST_EBREAK)) ? read_csr_data : exe_res) ;
wire                tmr_trap_ena ;
assign inst_type_o  = inst_type_i & {8{~tmr_trap_ena}} ;
assign rd_ena_o     = rd_ena_i    & (~tmr_trap_ena)    ;
assign rd_addr_o    = rd_addr_i                        ;

assign ls_addr_o    = (inst_type_i[1]|inst_type_i[0]) ? (op1_i + {{52{addr_offsel_i[11]}},addr_offsel_i}) : `ysyx22040228_ZEROWORD ;
assign ls_sel_o     = ls_sel_i  ;

wire     [`ysyx22040228_REGBUS]  upper_imm = {{32{op2_i[19]}},op2_i[19:0],12'd0} ;

reg   [63:0]   mul_data        ;
reg   [63:0]   divrem_data      ;
always @(*) begin
    if(rst == `ysyx22040228_RSTENA) begin  exe_res = `ysyx22040228_ZEROWORD   ;     end
    else begin
        case (inst_opcode_i) 
          `INST_ADDI ,  `INST_ADD:  begin exe_res = op1_add_op2              ;end
          `INST_SLTI ,  `INST_SLT:  begin exe_res = {63'd0 , op1_ls_op2}     ;end
          `INST_SLTIU , `INST_SLTU: begin exe_res = {63'd0 , (op1_i < op2_i)};end
          `INST_XORI ,  `INST_XOR:  begin exe_res = op1_i ^ op2_i            ;end
          `INST_ORI  ,  `INST_OR :  begin exe_res = op1_i | op2_i            ;end
          `INST_ANDI ,  `INST_AND:  begin exe_res = op1_i & op2_i            ;end
          `INST_SLLI ,  `INST_SLL:  begin exe_res = op1_i << op2_i[5:0]      ;end
          `INST_SRLI ,  `INST_SRL:  begin exe_res = op1_i >> op2_i[5:0]      ;end
          `INST_SRAI ,  `INST_SRA:  begin exe_res = shift_res                ;end
          `INST_SUB             :   begin exe_res = op1_sub_op2              ;end
          `INST_LUI  , `INST_AUIPC: begin exe_res = op1_i + upper_imm        ;end
          `INST_JAL  , `INST_JALR:  begin exe_res = op2_i + 64'd4            ;end
          `INST_ADDIW, `INST_ADDW:  begin exe_res = op1_addw_op2             ;end
          `INST_SLLIW, `INST_SLLW:  begin exe_res = sllw_res                 ;end
          `INST_SRLIW, `INST_SRLW:  begin exe_res = srlw_res                 ;end
          `INST_SRAIW, `INST_SRAW:  begin exe_res = sraw_res                 ;end
          `INST_SUBW             :  begin exe_res = subw_res                 ;end
          `INST_EBREAK           :  begin exe_res = op1_i                    ;end
          `INST_MUL ,  `INST_MULH,
          `INST_MULHSU,`INST_MULHU,
          `INST_MULW             :  begin exe_res = mul_data                 ;end 
          `INST_DIV , `INST_DIVU ,
          `INST_DIVUW,`INST_DIVW ,
          `INST_REM , `INST_REMU ,
          `INST_REMUW,`INST_REMW :  begin exe_res = divrem_data              ;end 
        default    :                begin exe_res = `ysyx22040228_ZEROWORD   ;end
        endcase
    end
end

wire clk_in ;
assign clk_in = clk ;
reg            mul_finish_sign ;
wire           mul_ready       ;
assign mul_ready =  (inst_opcode_i == `INST_MUL   ) | 
                    (inst_opcode_i == `INST_MULH  ) | 
                    (inst_opcode_i == `INST_MULHSU) | 
                    (inst_opcode_i == `INST_MULHU ) | 
                    (inst_opcode_i == `INST_MULW  ) ;

ysyx_22040228multiplier multiplier1 (
    .clk             (clk_in         ) ,
    .rst             (rst            ) ,
    .mult_ready      (mul_ready      ) ,
    .inst_opcode     (inst_opcode_i  ) ,
    .mult_op1        (op1_i          ) ,
    .mult_op2        (op2_i          ) ,
    .product_val     (mul_data       ) ,
    .mult_finish     (mul_finish_sign)  
);

reg            dr_finish_sign   ;
wire           dr_ready         ;
assign  dr_ready  = (inst_opcode_i == `INST_DIV     ) |
                    (inst_opcode_i == `INST_DIVU    ) |
                    (inst_opcode_i == `INST_DIVUW   ) |
                    (inst_opcode_i == `INST_DIVW    ) |
                    (inst_opcode_i == `INST_REM     ) |
                    (inst_opcode_i == `INST_REMU    ) |
                    (inst_opcode_i == `INST_REMUW   ) |
                    (inst_opcode_i == `INST_REMW    ) ;

wire  [63:0]  op1_divdata ;
wire  [63:0]  op2_divdata ;
assign op1_divdata = (inst_opcode_i == `INST_DIV     ) ? op1_i         :
                     (inst_opcode_i == `INST_DIVU    ) ? op1_i         :
                     (inst_opcode_i == `INST_DIVUW   ) ? {32'b0, op1_i[31:0]}   :
                     (inst_opcode_i == `INST_DIVW    ) ? (op1_i[31] ? {32'hffffffff, op1_i[31:0]} : {32'b0, op1_i[31:0]})   :
                     (inst_opcode_i == `INST_REM     ) ? op1_i         :
                     (inst_opcode_i == `INST_REMU    ) ? op1_i         :
                     (inst_opcode_i == `INST_REMUW   ) ? {32'b0, op1_i[31:0]}   :
                     (inst_opcode_i == `INST_REMW    ) ? (op1_i[31] ? {32'hffffffff, op1_i[31:0]} : {32'b0, op1_i[31:0]})   :
                                                `ysyx22040228_ZEROWORD ;

assign op2_divdata = (inst_opcode_i == `INST_DIV     ) ? op2_i         :
                     (inst_opcode_i == `INST_DIVU    ) ? op2_i         : 
                     (inst_opcode_i == `INST_DIVUW   ) ? {32'b0, op2_i[31:0]}   :
                     (inst_opcode_i == `INST_DIVW    ) ? (op2_i[31] ? {32'hffffffff, op2_i[31:0]} : {32'b0, op2_i[31:0]})   : 
                     (inst_opcode_i == `INST_REM     ) ? op2_i         :
                     (inst_opcode_i == `INST_REMU    ) ? op2_i         :  
                     (inst_opcode_i == `INST_REMUW   ) ? {32'b0, op2_i[31:0]}   :    
                     (inst_opcode_i == `INST_REMW    ) ? (op2_i[31] ? {32'hffffffff, op2_i[31:0]} : {32'b0, op2_i[31:0]})   :
                                                `ysyx22040228_ZEROWORD ;           
ysyx_22040228divider divider2 (
    .clk              (clk_in         ) ,
    .rst              (rst            ) ,

    .diviser          (op2_divdata    ) ,
    .dividend         (op1_divdata    ) ,
    .inst_opcode      (inst_opcode_i  ) ,
    .div_ready        (dr_ready       ) ,
    .div_rem_data     (divrem_data    ) ,
    .div_finish       (dr_finish_sign )  
);
wire   mul_div_req ;
assign mul_div_req = (~dr_finish_sign && dr_ready) || (~mul_finish_sign && mul_ready) ;

//branch
reg                ex_flush_branch                  ;

always @(*) begin
    if(~inst_type_i[2])  begin ex_flush_branch = `ysyx22040228_FLUSHDISABLE  ;    end
    else begin
        case (inst_opcode_i) 
             `INST_BEQ     : begin  ex_flush_branch = (op1_i == op2_i) ? `ysyx22040228_FLUSHDISABLE : `ysyx22040228_FLUSHABLE ;  end
             `INST_BNE     : begin  ex_flush_branch = (op1_i != op2_i) ? `ysyx22040228_FLUSHDISABLE : `ysyx22040228_FLUSHABLE ;  end
             `INST_BLTU    : begin  ex_flush_branch = (op1_i <  op2_i) ? `ysyx22040228_FLUSHDISABLE : `ysyx22040228_FLUSHABLE ;  end
             `INST_BGEU    : begin  ex_flush_branch = (op1_i >= op2_i) ? `ysyx22040228_FLUSHDISABLE : `ysyx22040228_FLUSHABLE ;  end
             `INST_BLT     : begin  ex_flush_branch = ( op1_ls_op2   ) ? `ysyx22040228_FLUSHDISABLE : `ysyx22040228_FLUSHABLE ;  end
             `INST_BGE     : begin  ex_flush_branch = (~op1_ls_op2   ) ? `ysyx22040228_FLUSHDISABLE : `ysyx22040228_FLUSHABLE ;  end
             default:        begin  ex_flush_branch = `ysyx22040228_FLUSHDISABLE  ;    end 
        endcase
    end
end

wire                trap_ena ;
reg                 cmt_mret_ena   ;
assign branch_pc_ena = (ex_flush_branch == `ysyx22040228_FLUSHABLE) | trap_ena | cmt_mret_ena ;
assign branch_pc     = (trap_ena | cmt_mret_ena) ? read_csr_data :
                       (ex_flush_branch == `ysyx22040228_FLUSHABLE) ? pc_i + 64'd4 :
                                                          `ysyx22040228_ZEROWORD   ;

assign ex_stall_req = mul_div_req    ;
assign ex_flush     = branch_pc_ena  ;

//CSR
wire  [11:0]        csr_idx = inst_type_i[7] ? op2_i[11:0] : 12'd0  ;
reg                 ecall_trap_ena ;
assign              trap_ena = ecall_trap_ena | (tmr_trap_ena) ;
reg                 csr_wr_en      ;
reg                 csr_rd_en      ;
reg   [`ysyx22040228_REGBUS]    wbck_csr_data  ;
reg   [`ysyx22040228_REGBUS]    trap_mcause_value ;

//assign tmr_trap_ena_o = tmr_trap_ena ;

wire [`ysyx22040228_REGBUS] mask_set_res   = read_csr_data | op1_i ;
wire [`ysyx22040228_REGBUS] mask_clear_res = read_csr_data & (~op1_i) ;

 ysyx_22040228csr csr0 (
     .clk               (clk_in)             ,
     .rst               (rst)                ,

     .pc_i              (pc_i)               ,
     .csr_wr_en         (csr_wr_en)          ,
     .csr_rd_en         (csr_rd_en)          ,
     .csr_idx           (csr_idx)            ,
     
     .cmt_mret_ena      (cmt_mret_ena)       ,
     .ecall_trap_ena    (ecall_trap_ena)     ,
     .trap_mcause_value (trap_mcause_value ) ,

     .tmr_intr_ena      (timer_intr)         ,
     .tmr_trap_ena      (tmr_trap_ena)       , 

     .read_csr_data     (read_csr_data)      ,
     .wbck_csr_data     (wbck_csr_data)      ,
     .ex_stall          (ex_stall) 
);

always @(*) begin
    if((~inst_type_i[7] ) || (rst == `ysyx22040228_RSTENA)) begin
        csr_wr_en          = `ysyx22040228_WDISABLE  ;
        csr_rd_en          = `ysyx22040228_RDISABLE  ;
        cmt_mret_ena       = 1'b0          ;
        ecall_trap_ena     = 1'b0          ;
        wbck_csr_data      = `ysyx22040228_ZEROWORD    ;
        trap_mcause_value  = `ysyx22040228_ZEROWORD    ;
    end
    else begin
        csr_wr_en          = `ysyx22040228_WDISABLE  ;
        csr_rd_en          = `ysyx22040228_RDISABLE  ;
        cmt_mret_ena       = 1'b0          ;
        ecall_trap_ena     = 1'b0          ;
        wbck_csr_data      = `ysyx22040228_ZEROWORD    ;
        trap_mcause_value  = `ysyx22040228_ZEROWORD    ;
        case (inst_opcode_i)
            `INST_CSRRW,`INST_CSRRWI: begin
                csr_wr_en           = `ysyx22040228_WENABLE   ;
                csr_rd_en           = (rd_addr_o == 5'b0) ?  `ysyx22040228_RDISABLE : `ysyx22040228_RENABLE    ;
                wbck_csr_data       = op1_i          ;
            end 
            `INST_CSRRS,`INST_CSRRSI: begin
                csr_wr_en           = (op1_i == `ysyx22040228_ZEROWORD) ? `ysyx22040228_WDISABLE : `ysyx22040228_WENABLE ;
                csr_rd_en           = `ysyx22040228_RENABLE    ;
                wbck_csr_data       = mask_set_res   ;
            end
            `INST_CSRRC,`INST_CSRRCI: begin
                csr_wr_en           = (op1_i == `ysyx22040228_ZEROWORD) ? `ysyx22040228_WDISABLE : `ysyx22040228_WENABLE ;
                csr_rd_en           = `ysyx22040228_RENABLE    ;
                wbck_csr_data       = mask_clear_res ;
            end
            `INST_ECALL:              begin
                ecall_trap_ena      = 1'b1           ;
                wbck_csr_data       = pc_i           ;
                trap_mcause_value   = 64'd11         ;
            end
            `INST_MRET:               begin
                cmt_mret_ena        = 1'b1           ;
            end   

            default: begin
               csr_wr_en            = `ysyx22040228_WDISABLE ;
               csr_rd_en            = `ysyx22040228_RDISABLE  ;
               cmt_mret_ena         = 1'b0          ;
               ecall_trap_ena       = 1'b0          ;
            end
        endcase
    end
    if(tmr_trap_ena) begin
        csr_wr_en          = `ysyx22040228_WDISABLE ;
        csr_rd_en          = `ysyx22040228_RDISABLE  ;
        cmt_mret_ena       = 1'b0          ;
        ecall_trap_ena     = 1'b0          ;
        wbck_csr_data      = pc_i          ;
        trap_mcause_value  = 64'h8000000000000007;
    end
end
   
endmodule//ex

