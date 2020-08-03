`timescale 1ns/100ps
module memory_access_unit
#(
    parameter                                   NB_ADDR                 = 5,
    parameter                                   NB_MEM_DATA_ADDR        = 32, 
    parameter                                   NB_DATA                 = 2**NB_ADDR,
    parameter                                   NB_LOAD_STORE_SEL       = 2
)
(
    //Outputs
    output wire [NB_DATA-1              : 0]    o_data_readed_ltchd,
    output wire [NB_DATA-1              : 0]    o_alu_result_ltchd,
    output wire                                 o_rf_wr_enb_ltchd,
    output wire                                 o_rf_wr_data_src_ltchd,
    output wire [NB_ADDR-1              : 0]    o_rf_wr_addr_ltchd,
    output wire                                 o_pc_source,
    output wire [NB_DATA-1              : 0]    o_branch_addr_ltchd,

    //Inputs           
    input wire                                  i_enable,
    input wire  [NB_MEM_DATA_ADDR-1     : 0]    i_addr,
    input wire  [NB_DATA-1              : 0]    i_rf_data,
    input wire                                  i_wr_enable,
    input wire                                  i_rd_enable,
    input wire                                  i_is_branch_instruction,
    input wire                                  i_is_jump_instruction,
    input wire  [NB_DATA-1              : 0]    i_jump_addr,
    input wire                                  i_alu_zero,
    input wire  [NB_DATA-1              : 0]    i_calculated_branch_addr,
    input wire  [NB_LOAD_STORE_SEL-1    : 0]    i_load_store_selector,
    //Input of ctrl singals to latch
    input wire                                  i_rf_wr_enb,
    input wire                                  i_rf_wr_data_src,
    //Input of rf wr addr to latch
    input wire  [NB_ADDR-1              : 0]    i_rf_wr_addr,

    //Clocking
    input wire                                  i_clock
);

    localparam                                  NB_BYTE                 = 8;

    //Signals for pipeline to if_stage
    wire                                        pc_branch_eq;
    wire                                        pc_branch_neq;
    assign                                      pc_branch_eq            = i_is_branch_instruction & i_alu_zero;                                                                                
    assign                                      pc_branch_neq           = i_is_branch_instruction & !i_alu_zero;  
    wire                                        pc_source               = (pc_branch_eq || pc_branch_neq || i_is_jump_instruction);
    reg                                         pc_source_ltchd;
    reg         [NB_DATA-1              : 0]    branch_addr_ltchd;
    wire        [NB_DATA-1              : 0]    effective_pc_addr;

    //Signals for pipeline to id_stage
    wire        [NB_DATA-1              : 0]    memory_data;
    wire        [NB_DATA-1              : 0]    memory_data_modified;
    reg         [NB_DATA-1              : 0]    memory_data_ltchd;
    reg         [NB_DATA-1              : 0]    alu_result_ltchd;
    reg                                         rf_wr_enb_ltchd;
    reg                                         rf_wr_data_src_ltchd;
    reg         [NB_ADDR-1              : 0]    rf_wr_addr_ltchd;

    assign                                      memory_data_modified    = (i_wr_enable && (i_load_store_selector == 2'b01))?   {{NB_DATA-NB_BYTE{1'b0}}  , memory_data[NB_BYTE-1 -: NB_BYTE]}    :
                                                                          (i_wr_enable && (i_load_store_selector == 2'b10))?   {{NB_DATA-2*NB_BYTE{1'b0}}, memory_data[2*NB_BYTE-1 -: 2*NB_BYTE]}:
                                                                                                                                    memory_data;    
                                                                                                                                    
    wire        [NB_DATA-1              : 0]    rf_rt_modified;                 //used for load-store byte and halfword
    
    assign                                      rf_rt_modified          =   (i_load_store_selector == 2'b00)?   i_rf_data                                                :
                                                                            (i_load_store_selector == 2'b01)?   {{NB_DATA-NB_BYTE{1'b0}},     i_rf_data[NB_BYTE-1 : 0]}  :
                                                                                                                {{NB_DATA-2*NB_BYTE{1'b0}},   i_rf_data[2*NB_BYTE-1 :0]} ;
                                    
    assign                                      effective_pc_addr       =   (i_is_jump_instruction)         ?   i_jump_addr : i_calculated_branch_addr; 

    //Latch of signals for pipeline to if_stage
    always @ (posedge i_clock)
    begin
        if(i_enable)
        begin
            pc_source_ltchd                 <=  pc_source;
            branch_addr_ltchd               <=  effective_pc_addr;
        end
        else
        begin
            pc_source_ltchd                 <=  pc_source_ltchd;
            branch_addr_ltchd               <=  branch_addr_ltchd;            
        end
    end                                                             
                                                                                                

    //Latch of signals for pipeline to id_stage
    always @ (posedge i_clock)
    begin 
        if(i_enable)
        begin
            memory_data_ltchd               <=  memory_data_modified;
            alu_result_ltchd                <=  i_addr;
            rf_wr_enb_ltchd                 <=  i_rf_wr_enb;
            rf_wr_data_src_ltchd            <=  i_rf_wr_data_src;
            rf_wr_addr_ltchd                <=  i_rf_wr_addr;
        end
        else
        begin
            memory_data_ltchd               <=  memory_data_ltchd;
            alu_result_ltchd                <=  alu_result_ltchd;
            rf_wr_enb_ltchd                 <=  rf_wr_enb_ltchd;
            rf_wr_data_src_ltchd            <=  rf_wr_data_src_ltchd;
            rf_wr_addr_ltchd                <=  rf_wr_addr_ltchd;
        end
    end

    //Modules
    data_memory
    u_data_memory
    (
        .o_data                                 (memory_data),

        .i_write_enable                         (i_wr_enable),
        .i_read_enable                          (i_rd_enable),
        .i_write_address                        (i_addr),
        .i_read_address                         (i_addr),
        .i_data                                 (rf_rt_modified),
        
        .i_clock                                (i_clock)
    );

    //Outputs
    assign                                      o_data_readed_ltchd     = memory_data_ltchd;
    assign                                      o_alu_result_ltchd      = alu_result_ltchd;
    assign                                      o_rf_wr_enb_ltchd       = rf_wr_enb_ltchd;
    assign                                      o_rf_wr_data_src_ltchd  = rf_wr_data_src_ltchd;
    assign                                      o_rf_wr_addr_ltchd      = rf_wr_addr_ltchd;
    assign                                      o_pc_source             = pc_source;
    assign                                      o_branch_addr_ltchd     = (i_is_jump_instruction && i_enable)         ?   i_jump_addr : i_calculated_branch_addr;

endmodule