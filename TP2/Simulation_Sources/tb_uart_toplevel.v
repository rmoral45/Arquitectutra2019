`timescale 1ns/100ps

module tb_uart_top_level();

localparam                      NB_DATA              =   8;
localparam                      NB_STOP              =   1;
localparam                      BAUD_RATE            =   9600;
localparam                      SYS_CLOCK            =   100*(10**6);
localparam                      TICK_RATE            =   SYS_CLOCK / (BAUD_RATE*16);
localparam                      NB_TICK_COUNTER      =   $clog2(TICK_RATE);
localparam                      NB_DATA_COUNTER      =   $clog2(NB_DATA); 
localparam                      NB_TB_COUNTER        =   20;


reg                             tb_i_clock;
reg                             tb_i_reset;
reg                             tb_i_rx;
reg     [NB_DATA-1 : 0]         tb_i_tx_data;
reg     [NB_TB_COUNTER-1 : 0]   tb_counter;
reg                             tb_i_tx_start;
wire    [NB_DATA-1 : 0]         tb_o_rx_data;
wire                            tb_o_rx_data_valid;
wire                            tb_o_tx_data;
wire                            tb_o_tx_data_valid;

initial
begin
    tb_i_clock      = 1'b0;
    tb_i_reset      = 1'b1;
    tb_i_rx         = 1'b1;      //linea rx arranca en 1 
    tb_i_tx_data    = {NB_DATA{1'b0}};
    tb_i_tx_start   = 1'b0;
    tb_counter      = {NB_TB_COUNTER{1'b0}};
#13
    tb_i_reset      = 1'b0;
end

always #1 tb_i_clock = ~tb_i_clock;

always @(posedge tb_i_clock)
begin

    tb_counter <= tb_counter+1;

    case (tb_counter)

        
        20'D10417:
            tb_i_rx = 1'b0;     //start bit

        20'D20833:
            tb_i_rx = 1'b1;     //1st bit
        20'D31249:
            tb_i_rx = 1'b0;     //2dn bit
        20'D41665:
            tb_i_rx = 1'b1;     //3rd bit
        20'D52081:
            tb_i_rx = 1'b0;     //4th bit
        20'D62497:
            tb_i_rx = 1'b1;     //5th bit
        20'D72913:
            tb_i_rx = 1'b0;     //6th bit
        20'D68401:
            tb_i_rx = 1'b1;     //7th bit
        20'D78801:
            tb_i_rx = 1'b0;     //8th bit
    endcase
    
    if(tb_o_rx_data_valid)
    begin
        tb_i_tx_data    = tb_o_rx_data;
        tb_i_tx_start   = 1'b1;
     end
end

uart_toplevel
#(
        .NB_DATA(NB_DATA),
        .NB_STOP(NB_STOP),
        .BAUD_RATE(BAUD_RATE),
        .SYS_CLOCK(SYS_CLOCK),
        .TICK_RATE(TICK_RATE),
        .NB_TICK_COUNTER(NB_TICK_COUNTER),
        .NB_DATA_COUNTER(NB_DATA_COUNTER)
)
u_tb_uart_toplevel
(
        .i_clock(tb_i_clock),
        .i_reset(tb_i_reset),
        .i_rx(tb_i_rx),
        .i_tx_data(tb_i_tx_data),
        .i_tx_start(tb_i_tx_start),
        .o_rx_data_valid(tb_o_rx_data_valid),
        .o_rx_data(tb_o_rx_data),
        .o_tx_data(tb_o_tx_data)
);

endmodule

