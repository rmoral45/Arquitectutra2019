`timescale 1ns/100ps

module mips
#(
    parameter                                   NB_ADDR                 =   5, 
    parameter                                   NB_DATA                 =   2**NB_ADDR,
    parameter                                   NB_OPCODE               =   6,
    parameter                                   NB_ALU_OP_SEL           =   2,
    parameter                                   NB_LOAD_STORE_SEL       =   2,
    parameter                                   FILE                    =   ""
)
(
    //Outputs
    //Instruction Fetch Pipeline Outputs


    //Inputs
    input wire                                  i_enable,
    
    //Prog mem writing
    input wire                                  i_prog_mem_wr_enb,
    input wire  [NB_ADDR-1              : 0]    i_prog_mem_wr_addr,
    input wire  [NB_DATA-1              : 0]    i_data,

    //Reset & clocking
    input wire                                  i_clock,
    input wire                                  i_reset                              
);

    //Prog mem writing
    /*wire        [NB_DATA-1              : 0]    instruction_readed;
    wire                                        prog_mem_wr_enb;
    wire        [NB_ADDR-1              : 0]    prog_mem_wr_addr;*/

    //Pipeline
    wire        [NB_DATA-1              : 0]    pipeline_wr_back;
    wire        [NB_DATA-1              : 0]    pipeline_data_mem;
    wire        [NB_DATA-1              : 0]    pipeline_alu_wb;    
    
    //Instruction fetch unit (ifu) signals
    wire        [NB_DATA-1              : 0]    pipeline_ifu_instruction;
    wire        [NB_DATA-1              : 0]    pipeline_ifu_pc_stage_0;

    //Instruction decoder unit (idu) signals
    wire        [NB_DATA-1              : 0]    pipeline_idu_rs_data;
    wire        [NB_DATA-1              : 0]    pipeline_idu_rt_data;
    wire        [NB_OPCODE-1            : 0]    pipeline_idu_alu_ctrl_opcode;
    wire                                        pipeline_idu_alu_data_src;
    wire        [NB_ALU_OP_SEL-1        : 0]    pipeline_idu_alu_op_type;
    wire                                        pipeline_idu_alu_sign_ope;
    wire                                        pipeline_idu_alu_inm_ope;
    wire        [NB_ADDR-1              : 0]    pipeline_idu_sa_operator;
    wire        [NB_DATA-1              : 0]    pipeline_idu_inmediate_operator;
    wire        [NB_DATA-1              : 0]    pipeline_idu_pc_stage_1;
    wire        [NB_ADDR-1              : 0]    pipeline_idu_rf_rt_addr;
    wire        [NB_ADDR-1              : 0]    pipeline_idu_rf_rd_addr;
    wire        [NB_ADDR-1              : 0]    pipeline_idu_rf_rs_addr;
    wire                                        pipeline_idu_rf_regdst;
    wire                                        pipeline_idu_data_mem_wr_enb;
    wire                                        pipeline_idu_data_mem_rd_enb;
    wire                                        pipeline_idu_is_branc_instruction;
    wire                                        pipeline_idu_is_jump_instruction;
    wire        [NB_DATA-1              : 0]    pipeline_idu_jump_addr;
    wire                                        pipeline_idu_rf_wr_enb;
    wire                                        pipeline_idu_rf_wr_data_src;
    wire        [NB_LOAD_STORE_SEL-1    : 0]    pipeline_idu_load_store_selector;
    wire                                        idu_stall_condition;

    //Control unit output signals
    wire        [NB_OPCODE-1            : 0]    instruction_type;
    assign                                      instruction_type        =   pipeline_ifu_instruction[NB_DATA-1 -: NB_OPCODE];
    wire                                        rf_wr_data_src;
    wire                                        rf_wr_addr_src;         //signal to indicate store addr (rt/rd)
    wire                                        rf_wr_enable;
    wire                                        is_branch;
    wire                                        is_jump;
    wire                                        data_mem_rd_enb;
    wire                                        data_mem_wr_enb;
    wire                                        alu_data_src;
    wire        [NB_ALU_OP_SEL-1        : 0]    alu_operation_type;
    wire                                        alu_signed_operation;
    wire                                        inmediate_operation;   
    wire        [NB_LOAD_STORE_SEL-1    : 0]    load_store_selector;
    //Execution unit (exu) signals
    wire                                        pipeline_exu_data_mem_wr_enb;
    wire                                        pipeline_exu_data_mem_rd_enb;
    wire                                        pipeline_exu_is_branch_instruction;
    wire                                        pipeline_exu_is_jump_instruction;
    wire        [NB_DATA-1              : 0]    pipeline_exu_jump_addr;
    wire        [NB_DATA-1              : 0]    pipeline_exu_alu_result;
    wire                                        pipeline_exu_alu_zero;
    wire        [NB_DATA-1              : 0]    pipeline_exu_branch_target_addr;
    wire        [NB_DATA-1              : 0]    pipeline_exu_rf_rt_data;
    wire                                        pipeline_exu_rf_wr_enb;
    wire                                        pipeline_exu_rf_wr_data_src;
    wire        [NB_ADDR-1              : 0]    pipeline_exu_rf_wr_addr;
    wire        [NB_LOAD_STORE_SEL-1    : 0]    pipeline_exu_load_store_selector;
    //Memory acces unit (mau) signals
    wire        [NB_DATA-1              : 0]    pipeline_mau_data_readed;
    wire        [NB_DATA-1              : 0]    pipeline_mau_alu_result;
    wire                                        pipeline_mau_rf_wr_enb;
    wire                                        pipeline_mau_rf_wr_data_src;
    wire        [NB_ADDR-1              : 0]    pipeline_mau_wr_addr; 
    wire                                        pipeline_mau_pc_source;
    wire        [NB_DATA-1              : 0]    pipeline_mau_branch_addr;
    //WR BACK signals
    wire        [NB_DATA-1              : 0]    pipeline_wr_data_back;


    //Modules
    instruction_fetch_unit
    #(
        .FILE                                   (FILE)
    )
    u_instruction_fetch_unit
    (
        .o_inst_fetched                         (pipeline_ifu_instruction),
        .o_pc_ltchd                             (pipeline_ifu_pc_stage_0),
        
        .i_enable                               (i_enable),
        .i_pc_source                            (pipeline_mau_pc_source),
        .i_branch_addr                          (pipeline_mau_branch_addr),   
        .i_stall                                (idu_stall_condition),

        .i_data                                 (i_data),
        .i_wr_enb                               (i_prog_mem_wr_enb),
        .i_wr_addr                              (i_prog_mem_wr_addr),

        .i_clock                                (i_clock),
        .i_reset                                (i_reset)
    );

    control_unit
    u_control_unit
    (
        .o_rf_wr_data_src                       (rf_wr_data_src),//wr_back mux
        .o_rf_wr_addr_src                       (rf_wr_addr_src),//regdst
        .o_rf_wr_enb                            (rf_wr_enable),
        .o_branch                               (is_branch),
        .o_jump                                 (is_jump),
        .o_data_mem_rd_enb                      (data_mem_rd_enb),
        .o_data_mem_wr_enb                      (data_mem_wr_enb),
        .o_alu_data_src                         (alu_data_src),
        .o_alu_operation                        (alu_operation_type),
        .o_signed_operation                     (alu_signed_operation),
        .o_inmediate_operation                  (inmediate_operation),
        .o_load_store_sel                       (load_store_selector),

        .i_instruction_opcode                   (instruction_type)
    );

    instruction_decode_unit
    u_instruction_decode_unit
    (
        //outputs latched ctrl signals
        //to ex_stage
        .o_rf_rs_data_ltchd                     (pipeline_idu_rs_data),
        .o_rf_rt_data_ltchd                     (pipeline_idu_rt_data),
        .o_alu_ctrl_opcode_ltchd                (pipeline_idu_alu_ctrl_opcode),
        .o_alu_data_src_ltchd                   (pipeline_idu_alu_data_src),
        .o_alu_op_type_ltchd                    (pipeline_idu_alu_op_type),
        .o_alu_signed_operation_ltchd           (pipeline_idu_alu_sign_ope),
        .o_alu_inmediate_operation_ltchd        (pipeline_idu_alu_inm_ope),
        .o_sa_operator_ltchd                    (pipeline_idu_sa_operator),
        .o_inmediate_operator_ltchd             (pipeline_idu_inmediate_operator),
        .o_pc_ltchd                             (pipeline_idu_pc_stage_1),
        .o_rf_rt_addr_ltchd                     (pipeline_idu_rf_rt_addr),
        .o_rf_rd_addr_ltchd                     (pipeline_idu_rf_rd_addr),
        .o_rf_rs_addr_ltchd                     (pipeline_idu_rf_rs_addr),
        .o_rf_regdst_ltchd                      (pipeline_idu_rf_regdst),
        .o_load_store_selector_ltchd            (pipeline_idu_load_store_selector),
        //to mem_stage
        .o_data_mem_wr_enb_ltchd                (pipeline_idu_data_mem_wr_enb),
        .o_data_mem_rd_enb_ltchd                (pipeline_idu_data_mem_rd_enb),
        .o_is_branch_instruction_ltchd          (pipeline_idu_is_branc_instruction),  
        .o_is_jump_instruction_ltchd            (pipeline_idu_is_jump_instruction),
        .o_jump_addr_ltchd                      (pipeline_idu_jump_addr),
        //to wr_back_stage
        .o_rf_wr_enb_ltchd                      (pipeline_idu_rf_wr_enb),
        .o_rf_wr_data_src                       (pipeline_idu_rf_wr_data_src),
        //HDU
        .o_stall                                (idu_stall_condition),
 
        .i_enable                               (i_enable),
        .i_wr_enable                            (pipeline_mau_rf_wr_enb),
        .i_rf_wr_addr                           (pipeline_mau_wr_addr),
        .i_rf_data                              (pipeline_wr_data_back),
        .i_pipeline_ifu_instruction             (pipeline_ifu_instruction),
        .i_flush                                (pipeline_mau_pc_source),
        
        //inputs ctrl signals to latch
        //to ex_stage
        .i_alu_data_src                         (alu_data_src),
        .i_alu_op_type                          (alu_operation_type),
        .i_alu_signed_operation_ltchd           (alu_signed_operation),
        .i_inmediate_operation                  (inmediate_operation),
        .i_pc_stage_0                           (pipeline_ifu_pc_stage_0),
        .i_rf_regdst                            (rf_wr_addr_src),
        .i_load_store_selector                  (load_store_selector),
        //to_mem_stage
        .i_data_mem_wr_enb                      (data_mem_wr_enb),
        .i_data_mem_rd_enb                      (data_mem_rd_enb),
        .i_is_branch_instruction                (is_branch),
        .i_is_jump_instruction                  (is_jump),
        //to wr_back_stage
        .i_rf_wr_enb                            (rf_wr_enable),
        .i_rf_wr_data_src                       (rf_wr_data_src),
        
        .i_clock                                (i_clock),
        .i_reset                                (i_reset)
    );

    execution_unit
    u_execution_unit
    (
        //outputs latched ctrl signals
        //to mem_stage        
        .o_data_mem_wr_enb_ltchd                (pipeline_exu_data_mem_wr_enb),
        .o_data_mem_rd_enb_ltchd                (pipeline_exu_data_mem_rd_enb),
        .o_is_branch_instruction_ltchd          (pipeline_exu_is_branch_instruction),
        .o_is_jump_instruction_ltchd            (pipeline_exu_is_jump_instruction),
        .o_jump_addr_ltchd                      (pipeline_exu_jump_addr),
        .o_alu_result_ltchd                     (pipeline_exu_alu_result),
        .o_alu_zero_ltchd                       (pipeline_exu_alu_zero),
        .o_branch_addr_ltchd                    (pipeline_exu_branch_target_addr),
        .o_rf_rt_data_ltchd                     (pipeline_exu_rf_rt_data),
        .o_load_store_selector_ltchd            (pipeline_exu_load_store_selector),           
        //to wr_back_stage
        .o_rf_wr_enb_ltchd                      (pipeline_exu_rf_wr_enb),
        .o_rf_wr_data_src_ltchd                 (pipeline_exu_rf_wr_data_src),
        .o_rf_wr_addr_ltchd                     (pipeline_exu_rf_wr_addr),


        .i_enable                               (i_enable),
        .i_rf_rs                                (pipeline_idu_rs_data),
        .i_rf_rt                                (pipeline_idu_rt_data),
        .i_alu_ctrl_opcode                      (pipeline_idu_alu_ctrl_opcode),
        .i_alu_data_src                         (pipeline_idu_alu_data_src),
        .i_alu_op_type                          (pipeline_idu_alu_op_type),
        .i_alu_signed_operation                 (pipeline_idu_alu_sign_ope),
        .i_inmediate_operation                  (pipeline_idu_alu_inm_ope),
        .i_sa_operator                          (pipeline_idu_sa_operator),
        .i_inmediate_operator                   (pipeline_idu_inmediate_operator),
        .i_pc_stage_1                           (pipeline_idu_pc_stage_1),
        .i_rf_rt_addr                           (pipeline_idu_rf_rt_addr),
        .i_rf_rd_addr                           (pipeline_idu_rf_rd_addr),
        .i_rf_rs_addr                           (pipeline_idu_rf_rs_addr),
        .i_rf_regdst                            (pipeline_idu_rf_regdst),
        .i_load_store_selector                  (pipeline_idu_load_store_selector),
        .i_flush                                (pipeline_mau_pc_source),

        //inputs ctrl signals to latch
        //to mem_stage
        .i_data_mem_wr_enb                      (pipeline_idu_data_mem_wr_enb),
        .i_data_mem_rd_enb                      (pipeline_idu_data_mem_rd_enb),
        .i_is_branch_instruction                (pipeline_idu_is_branc_instruction),
        .i_is_jump_instruction                  (pipeline_idu_is_jump_instruction),
        .i_jump_addr                            (pipeline_idu_jump_addr),
        //to wr_back_stage 
        .i_rf_wr_enb                            (pipeline_idu_rf_wr_enb),
        .i_rf_wr_data_src                       (pipeline_idu_rf_wr_data_src),
        //to forwarding unit
        .i_rf_rd_addr_from_mem                  (pipeline_mau_wr_addr),
        .i_rf_wr_enb_from_mem                   (pipeline_mau_rf_wr_enb),
        .i_alu_operator_replacement             (pipeline_wr_data_back),

        .i_clock                                (i_clock),
        .i_reset                                (i_reset)
    );

    memory_access_unit
    u_memory_access_unit
    (
        //All ouputs to idu
        .o_data_readed_ltchd                    (pipeline_mau_data_readed),
        .o_alu_result_ltchd                     (pipeline_mau_alu_result),
        .o_rf_wr_enb_ltchd                      (pipeline_mau_rf_wr_enb), 
        .o_rf_wr_data_src_ltchd                 (pipeline_mau_rf_wr_data_src),
        .o_rf_wr_addr_ltchd                     (pipeline_mau_wr_addr),
        .o_pc_source                            (pipeline_mau_pc_source),
        .o_branch_addr_ltchd                    (pipeline_mau_branch_addr),
        
        .i_enable                               (i_enable),
        .i_addr                                 (pipeline_exu_alu_result),
        .i_rf_data                              (pipeline_exu_rf_rt_data),
        .i_wr_enable                            (pipeline_exu_data_mem_wr_enb),
        .i_rd_enable                            (pipeline_exu_data_mem_rd_enb),
        .i_is_branch_instruction                (pipeline_exu_is_branch_instruction),
        .i_is_jump_instruction                  (pipeline_exu_is_jump_instruction),
        .i_jump_addr                            (pipeline_exu_jump_addr),
        .i_alu_zero                             (pipeline_exu_alu_zero),
        .i_calculated_branch_addr               (pipeline_exu_branch_target_addr),
        .i_load_store_selector                  (pipeline_exu_load_store_selector),
        //inputs ctrl signals to latch
        //to wr_back_stage
        .i_rf_wr_enb                            (pipeline_exu_rf_wr_enb),
        .i_rf_wr_data_src                       (pipeline_exu_rf_wr_data_src),
        .i_rf_wr_addr                           (pipeline_exu_rf_wr_addr),
        
        .i_clock                                (i_clock)
    );

/* WR BACK STAGE */

assign                                          pipeline_wr_data_back       = (pipeline_mau_rf_wr_data_src) ?   pipeline_mau_data_readed : pipeline_mau_alu_result;


endmodule
    