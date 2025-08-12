
//--------------------------------------------------------------------------------------------------------
// Module  : TOP MODULE FOR GAMECUBE ADAPTER
// Type    : synthesizable, fpga top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: example for usb_keyboard_top
//--------------------------------------------------------------------------------------------------------

module top (
    // clock
    input  wire        clk,     // connect to a 27MHz oscillator
//	output wire 		the60clk ,
// reset button
    input  wire        button,       // connect to a reset button, 0=reset, 1=release. If you don't have a button, tie this signal to 1. 
    input wire         button2,
    // LED
    output reg [5:0] led = 6'b000000 ,// Just setting LEDs to OFF
	// USB signals
    output wire        usb_dp_pull,  // connect to USB D+ by an 1.5k resistor
    inout  wire            usb_dp,       // connect to USB D+ pin23
    inout  wire            usb_dn,       // connect to USB D- pin25
    inout  wire            lineGC1, inout  wire lineGC2, inout  wire lineGC3, inout  wire lineGC4,
    // debug output info, only for USB developers, can be ignored for normally use
    output wire        uart_tx,       // If you want to see the debug info of USB device core, please connect this UART signal to host-PC (UART format: 115200,8,n,1), otherwise you can ignore this signal.
    wire GC_poll1 , wire GC_poll2 , wire GC_poll3 , wire GC_poll4
);

wire [15:0] GCBD1; wire [15:0] GCLA1; wire [15:0] GCRA1; wire [15:0] GCTA1; 
wire [15:0] GCBD2; wire [15:0] GCLA2; wire [15:0] GCRA2; wire [15:0] GCTA2;
wire [15:0] GCBD3; wire [15:0] GCLA3; wire [15:0] GCRA3; wire [15:0] GCTA3;
wire [15:0] GCBD4; wire [15:0] GCLA4; wire [15:0] GCRA4; wire [15:0] GCTA4;

wire RUMBLE1; wire RUMBLE2; wire RUMBLE3; wire RUMBLE4; wire sof; wire oktosend;
wire GC_enable1; wire GC_enable2; wire GC_enable3; wire GC_enable4; wire data_GCC1; wire data_GCC2; wire data_GCC3; wire data_GCC4; wire GCpollend1; wire GCpollend2; wire GCpollend3; wire GCpollend4;
wire connected1; wire connected2; wire connected3; wire connected4;
wire [2:0] connection_type1; wire [2:0] connection_type2; wire [2:0] connection_type3; wire [2:0] connection_type4;

assign lineGC1 = GC_poll1 ? 1'bZ : 1'b0; assign lineGC2 = GC_poll2 ? 1'bZ : 1'b0; assign lineGC3 = GC_poll3 ? 1'bZ : 1'b0; assign lineGC4 = GC_poll4 ? 1'bZ : 1'b0;

//-------------------------------------------------------------------------------------------------------------------------------------
// The USB controller core needs a 60MHz clock, this PLL module is to convert clk27mhz to clk60mhz
//-------------------------------------------------------------------------------------------------------------------------------------

wire       clk60mhz;
    Gowin_rPLL gowin_rpll(
        .clkout(clk60mhz), //output clkout
        .clkin(clk) //input clkin
    );

//-------------------------------------------------------------------------------------------------------------------------------------
// USB-HID WiiU Switch 1-2 Adapter Mode
//-------------------------------------------------------------------------------------------------------------------------------------

//reg [159:0] key_value   = {16'h0014,48'h002000400060,48'h003005000080,48'habcdef561234}; // [15:0] key_value   = 16'h0004;
reg [295:0] key_value   = {16'h2104,16'h0000,48'h000000000000,8'h04,16'h0000,48'h000000000000,8'h04,16'h0000,48'h000000000000,8'h04,16'h0000,48'h000000000000};
SwitchWiiU_Adapter #(
    .DEBUG           ( "FALSE"             )    // If you want to see the debug info of USB device core, set this parameter to "TRUE"
) SwitchWiiU (
    .rstn            ( button ),
    .clk             ( clk60mhz            ),
    // USB signals
    .usb_dp_pull     ( usb_dp_pull         ),
    .usb_dp          ( usb_dp              ),
    .usb_dn          ( usb_dn              ),
    // USB reset output
    .usb_rstn        (                 ),   // 1: connected , 0: disconnected (when USB cable unplug, or when system reset (rstn=0))
    // HID keyboard press signal
    .key_value       ( key_value           ),   // key_value runs from 16'h0004 (a) to 16'h0027 (9). The keyboard will type a~z and 0~9 cyclically.
    // debug output info, only for USB developers, can be ignored for normally use
    .debug_en        (                     ),
    .debug_data      (                     ),
    .debug_uart_tx   ( uart_tx             ),
    .sof             ( sof                  ),
    .RUMBLE1          ( RUMBLE1               ),
    .RUMBLE2          ( RUMBLE2               ),
    .RUMBLE3          ( RUMBLE3               ),
    .RUMBLE4          ( RUMBLE4               ),
    .oktosend           ( oktosend          )
);

//-------------------------------------------------------------------------------------------------------------------------------------
// Gamecube Controller Polling Data
//-------------------------------------------------------------------------------------------------------------------------------------

bounce      bounce_GCC1     ( .clk(clk)      ,  .line(lineGC1)     , .enable(GC_enable1)    , .debounced(data_GCC1) );
bounce      bounce_GCC2     ( .clk(clk)      ,  .line(lineGC2)     , .enable(GC_enable2)    , .debounced(data_GCC2) );
bounce      bounce_GCC3     ( .clk(clk)      ,  .line(lineGC3)     , .enable(GC_enable3)    , .debounced(data_GCC3) );
bounce      bounce_GCC4     ( .clk(clk)      ,  .line(lineGC4)     , .enable(GC_enable4)    , .debounced(data_GCC4) );
GC_PollGen  GC_PollGen1     ( .clk(clk60mhz) ,  .GC_poll(GC_poll1) , .GC_enable(GC_enable1) , .ready(sof) ,   .RUMBLE(RUMBLE1) , .connection_type(connection_type1) , .oktosend(oktosend) );
GC_PollGen  GC_PollGen2     ( .clk(clk60mhz) ,  .GC_poll(GC_poll2) , .GC_enable(GC_enable2) , .ready(sof) ,   .RUMBLE(RUMBLE2) , .connection_type(connection_type2) , .oktosend(oktosend) );
GC_PollGen  GC_PollGen3     ( .clk(clk60mhz) ,  .GC_poll(GC_poll3) , .GC_enable(GC_enable3) , .ready(sof) ,   .RUMBLE(RUMBLE3) , .connection_type(connection_type3) , .oktosend(oktosend) );
GC_PollGen  GC_PollGen4     ( .clk(clk60mhz) ,  .GC_poll(GC_poll4) , .GC_enable(GC_enable4) , .ready(sof) ,   .RUMBLE(RUMBLE4) , .connection_type(connection_type4) , .oktosend(oktosend) );
GC_Read     GC_Read1        ( .clk(clk) ,       .POLL(data_GCC1)   , .GC_enable(GC_enable1) , .GCBD(GCBD1) ,  .GCLA(GCLA1)     , .GCRA(GCRA1) , .GCTA(GCTA1)        , .GCpollend(GCpollend1) , .connected(connected1) , .connection_type(connection_type1) , .button2(button2) );
GC_Read     GC_Read2        ( .clk(clk) ,       .POLL(data_GCC2)   , .GC_enable(GC_enable2) , .GCBD(GCBD2) ,  .GCLA(GCLA2)     , .GCRA(GCRA2) , .GCTA(GCTA2)        , .GCpollend(GCpollend2) , .connected(connected2) , .connection_type(connection_type2) , .button2(button2) );
GC_Read     GC_Read3        ( .clk(clk) ,       .POLL(data_GCC3)   , .GC_enable(GC_enable3) , .GCBD(GCBD3) ,  .GCLA(GCLA3)     , .GCRA(GCRA3) , .GCTA(GCTA3)        , .GCpollend(GCpollend3) , .connected(connected3) , .connection_type(connection_type3) , .button2(button2) );
GC_Read     GC_Read4        ( .clk(clk) ,       .POLL(data_GCC4)   , .GC_enable(GC_enable4) , .GCBD(GCBD4) ,  .GCLA(GCLA4)     , .GCRA(GCRA4) , .GCTA(GCTA4)        , .GCpollend(GCpollend4) , .connected(connected4) , .connection_type(connection_type4) , .button2(button2) );


//-------------------------------------------------------------------------------------------------------------------------------------
// Gamecube Controller Data
//-------------------------------------------------------------------------------------------------------------------------------------

reg [18:0] count = 0;             // count is a clock counter that runs from 0 to 120000000, each period takes 2 seconds
reg prev_GCpoll = 0; reg [7:0] connect1 = 8'h04; reg [7:0] connect2 = 8'h04; reg [7:0] connect3 = 8'h04; reg [7:0] connect4 = 8'h04; // connect = 8'b00000100 means rumble is enabled on that port
always @ ( posedge clk ) begin      
        if ( (GCpollend1 && GCpollend2 && GCpollend3 && GCpollend4) && ~prev_GCpoll ) begin //This is to ensure only correct data gets send to the USB protocol. GCData only updates when an entire polling period has ended, and delays data until next full polling period
            prev_GCpoll <= 1;

            if ( connected1 ) begin
                connect1 <= 8'h14; //8'b00010100 means controller connected and rumble enabled
            end else begin
                connect1 <= 8'h04;
            end
            if ( connected2 ) begin
                connect2 <= 8'h14; //8'b00010100 means controller connected and rumble enabled
            end else begin
                connect2 <= 8'h04;
            end
            if ( connected3 ) begin
                connect3 <= 8'h14; //8'b00010100 means controller connected and rumble enabled
            end else begin 
                connect3 <= 8'h04;
            end
            if ( connected4 ) begin
                connect4 <= 8'h14; //8'b00010100 means controller connected and rumble enabled
            end else begin
                connect4 <= 8'h04;
            end

            key_value <= {8'h21 , //required start of USB packet
            connect1 , GCBD1[03:00] , GCBD1[11:08],4'h0 , GCBD1[06:04] , GCBD1[12] , GCLA1[15:00] , GCRA1[15:00] , GCTA1[15:00] , //Controller 1 Data
            connect2 , GCBD2[03:00] , GCBD2[11:08],4'h0 , GCBD2[06:04] , GCBD2[12] , GCLA2[15:00] , GCRA2[15:00] , GCTA2[15:00] , //Controller 2 Data
            connect3 , GCBD3[03:00] , GCBD3[11:08],4'h0 , GCBD3[06:04] , GCBD3[12] , GCLA3[15:00] , GCRA3[15:00] , GCTA3[15:00] , //Controller 3 Data
            connect4 , GCBD4[03:00] , GCBD4[11:08],4'h0 , GCBD4[06:04] , GCBD4[12] , GCLA4[15:00] , GCRA4[15:00] , GCTA4[15:00]}; //Controller 4 Data

        end else if ( ~(GCpollend1 && GCpollend2 && GCpollend3 && GCpollend4) && prev_GCpoll ) begin
            prev_GCpoll <= 0;
        end
    end

endmodule


//A  01 00
//B  02 00
//X  04 00
//Y  08 00
//Z  00 02
//St 00 01
//DU 80 00
//DD 40 00
//DR 20 00
//DL 10 00
//L  00 08
//R  00 04
//NOTES
//To flash the .fs file to the Tang Nano 9k, you will need Zadig to overwrite the WINUSB driver with FTDI.
//Run the command file and all should work