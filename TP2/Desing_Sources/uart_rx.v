`timescale 1ns/100ps

module uart_rx
#(
    parameter                               NB_DATA             = 8,
    parameter                               NB_STOP             = 1,
    parameter                               BAUD_RATE           = 9600
    parameter                               SYS_CLOCK           = 100**6,
    parameter                               TICK_RATE           = SYS_CLOCK / (BAUD_RATE*16),
    parameter                               NB_TICK_COUNTER     = $clog2(TICK_RATE),
    parameter                               NB_DATA_COUNTER     = $clog2(NB_DATA)                  
)
(
    input wire                              i_clock,
    input wire                              i_reset,
    input wire                              i_tick,
    input wire                              i_rx,
//    input wire                              i_data_valid_from_alu,        
    output reg                              o_data_valid,
    output wire     [NB_DATA-1 : 0]         o_data
);

    localparam                              N_STATES            = 4;
    localparam                              N_TICKS             = 16;
    localparam                              N_STOP_TICKS        = NB_STOP*N_TICKS;
    localparam                              NB_MIDDLE_START_BIT = 7
    localparam                              NB_MIDDLE_DATA_BIT  = 15
    //states
    localparam      [N_STATES-1 : 0]        IDLE                = 4'b0001;
    localparam      [N_STATES-1 : 0]        START               = 4'b0010;
    localparam      [N_STATES-1 : 0]        RECV                = 4'b0100;
    localparam      [N_STATES-1 : 0]        STOP                = 4'b1000;

    reg             [N_STATES-1 : 0]        state;
    reg             [N_STATES-1 : 0]        state_next;
    reg             [NB_TICK_COUNTER-1 : 0] tick_counter;
    reg             [NB_TICK_COUNTER-1 : 0] tick_counter_next;
    reg             [NB_DATA-1 : 0]         data;
    reg             [NB_DATA-1 : 0]         data_next;
    reg             [NB_DATA_COUNTER-1 : 0] data_bit_counter;
    reg             [NB_DATA_COUNTER-1 : 0] data_bit_counter_next;

    assign                                  o_data              = data;

    always @(posedge i_clock)
    begin
        
        if(i_reset)
        begin
            state               <= IDLE;
            data                <= {NB_DATA{1'b0}};
            data_bit_counter    <= {NB_DATA_COUNTER{1'b0}};
            tick_counter        <= {NB_TICK_COUNTER{1'b0}};
        end
        else
        begin
            state               <= state_next;
            data                <= data_next;
            data_bit_counter    <= data_bit_counter_next;
            tick_counter        <= tick_counter_next;
        end
    end

    always *
    begin

        state_next                                  = state;
        data_next                                   = data;
        data_bit_counter_next                       = data_bit_counter;
        tick_counter_next                           = tick_counter;
        o_data_valid                                = 1'b0;

        case state:

            IDLE:
            begin

                if(~i_rx)
                begin
                    state_next                      = START;
                    tick_counter_next               = {NB_TICK_COUNTER{1'b0}};
                end
            end

            START:
            begin
                
                if(i_tick)
                begin

                    if(tick_counter == NB_MIDDLE_START_BIT)
                    begin
                        state_next                  = RECV;
                        tick_counter_next           = {NB_TICK_COUNTER{1'b0}};
                        data_bit_counter_next       = {NB_DATA_COUNTER{1'b0}};
                    end
                    else
                        tick_counter_next           = tick_counter + 1;
                end
            end

            RECV:
            begin
                if(i_tick)
                begin
                    if(tick_counter == NB_MIDDLE_DATA_BIT)
                    begin
                        data                        = {i_rx, data[NB_DATA-1 : 1]};
                        tick_counter_next           = {NB_TICK_COUNTER{1'b0}};
                        
                        if(data_bit_counter == NB_DATA-1)
                        begin
                            state_next              = STOP;
                        end
                        else
                            data_bit_counter_next   = data_bit_counter + 1;
                    end
                    else
                        tick_counter_next           = tick_counter + 1;
                end
            end

            STOP:
            begin
                if(i_tick)
                begin
                    if(tick_counter == N_STOP_TICKS-1)
                    begin
                        state_next                  = IDLE;
                        o_data_valid                = 1'b1;
                    end
                    else
                        tick_counter_next           = tick_counter + 1;
                end
            end

            default:
            begin
                state_next                          = IDLE;
                data_bit_counter                    = {NB_DATA_COUNTER{1'b0}};
                tick_counter_next                   = {NB_TICK_COUNTER{1'b0}};
                data                                = {NB_DATA{1'b0}};
            end
        endcase
    end