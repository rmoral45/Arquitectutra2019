`timescale 1ns/100ps
module program_memory
#(
    parameter                               NB_ADDR         = 5,
    parameter                               NB_DATA         = 2**NB_ADDR,
    parameter                               ROM_DEPTH       = 30,
    parameter                               FILE            = ""
)
(   
    //Outputs
    output wire [NB_DATA-1   : 0]           o_data,

    //Inputs
    input wire  [NB_ADDR-1          : 0]    i_read_addr
);

    /*                              Internal Signals                                */
    reg         [NB_DATA-1   : 0]           rom [ROM_DEPTH-1 : 0];

    /*                              Alu algorithm begins                            */
    initial
        $readmemb(FILE, rom, 0, ROM_DEPTH-1);
    
    //Module outputs: reading - low latency
    assign                              o_data = rom[i_read_addr];

endmodule