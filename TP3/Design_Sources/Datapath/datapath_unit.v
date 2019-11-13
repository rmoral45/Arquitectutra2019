`timescale 1ns/100ps
module datapath_unit
#(
    parameter                           NB_INSTRUCTION  = 16,
    parameter                           NB_ADDR         = 11,
    parameter                           NB_OPCODE       = 5,
    parameter                           NB_OPERAND      = NB_INSTRUCTION-NB_OPCODE,
    parameter                           NB_SELECTOR_A   = 2
)
(
    input wire                          i_clock,
    input wire                          i_reset,
    input wire  [NB_INSTRUCTION-1 : 0]  i_ram_data,
    input wire  [NB_OPERAND-1 : 0]      i_operand,
    input wire  [NB_SELECTOR_A-1 : 0]   i_sel_a,
    input wire                          i_sel_b,
    input wire                          i_enb_acc,
    input wire                          i_operation

    output wire [NB_ADDR-1 : 0]         o_ram_addr,  
    output wire [NB_INSTRUCTION-1 : 0]  o_ram_data
);

    wire        [NB_INSTRUCTION-1 : 0]  mux_a;
    wire        [NB_INSTRUCTION-1 : 0]  mux_b;

    assign                              mux_a   =   (i_sel_a == 2'b00) ? i_ram_data[NB_OPERAND-1 : 0] :
                                                    (i_sel_a == 2'b01) ? 

endmodule