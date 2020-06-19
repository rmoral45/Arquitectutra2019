`timescale 1ns/100ps

module instruction_decode_unit
#(
    parameter                                   NB_ADDR                         =   5,
    parameter                                   NB_DATA                         =   2**NB_ADDR,
    parameter                                   ROM_DEPTH                       =   1024,
    parameter                                   NB_ALU_CTRL_OPCODE              =   6,
    parameter                                   NB_ALU_OP_SEL                   =   2

)
(
    //Outputs destinated to ex_stage
    output wire [NB_DATA-1              : 0]    o_rf_rs_data_ltchd,
    output wire [NB_DATA-1              : 0]    o_rf_rt_data_ltchd,
    output wire [NB_ALU_CTRL_OPCODE-1   : 0]    o_alu_ctrl_opcode_ltchd,
    output wire                                 o_alu_data_src_ltchd,
    output wire [NB_ALU_CTRL_OPCODE-1   : 0]    o_alu_op_type_ltchd,
    output wire                                 o_alu_signed_operation_ltchd,
    output wire                                 o_alu_inmediate_operation_ltchd,
    output wire [NB_DATA-1              : 0]    o_inmediate_operator_ltchd,
    output wire [NB_ADDR-1              : 0]    o_sa_operator_ltchd,        
    output wire [NB_ADDR-1              : 0]    o_pc_ltchd,
    output wire [NB_ADDR-1              : 0]    o_rf_rt_addr_ltchd,
    output wire [NB_ADDR-1              : 0]    o_rf_rd_addr_ltchd,
    output wire                                 o_rf_regdst_ltchd,
    //Outputs destinated to mem_stage
    output wire                                 o_data_mem_wr_enb_ltchd,
    output wire                                 o_data_mem_rd_enb_ltchd,
    output wire                                 o_is_branch_instruction_ltchd,
    //Outpus destinated to wr_back stage
    output wire                                 o_rf_wr_enb_ltchd,
    output wire                                 o_rf_wr_data_src,

    //Inputs
    input wire                                  i_wr_enable,
    input wire  [NB_DATA-1              : 0]    i_rf_data,
    input wire  [NB_DATA-1              : 0]    i_pipeline_if_id,
    input wire                                  i_inmediate_operation,
    input wire  [NB_ADDR-1              : 0]    i_rf_wr_addr,
    //Input of ctrl singals to latch
    //to ex_stage
    input wire                                  i_alu_data_src,
    input wire   [NB_ALU_OP_SEL-1       : 0]    i_alu_op_type,
    input wire                                  i_alu_signed_operation_ltchd,
    input wire                                  i_alu_inmediate_operation_ltchd,
    input wire  [NB_ADDR-1              : 0]    i_pc_stage_0,
    input wire                                  i_rf_regdst,
    //to mem_stage
    input wire                                  i_data_mem_wr_enb,
    input wire                                  i_data_mem_rd_enb,
    input wire                                  i_is_branch_instruction,
    
    //to wr_back stage
    input wire                                  i_rf_wr_enb,
    input wire                                  i_rf_wr_data_src,

    //Clocking
    input wire                                  i_clock
);

    //Localparameters
    localparam                                  RS_REG_ADDR_POSITION            =   NB_DATA-1-NB_OPCODE;
    localparam                                  RT_REG_ADDR_POSITION            =   NB_DATA-1-NB_OPCODE-NB_ADDR;
    localparam                                  RD_REG_ADDR_POSITION            =   NB_DATA-1-NB_OPCODE-2*NB_ADDR;
    localparam                                  SA_OPE_POSITION                 =   NB_DATA-1-NB_OPCODE-3*NB_ADDR;
    localparam                                  SIGN_BIT                        =   (NB_DATA/2);

    //Internal signals
    wire        [NB_ADDR-1              : 0]    rf_rs_addr;
    wire        [NB_ADDR-1              : 0]    rf_rt_addr;
    wire        [NB_ADDR-1              : 0]    rf_rd_addr;

    //Signals for pipeline to ex_stage
    wire        [NB_DATA-1              : 0]    rf_rs_data;
    wire        [NB_DATA-1              : 0]    rf_rt_data;
    reg         [NB_DATA-1              : 0]    rf_rs_data_ltchd;
    reg         [NB_DATA-1              : 0]    rf_rt_data_ltchd;
    wire        [NB_ADDR-1              : 0]    rf_sa_operator;
    wire        [NB_ADDR-1              : 0]    rf_sa_operator_ltchd;
    reg         [NB_ADDR-1              : 0]    pc_ltchd;
    wire        [NB_DATA-1              : 0]    inmediate_operator;
    reg         [NB_DATA-1              : 0]    inmediate_operator_ltchd;
    wire        [NB_ALU_CTRL_OPCODE-1   : 0]    alu_ctrl_opcode;
    reg         [NB_ALU_CTRL_OPCODE-1   : 0]    alu_ctrl_opcode_ltchd;
    reg                                         alu_data_src_ltchd;
    reg         [NB_ALU_OP_SEL-1        : 0]    alu_op_type_ltchd;
    reg                                         alu_signed_operation_ltchd;
    reg                                         alu_inmediate_operation_ltchd;
    reg         [NB_ADDR-1              : o]    rf_rt_addr_ltchd;
    reg         [NB_ADDR-1              : o]    rf_rd_addr_ltchd;
    reg                                         rf_regdst_ltchd;
    
    //Signals for pipeline to mem_stage
    reg                                         data_mem_wr_enb_ltchd;
    reg                                         data_mem_rd_enb_ltchd;
    reg                                         is_branch_instruction_ltchd;

    //Signals for pipeline to wr_back_stage
    reg                                         rf_wr_data_src_ltchd;
    reg                                         rf_wr_enb_ltchd;
    


    

    assign                                      rf_rs_addr                      =   i_pipeline_if_id[RS_REG_ADDR_POSITION -: NB_ADDR];
    assign                                      rf_rt_addr                      =   i_pipeline_if_id[RT_REG_ADDR_POSITION -: NB_ADDR];
    assign                                      rf_rd_addr                      =   i_pipeline_if_id[RD_REG_ADDR_POSITION -: NB_ADDR];
    assign                                      rf_wr_addr                      =   (rf_wr_addr_src)        ? rd_addr 
                                                                                                            : rt_addr;
    assign                                      inmediate_operator              =   {(NB_DATA-SIGN_BIT){pipeline_if_id[SIGN_BIT-1]}, pipeline_if_id[SIGN_BIT-1 -: NB_DATA/2]};

    assign                                      alu_ctrl_opcode                 =   (i_inmediate_operation) ? i_instruction[NB_DATA-1   -: NB_CTRL_OPCODE];
                                                                                                            : i_instruction[OPCODE_POS  -: NB_CTRL_OPCODE];

    assign                                      rf_sa_operator                  =   {(NB_DATA-NB_ADDR){1'b0}, i_instruction[SA_OPE_POSITION -: NB_ADDR]};                                                                                                        

    
    //ex_stage signals latch (pipeline)
    always @ (posedge i_clock)
    begin
        rf_rs_data_ltchd                <=      rf_rs_data;
        rf_rt_data_ltchd                <=      rf_rt_data;
        rf_sa_operator_ltchd            <=      rf_sa_operator;
        pc_ltchd                        <=      i_pc_stage_0;
        inmediate_operator_ltchd        <=      inmediate_operator;
        alu_ctrl_opcode_ltchd           <=      alu_ctrl_opcode;
        alu_data_src_ltchd              <=      i_alu_data_src;
        alu_op_type_ltchd               <=      i_alu_op_type;
        alu_signed_operation_ltchd      <=      i_alu_signed_operation_ltchd;
        alu_inmediate_operation_ltchd   <=      i_alu_inmediate_operation_ltchd; 
        rf_rt_addr_ltchd                <=      rf_rt_addr;
        rf_rd_addr_ltchd                <=      rf_rd_addr;
        rf_regdst_ltchd                 <=      i_rf_regdst;
    end

    //mem_stage signals latch (pipeline)
    always @ (posegde i_clock)
    begin
        data_mem_wr_enb_ltchd           <=      i_data_mem_wr_enb;
        data_mem_rd_enb_ltchd           <=      i_data_mem_rd_enb;
        is_branch_instruction_ltchd     <=      i_is_branch_instruction;
    end

    //mem_stage signals latch (pipeline)
    always @ (posedge i_clock)
    begin
        rf_wr_enb_ltchd                 <=      i_rf_wr_enb;
        rf_wr_data_src_ltchd            <=      i_rf_wr_data_src;
    end

    //Module instantiation
    register_file
    u_register_file
    (
        .o_data_a                               (rf_rs_data),
        .o_data_b                               (rf_rt_data),

        .i_write_enable                         (i_wr_enable),
        .i_write_addr                           (i_rf_wr_addr),
        .i_read_addr_a                          (rf_rs_addr),
        .i_read_addr_b                          (rf_rt_addr), 
        .i_data                                 (i_rf_data),

        .i_clock                                (i_clock)
    );

    //Outputs asignment
    assign                                      o_rf_rs_data_ltchd              = rf_rs_data_ltchd;
    assign                                      o_rf_rt_data_ltchd              = rf_rt_data_ltchd;
    assign                                      o_alu_ctrl_opcode_ltchd         = alu_ctrl_opcode_ltchd;
    assign                                      o_alu_data_src_ltchd            = alu_data_src_ltchd;
    assign                                      o_alu_op_type_ltchd             = alu_op_type_ltchd;
    assign                                      o_alu_signed_operation_ltchd    = alu_signed_operation_ltchd;
    assign                                      o_alu_inmediate_operation_ltchd = alu_inmediate_operation_ltchd;
    assign                                      o_sa_operator_ltchd             = rf_sa_operator_ltchd;
    assign                                      o_inmediate_operator_ltchd      = inmediate_operator_ltchd;
    assign                                      o_pc_ltchd                      = pc_ltchd;
    assign                                      o_rf_rt_addr_ltchd              = rf_rt_addr_ltchd;
    assign                                      o_rf_rd_addr_ltchd              = rf_rd_addr_ltchd;
    assign                                      o_rf_regdst_ltchd               = rf_regdst_ltchd;

    assign                                      o_data_mem_wr_enb_ltchd         = data_mem_wr_enb_ltchd;
    assign                                      o_data_mem_rd_enb_ltchd         = data_mem_rd_enb_ltchd;
    assign                                      o_is_branch_instruction_ltchd   = is_branch_instruction_ltchd;

    assign                                      o_rf_wr_enb_ltchd               = rf_wr_enb_ltchd;
    assign                                      o_rf_wr_data_src                = rf_wr_data_src_ltchd;
endmodule
