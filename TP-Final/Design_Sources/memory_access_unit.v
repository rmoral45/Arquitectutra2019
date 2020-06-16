`timescale 1ns/100ps
module memory_acess_unit
#(
    parameter                       NB_ADDR     = 5, 
    parameter                       NB_DATA     = 2**NB_ADDR  
)
(
    //Outputs
    output wire [NB_DATA-1  : 0]    o_data_ltchd,

    //Inputs            
    input wire  [NB_ADDR-1  : 0]    i_rd_addr,
    input wire  [NB_DATA-1  : 0]    i_alu_result,
    input wire  [NB_DATA-1  : 0]    i_rf_data,
    input wire                      i_wr_enable,
    input wire                      i_rd_enable,

    //Clocking
    input wire                      i_clock
);


    //Internal Signals
    wire        [NB_DATA-1  : 0]    memory_data;
    reg         [NB_DATA-1  : 0]    memory_data_ltchd;

    //Latch of alu result and memory data
    always @ (posedge i_clock)
    begin
        memory_data_ltchd       <=  memory_data;
    end

    //Modules
    data_memory
    u_data_memory
    (
        .o_data                     (memory_data),

        .i_write_enable             (i_wr_enable),
        .i_read_enable              (i_rd_enable),
        .i_write_address            (i_alu_result),
        .i_read_address             (i_rd_addr),
        .i_data                     (i_rf_data),
        
        .i_clock                    (i_clock)
    );

    //Outputs
    assign                          o_data_ltchd    = memory_data_ltchd;

endmodule