`timescale 1ns/100ps

module forwarding_unit
#(
    parameter                           NB_ADDR                 = 5,
    parameter                           NB_DATA                 = 2**NB_ADDR,
    parameter                           NB_MUX_SEL              = 2
)
(
    //Outputs
    output wire [NB_MUX_SEL-1   : 0]    o_mux_first_operator,
    output wire [NB_MUX_SEL-1   : 0]    o_mux_second_operator,
    //Inputs
    input wire  [NB_ADDR-1      : 0]    i_rf_rs_from_id_unit,
    input wire  [NB_ADDR-1      : 0]    i_rf_rt_from_id_unit,
    input wire  [NB_ADDR-1      : 0]    i_rf_rd_from_ex_unit,
    input wire  [NB_ADDR-1      : 0]    i_rf_rd_from_mem_unit,
    input wire                          i_rf_wr_enb_from_ex_unit,
    input wire                          i_rf_wr_enb_from_mem_unit
);

    localparam                          FORWARD_EX_HZRD         = 2'b10;
    localparam                          FORWARD_MEM_HZRD        = 2'b01;
    localparam                          DEFAULT_SEL_VALUE       = 2'b00;

    reg         [NB_MUX_SEL-1   : 0]    mux_a;
    reg         [NB_MUX_SEL-1   : 0]    mux_b;

    always @ (*)
    begin
        if(i_rf_wr_enb_from_ex_unit & (i_rf_rd_from_ex_unit == i_rf_rs_from_id_unit))
            mux_a = FORWARD_EX_HZRD;
        else if((i_rf_wr_enb_from_mem_unit & (i_rf_rd_from_mem_unit == i_rf_rs_from_id_unit)) & (!i_rf_wr_enb_from_ex_unit | i_rf_rd_from_ex_unit != i_rf_rs_from_id_unit))
            mux_a = FORWARD_MEM_HZRD;
        else
            mux_a = DEFAULT_SEL_VALUE;
        

        if(i_rf_wr_enb_from_ex_unit & (i_rf_rd_from_ex_unit == i_rf_rt_from_id_unit))
            mux_b = FORWARD_EX_HZRD;
        else if((i_rf_wr_enb_from_mem_unit & (i_rf_rd_from_mem_unit == i_rf_rt_from_id_unit)) & (!i_rf_wr_enb_from_ex_unit | (i_rf_rd_from_ex_unit != i_rf_rt_from_id_unit)))
            mux_b = FORWARD_MEM_HZRD;
        else
            mux_b = DEFAULT_SEL_VALUE;            
    end

    //Outputs assignment
    assign                              o_mux_first_operator    = mux_a;
    assign                              o_mux_second_operator   = mux_b;

endmodule