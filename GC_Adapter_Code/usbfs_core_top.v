
//--------------------------------------------------------------------------------------------------------
// Module  : usbfs_core_top
// Type    : synthesizable, IP's top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: A USB Full Speed (12Mbps) device controller
//--------------------------------------------------------------------------------------------------------

module usbfs_core_top #(
    parameter [ 18*8-1:0] DESCRIPTOR_DEVICE_GCNSO = 0,                  // 18  byte capacity
    parameter [ 18*8-1:0] DESCRIPTOR_DEVICE_XBOX = 0,                   // 18  byte capacity
    parameter [ 18*8-1:0] DESCRIPTOR_DEVICE_HORI2 = 0,                  // 18  byte capacity
    parameter [ 18*8-1:0] DESCRIPTOR_DEVICE_GCA = 0,                    // 18  byte capacity
    //parameter [ 64*8-1:0] DESCRIPTOR_STR0   = 0,                      // 64  byte capacity
    parameter [ 64*8-1:0] DESCRIPTOR_STR1   = 0,                        // 64  byte capacity
    parameter [ 64*8-1:0] DESCRIPTOR_STR2   = 0,                        // 64  byte capacity
    parameter [ 64*8-1:0] DESCRIPTOR_STR3   = 0,                        // 64  byte capacity
    parameter [ 64*8-1:0] DESCRIPTOR_STR4   = 0,                        // 64  byte capacity
    parameter [ 64*8-1:0] DESCRIPTOR_STR5   = 0,                        // 64  byte capacity
    parameter [ 64*8-1:0] DESCRIPTOR_STR6   = 0,                        // 64  byte capacity
    parameter [ 64*8-1:0] DESCRIPTOR_STR7gc   = 0,                      // 64  byte capacity
    parameter [ 64*8-1:0] DESCRIPTOR_STR7XBOX   = 0,                    // 64  byte capacity
    parameter [182*8-1:0] DESCRIPTOR_STR8   = 0,                        // 132 byte capacity
    parameter [512*8-1:0] DESCRIPTOR_STR9   = 0,                        // 512 byte capacity
    parameter [64*8-1:0] DESCRIPTOR_STR10  = 0,                         // 64  byte capacity
    parameter [18*8-1:0] DESCRIPTOR_STREE  = 0,                         // 64  byte capacity
    parameter [512*8-1:0] DESCRIPTOR_CONFIG_GCNSO = 0,                  // 512 byte capacity
    parameter [512*8-1:0] DESCRIPTOR_CONFIG_XBOX = 0,                   // 512 byte capacity
    parameter [512*8-1:0] DESCRIPTOR_CONFIG_HORI2 = 0,                  // 512 byte capacity
    parameter [512*8-1:0] DESCRIPTOR_CONFIG_GCA = 0,                    // 512 byte capacity
    parameter       [7:0] EP00_MAXPKTSIZE   = 8'h40,              // endpoint 00 (control endpoint) packet byte length.
    parameter       [9:0] EP81_MAXPKTSIZE   = 10'h40,             // endpoint 81 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP82_MAXPKTSIZE   = 10'h40,             // endpoint 82 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP83_MAXPKTSIZE   = 10'h40,             // endpoint 83 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP84_MAXPKTSIZE   = 10'h40,             // endpoint 84 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP85_MAXPKTSIZE   = 10'h40,             // endpoint 84 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP86_MAXPKTSIZE   = 10'h40,             // endpoint 84 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP87_MAXPKTSIZE   = 10'h40,             // endpoint 84 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP88_MAXPKTSIZE   = 10'h40,             // endpoint 84 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP89_MAXPKTSIZE   = 10'h40,             // endpoint 84 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP8A_MAXPKTSIZE   = 10'h40,             // endpoint 8A packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP8B_MAXPKTSIZE   = 10'h40,             // endpoint 8B packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP8C_MAXPKTSIZE   = 10'h40,             // endpoint 8C packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP8D_MAXPKTSIZE   = 10'h40,             // endpoint 8D packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter             EP81_ISOCHRONOUS  = 0,                  // endpoint 81 is ISOCHRONOUS ?
    parameter             EP82_ISOCHRONOUS  = 0,                  // endpoint 82 is ISOCHRONOUS ?
    parameter             EP83_ISOCHRONOUS  = 0,                  // endpoint 83 is ISOCHRONOUS ?
    parameter             EP84_ISOCHRONOUS  = 0,                  // endpoint 84 is ISOCHRONOUS ?
    parameter             EP85_ISOCHRONOUS  = 0,                  // endpoint 85 is ISOCHRONOUS ?
    parameter             EP86_ISOCHRONOUS  = 0,                  // endpoint 86 is ISOCHRONOUS ?
    parameter             EP87_ISOCHRONOUS  = 0,                  // endpoint 87 is ISOCHRONOUS ?
    parameter             EP88_ISOCHRONOUS  = 0,                  // endpoint 88 is ISOCHRONOUS ?
    parameter             EP89_ISOCHRONOUS  = 0,                  // endpoint 89 is ISOCHRONOUS ?
    parameter             EP8A_ISOCHRONOUS  = 0,                  // endpoint 8A is ISOCHRONOUS ?
    parameter             EP8B_ISOCHRONOUS  = 0,                  // endpoint 8B is ISOCHRONOUS ?
    parameter             EP8C_ISOCHRONOUS  = 0,                  // endpoint 8C is ISOCHRONOUS ?
    parameter             EP8D_ISOCHRONOUS  = 0,                  // endpoint 8D is ISOCHRONOUS ?
    parameter             EP01_ISOCHRONOUS  = 0,                  // endpoint 01 is ISOCHRONOUS ?
    parameter             EP02_ISOCHRONOUS  = 0,                  // endpoint 02 is ISOCHRONOUS ?
    parameter             EP03_ISOCHRONOUS  = 0,                  // endpoint 03 is ISOCHRONOUS ?
    parameter             EP04_ISOCHRONOUS  = 0,                  // endpoint 04 is ISOCHRONOUS ?
    parameter             EP05_ISOCHRONOUS  = 0,                  // endpoint 05 is ISOCHRONOUS ?
    parameter             EP06_ISOCHRONOUS  = 0,                  // endpoint 06 is ISOCHRONOUS ?
    parameter             EP07_ISOCHRONOUS  = 0,                  // endpoint 07 is ISOCHRONOUS ?
    parameter             EP08_ISOCHRONOUS  = 0,                  // endpoint 08 is ISOCHRONOUS ?
    parameter             EP09_ISOCHRONOUS  = 0,                  // endpoint 09 is ISOCHRONOUS ?
    parameter             EP0A_ISOCHRONOUS  = 0,                  // endpoint 0A is ISOCHRONOUS ?
    parameter             EP0B_ISOCHRONOUS  = 0,                  // endpoint 0B is ISOCHRONOUS ?
    parameter             EP0C_ISOCHRONOUS  = 0,                  // endpoint 0C is ISOCHRONOUS ?
    parameter             EP0D_ISOCHRONOUS  = 0,                  // endpoint 0D is ISOCHRONOUS ?
    parameter             DEBUG             = "FALSE"             // whether to output debug info, "TRUE" or "FALSE"
) (
    input  wire        rstn,          // active-low reset, reset when rstn=0 (USB will unplug when reset)
    input  wire        clk,           // 60MHz is required
    // USB signals
    output reg         usb_dp_pull,   // connect to USB D+ by an 1.5k resistor
    inout              usb_dp,        // USB D+
    inout              usb_dn,        // USB D-
    // USB reset output
    output reg         usb_rstn,      // 1: connected , 0: disconnected (when USB cable unplug, or when system reset (rstn=0))
    // 
    output wire        sot,           // detect a start of USB-transfer
    output wire        sof,           // detect a start of USB-frame
    // endpoint 0 (control endpoint) command response here
    output wire [63:0] ep00_setup_cmd,
    output wire [ 8:0] ep00_resp_idx,
    input  wire [ 7:0] ep00_resp,
    // endpoint 0x81 data input (device-to-host)
    input  wire [ 7:0] ep81_data,     // IN data byte
    input  wire [7:0]  ep81_size,
    input  wire        ep81_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep81_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x82 data input (device-to-host)
    input  wire [ 7:0] ep82_data,     // IN data byte
    input  wire        ep82_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep82_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x83 data input (device-to-host)
    input  wire [ 7:0] ep83_data,     // IN data byte
    input  wire        ep83_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep83_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x84 data input (device-to-host)
    input  wire [ 7:0] ep84_data,     // IN data byte
    input  wire        ep84_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep84_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x85 data input (device-to-host)
    input  wire [ 7:0] ep85_data,     // IN data byte
    input  wire        ep85_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep85_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x86 data input (device-to-host)
    input  wire [ 7:0] ep86_data,     // IN data byte
    input  wire        ep86_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep86_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x87 data input (device-to-host)
    input  wire [ 7:0] ep87_data,     // IN data byte
    input  wire        ep87_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep87_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x88 data input (device-to-host)
    input  wire [ 7:0] ep88_data,     // IN data byte
    input  wire        ep88_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep88_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x89 data input (device-to-host)
    input  wire [ 7:0] ep89_data,     // IN data byte
    input  wire        ep89_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep89_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x8A data input (device-to-host)
    input  wire [ 7:0] ep8A_data,     // IN data byte
    input  wire        ep8A_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep8A_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x8B data input (device-to-host)
    input  wire [ 7:0] ep8B_data,     // IN data byte
    input  wire [7:0]  ep8B_size,
    input  wire        ep8B_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep8B_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x8C data input (device-to-host)
    input  wire [ 7:0] ep8C_data,     // IN data byte
    input  wire        ep8C_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep8C_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x8D data input (device-to-host)
    input  wire [ 7:0] ep8D_data,     // IN data byte
    input  wire        ep8D_valid,    // when device want to send a data byte, assert valid=1. the data byte will be sent successfully when valid=1 & ready=1.
    output wire        ep8D_ready,    // handshakes with valid. ready=1 indicates the data byte can be accept.
    // endpoint 0x01 data output (host-to-device)
    output wire [ 7:0] ep01_data,     // OUT data byte
    output wire        ep01_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x02 data output (host-to-device)
    output wire [ 7:0] ep02_data,     // OUT data byte
    output wire        ep02_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x03 data output (host-to-device)
    output wire [ 7:0] ep03_data,     // OUT data byte
    output wire        ep03_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x04 data output (host-to-device)
    output wire [ 7:0] ep04_data,     // OUT data byte
    output wire        ep04_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x05 data output (host-to-device)
    output wire [ 7:0] ep05_data,     // OUT data byte
    output wire        ep05_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x06 data output (host-to-device)
    output wire [ 7:0] ep06_data,     // OUT data byte
    output wire        ep06_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x07 data output (host-to-device)
    output wire [ 7:0] ep07_data,     // OUT data byte
    output wire        ep07_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x08 data output (host-to-device)
    output wire [ 7:0] ep08_data,     // OUT data byte
    output wire        ep08_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x09 data output (host-to-device)
    output wire [ 7:0] ep09_data,     // OUT data byte
    output wire        ep09_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x0A data output (host-to-device)
    output wire [ 7:0] ep0A_data,     // OUT data byte
    output wire        ep0A_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x0B data output (host-to-device)
    output wire [ 7:0] ep0B_data,     // OUT data byte
    output wire        ep0B_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x0C data output (host-to-device)
    output wire [ 7:0] ep0C_data,     // OUT data byte
    output wire        ep0C_valid,    // when out_valid=1 pulses, a data byte is received on out_data
    // endpoint 0x0D data output (host-to-device)
    output wire [ 7:0] ep0D_data,     // OUT data byte
    output wire        ep0D_valid,    // when out_valid=1 pulses, a data byte is received on out_data

    output wire        controller_count_start,
    input wire [3:0]  Mode_Select,
    // debug output info, only for USB developers, can be ignored for normally use
    output wire        debug_en,      // when debug_en=1 pulses, a byte of debug info appears on debug_data
    output wire [ 7:0] debug_data,    // 
    output wire        debug_uart_tx  // debug_uart_tx is the signal after converting {debug_en,debug_data} to UART (format: 115200,8,n,1). If you want to transmit debug info via UART, you can use this signal. If you want to transmit debug info via other custom protocols, please ignore this signal and use {debug_en,debug_data}.
);



initial usb_dp_pull = 1'b0;
initial usb_rstn    = 1'b0;

//-------------------------------------------------------------------------------------------------------------------------------------
// USB driving signals
//-------------------------------------------------------------------------------------------------------------------------------------
wire        usb_oe;
wire        usb_dp_tx;
wire        usb_dn_tx;

//-------------------------------------------------------------------------------------------------------------------------------------
// USB bit-level RX signals
//-------------------------------------------------------------------------------------------------------------------------------------
wire        rx_sta;
wire        rx_ena;
wire        rx_bit;
wire        rx_fin;

//-------------------------------------------------------------------------------------------------------------------------------------
// USB bit-level TX signals
//-------------------------------------------------------------------------------------------------------------------------------------
wire        tx_sta;
wire        tx_req;
wire        tx_bit;
wire        tx_fin;

//-------------------------------------------------------------------------------------------------------------------------------------
// USB packet-level RX signals
//-------------------------------------------------------------------------------------------------------------------------------------
wire [ 3:0] rp_pid;
wire [10:0] rp_addr;
wire        rp_byte_en;
wire [ 7:0] rp_byte;
wire        rp_fin;
wire        rp_okay;


//-------------------------------------------------------------------------------------------------------------------------------------
// USB packet-level TX signals
//-------------------------------------------------------------------------------------------------------------------------------------
wire        tp_sta;
wire [ 3:0] tp_pid;
wire        tp_byte_req;
wire [ 7:0] tp_byte;
wire        tp_fin_n;



//-------------------------------------------------------------------------------------------------------------------------------------
// USB reset control (device reset when rstn=0 and maintain for 2000ms, host reset when dp=dn=0 for 5us)
//-------------------------------------------------------------------------------------------------------------------------------------
localparam RESET_CYCLES = 120000000;  // 2000ms

reg  [31:0] usb_rstn_cnt = 0;

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        usb_dp_pull <= 1'b0;
        usb_rstn <= 1'b0;
        usb_rstn_cnt <= 0;
    end else begin
        if (usb_rstn_cnt < RESET_CYCLES) begin
            usb_dp_pull <= 1'b0;
            usb_rstn <= 1'b0;
            usb_rstn_cnt <= usb_rstn_cnt + 1;
        end else if (usb_dp != usb_dn) begin
            usb_dp_pull <= 1'b1;
            usb_rstn <= 1'b1;
            usb_rstn_cnt <= RESET_CYCLES + 300;
        end else if (usb_rstn_cnt > RESET_CYCLES) begin
            usb_dp_pull <= 1'b1;
            usb_rstn <= 1'b1;
            usb_rstn_cnt <= usb_rstn_cnt - 1;
        end else begin
            usb_dp_pull <= 1'b1;
            usb_rstn <= 1'b0;
        end
    end



//-------------------------------------------------------------------------------------------------------------------------------------
// USB D+ and D- tri-state driver
//-------------------------------------------------------------------------------------------------------------------------------------
assign usb_dp = usb_oe ? usb_dp_tx : 1'bz;
assign usb_dn = usb_oe ? usb_dn_tx : 1'bz;



//-------------------------------------------------------------------------------------------------------------------------------------
// USB bit-level
//-------------------------------------------------------------------------------------------------------------------------------------
usbfs_bitlevel u_usbfs_bitlevel (
    .rstn               ( usb_rstn           ),
    .clk                ( clk                ),
    .usb_oe             ( usb_oe             ),
    .usb_dp_tx          ( usb_dp_tx          ),
    .usb_dn_tx          ( usb_dn_tx          ),
    .usb_dp_rx          ( usb_dp             ),
    .usb_dn_rx          ( usb_dn             ),
    .rx_sta             ( rx_sta             ),
    .rx_ena             ( rx_ena             ),
    .rx_bit             ( rx_bit             ),
    .rx_fin             ( rx_fin             ),
    .tx_sta             ( tx_sta             ),
    .tx_req             ( tx_req             ),
    .tx_bit             ( tx_bit             ),
    .tx_fin             ( tx_fin             )
);



//-------------------------------------------------------------------------------------------------------------------------------------
// USB packet-level RX to bit-level RX
//-------------------------------------------------------------------------------------------------------------------------------------
usbfs_packet_rx u_usbfs_packet_rx (
    .rstn               ( usb_rstn           ),
    .clk                ( clk                ),
    .rx_sta             ( rx_sta             ),
    .rx_ena             ( rx_ena             ),
    .rx_bit             ( rx_bit             ),
    .rx_fin             ( rx_fin             ),
    .rp_pid             ( rp_pid             ),
    .rp_addr            ( rp_addr            ),
    .rp_byte_en         ( rp_byte_en         ),
    .rp_byte            ( rp_byte            ),
    .rp_fin             ( rp_fin             ),
    .rp_okay            ( rp_okay            )
);



//-------------------------------------------------------------------------------------------------------------------------------------
// USB packet-level TX to bit-level TX
//-------------------------------------------------------------------------------------------------------------------------------------
usbfs_packet_tx u_usbfs_packet_tx (
    .rstn               ( usb_rstn           ),
    .clk                ( clk                ),
    .tp_sta             ( tp_sta             ),
    .tp_pid             ( tp_pid             ),
    .tp_byte_req        ( tp_byte_req        ),
    .tp_byte            ( tp_byte            ),
    .tp_fin_n           ( tp_fin_n           ),
    .tx_sta             ( tx_sta             ),
    .tx_req             ( tx_req             ),
    .tx_bit             ( tx_bit             ),
    .tx_fin             ( tx_fin             )
);



//-------------------------------------------------------------------------------------------------------------------------------------
// USB transaction-level
//-------------------------------------------------------------------------------------------------------------------------------------
usbfs_transaction #(
    .DESCRIPTOR_DEVICE_GCNSO  ( DESCRIPTOR_DEVICE_GCNSO ),
    .DESCRIPTOR_DEVICE_XBOX  ( DESCRIPTOR_DEVICE_XBOX  ),
    .DESCRIPTOR_DEVICE_HORI2  ( DESCRIPTOR_DEVICE_HORI2  ),
    .DESCRIPTOR_DEVICE_GCA  ( DESCRIPTOR_DEVICE_GCA  ),
    .DESCRIPTOR_STR1    ( DESCRIPTOR_STR1    ),
    .DESCRIPTOR_STR2    ( DESCRIPTOR_STR2    ),
    .DESCRIPTOR_STR3    ( DESCRIPTOR_STR3    ),
    .DESCRIPTOR_STR4    ( DESCRIPTOR_STR4    ),
    .DESCRIPTOR_STR5    ( DESCRIPTOR_STR5    ),
    .DESCRIPTOR_STR6    ( DESCRIPTOR_STR6    ),
    .DESCRIPTOR_STR7gc    ( DESCRIPTOR_STR7gc    ),
    .DESCRIPTOR_STR7XBOX    ( DESCRIPTOR_STR7XBOX    ),
    .DESCRIPTOR_STR8    ( DESCRIPTOR_STR8    ),
    .DESCRIPTOR_STR10    ( DESCRIPTOR_STR10    ),
    .DESCRIPTOR_STREE    ( DESCRIPTOR_STREE    ),
    .DESCRIPTOR_CONFIG_GCNSO  ( DESCRIPTOR_CONFIG_GCNSO  ),
    .DESCRIPTOR_CONFIG_XBOX  ( DESCRIPTOR_CONFIG_XBOX  ),
    .DESCRIPTOR_CONFIG_HORI2  ( DESCRIPTOR_CONFIG_HORI2  ),
    .DESCRIPTOR_CONFIG_GCA  ( DESCRIPTOR_CONFIG_GCA  ),
    .EP00_MAXPKTSIZE    ( EP00_MAXPKTSIZE    ),
    .EP81_MAXPKTSIZE    ( EP81_MAXPKTSIZE    ),
    .EP82_MAXPKTSIZE    ( EP82_MAXPKTSIZE    ),
    .EP83_MAXPKTSIZE    ( EP83_MAXPKTSIZE    ),
    .EP84_MAXPKTSIZE    ( EP84_MAXPKTSIZE    ),
    .EP85_MAXPKTSIZE    ( EP85_MAXPKTSIZE    ),
    .EP86_MAXPKTSIZE    ( EP86_MAXPKTSIZE    ),
    .EP87_MAXPKTSIZE    ( EP87_MAXPKTSIZE    ),
    .EP88_MAXPKTSIZE    ( EP88_MAXPKTSIZE    ),
    .EP89_MAXPKTSIZE    ( EP89_MAXPKTSIZE    ),
    .EP8A_MAXPKTSIZE    ( EP8A_MAXPKTSIZE    ),
    .EP8B_MAXPKTSIZE    ( EP8B_MAXPKTSIZE    ),
    .EP8C_MAXPKTSIZE    ( EP8C_MAXPKTSIZE    ),
    .EP8D_MAXPKTSIZE    ( EP8D_MAXPKTSIZE    ),
    .EP81_ISOCHRONOUS   ( 1'b0   ),
    .EP82_ISOCHRONOUS   ( 1'b0   ),
    .EP83_ISOCHRONOUS   ( 1'b0   ),
    .EP84_ISOCHRONOUS   ( 1'b0   ),
    .EP85_ISOCHRONOUS   ( 1'b0   ),
    .EP86_ISOCHRONOUS   ( 1'b0   ),
    .EP87_ISOCHRONOUS   ( 1'b0   ),
    .EP88_ISOCHRONOUS   ( 1'b0   ),
    .EP89_ISOCHRONOUS   ( 1'b0   ),
    .EP8A_ISOCHRONOUS   ( 1'b0   ),
    .EP8B_ISOCHRONOUS   ( 1'b0   ),
    .EP8C_ISOCHRONOUS   ( 1'b0   ),
    .EP8D_ISOCHRONOUS   ( 1'b0   ),
    .EP01_ISOCHRONOUS   ( 1'b0   ),
    .EP02_ISOCHRONOUS   ( 1'b0   ),
    .EP03_ISOCHRONOUS   ( 1'b0   ),
    .EP04_ISOCHRONOUS   ( 1'b0   ),
    .EP05_ISOCHRONOUS   ( 1'b0   ),
    .EP06_ISOCHRONOUS   ( 1'b0   ),
    .EP07_ISOCHRONOUS   ( 1'b0   ),
    .EP08_ISOCHRONOUS   ( 1'b0   ),
    .EP09_ISOCHRONOUS   ( 1'b0   ),
    .EP0A_ISOCHRONOUS   ( 1'b0   ),
    .EP0B_ISOCHRONOUS   ( 1'b0   ),
    .EP0C_ISOCHRONOUS   ( 1'b0   ),
    .EP0D_ISOCHRONOUS   ( 1'b0   )
) u_usbfs_transaction (
    .rstn               ( usb_rstn           ),
    .clk                ( clk                ),
    .rp_pid             ( rp_pid             ),
    .rp_endp            ( rp_addr[10:7]      ),
    .rp_address         ( rp_addr[6:0] ),
    .rp_byte_en         ( rp_byte_en         ),
    .rp_byte            ( rp_byte            ),
    .rp_fin             ( rp_fin             ),
    .rp_okay            ( rp_okay            ),
    .tp_sta             ( tp_sta             ),
    .tp_pid             ( tp_pid             ),
    .tp_byte_req        ( tp_byte_req        ),
    .tp_byte            ( tp_byte            ),
    .tp_fin_n           ( tp_fin_n           ),
    .sot                ( sot                ),
    .sof                ( sof                ),
    .ep00_setup_cmd     ( ep00_setup_cmd     ),
    .ep00_resp_idx      ( ep00_resp_idx      ),
    .ep00_resp          ( ep00_resp          ),
    .ep81_data          ( ep81_data          ),
    .ep81_size          ( ep81_size  ),
    .ep81_valid         ( ep81_valid         ),
    .ep81_ready         ( ep81_ready         ),
    .ep82_data          ( ep82_data          ),
    .ep82_valid         ( ep82_valid         ),
    .ep82_ready         ( ep82_ready         ),
    .ep83_data          ( ep83_data          ),
    .ep83_valid         ( ep83_valid         ),
    .ep83_ready         ( ep83_ready         ),
    .ep84_data          ( ep84_data          ),
    .ep84_valid         ( ep84_valid         ),
    .ep84_ready         ( ep84_ready         ),
    .ep85_data          ( ep85_data          ),
    .ep85_valid         ( ep85_valid         ),
    .ep85_ready         ( ep85_ready         ),
    .ep86_data          ( ep86_data          ),
    .ep86_valid         ( ep86_valid         ),
    .ep86_ready         ( ep86_ready         ),
    .ep87_data          ( ep87_data          ),
    .ep87_valid         ( ep87_valid         ),
    .ep87_ready         ( ep87_ready         ),
    .ep88_data          ( ep88_data          ),
    .ep88_valid         ( ep88_valid         ),
    .ep88_ready         ( ep88_ready         ),
    .ep89_data          ( ep89_data          ),
    .ep89_valid         ( ep89_valid         ),
    .ep89_ready         ( ep89_ready         ),
    .ep8A_data          ( ep8A_data          ),
    .ep8A_valid         ( ep8A_valid         ),
    .ep8A_ready         ( ep8A_ready         ),
    .ep8B_data          ( ep8B_data          ),
    .ep8B_size          ( ep8B_size  ),
    .ep8B_valid         ( ep8B_valid         ),
    .ep8B_ready         ( ep8B_ready         ),
    .ep8C_data          ( ep8C_data          ),
    .ep8C_valid         ( ep8C_valid         ),
    .ep8C_ready         ( ep8C_ready         ),
    .ep8D_data          ( ep8D_data          ),
    .ep8D_valid         ( ep8D_valid         ),
    .ep8D_ready         ( ep8D_ready         ),
    .ep01_data          ( ep01_data          ),
    .ep01_valid         ( ep01_valid         ),
    .ep02_data          ( ep02_data          ),
    .ep02_valid         ( ep02_valid         ),
    .ep03_data          ( ep03_data          ),
    .ep03_valid         ( ep03_valid         ),
    .ep04_data          ( ep04_data          ),
    .ep04_valid         ( ep04_valid         ),
    .ep05_data          ( ep05_data          ),
    .ep05_valid         ( ep05_valid         ),
    .ep06_data          ( ep06_data          ),
    .ep06_valid         ( ep06_valid         ),
    .ep07_data          ( ep07_data          ),
    .ep07_valid         ( ep07_valid         ),
    .ep08_data          ( ep08_data          ),
    .ep08_valid         ( ep08_valid         ),
    .ep09_data          ( ep09_data          ),
    .ep09_valid         ( ep09_valid         ),
    .ep0A_data          ( ep0A_data          ),
    .ep0A_valid         ( ep0A_valid         ),
    .ep0B_data          ( ep0B_data          ),
    .ep0B_valid         ( ep0B_valid         ),
    .ep0C_data          ( ep0C_data          ),
    .ep0C_valid         ( ep0C_valid         ),
    .ep0D_data          ( ep0D_data          ),
    .ep0D_valid         ( ep0D_valid         ),
    .Mode_Select        ( Mode_Select ),
.controller_count_start ( controller_count_start)
);



//-------------------------------------------------------------------------------------------------------------------------------------
// for printing debug info. Can be ignored in normal use.
//-------------------------------------------------------------------------------------------------------------------------------------

generate
if (DEBUG == "TRUE") begin

usbfs_debug_monitor u_usbfs_debug_monitor (
    .rstn               ( usb_rstn           ),
    .clk                ( clk                ),
    .rp_pid             ( rp_pid             ),
    .rp_endp            ( rp_addr[10:7]      ),
    .rp_address         ( rp_addr[6:0] ),   
    .rp_byte_en         ( rp_byte_en         ),
    .rp_byte            ( rp_byte            ),
    .rp_fin             ( rp_fin             ),
    .rp_okay            ( rp_okay            ),
    .tp_pid             ( tp_pid             ),
    .tp_byte_req        ( tp_byte_req        ),
    .tp_byte            ( tp_byte            ),
    .tp_fin_n           ( tp_fin_n           ),
    .debug_en           ( debug_en           ),
    .debug_data         ( debug_data         )
);

usbfs_debug_uart_tx #(
    .CLK_DIV            ( 521                ),   // 60MHz/521 = 115200
    .ASIZE              ( 14                 )    // buffer size = 2^14=16384 bytes
) u_usbfs_debug_uart_tx (
    .rstn               ( usb_rstn           ),
    .clk                ( clk                ),
    .tx_data            ( debug_data         ),
    .tx_en              ( debug_en           ),
    .tx_rdy             (                    ),
    .o_uart_tx          ( debug_uart_tx      )
);

end else begin

assign debug_en = 1'b0;
assign debug_data = 8'h0;
assign debug_uart_tx = 1'b1;    // print nothing on UART

end
endgenerate



endmodule