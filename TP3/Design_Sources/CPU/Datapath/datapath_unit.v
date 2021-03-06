`timescale 1ns/100ps
module datapath_unit
#(
    parameter                           NB_INSTRUCTION      = 16,
    parameter                           NB_ADDR             = 11,
    parameter                           NB_OPCODE           = 5,
    parameter                           NB_OPERAND          = NB_INSTRUCTION-NB_OPCODE,
    parameter                           NB_SELECTOR_A       = 2
)
(
    input wire                          i_clock,
    input wire                          i_reset,
    input wire  [NB_INSTRUCTION-1 : 0]  i_ram_data,
    input wire  [NB_OPERAND-1 : 0]      i_operand,
    input wire  [NB_SELECTOR_A-1 : 0]   i_sel_a,
    input wire                          i_sel_b,
    input wire                          i_enb_acc,
    input wire                          i_operation,

    output wire [NB_INSTRUCTION-1 : 0]  o_ram_data
);

    localparam                          ADD                 = 1'b1;
    localparam                          SUB                 = 1'b0;

    reg         [NB_INSTRUCTION-1 : 0]  accumulator;
    reg         [NB_INSTRUCTION-1 : 0]  adder_result;   

    wire        [NB_INSTRUCTION-1 : 0]  mux_a;
    wire        [NB_INSTRUCTION-1 : 0]  mux_b;
    wire        [NB_INSTRUCTION-1 : 0]  signal_extension;
    
    
    wire        [NB_OPCODE-1 : 0]       sign;


    //generate for extend the sign
    genvar i;
    for(i=0; i<NB_OPCODE; i=i+1)
    begin: ger_sign_extension
        assign sign[i] = i_operand[NB_OPERAND-1];
    end
    //end of generate

    assign                              o_ram_data          =   accumulator;   

    assign                              signal_extension    =   {{sign, i_operand}};
    
    assign                              mux_b               =   (!i_sel_b)  ? signal_extension : i_ram_data;

    always @(posedge i_clock)
    begin
        if(i_reset)
            accumulator <= {NB_INSTRUCTION{1'b0}};
        else if(i_enb_acc)
        begin
            if(i_sel_a == 2'b00)
                accumulator <= i_ram_data;
            else if(i_sel_a == 2'b01)
                accumulator <= signal_extension;
            else if(i_sel_a == 2'b10)
                accumulator <= adder_result;
            else
                accumulator <= accumulator;
        end
    end       

    always @ *
    begin

        adder_result = {NB_INSTRUCTION{1'b0}};

        case(i_operation)

            ADD:
                adder_result = accumulator + mux_b;

            SUB:    
                adder_result = accumulator - mux_b;

            default:
                adder_result = adder_result;
        
        endcase
    end

endmodule