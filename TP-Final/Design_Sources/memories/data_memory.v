`timescale 1ns/100ps
module data_memory
#(
    parameter                           NB_ADDR     = 32,
    parameter                           NB_DATA     = 32,
    parameter                           RAM_DEPTH   = 32
)
(
    //Outputs
    output wire [NB_DATA-1 : 0]         o_data,

    //Inputs
    input wire                          i_write_enable,
    input wire                          i_read_enable,
    input wire  [NB_ADDR-1 : 0]         i_write_address,
    input wire  [NB_ADDR-1 : 0]         i_read_address,
    input wire  [NB_DATA-1 : 0]         i_data,

    //Clocking
    input wire                          i_clock
    
);
    //Internal signals1
    reg         [NB_DATA-1 : 0]         data_memory [RAM_DEPTH-1 : 0];

    //writing
    always @(posedge i_clock)
    begin        
        if(i_write_enable)
            data_memory[i_write_address]            <= i_data;
    end   

    //Outputs
    assign                              o_data      = (i_read_enable) ? data_memory[i_read_address] : {NB_DATA{1'b0}};

endmodule
    