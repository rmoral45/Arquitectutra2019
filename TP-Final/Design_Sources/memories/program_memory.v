`timescale 1ns/100ps
module program_memory
#(
    parameter                               NB_ADDR         = 32,
    parameter                               NB_ADDR_CUSTOM  =  5,
    parameter                               NB_DATA         = 32,
    parameter                               ROM_DEPTH       = 30,
    parameter                               FILE            = ""
)
(   
    //Outputs
    output wire [NB_DATA-1          : 0]    o_data,

    //Inputs
    input wire                              i_wr_enable,
    input wire  [NB_ADDR_CUSTOM-1   : 0]    i_wr_addr,
    input wire  [NB_DATA-1          : 0]    i_data,
    input wire  [NB_ADDR-1          : 0]    i_read_addr,
    
    //Clocking
    input wire                              i_clock
);

    /*                              Internal Signals                                */
    reg         [NB_DATA-1   : 0]           rom [ROM_DEPTH-1 : 0];

    /*                              Alu algorithm begins                            */
    always @ (posedge i_clock)
    begin
        if(i_wr_enable)
        begin
            rom[i_wr_addr] <= i_data;
        end
    end
    
    /*initial
        $readmemb(FILE, rom, 0, ROM_DEPTH-1);*/
    
    //Module outputs: reading - low latency
    assign                              o_data = rom[i_read_addr];

endmodule