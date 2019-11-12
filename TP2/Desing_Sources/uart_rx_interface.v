`timescale 1ns/100ps

module uart_interface
#(
    parameter                           NB_DATA         = 8,
    parameter                           NB_OPCODE       = 6,
    parameter                           N_INPUTS        = 3
)
(
    input wire                          i_clock,
    input wire                          i_reset,
    input wire  [NB_DATA-1 : 0]         i_uart_data,
    input wire                          i_uart_data_valid,

    output wire [N_INPUTS-1 : 0]        o_dbg_uart,
    output wire                         o_tx_start,
    output wire [NB_DATA-1 : 0]         o_first_operator,
    output wire [NB_DATA-1 : 0]         o_second_operator,
    output wire [NB_OPCODE-1 : 0]       o_opcode
    );
  

    localparam                          NB_STATES               = 3;
    localparam  [NB_STATES-1 : 0]       SAVE_FIRST_OPERATOR     = 3'b001;
    localparam  [NB_STATES-1 : 0]       SAVE_SECOND_OPERATOR    = 3'b010;
    localparam  [NB_STATES-1 : 0]       SAVE_OPCODE             = 3'b100;

    reg         [NB_STATES-1 : 0]       state_alu_fsm;
    reg         [NB_STATES-1 : 0]       state_alu_fsm_next;
    reg         [NB_DATA-1 : 0]         first_operator;
    reg         [NB_DATA-1 : 0]         second_operator;    
    reg         [NB_OPCODE-1 : 0]       opcode;

    reg                                 save_first_operator;
    reg                                 save_second_operator;
    reg                                 save_opcode;

    reg                                 tx_start;
    reg                                 tx_start_next;

    reg         [NB_DATA-1 : 0]         uart_rx_data;

//Interface to ALU
    assign                              o_first_operator        = first_operator;
    assign                              o_second_operator       = second_operator;
    assign                              o_opcode                = opcode;
    assign                              o_dbg_uart              = state_alu_fsm;
    assign                              o_tx_start              = tx_start;         

    always @(posedge i_clock)
    begin
        
        if(i_reset)
        begin
            state_alu_fsm   <=  SAVE_FIRST_OPERATOR;
        end
        else
        begin
            state_alu_fsm   <=  state_alu_fsm_next;
        end
    
    end

    always @(posedge i_clock)
    begin
        if(i_reset)
            first_operator  <=  {NB_DATA{1'b0}};
        else if(save_first_operator)
            first_operator <= i_uart_data;
    end

    always @(posedge i_clock)
    begin
        if(i_reset)
            second_operator  <=  {NB_DATA{1'b0}};
        else if(save_second_operator)
            second_operator <= i_uart_data;
    end

    always @(posedge i_clock)
    begin
        if(i_reset)
            opcode  <= {NB_OPCODE{1'b0}};
        else if(save_opcode)
            opcode <= i_uart_data[NB_OPCODE-1 : 0];
    end

    always @(posedge i_clock)
    begin
        if(i_reset)
            tx_start    <= 1'b0;
        else 
            tx_start    <= tx_start_next;
    end

    always @(*)
    begin

        state_alu_fsm_next  = state_alu_fsm;
        save_first_operator = 1'b0;
        save_second_operator = 1'b0;
        save_opcode = 1'b0;
        tx_start_next = 1'b0;

        case (state_alu_fsm)

            SAVE_FIRST_OPERATOR:
            begin
                if(i_uart_data_valid)
                begin
                    state_alu_fsm_next  = SAVE_SECOND_OPERATOR;
                    save_first_operator = 1'b1;
                end
            end

            SAVE_SECOND_OPERATOR:
            begin
                if(i_uart_data_valid)
                begin
                    state_alu_fsm_next  = SAVE_OPCODE;
                    save_second_operator = 1'b1;
                end
            end

            SAVE_OPCODE:
            begin
                if(i_uart_data_valid)
                begin
                    state_alu_fsm_next  = SAVE_FIRST_OPERATOR;
                    save_opcode         = 1'b1;
                    tx_start_next = 1'b1;
                end
            end

            default:
            begin
                state_alu_fsm_next      =  SAVE_FIRST_OPERATOR;
            end
        endcase
    end
//End of interface to ALU

endmodule

