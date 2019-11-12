`timescale 1ns/100ps

module tb_uart_rx();

localparam                  NB_DATA              =   8;
localparam                  NB_STOP              =   1;
localparam                  BAUD_RATE            =   9600;
localparam                  SYS_CLOCK            =   100*(10**6);
localparam                  TICK_RATE            =   SYS_CLOCK / (BAUD_RATE*16);
localparam                  NB_TICK_COUNTER      =   $clog2(TICK_RATE);
localparam                  NB_DATA_COUNTER      =   $clog2(NB_DATA); 
localparam                  NB_TB_COUNTER        =   20;

reg                         tb_i_clock;
reg                         tb_i_reset;
wire                        tb_tick;
reg                         tb_i_rx;
wire                        tb_o_data_valid;
wire [NB_DATA-1 : 0]        tb_o_data;
reg [NB_TB_COUNTER-1 : 0]   tb_counter;

initial
begin
    tb_i_clock      = 1'b0;
    tb_i_reset      = 1'b1;
    tb_i_rx         = 1'b1;      //linea rx arranca en 1 
    tb_counter      = {NB_TB_COUNTER{1'b0}};
#10
    tb_i_reset      = 1'b0;
end

always #2 tb_i_clock = ~tb_i_clock;

always @(posedge tb_i_clock)
begin
    
    tb_counter <= tb_counter+1;

    case (tb_counter)
        
        20'D99:
            tb_i_rx = 1'b0;     //start bit

        20'D4750:
            tb_i_rx = 1'b1;     //1st bit
        20'D16400:
            tb_i_rx = 1'b0;     //2dn bit
        20'D26800:
            tb_i_rx = 1'b1;     //3rd bit
        20'D37200:
            tb_i_rx = 1'b0;     //4th bit
        20'D47600:
            tb_i_rx = 1'b1;     //5th bit
        20'D58000:
            tb_i_rx = 1'b0;     //6th bit
        20'D68400:
            tb_i_rx = 1'b1;     //7th bit
        20'D78800:
            tb_i_rx = 1'b0;     //8th bit
    endcase
end

baudrate_generator
#(
    .BAUD_RATE(BAUD_RATE),
    .SYS_CLOCK(SYS_CLOCK),
    .TICK_RATE(TICK_RATE),
    .NB_TICK_COUNTER(NB_TICK_COUNTER)
)
u_baudrate_gen
(
    .i_clock(tb_i_clock),
    .i_reset(tb_i_reset),
    .o_tick(tb_tick)
);


uart_rx
#(
    .NB_DATA(NB_DATA),
    .NB_STOP(NB_STOP),
    .BAUD_RATE(BAUD_RATE),
    .SYS_CLOCK(SYS_CLOCK),
    .TICK_RATE(TICK_RATE),
    .NB_TICK_COUNTER(NB_TICK_COUNTER),
    .NB_DATA_COUNTER(NB_DATA_COUNTER)
)
u_uart_rx
(
    .i_clock(tb_i_clock),
    .i_reset(tb_i_reset),
    .i_tick(tb_tick),
    .i_rx(tb_i_rx),
    .o_data_valid(tb_o_data_valid),
    .o_data(tb_o_data)
);

endmodule
