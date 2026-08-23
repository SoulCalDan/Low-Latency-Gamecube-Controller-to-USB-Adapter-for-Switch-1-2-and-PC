
module GC_Top (
    // clock
    input  wire clk,
    input  wire RESET,     // connect to a reset button, 0=reset, 1=release. If you don't have a button, tie this signal to 1. 
    input wire button,
    output wire [5:0] led ,// Just setting LEDs to OFF
    output wire usb_dp_pull,  // connect to USB D+ by an 1.5k resistor
    inout  wire usb_dp,       // connect to USB D+
    inout  wire usb_dn,       // connect to USB D- 
    inout  wire lineGC1, inout wire lineGC2, inout wire lineGC3, inout wire lineGC4    //output wire        uart_tx   
);

wire sof;
wire GC_poll1;     wire GC_poll2;     wire GC_poll3;     wire GC_poll4;
wire [15:0] GCBD1; wire [15:0] GCLA_X1; wire [15:0] GCRA_X1; wire [15:0] GCLA_A1; wire [15:0] GCRA_A1; wire [15:0] GCTA1;
wire [15:0] GCBD2; wire [15:0] GCLA_X2; wire [15:0] GCRA_X2; wire [15:0] GCLA_A2; wire [15:0] GCRA_A2; wire [15:0] GCTA2;
wire [15:0] GCBD3; wire [15:0] GCLA_X3; wire [15:0] GCRA_X3; wire [15:0] GCLA_A3; wire [15:0] GCRA_A3; wire [15:0] GCTA3;
wire [15:0] GCBD4; wire [15:0] GCLA_X4; wire [15:0] GCRA_X4; wire [15:0] GCLA_A4; wire [15:0] GCRA_A4; wire [15:0] GCTA4;
wire RUMBLE1;                               wire RUMBLE2;                               wire RUMBLE3;                               wire RUMBLE4;   wire controller_count_start;
wire connected1;                            wire connected2;                            wire connected3;                            wire connected4; 
wire [2:0] connection_type1;                wire [2:0] connection_type2;                wire [2:0] connection_type3;                wire [2:0] connection_type4; 
wire GC_enable1;                            wire GC_enable2;                            wire GC_enable3;                            wire GC_enable4;  
wire GCpollend1;                            wire GCpollend2;                            wire GCpollend3;                            wire GCpollend4;
wire data_GCC1;                             wire data_GCC2;                             wire data_GCC3;                             wire data_GCC4;
assign lineGC1 = GC_poll1 ? 1'bZ : 1'b0;    assign lineGC2 = GC_poll2 ? 1'bZ : 1'b0;    assign lineGC3 = GC_poll3 ? 1'bZ : 1'b0;    assign lineGC4 = GC_poll4 ? 1'bZ : 1'b0;


assign led[5:0] = 6'b111111;
//assign led[5:0] = { Apress , 5'b11111  }; //for lag testing
//PLL Generation---------------------------------------------------------------------------

wire clk60mhz;
Gowin_rPLL gowin_rpll(
    .clkout(clk60mhz), //output clkout
    .clkin(clk) //input clkin
);

// USB-HID Controller Processing-----------------------------------------------------------
reg [295:0] GC_Adapter_Data =   {16'h2104,16'h0000,48'h000000000000,8'h04,16'h0000,48'h000000000000,8'h04,16'h0000,48'h000000000000,8'h04,16'h0000,48'h000000000000};
reg [63:0]  HORI2_Pro1 =        { 8'h00 , 8'h00 , 8'h0F , 8'h7F , 8'h7F , 8'h7F , 8'h7F , 8'h00 };
reg [63:0]  HORI2_Pro2 =        { 8'h00 , 8'h00 , 8'h0F , 8'h7F , 8'h7F , 8'h7F , 8'h7F , 8'h00 };
reg [63:0]  HORI2_Pro3 =        { 8'h00 , 8'h00 , 8'h0F , 8'h7F , 8'h7F , 8'h7F , 8'h7F , 8'h00 };
reg [63:0]  HORI2_Pro4 =        { 8'h00 , 8'h00 , 8'h0F , 8'h7F , 8'h7F , 8'h7F , 8'h7F , 8'h00 };
reg [511:0] Gamecube_NSO1 =     {8'h0A , 8'h69 , 8'h1B , 8'h00 , 8'h00 , 8'h00 , 8'hF0 , 8'h07 , 8'h7F , 8'hF0 , 8'h07 , 8'h7F , 8'h30 , 8'h0 , 8'h0 , 392'h0 };
reg [159:0] XBOX360_1 =         {16'h0014,48'h000000000000,48'h000000000000,48'h000000000000};
reg [159:0] XBOX360_2 =         {16'h0014,48'h000000000000,48'h000000000000,48'h000000000000};
reg [159:0] XBOX360_3 =         {16'h0014,48'h000000000000,48'h000000000000,48'h000000000000};
reg [159:0] XBOX360_4 =         {16'h0014,48'h000000000000,48'h000000000000,48'h000000000000};

reg [3:0] Mode_Select = 4'b0;

GC_HID #(
    .DEBUG           ( "FALSE"             )    // If you want to see the debug info of USB device core, set this parameter to "TRUE"
) GC_HID (
    .rstn      ( RESET ),    .usb_rstn (     ), // 1: connected , 0: disconnected (when USB cable unplug, or when system reset (rstn=0))
    .clk       ( clk60mhz ), .sof      ( sof ),
    .usb_dp_pull ( usb_dp_pull ),
    .usb_dp      ( usb_dp ),
    .usb_dn      ( usb_dn ),
    .GC_Adapter_Data ( GC_Adapter_Data ),
    .Gamecube_NSO1   ( Gamecube_NSO1 ),
    .HORI2_Pro1      ( HORI2_Pro1 ),
    .HORI2_Pro2      ( HORI2_Pro2 ),
    .HORI2_Pro3      ( HORI2_Pro3 ),
    .HORI2_Pro4      ( HORI2_Pro4 ),
    .XBOX360_1       ( XBOX360_1 ),
    .XBOX360_2       ( XBOX360_2 ),
    .XBOX360_3       ( XBOX360_3 ),
    .XBOX360_4       ( XBOX360_4 ),
    .Mode_Select     ( Mode_Select ),
    .RUMBLE1   ( RUMBLE1 ),.RUMBLE2   ( RUMBLE2 ),.RUMBLE3   ( RUMBLE3 ),.RUMBLE4   ( RUMBLE4 ),
    // debug output info, only for USB developers, can be ignored for normally use
    .debug_en        (                     ),    .debug_data      (                     ),    .debug_uart_tx   ( uart_tx             ),
    .controller_count_start ( controller_count_start)
);

// Gamecube Controller Polling Data - All modules MUST be in the same clock domain! DO NOT MIX UP CLOCK DOMAINS!!!
bounce      bounce_GCC1     ( .clk(clk60mhz) ,  .line(lineGC1)      ,  .enable(GC_enable1)      , .debounced(data_GCC1) );
bounce      bounce_GCC2     ( .clk(clk60mhz) ,  .line(lineGC2)      ,  .enable(GC_enable2)      , .debounced(data_GCC2) );
bounce      bounce_GCC3     ( .clk(clk60mhz) ,  .line(lineGC3)      ,  .enable(GC_enable3)      , .debounced(data_GCC3) );
bounce      bounce_GCC4     ( .clk(clk60mhz) ,  .line(lineGC4)      ,  .enable(GC_enable4)      , .debounced(data_GCC4) );
PollGen     GCPollGen1      ( .clk(clk60mhz) ,  .GC_poll(GC_poll1)  ,  .ready(sof)              , .GC_enable(GC_enable1) ,      .RUMBLE(RUMBLE1)    , .connection_type(connection_type1) );
PollGen     GCPollGen2      ( .clk(clk60mhz) ,  .GC_poll(GC_poll2)  ,  .ready(sof)              , .GC_enable(GC_enable2) ,      .RUMBLE(RUMBLE2)    , .connection_type(connection_type2) );
PollGen     GCPollGen3      ( .clk(clk60mhz) ,  .GC_poll(GC_poll3)  ,  .ready(sof)              , .GC_enable(GC_enable3) ,      .RUMBLE(RUMBLE3)    , .connection_type(connection_type3) );
PollGen     GCPollGen4      ( .clk(clk60mhz) ,  .GC_poll(GC_poll4)  ,  .ready(sof)              , .GC_enable(GC_enable4) ,      .RUMBLE(RUMBLE4)    , .connection_type(connection_type4) );
Cont_Input  GC_Read1        ( .clk(clk60mhz) ,  .POLL(data_GCC1)    ,  .GC_enable(GC_enable1)   , .GCBD(GCBD1) , .GCLA_X(GCLA_X1) , .GCRA_X(GCRA_X1) , .GCLA_A(GCLA_A1) , .GCRA_A(GCRA_A1) , .GCTA(GCTA1) , .GCpollend(GCpollend1) , .connected(connected1) , .connection_type(connection_type1) , .Mode(Mode_Select) ) ;  
Cont_Input  GC_Read2        ( .clk(clk60mhz) ,  .POLL(data_GCC2)    ,  .GC_enable(GC_enable2)   , .GCBD(GCBD2) , .GCLA_X(GCLA_X2) , .GCRA_X(GCRA_X2) , .GCLA_A(GCLA_A2) , .GCRA_A(GCRA_A2) , .GCTA(GCTA2) , .GCpollend(GCpollend2) , .connected(connected2) , .connection_type(connection_type2) , .Mode(Mode_Select) ) ;  
Cont_Input  GC_Read3        ( .clk(clk60mhz) ,  .POLL(data_GCC3)    ,  .GC_enable(GC_enable3)   , .GCBD(GCBD3) , .GCLA_X(GCLA_X3) , .GCRA_X(GCRA_X3) , .GCLA_A(GCLA_A3) , .GCRA_A(GCRA_A3) , .GCTA(GCTA3) , .GCpollend(GCpollend3) , .connected(connected3) , .connection_type(connection_type3) , .Mode(Mode_Select) ) ;  
Cont_Input  GC_Read4        ( .clk(clk60mhz) ,  .POLL(data_GCC4)    ,  .GC_enable(GC_enable4)   , .GCBD(GCBD4) , .GCLA_X(GCLA_X4) , .GCRA_X(GCRA_X4) , .GCLA_A(GCLA_A4) , .GCRA_A(GCRA_A4) , .GCTA(GCTA4) , .GCpollend(GCpollend4) , .connected(connected4) , .connection_type(connection_type4) , .Mode(Mode_Select) ) ;  

// Controller Data
reg [11:0] count = 0;   reg [7:0] counter = 8'd255;          reg [7:0] counter2 = 8'h23;   reg [7:0] bs = 8'b10000000;  reg Apress = 1'b1;
reg HOME = 1'b0;        reg ZL = 1'b0;        reg CAPTURE = 1'b0;
reg prev_GCpoll = 0; 
reg [7:0] connect1 = 8'h04; reg [7:0] connect2 = 8'h04; reg [7:0] connect3 = 8'h04; reg [7:0] connect4 = 8'h04;
reg [3:0] hat1 = 4'hF;  reg [3:0] hat2 = 4'hF;  reg [3:0] hat3 = 4'hF;  reg [3:0] hat4 = 4'hF;

always @ ( posedge clk60mhz or negedge RESET ) begin

    if ( ~RESET ) begin
        counter <= 8'hE1;        counter2 <= 8'h21;
        prev_GCpoll <= 0;
        HOME <= 1'b0;
        GC_Adapter_Data <= {16'h2104,16'h0000,48'h000000000000,8'h04,16'h0000,48'h000000000000,8'h04,16'h0000,48'h000000000000,8'h04,16'h0000,48'h000000000000};
        HORI2_Pro1      <= { 16'h0000 , 8'h0F , 32'h7F7F7F7F , 8'h00 };        HORI2_Pro2      <= { 16'h0000 , 8'h0F , 32'h7F7F7F7F , 8'h00 };        HORI2_Pro3      <= { 16'h0000 , 8'h0F , 32'h7F7F7F7F , 8'h00 };        HORI2_Pro4      <= { 16'h0000 , 8'h0F , 32'h7F7F7F7F , 8'h00 };
        Gamecube_NSO1   <= {8'h0A , 8'h69 , 8'h1B , 8'h00 , 8'h00 , 8'h00 , 8'hFF , 8'hF7 , 8'h7F , 8'hFF , 8'hF7 , 8'h7F , 8'h38 , 8'h0 , 8'h0 , 392'h0 };
        XBOX360_1       <= {16'h0014,144'h0};          XBOX360_2       <= {16'h0014,144'h0};          XBOX360_3       <= {16'h0014,144'h0};          XBOX360_4       <= {16'h0014,144'h0};  
        Mode_Select[3:0] <= 4'h0;

    end else begin
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

    if (sof) begin 
        if ( GCBD1[4] == 1 ) begin
            bs[7:0] <= {bs[6:0] , bs[7]};
        end
        if (controller_count_start) begin
            counter <= counter + 1'b1;
        end
    end
    if ( counter == 8'h21 ) begin
        counter2 <= 8'h23;
    end
    if ( (GCpollend1 && GCpollend2 && GCpollend3 && GCpollend4) && ~prev_GCpoll ) begin //This is to ensure only correct data gets send to the USB data. GCData only updates when an entire polling period has ended, and delays data until next full polling period
        prev_GCpoll <= 1;
        Apress <= ~GCBD1[8];
        if ( Mode_Select[3:0] == 4'h0 && ( connected1 ) ) begin //| connected2 | connected3 | connected4 ) ) begin
            Mode_Select[3:0] <= ( GCBD1[11:08] ); //Y-X-B-A
        end 
//Gamecube Adapter Data
        GC_Adapter_Data <= {8'h21 , //required start of USB packet for GC Adapter
        connect1 , GCBD1[03:00] , GCBD1[11:08], 4'h0 , GCBD1[06:04] , GCBD1[12] , GCLA_A1[15:00] , GCRA_A1[15:00] , GCTA1[15:00] , //Controller 1 Data
        connect2 , GCBD2[03:00] , GCBD2[11:08], 4'h0 , GCBD2[06:04] , GCBD2[12] , GCLA_A2[15:00] , GCRA_A2[15:00] , GCTA2[15:00] , //Controller 2 Data
        connect3 , GCBD3[03:00] , GCBD3[11:08], 4'h0 , GCBD3[06:04] , GCBD3[12] , GCLA_A3[15:00] , GCRA_A3[15:00] , GCTA3[15:00] , //Controller 3 Data
        connect4 , GCBD4[03:00] , GCBD4[11:08], 4'h0 , GCBD4[06:04] , GCBD4[12] , GCLA_A4[15:00] , GCRA_A4[15:00] , GCTA4[15:00]}; //Controller 4 Data

//XBOX360 Data
        if ( GCBD1[12] == 1 ) begin
            if ( count < 1500 ) begin
                count <= count + 1'b1;
                HOME <= 0;
                CAPTURE <= 0;
                ZL <= 0;
            end
            else if ( count >= 1500 && count < 1600) begin
                if ( GCBD1[03] == 1 ) begin //up press
                    ZL <= 1;
                end else if ( GCBD1[00] == 1 || GCBD1[01] == 1 ) begin //left press
                    CAPTURE <= 1;
                end else begin
                    HOME <= 1;
                end
                count <= count + 1'b1;
            end
            else if ( count >= 1600 && count < 2999 ) begin
                if ( GCBD1[01] == 1 ) begin //right press
                    CAPTURE <= 1;
                end
                else begin
                    HOME <= 0;
                    ZL <= 0;
                    CAPTURE <= 0;
                end
                count <= count + 1'b1;
            end
            else begin
                HOME <= 0;
                ZL <= 0;
                CAPTURE <= 0;
                count <= 3100;
            end
        end
        else begin
            count <= 0;
            HOME <= 0;
        end
        if ( connected1 ) begin
            XBOX360_1 = {16'h0014, //required start of USB packet - XBOX DATA - R3 L3 BACK St DR DL DD DU Y X B A 0 Home RB LB 8LT 8RT 16LS 16RS      //GC DATA   0 0 0 St Y X B A 1 L R Z DU DD DR DL JX JY CX CY AL AR
            1'b0,1'b0,1'b0, GCBD1[12],  GCBD1[01],  GCBD1[00],  GCBD1[02],  GCBD1[03], // 8 bits button data (click stick not applicable)
            GCBD1[11:08],1'b0,HOME,GCBD1[04],1'b0, // 8 bits button data (BACK and XBOX button not compatible with GC) 
            GCTA1[15:0], //Analog Triggers
            8'h00 , { ~GCLA_X1[15] , GCLA_X1[14:08] } , 8'h00 , { ~GCLA_X1[07] , GCLA_X1[06:00] } , 8'h00 , { ~GCRA_X1[15] , GCRA_X1[14:08] } , 8'h00 , { ~GCRA_X1[07] , GCRA_X1[06:00] } , //All Analog Stick data here            
            48'h0 }; //padding for the total 80bytes sent
        end else begin
            XBOX360_1 = {16'h0014,144'h0};            
        end

        if ( connected2 ) begin
            XBOX360_2 = {16'h0014, //required start of USB packet - XBOX DATA - R3 L3 BACK St DR DL DD DU Y X B A 0 Home RB LB 8LT 8RT 16LS 16RS      //GC DATA   0 0 0 St Y X B A 1 L R Z DU DD DR DL JX JY CX CY AL AR
            1'b0,1'b0,1'b0, GCBD2[12],  GCBD2[01],  GCBD2[00],  GCBD2[02],  GCBD2[03], // 8 bits button data (click stick not applicable)
            GCBD2[11:08],1'b0,1'b0,GCBD2[04],1'b0, // 8 bits button data (BACK and XBOX button not compatible with GC) 
            GCTA2[15:0], //Analog Triggers
            8'h00 , { ~GCLA_X2[15] , GCLA_X2[14:08] } , 8'h00 , { ~GCLA_X2[07] , GCLA_X2[06:00] } , 8'h00 , { ~GCRA_X2[15] , GCRA_X2[14:08] } , 8'h00 , { ~GCRA_X2[07] , GCRA_X2[06:00] } , //All Analog Stick data here            
            48'h0 }; //padding for the total 80bytes sent
        end else begin
            XBOX360_2 = {16'h0014,144'h0};            
        end

         if ( connected3 ) begin
            XBOX360_3 = {16'h0014, //required start of USB packet - XBOX DATA - R3 L3 BACK St DR DL DD DU Y X B A 0 Home RB LB 8LT 8RT 16LS 16RS      //GC DATA   0 0 0 St Y X B A 1 L R Z DU DD DR DL JX JY CX CY AL AR
            1'b0,1'b0,1'b0, GCBD3[12],  GCBD3[01],  GCBD3[00],  GCBD3[02],  GCBD3[03], // 8 bits button data (click stick not applicable)
            GCBD3[11:08],1'b0,1'b0,GCBD3[04],1'b0, // 8 bits button data (BACK and XBOX button not compatible with GC) 
            GCTA3[15:0], //Analog Triggers
            8'h00 , { ~GCLA_X3[15] , GCLA_X3[14:08] } , 8'h00 , { ~GCLA_X3[07] , GCLA_X3[06:00] } , 8'h00 , { ~GCRA_X3[15] , GCRA_X3[14:08] } , 8'h00 , { ~GCRA_X3[07] , GCRA_X3[06:00] } , //All Analog Stick data here            
            48'h0 }; //padding for the total 80bytes sent
        end else begin
            XBOX360_3 = {16'h0014,144'h0};            
        end

        if ( connected4 ) begin
            XBOX360_4 = {16'h0014, //required start of USB packet - XBOX DATA - R3 L3 BACK St DR DL DD DU Y X B A 0 Home RB LB 8LT 8RT 16LS 16RS      //GC DATA   0 0 0 St Y X B A 1 L R Z DU DD DR DL JX JY CX CY AL AR
            1'b0,1'b0,1'b0, GCBD4[12],  GCBD4[01],  GCBD4[00],  GCBD4[02],  GCBD4[03], // 8 bits button data (click stick not applicable)
            GCBD4[11:08],1'b0,1'b0,GCBD4[04],1'b0, // 8 bits button data (BACK and XBOX button not compatible with GC) 
            GCTA4[15:0], //Analog Triggers
            8'h00 , { ~GCLA_X4[15] , GCLA_X4[14:08] } , 8'h00 , { ~GCLA_X4[07] , GCLA_X4[06:00] } , 8'h00 , { ~GCRA_X4[15] , GCRA_X4[14:08] } , 8'h00 , { ~GCRA_X4[07] , GCRA_X4[06:00] } , //All Analog Stick data here            
            48'h0 }; //padding for the total 80bytes sent
        end else begin
            XBOX360_4 = {16'h0014,144'h0};            
        end

//Gamecube NSO Data
        if ( connected1 ) begin
            Gamecube_NSO1 <= {8'h0A , counter , 8'h17 , 
            1'b0 , GCBD1[12] , GCBD1[4] , GCBD1[5] , GCBD1[10] , GCBD1[11] , GCBD1[8] , GCBD1[9] , 2'b00 , ZL, GCBD1[6] , GCBD1[3] , GCBD1[0] , GCBD1[1] , GCBD1[2] , 6'b000000 , CAPTURE , HOME ,//padding, count, buttons 3bytes
            GCLA_A1[11:08] , 4'hF , 4'hF , GCLA_A1[15:12] , GCLA_A1[07:00] ,  GCRA_A1[11:08] , 4'hF , 4'hF , GCRA_A1[15:12] , GCRA_A1[07:00] ,
            8'h38 , GCTA1[15:8] , GCTA1[7:0] , 392'h0 }; //0x30pad, LT, RL, padding , analog stick format -12bits per axis 4'h_Xmiddle , 4'h_Xlow, 4'h_Ylow, 4'h_Xhigh, 8'h_Yhigh
        end else begin  //DPAD         //up 00 08 00    //left 00 04 00     //right 00 02 00        //down 00 01 00   
            Gamecube_NSO1   <= {8'h0A , 8'h69 , 8'h1B , 8'h00 , 8'h00 , 8'h00 , 8'hFF , 8'hF7 , 8'h7F , 8'hF0 , 8'h07 , 8'h7F , 8'h38 , 8'h0 , 8'h0 , 392'h0 };
        end        

//HORI2 Pro Controller Data
        case ({GCBD1[03], GCBD1[02], GCBD1[01], GCBD1[00]}) //HAT -> DU = 0x00 , DD = 0x04 , DR = 0x02 , DL = 0x06 , None = 0x0F , UR = 0x01 , UL = 0x07 , BR = 0x03 , BL = 0x05
        4'b1000: hat1 <= 4'h0; // Up
        4'b1010: hat1 <= 4'h1; // Up-Right
        4'b0010: hat1 <= 4'h2; // Right
        4'b0110: hat1 <= 4'h3; // Down-Right
        4'b0100: hat1 <= 4'h4; // Down
        4'b0101: hat1 <= 4'h5; // Down-Left
        4'b0001: hat1 <= 4'h6; // Left
        4'b1001: hat1 <= 4'h7; // Up-Left
        default: hat1 <= 4'hF; // Center / invalid combos
        endcase
        case ({GCBD2[03], GCBD2[02], GCBD2[01], GCBD2[00]}) //HAT -> DU = 0x00 , DD = 0x04 , DR = 0x02 , DL = 0x06 , None = 0x0F , UR = 0x01 , UL = 0x07 , BR = 0x03 , BL = 0x05
        4'b1000: hat2 <= 4'h0; // Up
        4'b1010: hat2 <= 4'h1; // Up-Right
        4'b0010: hat2 <= 4'h2; // Right
        4'b0110: hat2 <= 4'h3; // Down-Right
        4'b0100: hat2 <= 4'h4; // Down
        4'b0101: hat2 <= 4'h5; // Down-Left
        4'b0001: hat2 <= 4'h6; // Left
        4'b1001: hat2 <= 4'h7; // Up-Left
        default: hat2 <= 4'hF; // Center / invalid combos
        endcase
        case ({GCBD3[03], GCBD3[02], GCBD3[01], GCBD3[00]}) //HAT -> DU = 0x00 , DD = 0x04 , DR = 0x02 , DL = 0x06 , None = 0x0F , UR = 0x01 , UL = 0x07 , BR = 0x03 , BL = 0x05
        4'b1000: hat3 <= 4'h0; // Up
        4'b1010: hat3 <= 4'h1; // Up-Right
        4'b0010: hat3 <= 4'h2; // Right
        4'b0110: hat3 <= 4'h3; // Down-Right
        4'b0100: hat3 <= 4'h4; // Down
        4'b0101: hat3 <= 4'h5; // Down-Left
        4'b0001: hat3 <= 4'h6; // Left
        4'b1001: hat3 <= 4'h7; // Up-Left
        default: hat3 <= 4'hF; // Center / invalid combos
        endcase
        case ({GCBD4[03], GCBD4[02], GCBD4[01], GCBD4[00]}) //HAT -> DU = 0x00 , DD = 0x04 , DR = 0x02 , DL = 0x06 , None = 0x0F , UR = 0x01 , UL = 0x07 , BR = 0x03 , BL = 0x05
        4'b1000: hat4 <= 4'h0; // Up
        4'b1010: hat4 <= 4'h1; // Up-Right
        4'b0010: hat4 <= 4'h2; // Right
        4'b0110: hat4 <= 4'h3; // Down-Right
        4'b0100: hat4 <= 4'h4; // Down
        4'b0101: hat4 <= 4'h5; // Down-Left
        4'b0001: hat4 <= 4'h6; // Left
        4'b1001: hat4 <= 4'h7; // Up-Left
        default: hat4 <= 4'hF; // Center / invalid combos
        endcase

        if (connected1) begin
            HORI2_Pro1[63:0] <= { GCBD1[05] , GCBD1[06] , GCBD1[04] , 1'b0 , GCBD1[10] , GCBD1[08] , GCBD1[09] , GCBD1[11] , 2'b00 , 1'b0 , HOME , 1'b0 , 1'b0 , GCBD1[12], ZL , 4'h0 , hat1[3:0] , GCLA_X1[15:08] , ~GCLA_X1[07:00] , GCRA_X1[15:08] , ~GCRA_X1[07:00] , 8'h00 }; 
        end else begin
            HORI2_Pro1[63:0] = { 8'h00 , 8'h00 , 8'h0F , 8'h7F , 8'h7F , 8'h7F , 8'h7F , 8'h00 };
        end
        if (connected1) begin
            HORI2_Pro2[63:0] <= { GCBD2[05] , GCBD2[06] , GCBD2[04] , 1'b0 , GCBD2[10] , GCBD2[08] , GCBD2[09] , GCBD2[11] , 2'b00 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , GCBD2[12], 1'b0 , 4'h0 , hat2[3:0] , GCLA_X2[15:08] , ~GCLA_X2[07:00] , GCRA_X2[15:08] , ~GCRA_X2[07:00] , 8'h00 };
        end else begin
            HORI2_Pro2[63:0] = { 8'h00 , 8'h00 , 8'h0F , 8'h7F , 8'h7F , 8'h7F , 8'h7F , 8'h00 };
        end
        if (connected1) begin
            HORI2_Pro3[63:0] <= { GCBD3[05] , GCBD3[06] , GCBD3[04] , 1'b0 , GCBD3[10] , GCBD3[08] , GCBD3[09] , GCBD3[11] , 2'b00 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , GCBD3[12], 1'b0 , 4'h0 , hat3[3:0] , GCLA_X3[15:08] , ~GCLA_X3[07:00] , GCRA_X3[15:08] , ~GCRA_X3[07:00] , 8'h00 };
        end else begin
            HORI2_Pro3[63:0] = { 8'h00 , 8'h00 , 8'h0F , 8'h7F , 8'h7F , 8'h7F , 8'h7F , 8'h00 };
        end
        if (connected1) begin
            HORI2_Pro4[63:0] <= { GCBD4[05] , GCBD4[06] , GCBD4[04] , 1'b0 , GCBD4[10] , GCBD4[08] , GCBD4[09] , GCBD4[11] , 2'b00 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , GCBD4[12], 1'b0 , 4'h0 , hat4[3:0] , GCLA_X4[15:08] , ~GCLA_X4[07:00] , GCRA_X4[15:08] , ~GCRA_X4[07:00] , 8'h00 };
        end else begin
            HORI2_Pro4[63:0] = { 8'h00 , 8'h00 , 8'h0F , 8'h7F , 8'h7F , 8'h7F , 8'h7F , 8'h00 };
        end
    end else if ( ~(GCpollend1 && GCpollend2 && GCpollend3 && GCpollend4) && prev_GCpoll ) begin
        prev_GCpoll <= 0;
    end
    end
end

endmodule
