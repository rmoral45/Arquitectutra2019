`timescale 1ns/100ps
module register_file
#(
    parameter                       NB_ADDR         = 5,
    parameter                       NB_DATA         = 2**NB_ADDR,
    parameter                       RAM_DEPTH       = 2**NB_ADDR
)
(
    //Outputs
    output  wire    [NB_DATA-1 : 0] o_data_a,
    output  wire    [NB_DATA-1 : 0] o_data_b,

    //Inputs
    input   wire                    i_clock,
    input   wire                    i_write_enable,
    input   wire    [NB_ADDR-1 : 0] i_write_addr,
    input   wire    [NB_ADDR-1 : 0] i_read_addr_a,
    input   wire    [NB_ADDR-1 : 0] i_read_addr_b,
    input   wire    [NB_DATA-1 : 0] i_data
);
    /*                              Internal Signals                                */
    reg             [NB_DATA-1 : 0] register_file [RAM_DEPTH-1 : 0];

    /*                              Alu algorithm begins                            */  
    always @(posedge i_clock)
    begin
        if(i_write_enable)
            register_file[i_write_addr]             <= i_data;
    end   

    //Module outputs: reading - low latency
    assign                      o_data_a            = register_file[i_read_addr_a];
    assign                      o_data_b            = register_file[i_read_addr_b];
    
 endmodule