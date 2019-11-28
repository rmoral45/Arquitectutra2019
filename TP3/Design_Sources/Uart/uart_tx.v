`timescale 1ns/100ps

module uart_tx
#(
    parameter                               NB_DATA             = 8,
    parameter                               NB_STOP             = 1,
    parameter                               BAUD_RATE           = 9600,
    parameter                               SYS_CLOCK           = 100000000,
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
    output wire                             o_data
);

    localparam                              N_STATES            = 4;
    localparam                              N_TICKS             = 16;
    localparam                              N_STOP_TICKS        = NB_STOP*N_TICKS;
    localparam                              NB_MIDDLE_START_BIT = 7;
    localparam                              NB_MIDDLE_DATA_BIT  = 15;
    //states
    localparam      [N_STATES-1 : 0]        IDLE                = 4'b0001;
    localparam      [N_STATES-1 : 0]        START               = 4'b0010;
    localparam      [N_STATES-1 : 0]        SEND                = 4'b0100;
    localparam      [N_STATES-1 : 0]        STOP                = 4'b1000;

    reg             [N_STATES-1 : 0]        state;
    reg             [N_STATES-1 : 0]        state_next;
    reg             [NB_TICK_COUNTER-1 : 0] tick_counter;
    reg                                     reset_tick_counter;
    
    reg             [NB_DATA-1 : 0]         data;
    reg             [NB_DATA-1 : 0]         data_next;
    reg             [NB_DATA_COUNTER-1 : 0] data_bit_counter;
    reg                                     reset_data_counter;
    reg                                     inc_data_counter;

    reg                                     tx;
    reg                                     tx_next;
    
    reg                                     flag;

    assign                                  o_data  = tx;
    
   

    always @(posedge i_clock)
    begin
        
        if(i_reset)
        begin
            state                   <=  IDLE;
            data                    <=  {NB_DATA{1'b1}};
            tx                      <=  1'b1;
        end
        else
        begin
            state                   <=  state_next;
            data                    <=  data_next;
            tx                      <=  tx_next;
        end
    end

    always @ (posedge i_clock)
    begin
        if(i_reset || reset_tick_counter)
            tick_counter            <=  {NB_TICK_COUNTER{1'b0}};
        else if(i_tick)
            tick_counter            <=  tick_counter + 1;
    end

    always @ (posedge i_clock)
    begin
        if(i_reset || reset_data_counter)
            data_bit_counter        <= {NB_DATA_COUNTER{1'b0}};
        else if(inc_data_counter)
            data_bit_counter        <= data_bit_counter + 1;      
    end

    always @(*)
    begin
            state_next                              = state;
            reset_tick_counter                      = 1'b0;
            data_next                               = data;
            reset_data_counter                      = 1'b0;
            inc_data_counter                        = 1'b0;  
            tx_next                                 = tx;

        case (state)

            IDLE:
            begin
                tx_next                             = 1'b1;            //linea idle en 1
                if(i_start)
                begin
                    state_next                      = START;
                    reset_tick_counter              = 1'b1;
                    data_next                       = i_data;
                end
            end

            START:
            begin 
                tx_next                             = 1'b0;                 
                if(tick_counter == N_TICKS-1)
                begin
                    reset_data_counter              = 1'b1;
                    state_next                      = SEND;
                    reset_tick_counter              = 1'b1;
                end
            end

            SEND:
            begin
                tx_next                             = data[0];
                if(tick_counter ==  N_TICKS-1)
                begin
                    data_next                       = data >> 1;
                    reset_tick_counter              = 1'b1;

                    if(data_bit_counter == NB_DATA-1)
                    begin
                        state_next                  = STOP;
                        reset_data_counter          = 1'b0;
                    end
                    else
                        inc_data_counter            = 1'b1;
                end
            end

            STOP:
            begin
                data_next                           = 1'b1;
                if(tick_counter == N_STOP_TICKS-1)
                begin
                    state_next                      = IDLE;
                end
            end

            default:
            begin
                state_next                          = IDLE;
                reset_data_counter                  = 1'b1;   
            end
        endcase
    end

endmodule
