`timescale 1ns/100ps
module ram
#(
    parameter                           NB_INSTRUCTION  = 16,
    parameter                           NB_ADDR         = 10,
    parameter                           RAM_DEPTH       = 2**NB_ADDR
)
(
    input wire                          i_clock,
    input wire                          i_write_enable,
    //input wire                          i_read_enable,
    input wire  [NB_ADDR-1 : 0]         i_write_address,
    input wire  [NB_ADDR-1 : 0]         i_read_address,
    input wire  [NB_INSTRUCTION-1 : 0]  i_data,
    output wire [NB_INSTRUCTION-1 : 0]  o_data
);

    reg         [NB_INSTRUCTION-1 : 0]  ram [RAM_DEPTH-1 : 0];

    //reading - low latency
    assign                              o_data = ram[i_read_address];

    //writing
    always @(posedge i_clock)
    begin
        
        if(i_write_enable)
            ram[i_write_address] <= i_data;
    end   
    
 endmodule