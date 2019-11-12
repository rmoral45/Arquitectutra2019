`timescale 1ns/100ps

module baudrate_generator
#(
    parameter                   BAUD_RATE       = 9600,
    parameter                   SYS_CLOCK       = 100000000, 
    parameter                   TICK_RATE       = SYS_CLOCK / (BAUD_RATE*16),
    parameter                   NB_TICK_COUNTER = $clog2(TICK_RATE)                  
)
(
    input wire                  i_clock,
    input wire                  i_reset,
    output wire                 o_tick
);

    reg [NB_TICK_COUNTER-1 : 0] counter;
    wire                        reset_counter = (counter == TICK_RATE-1) ? 1'b1 : 1'b0; 
    //cuando se resetea el contador, genero el tick
    assign                      o_tick        = reset_counter;

    always @(posedge i_clock)
    begin

        if(i_reset)
            counter <= {NB_TICK_COUNTER{1'b0}};

        else if(reset_counter)
            counter <= {NB_TICK_COUNTER{1'b0}};

        else
            counter <= counter + 1;    

    end

endmodule