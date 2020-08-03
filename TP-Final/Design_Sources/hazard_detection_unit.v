`timescale 1ns/100ps

module hazard_detection_unit
#(
    parameter                       NB_ADDR     = 5,
    parameter                       NB_DATA     = 2**NB_ADDR
)
(
    //Outputs
    output wire                     o_stall,

    //Inputs
    input wire  [NB_ADDR-1  : 0]    i_rf_rs_from_id_unit,
    input wire  [NB_ADDR-1  : 0]    i_rf_rt_from_id_unit,
    input wire  [NB_ADDR-1  : 0]    i_rf_rt_from_ex_unit,
    input wire                      i_is_load_instruction

);

    //Output assignment
    assign                          o_stall     = (i_is_load_instruction & ((i_rf_rs_from_id_unit == i_rf_rt_from_ex_unit) | (i_rf_rt_from_id_unit == i_rf_rt_from_ex_unit)));

endmodule