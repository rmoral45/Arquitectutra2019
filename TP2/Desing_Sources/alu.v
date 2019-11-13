`timescale 1ns/100ps

module alu
#(
    parameter                                       NB_DATA   = 8,
    parameter                                       NB_OPCODE = 6    
)
(
    input wire signed       [NB_DATA-1 : 0]         i_first_operator,
    input wire signed       [NB_DATA-1 : 0]         i_second_operator,
    input wire signed       [NB_OPCODE-1 : 0]       i_opcode,
    output reg signed       [NB_DATA-1 : 0]         o_result
);

    localparam              [NB_OPCODE-1 : 0]       ADD = 6'b100000;
    localparam              [NB_OPCODE-1 : 0]       SUB = 6'b100010;
    localparam              [NB_OPCODE-1 : 0]       AND = 6'b100100;
    localparam              [NB_OPCODE-1 : 0]       OR  = 6'b100101;
    localparam              [NB_OPCODE-1 : 0]       XOR = 6'b100110;
    localparam              [NB_OPCODE-1 : 0]       SRA = 6'b000011;
    localparam              [NB_OPCODE-1 : 0]       SRL = 6'b000010;
    localparam              [NB_OPCODE-1 : 0]       NOR = 6'b100111;
    
    always @ * 
    begin
        case(i_opcode)

                
                ADD: o_result = i_first_operator + i_second_operator;
                SUB: o_result = i_first_operator - i_second_operator;
                AND: o_result = i_first_operator & i_second_operator;
                OR:  o_result = i_first_operator | i_second_operator;
                XOR: o_result = i_first_operator ^ i_second_operator;
                SRA: o_result = i_first_operator >>> i_second_operator;
                SRL: o_result = i_first_operator >> i_second_operator;
                NOR: o_result = ~(i_first_operator | i_second_operator);
                
                default:
                    o_result = {NB_DATA{1'b0}};
                
            
        endcase             
    end

endmodule
