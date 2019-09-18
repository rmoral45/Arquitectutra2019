`timescale 1ns/100ps

module toplevel_alu
#(
    parameter                               NB_DATA_BUS = 8,
    parameter                               NB_DBG_LED  = 3,
    parameter                               NB_OPCODE   = 6

)
(
    input wire                              i_clock,
    input wire                              i_valid,
    input wire      [NB_DATA_BUS-1 : 0]     i_switch,
    input wire                              i_btnL,                 // button 1st_ope
    input wire                              i_btnC,                 // button 2nd_ope
    input wire                              i_btnR,                 // button opcode
    input wire                              i_btnU,                 // reset button
    output wire     [NB_DATA_BUS-1 : 0]     o_led,
    output wire     [NB_DBG_LED-1 : 0]      o_led_dbg
);

    reg                                     latch_first_operator;
    reg                                     latch_second_operator;
    reg                                     latch_opcode;
    reg             [NB_DATA_BUS-1 : 0]     reg_first_operator;
    reg             [NB_DATA_BUS-1 : 0]     reg_second_operator;
    reg             [NB_OPCODE-1 : 0]       reg_opcode;
    reg                                     led_first_operator;
    reg                                     led_second_operator;
    reg                                     led_opcode;

    wire                                    reset;
    wire                                    save_first_operator;
    wire                                    save_second_operator;
    wire                                    save_opcode;
    wire            [NB_DATA_BUS-1 : 0]     first_operator;
    wire            [NB_DATA_BUS-1 : 0]     second_operator;
    wire            [NB_OPCODE-1 : 0]       opcode;
    wire            [NB_DATA_BUS-1 : 0]     result;
    
    assign                                  save_first_operator     = (latch_first_operator == 0 && i_btnL == 1)    ? 1 : 0;
    assign                                  save_second_operator    = (latch_second_operator == 0 && i_btnC == 1)   ? 1 : 0;
    assign                                  save_opcode             = (latch_opcode == 0 && i_btnR == 1)            ? 1 : 0;
    assign                                  reset                   = i_btnU;
    assign                                  first_operator          = reg_first_operator;
    assign                                  second_operator         = reg_second_operator;
    assign                                  opcode                  = reg_opcode;
    assign                                  o_led                   = result;
    assign                                  o_led_dbg               = {led_first_operator, led_second_operator, led_opcode};

//always for 1st operator and debug signal
    always @ (posedge i_clock)
    begin
        
        latch_first_operator        <= i_btnL;

        if(reset)
        begin
            led_first_operator      <= 1'b0;
            reg_first_operator      <= {NB_DATA_BUS{1'b0}};
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

        if(reset)
        begin
            led_second_operator     <= 1'b0;
            reg_second_operator     <= {NB_DATA_BUS{1'b0}};
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

        if(reset)
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
    .NB_DATA_BUS(NB_DATA_BUS),
    .NB_OPCODE(NB_OPCODE)
    )
u_alu
    (
    .i_valid(i_valid),
    .i_first_operator(first_operator),
    .i_second_operator(second_operator),
    .i_opcode(opcode),
    .o_result(result)
    );

endmodule