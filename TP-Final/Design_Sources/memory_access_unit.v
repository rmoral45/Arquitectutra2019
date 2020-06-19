`timescale 1ns/100ps
module memory_acess_unit
#(
    parameter                       NB_ADDR                 = 5, 
    parameter                       NB_DATA                 = 2**NB_ADDR  
)
(
    //Outputs
    output wire [NB_DATA-1  : 0]    o_data_readed_ltchd,
    output wire [NB_DATA-1  : 0]    o_alu_result_ltchd,
    output wire                     o_rf_wr_enb_ltchd,
    output wire                     o_rf_wr_data_src_ltchd,
    output wire [NB_ADDR-1  : 0]    o_rf_wr_addr_ltchd,
    output wire                     o_pc_source

    //Inputs            
    input wire  [NB_ADDR-1  : 0]    i_addr,
    input wire  [NB_DATA-1  : 0]    i_rf_data,
    input wire                      i_wr_enable,
    input wire                      i_rd_enable,
    input wire                      i_is_branch_instruction,
    input wire                      i_alu_zero,
    input wire  [NB_ADDR-1  : 0]    i_calculated_branch_addr,
    //Input of ctrl singals to latch
    input wire                      i_rf_wr_enb,
    input wire                      i_rf_wr_data_src,
    //Input of rf wr addr to latch
    input wire  [NB_ADDR-1  : 0]    i_rf_wr_addr,

    //Clocking
    input wire                      i_clock
);

    //Internal Signals
    wire                            pc_branch_eq;
    wire                            pc_branch_neq;
    assign                          pc_branch_eq            =   i_is_branch_instruction & i_alu_zero;                                                                                
    assign                          pc_branch_neq           =   i_is_branch_instruction & !i_alu_zero;  

    //Signals for pipeline to id_stage
    wire        [NB_DATA-1  : 0]    memory_data;
    reg         [NB_DATA-1  : 0]    memory_data_ltchd;
    reg         [NB_DATA-1  : 0]    alu_result_ltchd;
    reg                             rf_wr_enb_ltchd;
    reg                             rf_wr_data_src_ltchd;
    reg                             rf_wr_addr_ltchd;

    //Latch of signals for pipeline to id_stage
    always @ (posedge i_clock)
    begin
        memory_data_ltchd       <=  memory_data;
        alu_result_ltchd        <=  i_addr;
        rf_wr_addr_ltchd        <=  i_rf_wr_enb;
        rf_wr_data_src_ltchd    <=  i_rf_wr_data_src;
        rf_wr_addr_ltchd        <=  i_rf_wr_addr;
    end

    //Modules
    data_memory
    u_data_memory
    (
        .o_data                     (memory_data),

        .i_write_enable             (i_wr_enable),
        .i_read_enable              (i_rd_enable),
        .i_write_address            (i_addr),
        .i_read_address             (i_addr),
        .i_data                     (i_rf_data),
        
        .i_clock                    (i_clock)
    );

    //Outputs
    assign                          o_data_ltchd            = memory_data_ltchd;
    assign                          o_alu_result_ltchd      = alu_result_ltchd;
    assign                          o_rf_wr_enb_ltchd       = rf_wr_enb_ltchd;
    assign                          o_rf_wr_data_src_ltchd  = rf_wr_data_src_ltchd;
    assign                          o_rf_wr_addr_ltchd      = rf_wr_addr_ltchd;
    assign                          o_pc_source             =   (pc_branch_eq || pc_branch_neq);
endmodule