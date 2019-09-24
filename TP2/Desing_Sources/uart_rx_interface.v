`timescale 1ns/100ps


module uart_rx_interface
#(
    parameter                           NB_DATA         = 8,
    parameter                           NB_OPCODE       = 6,
    parameter                           N_POSIBILITIES  = 3
)
(
    input wire                          i_clock,
    input wire                          i_reset,
    input wire  [NB_DATA-1 : 0]         i_uart_rx_data,
    input wire                          i_uart_rx_data_valid,
    input wire  [NB_DATA-1 : 0]         i_alu_data,
    input wire                          i_alu_data_valid

    output wire [NB_DATA-1 : 0]         o_uart_rx_data,
    output wire                         o_uart_rx_data_valid;       
    output wire [NB_DATA-1 : 0]         o_first_operator,
    output wire [NB_DATA-1 : 0]         o_second_operator,
    output wire [NB_OPCODE-1 : 0]       o_opcode,
    output wire                         o_data_valid_alu      //data_valid to alu
);
  

    localparam                          NB_STATES               = 3
    localparam  [NB_STATES-1 : 0]       SAVE_FIRST_OPERATOR     = 3'b001;
    localparam  [NB_STATES-1 : 0]       SAVE_SECOND_OPERATOR    = 3'b010;
    localparam  [NB_STATES-1 : 0]       SAVE_OPCODE             = 3'b100;

    reg         [NB_STATES-1 : 0]       state_alu_fsm;
    reg         [NB_STATES-1 : 0]       state_alu_fsm_next;
    reg         [NB_DATA-1 : 0]         first_operator;
    reg         [NB_DATA-1 : 0]         second_operator;    
    reg         [NB_OPCODE-1 : 0]       opcode;
    reg                                 data_valid_alu;
    reg                                 data_valid_alu_next;

    reg         [NB_DATA-1 : 0]         uart_rx_data;

//Interface to ALU
    assign                              o_first_operator        = first_operator;
    assign                              o_second_operator       = second_operator:
    assign                              o_opcode                = opcode;
    assign                              o_data_valid_alu        = data_valid_alu;                

    always @(posedge i_clock)
    begin
        
        if(i_reset)
        begin
            state_alu_fsm   <=  SAVE_FIRST_OPERATOR;
            first_operator  <=  {NB_DATA{1'b0}};
            second_operator <=  {NB_DATA{1'b0}};
            opcode          <=  {NB_OPCODE{1'b0}};
            data_valid_alu  <=  1'b0;
        end
        else
        begin
            state_alu_fsm   <=  state_alu_fsm_next;
            data_valid_alu  <=  data_valid_alu_next;
        end
    
    end

    always *
    begin

        state_alu_fsm_next  = state_alu_fsm;
        data_valid_alu_next = 1'b0;

        case state:

            SAVE_FIRST_OPERATOR:
            begin
                if(i_uart_rx_data_valid):
                begin
                    state_alu_fsm_next  = SAVE_SECOND_OPERATOR;
                    first_operator      = i_uart_rx_data;
                    data_valid_alu_next = 1'b1;
                end
            end

            SAVE_SECOND_OPERATOR:
            begin
                if(i_uart_rx_data_valid):
                begin
                    state_alu_fsm_next  = SAVE_OPCODE;
                    second_operator     = i_uart_rx_data;
                    data_valid_alu_next = 1'b1;
                end
            end

            SAVE_OPCODE:
            begin
                if(i_uart_rx_data_valid):
                begin
                    state_alu_fsm_next  = SAVE_FIRST_OPERATOR;
                    opcode              = i_uart_rx_data;
                    data_valid_alu_next = 1'b1;
                end
            end

            default:
            begin
                state_alu_fsm_next      = SAVE_FIRST_OPERATOR;
                first_operator          =  {NB_DATA{1'b0}};
                second_operator         =  {NB_DATA{1'b0}};
                opcode                  =  {NB_OPCODE{1'b0}};                
            end
        endcase
    end
//End of interface to ALU

//Interface to uart_rx
    always *
    begin
        
        if(i_alu_data_valid)
        begin
            o_uart_rx_data          = i_alu_data;
            o_uart_rx_data_valid    = 1'b1;
        end
        else
        begin
            o_uart_rx_data          = {NB_DATA{1'b0}};
            o_uart_rx_data_valid    = 1'b0;
        end
    end
//End of interface to uart_rx

endmodule

