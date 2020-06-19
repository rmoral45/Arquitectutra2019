`timescale 1ns/100ps
module execution_unit
#(
    parameter                               NB_ADDR                         = 5, 
    parameter                               NB_DATA                         = 2**NB_ADDR,
    parameter                               NB_CTRL_OPCODE                  = 6,
    parameter                               NB_ALU_OPCODE                   = 4,
    parameter                               NB_ALU_OP_SEL                   = 2
)
(
    //Outputs destinated to mem_stage
    output wire                             o_data_mem_wr_enb_ltchd,
    output wire                             o_data_mem_rd_enb_ltchd,
    output wire                             o_is_branch_instruction_ltchd,
    output wire [NB_DATA-1          : 0]    o_alu_result_ltchd,
    output wire                             o_alu_zero_ltchd,
    output wire [NB_DATA-1          : 0]    o_branch_addr_ltchd,
    output wire [NB_DATA-1          : 0]    o_rf_rt_data_ltchd,
    //to wr_back stage
    output wire                             o_rf_wr_enb_ltchd,
    output wire                             o_rf_wr_data_src_ltchd,
    output wire [NB_ADDR-1          : 0]    o_rf_wr_addr_ltchd,

    //Inputs
    input wire  [NB_DATA-1          : 0]    i_rf_rs,
    input wire  [NB_DATA-1          : 0]    i_rf_rt,
    input wire  [NB_CTRL_OPCODE-1   : 0]    i_alu_ctrl_opcode,
    input wire                              i_alu_data_src,             //0: from rf; 1: from inst.
    input wire  [NB_ALU_OP_SEL-1    : 0]    i_alu_op_type,
    input wire                              i_alu_signed_operation,
    input wire                              i_inmediate_operation,
    input wire  [NB_ADDR-1          : 0]    i_sa_operator,
    input wire  [NB_DATA-1          : 0]    i_inmediate_operator,
    input wire  [NB_ADDR-1          : 0]    i_pc_stage_1,
    input wire  [NB_ADDR-1          : 0]    i_rf_rt_addr,
    input wire  [NB_ADDR-1          : 0]    i_rf_rd_addr,
    input wire                              i_rf_regdst,
    //Input of ctrl singals to latch
    //to mem_stage
    input wire                              i_data_mem_wr_enb,
    input wire                              i_data_mem_rd_enb,
    input wire                              i_is_branch_instruction,
    //to wr_back_stage
    input wire                              i_rf_wr_enb,
    input wire                              i_rf_wr_data_src,

    //Clocking
    input wire                              i_clock
);

    //Internal Signals
    wire                                    use_sa_sec;
    wire                                    use_rt_first;
    wire        [NB_DATA-1          : 0]    alu_first_operator;
    wire        [NB_DATA-1          : 0]    alu_second_operator;
    assign                                  alu_first_operator              =   (use_rt_first)              ? i_rf_rs               : i_rf_rt;

    assign                                  alu_second_operator             =   (i_alu_data_src)            ? i_inmediate_operator  :
                                                                                (use_sa_sec)                ? i_sa_operator         : i_rf_rt;

    assign                                  branch_addr                     =   (i_alu_op_type == 2'b10)    ? i_pc_stage_1  + i_inmediate_operator : {NB_DATA{1'b0}};                                                                        

    //Signals for pipeline to mem_stage
    reg                                     data_mem_wr_enb_ltchd;
    reg                                     data_mem_rd_enb_ltchd;
    reg                                     is_branch_instruction_ltchd;
    wire        [NB_DATA-1          : 0]    alu_result;
    reg         [NB_DATA-1          : 0]    alu_result_ltchd;
    wire                                    alu_zero;
    reg                                     alu_zero_ltchd;
    wire        [NB_DATA-1          : 0]    branch_addr;
    reg         [NB_DATA-1          : 0]    branch_addr_ltchd;
    reg         [NB_DATA-1          : 0]    rf_rt_data_ltchd;

    //Signals for pipeline to wr_back
    wire        [NB_ADDR-1          : 0]    rf_regdst_addr;
    assign                                  rf_regdst_addr                  =   (i_rf_regdst)               ? i_rf_rd_addr          : i_rf_rt_addr;   
    reg         [NB_ADDR-1          : 0]    rf_regdst_addr_ltchd;
    reg                                     rf_wr_enb_ltchd;
    reg                                     rf_wr_data_src_ltchd;
    


    //mem_stage signals latch (pipeline)
    always @ (posedge i_clock)
    begin
        data_mem_wr_enb_ltchd       <=      i_data_mem_wr_enb;
        data_mem_rd_enb_ltchd       <=      i_data_mem_rd_enb;
        is_branch_instruction_ltchd <=      i_is_branch_instruction;
        alu_result_ltchd            <=      alu_result;
        alu_zero_ltchd              <=      alu_zero;
        branch_addr_ltchd           <=      branch_addr;
        rf_rt_data_ltchd            <=      i_rf_rt;        
    end

    //wr_back_stage signals latch (pipeline)
    always @ (posedge i_clock)
    begin
        rf_wr_enb_ltchd             <=      i_rf_wr_enb;
        rf_wr_data_src_ltchd        <=      i_rf_wr_data_src;
        rf_regdst_addr_ltchd        <=      rf_regdst_addr;
    end


    //Modules
    alu_control
    u_alu_control
    (
        .o_second_ope_sa                    (use_sa_sec),
        .o_first_ope_rt                     (use_rt_first),
        .o_alu_opcode                       (alu_opcode),

        .i_ctrl_opcode                      (i_alu_ctrl_opcode),
        .i_operation                        (i_alu_op_type)
    );

    alu
    u_alu
    (
        .o_result                           (alu_result         ),
        .o_zero                             (alu_zero),
        
        .i_first_operator                   (alu_first_operator ),
        .i_second_operator                  (alu_second_operator),
        .i_opcode                           (alu_opcode         ),
        .i_signed_operation                 (i_alu_signed_operation)
    );

    //Outputs
    assign                                  o_data_mem_wr_enb_ltchd         = data_mem_wr_enb_ltchd;
    assign                                  o_data_mem_rd_enb_ltchd         = data_mem_rd_enb_ltchd;
    assign                                  o_is_branch_instruction_ltchd   = is_branch_instruction_ltchd;
    assign                                  o_alu_result_ltchd              = alu_result_ltchd;
    assign                                  o_alu_zero_ltchd                = alu_zero_ltchd;    
    assign                                  o_branch_addr_ltchd             = branch_addr_ltchd;
    assign                                  o_rf_rt_data_ltchd              = rf_rt_data_ltchd;
    
    assign                                  o_rf_wr_enb_ltchd               = rf_wr_enb_ltchd;
    assign                                  o_rf_wr_data_src_ltchd          = rf_wr_data_src_ltchd;
    assign                                  o_rf_wr_addr_ltchd              = rf_regdst_addr_ltchd;
endmodule

