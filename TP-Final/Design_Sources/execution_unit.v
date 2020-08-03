`timescale 1ns/100ps
module execution_unit
#(
    parameter                                   NB_ADDR                         = 5, 
    parameter                                   NB_DATA                         = 2**NB_ADDR,
    parameter                                   NB_CTRL_OPCODE                  = 6,
    parameter                                   NB_ALU_OPCODE                   = 4,
    parameter                                   NB_ALU_OP_SEL                   = 2,
    parameter                                   NB_LOAD_STORE_SEL               = 2,
    parameter                                   NB_ALU_MUX_SEL                  = 2
)
(
    //Outputs destinated to mem_stage
    output wire                                 o_data_mem_wr_enb_ltchd,
    output wire                                 o_data_mem_rd_enb_ltchd,
    output wire                                 o_is_branch_instruction_ltchd,
    output wire                                 o_is_jump_instruction_ltchd,
    output wire [NB_DATA-1              : 0]    o_jump_addr_ltchd,
    output wire [NB_DATA-1              : 0]    o_alu_result_ltchd,
    output wire                                 o_alu_zero_ltchd,
    output wire [NB_DATA-1              : 0]    o_branch_addr_ltchd,
    output wire [NB_DATA-1              : 0]    o_rf_rt_data_ltchd,
    output wire [NB_LOAD_STORE_SEL-1    : 0]    o_load_store_selector_ltchd,
    //to wr_back stage
    output wire                                 o_rf_wr_enb_ltchd,
    output wire                                 o_rf_wr_data_src_ltchd,
    output wire [NB_ADDR-1              : 0]    o_rf_wr_addr_ltchd,

    
    //Inputs
    input wire                                  i_enable,
    input wire  [NB_DATA-1              : 0]    i_rf_rs,
    input wire  [NB_DATA-1              : 0]    i_rf_rt,
    input wire  [NB_CTRL_OPCODE-1       : 0]    i_alu_ctrl_opcode,
    input wire                                  i_alu_data_src,             //0: from rf; 1: from inst.
    input wire  [NB_ALU_OP_SEL-1        : 0]    i_alu_op_type,
    input wire                                  i_alu_signed_operation,
    input wire                                  i_inmediate_operation,
    input wire  [NB_ADDR-1              : 0]    i_sa_operator,
    input wire  [NB_DATA-1              : 0]    i_inmediate_operator,
    input wire  [NB_DATA-1              : 0]    i_pc_stage_1,
    input wire  [NB_ADDR-1              : 0]    i_rf_rt_addr,
    input wire  [NB_ADDR-1              : 0]    i_rf_rd_addr,
    input wire  [NB_ADDR-1              : 0]    i_rf_rs_addr,
    input wire                                  i_rf_regdst,
    input wire  [NB_LOAD_STORE_SEL-1    : 0]    i_load_store_selector,
    input wire                                  i_flush,
    //Input of ctrl singals to latch
    //to mem_stage
    input wire                                  i_data_mem_wr_enb,
    input wire                                  i_data_mem_rd_enb,
    input wire                                  i_is_branch_instruction,
    input wire                                  i_is_jump_instruction,
    input wire  [NB_DATA-1              : 0]    i_jump_addr,
    //to wr_back_stage
    input wire                                  i_rf_wr_enb,
    input wire                                  i_rf_wr_data_src,

    //to forwarding unit
    input wire  [NB_ADDR-1              : 0]    i_rf_rd_addr_from_mem,
    input wire                                  i_rf_wr_enb_from_mem,
    input wire  [NB_DATA-1              : 0]    i_alu_operator_replacement,

    //Clocking
    input wire                                  i_clock,
    input wire                                  i_reset
);

    localparam                                  NB_BYTE                         =   8;
    localparam                                  FORWARD_EX_HZRD                 =   2'b10;
    localparam                                  FORWARD_MEM_HZRD                =   2'b01;
    localparam                                  DEFAULT_SEL_VALUE               =   2'b00;
    localparam                                  DEF_LINK_REG                    =   32'b00000000000000000000000000011111;//31

    //Signals for pipeline to mem_stage
    reg                                         data_mem_wr_enb_ltchd;
    reg                                         data_mem_rd_enb_ltchd;
    reg                                         is_branch_instruction_ltchd;
    reg                                         is_jump_instruction_ltchd;
    reg         [NB_DATA-1              : 0]    jump_addr_ltchd;
    wire        [NB_ALU_OPCODE-1        : 0]    alu_opcode;
    wire        [NB_DATA-1              : 0]    alu_result;
    reg         [NB_DATA-1              : 0]    alu_result_ltchd;
    wire                                        alu_zero;
    reg                                         alu_zero_ltchd;
    reg         [NB_DATA-1              : 0]    rf_rt_data_ltchd;

    //Signals for pipeline to wr_back
    wire        [NB_ADDR-1              : 0]    rf_regdst_addr;
    assign                                      rf_regdst_addr                  =   (i_rf_regdst)                                   ? i_rf_rd_addr                              : i_rf_rt_addr;   
      
    reg         [NB_ADDR-1              : 0]    rf_regdst_addr_ltchd;
    reg                                         rf_wr_enb_ltchd;
    reg                                         rf_wr_data_src_ltchd;

    //For HDU
    reg         [NB_ADDR-1              : 0]    rf_rt_addr_ltchd;     

    //Internal Signals
    wire                                        use_sa_sec;
    wire                                        use_rs_sec;
    wire                                        use_rt_first;
    wire        [NB_DATA-1              : 0]    alu_first_operator_original;
    wire        [NB_DATA-1              : 0]    alu_second_operator_original;
    wire        [NB_DATA-1              : 0]    alu_first_operator_forwarded;
    wire        [NB_DATA-1              : 0]    alu_second_operator_forwarded;
    wire        [NB_ALU_MUX_SEL-1       : 0]    mux_alu_first_operator;
    wire        [NB_ALU_MUX_SEL-1       : 0]    mux_alu_second_operator;
    wire        [NB_DATA-1              : 0]    branch_addr;
    reg         [NB_DATA-1              : 0]    branch_addr_ltchd;  
    reg         [NB_LOAD_STORE_SEL-1    : 0]    load_store_selector_ltchd;          
    
    assign                                      alu_first_operator_original     =   (use_rt_first)                                  ? i_rf_rt                                   : 
                                                                                    (i_data_mem_wr_enb)                             ? {{NB_DATA-NB_ADDR{1'b0}}, i_rf_rs_addr}   : i_rf_rs;

    assign                                      alu_first_operator_forwarded    =   (mux_alu_first_operator == FORWARD_EX_HZRD)     ? alu_result_ltchd                          :
                                                                                    (mux_alu_first_operator == FORWARD_MEM_HZRD)    ? i_alu_operator_replacement                :
                                                                                                                                      alu_first_operator_original               ;

    assign                                      alu_second_operator_forwarded   =   (mux_alu_second_operator == FORWARD_EX_HZRD)    ? alu_result_ltchd                          :
                                                                                    (mux_alu_second_operator == FORWARD_EX_HZRD)    ? i_alu_operator_replacement                :
                                                                                                                                      alu_second_operator_original              ;                                                                               

    assign                                      alu_second_operator_original    =   (i_alu_data_src)                                ? i_inmediate_operator                      :
                                                                                    (use_sa_sec)                                    ? i_sa_operator                             :         
                                                                                    (use_rs_sec)                                    ? i_rf_rs                                   : i_rf_rt;

    assign                                      branch_addr                     =    i_is_branch_instruction                        ? i_pc_stage_1  + i_inmediate_operator      : {NB_DATA{1'b0}};                                                                                                                                                            

    //for HDU
    always @ (posedge i_clock)
    begin
        if(i_reset || i_flush)
            rf_rt_addr_ltchd            <=      {NB_ADDR{1'b0}};
        else if(i_enable)
            rf_rt_addr_ltchd            <=      i_rf_rt_addr;
        else
            rf_rt_addr_ltchd            <=      rf_rt_addr_ltchd;            
    end

    //mem_stage signals latch (pipeline)
    always @ (posedge i_clock)
    begin
        if(i_reset || i_flush)
        begin
            data_mem_wr_enb_ltchd       <=      1'b0;
            data_mem_rd_enb_ltchd       <=      1'b0;
            is_branch_instruction_ltchd <=      1'b0;
            is_jump_instruction_ltchd   <=      1'b0;
            alu_result_ltchd            <=      {NB_DATA{1'b0}};
            alu_zero_ltchd              <=      1'b0;;
            branch_addr_ltchd           <=      {NB_DATA{1'b0}};
            rf_rt_data_ltchd            <=      {NB_DATA{1'b0}};
            load_store_selector_ltchd   <=      1'b0;
            jump_addr_ltchd             <=      {NB_DATA{1'b0}};
        end
        else if(i_enable)
        begin
            data_mem_wr_enb_ltchd       <=      i_data_mem_wr_enb;
            data_mem_rd_enb_ltchd       <=      i_data_mem_rd_enb;
            is_branch_instruction_ltchd <=      i_is_branch_instruction;
            is_jump_instruction_ltchd   <=      i_is_jump_instruction;
            alu_result_ltchd            <=      alu_result;
            alu_zero_ltchd              <=      alu_zero;
            branch_addr_ltchd           <=      branch_addr;
            rf_rt_data_ltchd            <=      i_rf_rt;
            load_store_selector_ltchd   <=      i_load_store_selector;
            jump_addr_ltchd             <=      i_jump_addr;
        end
        else
        begin
            data_mem_wr_enb_ltchd       <=      data_mem_wr_enb_ltchd;
            data_mem_rd_enb_ltchd       <=      data_mem_rd_enb_ltchd;
            is_branch_instruction_ltchd <=      is_branch_instruction_ltchd;
            is_jump_instruction_ltchd   <=      is_jump_instruction_ltchd;
            alu_result_ltchd            <=      alu_result_ltchd;
            alu_zero_ltchd              <=      alu_zero_ltchd;
            branch_addr_ltchd           <=      branch_addr_ltchd;
            rf_rt_data_ltchd            <=      rf_rt_data_ltchd;
            load_store_selector_ltchd   <=      load_store_selector_ltchd;
            jump_addr_ltchd             <=      jump_addr_ltchd;
        end        
    end

    //wr_back_stage signals latch (pipeline)
    always @ (posedge i_clock)
    begin
        if(i_reset)
        begin
            rf_wr_enb_ltchd             <=      1'b0;
            rf_wr_data_src_ltchd        <=      1'b0;
            rf_regdst_addr_ltchd        <=      {NB_ADDR{1'b0}};
        end
        else if(i_enable)
        begin
            rf_wr_enb_ltchd             <=      i_rf_wr_enb;
            rf_wr_data_src_ltchd        <=      i_rf_wr_data_src;
            rf_regdst_addr_ltchd        <=      rf_regdst_addr;
        end
        else
        begin
            rf_wr_enb_ltchd             <=      rf_wr_enb_ltchd;
            rf_wr_data_src_ltchd        <=      rf_wr_data_src_ltchd;
            rf_regdst_addr_ltchd        <=      rf_regdst_addr_ltchd;
        end        
    end


    //Modules
    alu_control
    u_alu_control
    (
        .o_second_ope_sa                        (use_sa_sec),
        .o_second_ope_rs                        (use_rs_sec),
        .o_first_ope_rt                         (use_rt_first),
        .o_alu_opcode                           (alu_opcode),

        .i_ctrl_opcode                          (i_alu_ctrl_opcode),
        .i_operation                            (i_alu_op_type)
    );

    alu
    u_alu
    (
        .o_result                               (alu_result),
        .o_zero                                 (alu_zero),
        
        .i_first_operator                       (alu_first_operator_forwarded ),
        .i_second_operator                      (alu_second_operator_forwarded),
        .i_opcode                               (alu_opcode),
        .i_signed_operation                     (i_alu_signed_operation)
    );

    forwarding_unit
    u_forwarding_unit
    (
        .o_mux_first_operator                   (mux_alu_first_operator),
        .o_mux_second_operator                  (mux_alu_second_operator),

        .i_rf_rs_from_id_unit                   (i_rf_rs_addr),
        .i_rf_rt_from_id_unit                   (i_rf_rt_addr),
        .i_rf_rd_from_ex_unit                   (rf_regdst_addr_ltchd),
        .i_rf_rd_from_mem_unit                  (i_rf_rd_addr_from_mem),
        .i_rf_wr_enb_from_ex_unit               (rf_wr_enb_ltchd),
        .i_rf_wr_enb_from_mem_unit              (i_rf_wr_enb_from_mem)
    );

    //Outputs
    assign                                      o_data_mem_wr_enb_ltchd         = data_mem_wr_enb_ltchd;
    assign                                      o_data_mem_rd_enb_ltchd         = data_mem_rd_enb_ltchd;
    assign                                      o_is_branch_instruction_ltchd   = is_branch_instruction_ltchd;
    assign                                      o_is_jump_instruction_ltchd     = is_jump_instruction_ltchd;
    assign                                      o_jump_addr_ltchd               = jump_addr_ltchd;
    assign                                      o_alu_result_ltchd              = alu_result_ltchd;
    assign                                      o_alu_zero_ltchd                = alu_zero_ltchd;    
    assign                                      o_branch_addr_ltchd             = branch_addr_ltchd;
    assign                                      o_rf_rt_data_ltchd              = rf_rt_data_ltchd;
    assign                                      o_load_store_selector_ltchd     = load_store_selector_ltchd;
    
    assign                                      o_rf_wr_enb_ltchd               = rf_wr_enb_ltchd;
    assign                                      o_rf_wr_data_src_ltchd          = rf_wr_data_src_ltchd;
    assign                                      o_rf_wr_addr_ltchd              = rf_regdst_addr_ltchd;
endmodule

