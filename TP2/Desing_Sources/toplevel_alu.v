`timescale 1ns/100ps

module toplevel_alu
#(
    parameter                               NB_DATA     = 8,
    parameter                               NB_OPCODE   = 6,
    parameter                               NB_DBG_LED  = 3,
    parameter                               N_INPUTS    = 3
)
(
    input wire                              i_clock,
    input wire                              i_reset,
    input wire                              i_valid,
    input wire      [NB_DATA-1 : 0]         i_first_operator,
    input wire      [NB_DATA-1 : 0]         i_second_operator,
    input wire      [NB_OPCODE-1 : 0]       i_opcode,
    output wire     [NB_DATA-1 : 0]         o_led,
    output wire                             o_valid,    
    output wire     [NB_DBG_LED-1 : 0]      o_dbg_alu
);

    reg             [NB_DATA-1 : 0]         reg_first_operator;
    reg             [NB_DATA-1 : 0]         reg_second_operator;
    reg             [NB_OPCODE-1 : 0]       reg_opcode;
    reg                                     led_first_operator;
    reg                                     led_second_operator;
    reg                                     led_opcode;

    wire            [NB_DATA-1 : 0]         first_operator;
    wire            [NB_DATA-1 : 0]         second_operator;
    wire            [NB_OPCODE-1 : 0]       opcode;
    wire            [NB_DATA-1 : 0]         result;
    

    assign                                  first_operator          = reg_first_operator;
    assign                                  second_operator         = reg_second_operator;
    assign                                  opcode                  = reg_opcode;
    assign                                  o_led                   = result;
    assign                                  o_dbg_alu               = {led_first_operator, led_second_operator, led_opcode};

//always for 1st operator and debug signal
    always @ (posedge i_clock)
    begin
        
        if(i_reset)
        begin
            led_first_operator      <= 1'b0;
            reg_first_operator      <= {NB_DATA{1'b0}};
        end
        else if(save_first_operator)
        begin
            led_first_operator      <= 1'b1;
            reg_first_operator      <= i_switch;
        end
        else
        begin
            led_first_operator      <= led_first_operator;
            reg_first_operator      <= reg_first_operator;
        end
    end

    //always for 2nd operator
    always @(posedge i_clock) 
    begin

        latch_second_operator       <= i_btnC;

        if(i_reset)
        begin
            led_second_operator     <= 1'b0;
            reg_second_operator     <= {NB_DATA{1'b0}};
        end
        else if(save_second_operator)
        begin
            led_second_operator     <= 1'b1;
            reg_second_operator     <= i_switch;
        end
        else
        begin
            led_second_operator     <= led_second_operator;
            reg_second_operator     <= reg_second_operator;  
        end
    end

    //always for opcode
    always @(posedge i_clock)
    begin

        latch_opcode                <= i_btnR;

        if(i_reset)
        begin
            led_opcode              <= 1'b0;
            reg_opcode              <= {NB_OPCODE{1'b0}};
        end
        else if(save_opcode)
        begin
            led_opcode              <= 1'b1;
            reg_opcode              <= i_switch [NB_OPCODE-1 : 0];
        end
        else
            led_opcode              <= led_opcode;    
            reg_opcode              <= reg_opcode;
    end

alu#(
    .NB_DATA(NB_DATA),
    .NB_OPCODE(NB_OPCODE)
    )
u_alu
    (
    .i_valid(i_valid),
    .i_first_operator(first_operator),
    .i_second_operator(second_operator),
    .i_opcode(opcode),
    .o_result(result),
    .o_valid(o_valid)
    );

endmodule