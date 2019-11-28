`timescale 1ns/100ps

module uart_rx
#(
    parameter                               NB_DATA             = 8,
    parameter                               NB_STOP             = 1,
    parameter                               BAUD_RATE           = 9600,
    parameter                               SYS_CLOCK           = 100*(10**6),
    parameter                               TICK_RATE           = SYS_CLOCK / (BAUD_RATE*16),
    parameter                               NB_TICK_COUNTER     = $clog2(TICK_RATE),
    parameter                               NB_DATA_COUNTER     = $clog2(NB_DATA)                  
)
(
    input wire                              i_clock,
    input wire                              i_reset,
    input wire                              i_tick,
    input wire                              i_rx,
    
    output reg                              o_data_valid,
    output wire     [NB_DATA-1 : 0]         o_data
);

    localparam                              N_STATES            = 4;
    localparam                              N_TICKS             = 16;
    localparam                              N_STOP_TICKS        = NB_STOP*N_TICKS;
    localparam                              NB_MIDDLE_START_BIT = 7;
    localparam                              NB_MIDDLE_DATA_BIT  = 16;
    //states
    localparam      [N_STATES-1 : 0]        IDLE                = 4'b0001;
    localparam      [N_STATES-1 : 0]        START               = 4'b0010;
    localparam      [N_STATES-1 : 0]        RECV                = 4'b0100;
    localparam      [N_STATES-1 : 0]        STOP                = 4'b1000;

    reg             [N_STATES-1 : 0]        state;
    reg             [N_STATES-1 : 0]        state_next;

    reg                                     reset_tick_counter;
    reg             [NB_TICK_COUNTER-1 : 0] tick_counter;


    reg                                     reset_data_counter;
    reg                                     inc_data_counter;
    reg             [NB_DATA-1 : 0]         data;
    reg             [NB_DATA-1 : 0]         data_next;
    reg             [NB_DATA_COUNTER-1 : 0] data_bit_counter;
  

    assign                                  o_data              = data;

    always @(posedge i_clock)
    begin
        if(i_reset)
        begin
            state               <= IDLE;
            data                <= {NB_DATA{1'b0}};
        end
        else
        begin
            state               <= state_next;
            data                <= data_next;
        end
    end

    always @ (posedge i_clock)
    begin
        if (i_reset || reset_tick_counter)
            tick_counter <= {NB_TICK_COUNTER{1'b0}};
        else if (i_tick)
            tick_counter <= tick_counter + 1;
    end

    always @ (posedge i_clock)
    begin
        if (i_reset || reset_data_counter)
            data_bit_counter <= {NB_DATA_COUNTER{1'b0}};
        else if(inc_data_counter)
            data_bit_counter <= data_bit_counter + 1;
    end

    always @(*)
    begin

        state_next                                  = state;
        data_next                                   = data;
        reset_tick_counter                          = 1'b0;
        reset_data_counter                          = 1'b0;
        inc_data_counter                            = 1'b0;
        o_data_valid                                = 1'b0;

        case (state)

            IDLE:
            begin

                if(~i_rx)
                begin
                    state_next                      = START;
                    reset_tick_counter              = 1'b1;
                end
            end

            START:
            begin
                if(tick_counter == NB_MIDDLE_START_BIT)
                begin
                    state_next                  = RECV;
                    reset_tick_counter          = 1'b1;
                    reset_data_counter          = 1'b1;
                end         
            end

            RECV:
            begin
                if(tick_counter == NB_MIDDLE_DATA_BIT)
                begin
                    data_next                   = {i_rx, data[NB_DATA-1 : 1]};
                    reset_tick_counter          = 1'b1;
                    inc_data_counter            = 1'b1;

                    if(data_bit_counter == NB_DATA-1)
                    begin
                        state_next              = STOP;
                        reset_data_counter      = 1'b1;

                    end
                end
            end

            STOP:
            begin
                if(tick_counter == N_STOP_TICKS-1)
                begin
                    state_next                  = IDLE;
                    o_data_valid                = 1'b1;
                end
            end

            default:
            begin
                state_next                          = IDLE;
                data_next                           = {NB_DATA{1'b0}};
            end
        endcase
    end
    
    endmodule