`timescale 1ns/100ps
module rom
#(
    parameter                       NB_INSTRUCTION  = 16,
    parameter                       NB_ADDR         = 10,
    parameter                       ROM_DEPTH       = 2**NB_ADDR,
    parameter                       FILE            = ""
)
(   
//    input wire                          i_clock,
//    input wire                          i_reset,
    input wire  [NB_ADDR-1 : 0]         i_read_addr, 
    output wire [NB_INSTRUCTION-1 : 0]  o_data
);

    reg         [NB_INSTRUCTION-1 : 0]  rom [ROM_DEPTH-1 : 0];


    //reading - low latency
    assign                              o_data = rom[i_read_addr];

    //writing
    initial
        $readmemb(FILE, rom, 0, ROM_DEPTH-1);

endmodule