`timescale 1ns/100ps

module mips
#(
    parameter                                   NB_DATA                 =   32,
    parameter                                   NB_ADDR                 =   $clog2(NB_DATA), 
    parameter                                   NB_OPCODE               =   6
)
(
    //Outputs

    //Inputs
    input wire                                  i_enable,

    //Reset & clocking
    input wire                                  i_clock,
    input wire                                  i_reset                              
);
    /*                                              Localparameters                                                 */
    localparam                          NB_ALU_OP_SEL           =   2;

    /*                              Internal Signals                                */
    wire                                        pc_branch_eq;
    wire                                        pc_branch_neq;

    //Pipeline
    wire        [NB_DATA-1              : 0]    pipeline_if_id;
    wire        [NB_ADDR-1              : 0]    pipeline_pc_stage_0;.

    wire        [NB_DATA-1              : 0]    pipeline_rs_id_ex;
    wire        [NB_DATA-1              : 0]    pipeline_rt_id_ex;
    wire        [NB_DATA-1              : 0]    pipeline_inmediate_operator;
    wire        [NB_OPCODE-1            : 0]    pipeline_alu_ctrl_opcode;
    wire        [NB_ADDR-1              : 0]    pipeline_pc_stage_1;
    wire        [NB_DATA-1              : 0]    pipeline_sa_operator;

    wire        [NB_DATA-1              : 0]    pipeline_alu_result;
    wire        [NB_DATA-1              : 0]    pipeline_alu_zero;
    wire        [NB_DATA-1              : 0]    pipeline_branch_target_addr;
    

    //Program memory signals
    
    wire        [NB_DATA-1      : 0]    sa_operator;
    //Control unit signals
    wire        [NB_OPCODE-1    : 0]    instruction_type;
    wire                                is_branch;
    //Register file signals
    wire                                rf_wr_data_src;
    wire                                rf_wr_addr_src;         //signal to indicate store addr (rt/rd)
    wire                                rf_wr_enb;
    wire        [NB_DATA-1      : 0]    rf_wr_data;   
    wire        [NB_DATA-1      : 0]    rf_rs_data_decoded;              
    wire        [NB_DATA-1      : 0]    rf_rt_data_decoded;              
    //Data memory signals
    wire                                data_mem_rd_enb;
    wire                                data_mem_wr_enb;
    //Alu control signals
    wire        [NB_ALU_OP_SEL-1 : 0]   alu_operation_type;
    //Alu signals
    wire                                alu_data_src;

    //Inputs from pipeline_if_id to rfassign                              sa_operator             =   
    //Control unit assigns
    assign                              instruction_type        =   pipeline_if_id[NB_DATA-1 -: NB_OPCODE];
    
    
    assign                              pc_branch_eq            =   is_branch & alu_zero_flag;                                                                                
    assign                              pc_branch_neq           =   is_branch & !alu_zero_flag;  
    assign                              pc_source               =   (pc_branch_eq || pc_branch_neq);

    //Modules
    control_unit
    u_control_unit
    (
        .o_rf_wr_data_src               (rf_wr_data_src),//wr_back mux
        .o_rf_wr_addr_src               (rf_wr_addr_src),
        .o_rf_wr_enb                    (rf_wr_enable),
        .o_branch                       (is_branch),
        .o_data_mem_rd_enb              (data_mem_rd_enb),
        .o_data_mem_wr_enb              (data_mem_wr_enb),
        .o_alu_data_src                 (alu_data_src),
        .o_alu_operation                (alu_operation_type),
        .o_signed_operation             (alu_signed_operation),
        .o_inmediate_operation          (inmediate_operation),

        .i_instruction_type             (instruction_type)
    );

    instruction_fetch_unit
    #(
        .FILE                           (FILE)
    )
    u_instruction_fetch_unit
    (
        .o_inst_fetched                 (pipeline_if_id),
        .o_pc_ltchd                     (pipeline_pc_stage_0),
        
        .i_pc_source                    (pc_source),
        .i_branch_addr                  (inmediate_operator),   

        .i_clock                        (i_clock)
    );

    instruction_decode_unit
    u_instruction_decode_unit
    (
        .o_rf_rs_data_ltchd             (pipeline_rs_id_ex),
        .o_rf_rs_data_ltchd             (pipeline_rt_id_ex),
        .o_alu_ctrl_opcode_ltchd        (pipeline_alu_ctrl_opcode),
        .o_inmediate_operator_ltchd     (pipeline_inmediate_operator),
        .o_sa_operator_ltchd            (pipeline_sa_operator),
        .o_pc_ltchd                     (pipeline_pc_stage_1),

        .i_wr_enable                    (rf_wr_enb),
        .i_rf_wr_addr_src               (rf_wr_addr_src),
        .i_rf_data                      (//from wr_back),
        .i_pipeline_if_id               (pipeline_if_id),
        .i_inmediate_operation          (inmediate_operation),
        .i_pc_stage_0                   (pipeline_pc_stage_0),

        .i_clock                        (i_clock)
    );

    execution_unit
    u_execution_unit
    (
        .o_alu_result_ltchd             (pipeline_alu_result),
        .o_alu_zero_ltchd               (pipeline_alu_zero),
        .o_branch_addr_ltchd            (pipeline_branch_target_addr),

        .i_rf_rs                        (pipeline_rs_id_ex),
        .i_rf_rt                        (pipeline_rt_id_ex),
        .i_alu_ctrl_opcode              (pipeline_alu_ctrl_opcode),
        .i_alu_op_type                  (alu_operation_type),
        .i_alu_data_src                 (alu_data_src),
        .i_alu_signed_operation         (alu_signed_operation),
        .i_inmediate_operation          (inmediate_operation),
        .i_sa_operator                  (pipeline_sa_operator),
        .i_pc_stage_1                   (pipeline_pc_stage_1),

        .i_clock                        (i_clock)
    );

endmodule
    