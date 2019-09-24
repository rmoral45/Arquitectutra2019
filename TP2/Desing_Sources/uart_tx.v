`timescale 1ns/100ps

module uart_tx
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
    input wire      [NB_DATA-1 : 0]         i_data,
    input wire                              i_start,
    output wire                             o_data,
    output wire                             o_data_valid
);

    localparam                              N_STATES            = 4;
    localparam                              N_TICKS             = 16;
    localparam                              N_STOP_TICKS        = NB_STOP*N_TICKS;
    localparam                              NB_MIDDLE_START_BIT = 7
    localparam                              NB_MIDDLE_DATA_BIT  = 15
    //states
    localparam      [N_STATES-1 : 0]        IDLE                = 4'b0001;
    localparam      [N_STATES-1 : 0]        START               = 4'b0010;
    localparam      [N_STATES-1 : 0]        SEND                = 4'b0100;
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
            state                   <=  IDLE;
            tick_counter            <=  {NB_TICK_COUNTER{1'b0}};
            data                    <=  {NB_DATA{1'b0}};
            data_bit_counter        <=  {NB_DATA_COUNTER{1'b0}};
        end
        else
        begin
            state                   <=  state_next;
            tick_counter            <=  tick_counter_next;
            data                    <=  data_next;
            data_bit_counter        <=  data_bit_counter_next;
        end
    end

    always *
    begin

            state_next                              =   state;
            tick_counter_next                       =   tick_counter;
            data_next                               =   data;
            data_bit_counter_next                   =   data_bit_counter;
            o_data_valid                            =   1'b0;

        case state:

            IDLE:
            begin
            
                tx_next                             = 1'b1;
                if(i_start)
                begin
                    state_next                      = START;
                    tick_counter_next               = 0;
                    data_next                       = i_data;
                end
            end

            START:
            begin
                
                tx_next =   1'b0;
                if(i_tick)
                begin

                    if(tick_counter == N_TICKS-1)
                    begin
                        data_bit_counter_next       = 0;
                        state_next                  = SEND;
                        tick_counter_next           = 0;
                    end
                    else    
                        tick_counter_next           = tick_counter + 1;
                end
            end

            SEND:
            begin

                tx_next =   data[0];
                if(i_tick)
                begin

                    if(tick_counter ==  N_TICKS-1)
                    begin
                        data_next                   = data >> 1;
                        tick_counter_next           = 1'b0;

                        if(data_bit_counter == NB_DATA-1)
                            state_next              = STOP;
                        else
                            data_bit_counter_next   = data_bit_counter + 1;
                    
                    else
                        tick_counter_next           =   tick_counter + 1;
                    end

                end
            end

            STOP:
            begin
                
            end


    end
