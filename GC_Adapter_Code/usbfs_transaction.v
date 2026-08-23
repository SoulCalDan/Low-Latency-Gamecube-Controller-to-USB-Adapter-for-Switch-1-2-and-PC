
//--------------------------------------------------------------------------------------------------------
// Module  : usbfs_transaction
// Type    : synthesizable, IP's sub module
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: USB device transaction level controller
//--------------------------------------------------------------------------------------------------------
// ep00_setup_cmd structure:
// |  wLength  |  wIndex   |  wValue   |  bRequest  |  bmRequestType                      |
// |  wLength  |  wIndex   |  wValue   |  bRequest  |  Direction  |  Type   |  Recipient  |
// |  [63:48]  |  [47:32]  |  [31:16]  |  [15:8]    |  [7]        |  [6:5]  |  [4:0]      |
//--------------------------------------------------------------------------------------------------------

module usbfs_transaction #(
    parameter [ 18*8-1:0] DESCRIPTOR_DEVICE_GCNSO = 0,                  // 18  byte capacity
    parameter [ 18*8-1:0] DESCRIPTOR_DEVICE_XBOX = 0,                   // 18  byte capacity
    parameter [ 18*8-1:0] DESCRIPTOR_DEVICE_HORI2 = 0,                  // 18  byte capacity
    parameter [ 18*8-1:0] DESCRIPTOR_DEVICE_GCA = 0,                    // 18  byte capacity
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
    parameter       [9:0] EP85_MAXPKTSIZE   = 10'h40,             // endpoint 85 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP86_MAXPKTSIZE   = 10'h40,             // endpoint 86 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP87_MAXPKTSIZE   = 10'h40,             // endpoint 87 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP88_MAXPKTSIZE   = 10'h40,             // endpoint 88 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
    parameter       [9:0] EP89_MAXPKTSIZE   = 10'h40,             // endpoint 89 packet byte length. If it is a ISOCHRONOUS endpoint, MAXPKTSIZE can be 10'h1~10'h3FF, otherwise MAXPKTSIZE can only be 10'h8, 10'h10, 10'h20, or 10'h40.
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
    parameter             EP0A_ISOCHRONOUS  = 0,                  // endpoint 8A is ISOCHRONOUS ?
    parameter             EP0B_ISOCHRONOUS  = 0,                  // endpoint 8B is ISOCHRONOUS ?
    parameter             EP0C_ISOCHRONOUS  = 0,                  // endpoint 8C is ISOCHRONOUS ?
    parameter             EP0D_ISOCHRONOUS  = 0                   // endpoint 8D is ISOCHRONOUS ?
) (
    input  wire        rstn,
    input  wire        clk,
    // RX packet-level signals
    input  wire [ 3:0] rp_pid,
    input  wire [ 3:0] rp_endp,
    input  wire [6:0]  rp_address,
    input  wire        rp_byte_en,
    input  wire [ 7:0] rp_byte,
    input  wire        rp_fin,
    input  wire        rp_okay,
    // TX packet-level signals (device NEVER send token and special packet)
    output reg         tp_sta,
    output reg  [ 3:0] tp_pid,
    input  wire        tp_byte_req,
    output reg  [ 7:0] tp_byte,
    output reg         tp_fin_n,
    // 
    output reg         sot,            // detect a start of USB-transfer
    output reg         sof,            // detect a start of USB-frame
    // endpoint 0 (control endpoint) command response interface
    output reg  [63:0] ep00_setup_cmd,
    output reg  [ 8:0] ep00_resp_idx,
    input  wire [ 7:0] ep00_resp,
    // endpoint 0x81 data input
    input  wire [ 7:0] ep81_data,
    input  wire [7:0]  ep81_size,
    input  wire        ep81_valid,
    output wire        ep81_ready,
    // endpoint 0x82 data input
    input  wire [ 7:0] ep82_data,
    input  wire        ep82_valid,
    output wire        ep82_ready,
    // endpoint 0x83 data input
    input  wire [ 7:0] ep83_data,
    input  wire        ep83_valid,
    output wire        ep83_ready,
    // endpoint 0x84 data input
    input  wire [ 7:0] ep84_data,
    input  wire        ep84_valid,
    output wire        ep84_ready,
    // endpoint 0x85 data input
    input  wire [ 7:0] ep85_data,
    input  wire        ep85_valid,
    output wire        ep85_ready,
    // endpoint 0x86 data input
    input  wire [ 7:0] ep86_data,
    input  wire        ep86_valid,
    output wire        ep86_ready,
    // endpoint 0x87 data input
    input  wire [ 7:0] ep87_data,
    input  wire        ep87_valid,
    output wire        ep87_ready,
    // endpoint 0x88 data input
    input  wire [ 7:0] ep88_data,
    input  wire        ep88_valid,
    output wire        ep88_ready,
    // endpoint 0x89 data input
    input  wire [ 7:0] ep89_data,
    input  wire        ep89_valid,
    output wire        ep89_ready,
    // endpoint 0x8A data input
    input  wire [ 7:0] ep8A_data,
    input  wire        ep8A_valid,
    output wire        ep8A_ready,
    // endpoint 0x8B data input
    input  wire [ 7:0] ep8B_data,
    input  wire [7:0]  ep8B_size,
    input  wire        ep8B_valid,
    output wire        ep8B_ready,
    // endpoint 0x8C data input
    input  wire [ 7:0] ep8C_data,
    input  wire        ep8C_valid,
    output wire        ep8C_ready,
    // endpoint 0x8D data input
    input  wire [ 7:0] ep8D_data,
    input  wire        ep8D_valid,
    output wire        ep8D_ready,

    // endpoint 0x01 data output
    output reg  [ 7:0] ep01_data,
    output reg         ep01_valid,
    // endpoint 0x02 data output
    output reg  [ 7:0] ep02_data,
    output reg         ep02_valid,
    // endpoint 0x03 data output
    output reg  [ 7:0] ep03_data,
    output reg         ep03_valid,
    // endpoint 0x04 data output
    output reg  [ 7:0] ep04_data,
    output reg         ep04_valid,
    // endpoint 0x05 data output
    output reg  [ 7:0] ep05_data,
    output reg         ep05_valid,
    // endpoint 0x06 data output
    output reg  [ 7:0] ep06_data,
    output reg         ep06_valid,
    // endpoint 0x07 data output
    output reg  [ 7:0] ep07_data,
    output reg         ep07_valid,
    // endpoint 0x08 data output
    output reg  [ 7:0] ep08_data,
    output reg         ep08_valid,
    // endpoint 0x09 data output
    output reg  [ 7:0] ep09_data,
    output reg         ep09_valid,
    // endpoint 0x04 data output
    output reg  [ 7:0] ep0A_data,
    output reg         ep0A_valid,
    // endpoint 0x04 data output
    output reg  [ 7:0] ep0B_data,
    output reg         ep0B_valid,
    // endpoint 0x04 data output
    output reg  [ 7:0] ep0C_data,
    output reg         ep0C_valid,
    // endpoint 0x04 data output
    output reg  [ 7:0] ep0D_data,
    output reg         ep0D_valid,

    input  wire [3:0]  Mode_Select,
    output reg         controller_count_start 
);

initial tp_sta   = 1'b0;
initial tp_pid   = 4'h0;
initial tp_byte  = 8'h0;
initial tp_fin_n = 1'b0;
initial sot = 1'b0;
initial sof = 1'b0;
initial ep00_setup_cmd = 64'h0;
initial ep00_resp_idx  = 9'h0;
initial ep01_data  = 8'h0;  initial ep01_valid = 1'b0;
initial ep02_data  = 8'h0;  initial ep02_valid = 1'b0;
initial ep03_data  = 8'h0;  initial ep03_valid = 1'b0;
initial ep04_data  = 8'h0;  initial ep04_valid = 1'b0;
initial ep05_data  = 8'h0;  initial ep05_valid = 1'b0;
initial ep06_data  = 8'h0;  initial ep06_valid = 1'b0;
initial ep07_data  = 8'h0;  initial ep07_valid = 1'b0;
initial ep08_data  = 8'h0;  initial ep08_valid = 1'b0;
initial ep09_data  = 8'h0;  initial ep09_valid = 1'b0;
initial ep0A_data  = 8'h0;  initial ep0A_valid = 1'b0;
initial ep0B_data  = 8'h0;  initial ep0B_valid = 1'b0;
initial ep0C_data  = 8'h0;  initial ep0C_valid = 1'b0;
initial ep0D_data  = 8'h0;  initial ep0D_valid = 1'b0;
initial controller_count_start = 1'b0;

localparam [3:0] PID_OUT    = 4'h1;
localparam [3:0] PID_IN     = 4'h9;
localparam [3:0] PID_SETUP  = 4'hD;
localparam [3:0] PID_SOF    = 4'h5;
localparam [3:0] PID_DATA0  = 4'h3;
localparam [3:0] PID_DATA1  = 4'hB;
//localparam [3:0] PID_DATA2  = 4'h7;  // unused in USB 1.1
//localparam [3:0] PID_MDATA  = 4'hF;  // unused in USB 1.1
localparam [3:0] PID_ACK    = 4'h2;
localparam [3:0] PID_NAK    = 4'hA;
localparam [3:0] PID_STALL  = 4'hE;  // unused in this USB 1.1 device core
//localparam [3:0] PID_NYET   = 4'h6;  // unused in USB 1.1


reg [ 9:0] tp_cnt = 10'h0;
reg [ 3:0] endp = 4'h0;
reg [ 6:0] address_setup = 7'b0;
reg  [6:0] dev_addr;
wire       addr_match; 
wire is_set_address_cmd;
assign addr_match =    (rp_address == dev_addr) || (((dev_addr == 7'd0) && (rp_address == 7'd0)) && configured == 0);
assign is_set_address_cmd = (
       (ep00_setup_cmd[15:8] == 8'h05) &&   // SET_ADDRESS
       (ep00_setup_cmd[7:0]  == 8'h00) );  // Host→Device
reg configured; 

reg        ep00_setup = 1'b0;
reg [15:0] ep00_total = 16'h0;
(*  syn_noprune *) reg [ 7:0] ep00_data  = 8'h0;
reg        ep00_data1 = 1'b0;
reg        ep81_data1 = 1'b0;
reg        ep82_data1 = 1'b0;
reg        ep83_data1 = 1'b0;
reg        ep84_data1 = 1'b0;
reg        ep85_data1 = 1'b0;
reg        ep86_data1 = 1'b0;
reg        ep87_data1 = 1'b0;
reg        ep88_data1 = 1'b0;
reg        ep89_data1 = 1'b0;
reg        ep8A_data1 = 1'b0;
reg        ep8B_data1 = 1'b0;
reg        ep8C_data1 = 1'b0;
reg        ep8D_data1 = 1'b0;

reg [4:0] NAK_cnt = 5'b0;
reg [3:0] GCA_NAK = 4'b0; //create artificial NAK packets on Gamecube Adapter to sync to game's framerate

wire [13:0] ep8x_valid = {ep8D_valid, ep8C_valid, ep8B_valid, ep8A_valid, ep89_valid, ep88_valid, ep87_valid, ep86_valid, ep85_valid, ep84_valid, ep83_valid, ep82_valid, ep81_valid, 1'b1};
wire [7:0] ep8x_data [13:0];
assign ep8x_data[0] =  ep00_data;
assign ep8x_data[1] =  ep81_data;
assign ep8x_data[2] =  ep82_data;
assign ep8x_data[3] =  ep83_data;
assign ep8x_data[4] =  ep84_data;
assign ep8x_data[5] =  ep85_data;
assign ep8x_data[6] =  ep86_data;
assign ep8x_data[7] =  ep87_data;
assign ep8x_data[8] =  ep88_data;
assign ep8x_data[9] =  ep89_data;
assign ep8x_data[10] = ep8A_data;
assign ep8x_data[11] = ep8B_data;
assign ep8x_data[12] = ep8C_data;
assign ep8x_data[13] = ep8D_data;


//-------------------------------------------------------------------------------------------------------------------------------------
// main
//-------------------------------------------------------------------------------------------------------------------------------------
always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        tp_sta   <= 1'b0;
        tp_pid   <= 4'h0;
        tp_byte  <= 8'h0;
        tp_fin_n <= 1'b0;
        tp_cnt <= 10'h0;
        endp   <= 4'h0;
        ep00_setup <= 1'b0;        ep00_total <= 16'h0;        ep00_data1 <= 1'b0;
        ep81_data1 <= 1'b0;
        ep82_data1 <= 1'b0;
        ep83_data1 <= 1'b0;
        ep84_data1 <= 1'b0;
        ep85_data1 <= 1'b0;
        ep86_data1 <= 1'b0;
        ep87_data1 <= 1'b0;
        ep88_data1 <= 1'b0;
        ep89_data1 <= 1'b0;
        ep8A_data1 <= 1'b0;
        ep8B_data1 <= 1'b0;
        ep8C_data1 <= 1'b0;
        ep8D_data1 <= 1'b0;
        ep00_resp_idx <= 9'h0;
        dev_addr <= 7'b0;
        configured <= 0;
    end else begin
        tp_sta <= 1'b0;
        if (rp_fin & rp_okay) begin                                                                  // recv a packet
            if ((rp_pid == PID_SETUP && rp_endp == 4'd0) && addr_match ) begin                       //   recv SETUP token
                endp <= rp_endp;                                                                     //
                if (rp_endp == 4'd0) begin                                                           //
                    if (ep00_setup_cmd[31:0] == 32'h0600_06_80) begin
                        tp_pid <= PID_STALL;
                    end
                    ep00_setup <= 1'b1;                                                              //
                    ep00_data1 <= 1'b1;                                                              //
                end                                                                                  
            end else if (rp_pid == PID_OUT && addr_match) begin                                      //   recv OUT token
                endp <= rp_endp;                                                                     //
                if (rp_endp == 4'd0)                                                                 //
                    ep00_setup <= 1'b0;                                                              //
            end else if (rp_pid == PID_IN && addr_match) begin                                       //   recv IN token
                endp <= rp_endp;                                                                     //
                tp_sta <= 1'b1;                                                                      //
                tp_pid <= PID_NAK;                                                                   //     send NAK by default
                tp_cnt <= 10'h0;                                                                     //     send len = 0 by default
                if (rp_endp == 4'd0) begin                                                           //     if IN ENDP=0
                    ep00_setup <= 1'b0;                                                              //
                    tp_pid <= ep00_data1 ? PID_DATA1 : PID_DATA0;                                    //     send DATA1 or DATA0
                    if (ep00_total >= {8'h0,EP00_MAXPKTSIZE}) begin                                  //
                        tp_cnt <= {2'h0, EP00_MAXPKTSIZE};                                           //
                        ep00_total <= ep00_total - {8'h0,EP00_MAXPKTSIZE};                           //
                    end else begin                                                                   
                        tp_cnt <= {2'h0, ep00_total[7:0]};                                           //
                        ep00_total <= 16'h0;                                                         //
                    end                                                                              
                end 
                else if (rp_endp == 4'd1) begin                                                      //     if IN ENDP=1
                    if (ep81_valid) begin                                                            //
                        tp_pid <= (ep81_data1 && !EP81_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= ep81_size;
                    end
                end else if (rp_endp == 4'd2) begin                                                  //     if IN ENDP=2
                    if (ep82_valid) begin                                                            //
                        tp_pid <= (ep82_data1 && !EP82_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP82_MAXPKTSIZE;                                                   //
                    end                                                                              
                end else if (rp_endp == 4'd3) begin                                                  //     if IN ENDP=3
                    if (ep83_valid) begin                                                            //
                        tp_pid <= (ep83_data1 && !EP83_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP83_MAXPKTSIZE;                                                   //
                    end                                                                              
                end else if (rp_endp == 4'd4) begin                                                  //     if IN ENDP=4
                    if (ep84_valid) begin                 
                        tp_pid <= (ep84_data1 && !EP84_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP84_MAXPKTSIZE;
                    end                                                                              //                          
                end else if (rp_endp == 4'd5) begin                                                  //     if IN ENDP=5
                    if (ep85_valid) begin                                                            //
                        tp_pid <= (ep85_data1 && !EP85_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP85_MAXPKTSIZE;
                    end
                end else if (rp_endp == 4'd6) begin                                                  //     if IN ENDP=6
                    if (ep86_valid) begin                                                            //
                        tp_pid <= (ep86_data1 && !EP86_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP86_MAXPKTSIZE;                                                   //
                    end                                                                              
                end else if (rp_endp == 4'd7) begin                                                  //     if IN ENDP=7
                    if (ep87_valid) begin                                                            //
                        tp_pid <= (ep87_data1 && !EP87_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP87_MAXPKTSIZE;                                                   //
                    end                                                                              
                end else if (rp_endp == 4'd8) begin                                                  //     if IN ENDP=8
                    if (ep88_valid) begin                 
                        tp_pid <= (ep88_data1 && !EP88_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP88_MAXPKTSIZE;
                    end  
                end else if (rp_endp == 4'd9) begin                                                  //     if IN ENDP=9
                    if (ep89_valid) begin                 
                        tp_pid <= (ep89_data1 && !EP89_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP89_MAXPKTSIZE;
                    end                                                                              //
                end else if (rp_endp == 4'hA) begin                                                  //     if IN ENDP=A
                    if (ep8A_valid) begin  
                        if ( NAK_cnt < 5'b11110 ) begin    //Enabling GC NSO joystick too soon results in the stick not working. Adding artificial delay for Switch 2.
                            tp_pid <= PID_NAK;
                            NAK_cnt <= NAK_cnt + 1'b1;
                        end else begin
                            tp_pid <= (ep8A_data1 && !EP8A_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                            tp_cnt <= EP8A_MAXPKTSIZE;
                        end
                        controller_count_start <= 1'b1;
                    end                                                                              //
                end else if (rp_endp == 4'hB) begin                                                  //     if IN ENDP=B
                    if (ep8B_valid) begin                 
                        tp_pid <= (ep8B_data1 && !EP8B_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= ep8B_size;
                    end                                                                              //
                end else if (rp_endp == 4'hC) begin                                                  //     if IN ENDP=C
                    if (ep8C_valid) begin                 
                        tp_pid <= (ep8C_data1 && !EP8C_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP8C_MAXPKTSIZE;
                    end                                                                              //
                end else if (rp_endp == 4'hD) begin                                                  //     if IN ENDP=D
                    if (ep8D_valid) begin                 
                        tp_pid <= (ep8D_data1 && !EP8D_ISOCHRONOUS) ? PID_DATA1 : PID_DATA0;
                        tp_cnt <= EP8D_MAXPKTSIZE;
                    end                                                                              //
                end
            end else if ( rp_pid == PID_ACK ) begin                                                  //    recv ACK handshake

            // Apply set_address after status stage ACK
                if (endp == 4'd0 && is_set_address_cmd  && configured == 0) begin
                    dev_addr <= address_setup; configured <= 1;
                end

                if      (endp == 4'd0)
                    ep00_data1 <= ~ep00_data1;                                                       //       DATA0/1 flop
                else if (endp == 4'd1)
                    ep81_data1 <= ~ep81_data1 && !EP81_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'd2)
                    ep82_data1 <= ~ep82_data1 && !EP82_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'd3)
                    ep83_data1 <= ~ep83_data1 && !EP83_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'd4)
                    ep84_data1 <= ~ep84_data1 && !EP84_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'd5)
                    ep85_data1 <= ~ep85_data1 && !EP85_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'd6)
                    ep86_data1 <= ~ep86_data1 && !EP86_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'd7)
                    ep87_data1 <= ~ep87_data1 && !EP87_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'd8)
                    ep88_data1 <= ~ep88_data1 && !EP88_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'd9)
                    ep89_data1 <= ~ep89_data1 && !EP89_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'hA)
                    ep8A_data1 <= ~ep8A_data1 && !EP8A_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'hB)
                    ep8B_data1 <= ~ep8B_data1 && !EP8B_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'hC)
                    ep8C_data1 <= ~ep8C_data1 && !EP8C_ISOCHRONOUS;                                  //       DATA0/1 flop
                else if (endp == 4'hD)
                    ep8D_data1 <= ~ep8D_data1 && !EP8D_ISOCHRONOUS;                                  //       DATA0/1 flop

            end else if ((rp_pid == PID_DATA0 || rp_pid == PID_DATA1) && addr_match == 1 ) begin     //   recv packet is DATA0 or DATA1
                if (endp == 4'd0) begin                                                              //   previous token (OUT or setup) is endpoint 00 
                    ep00_total <= 16'h0;                                                             
                    if (ep00_setup) begin                                                            //   if last token = SETUP, device has received a 8byte SETUP command
                        if (ep00_setup_cmd[7]) begin
                            ep00_total <= ep00_setup_cmd[63:48];                                     //
                        end
                        ep00_resp_idx <= 9'h0;                                                       //
                    end
                end                                                                                  //
                tp_sta <= 1'b1;                                                                      //       send ACK by default
                tp_pid <= PID_ACK;                                                                   //       send ACK by default
                if ((endp == 4'd1 && EP01_ISOCHRONOUS) ||                                            //
                    (endp == 4'd2 && EP02_ISOCHRONOUS) ||                                            //
                    (endp == 4'd3 && EP03_ISOCHRONOUS) ||                                            //
                    (endp == 4'd4 && EP04_ISOCHRONOUS) ||
                    (endp == 4'd5 && EP05_ISOCHRONOUS) ||
                    (endp == 4'd6 && EP06_ISOCHRONOUS) ||
                    (endp == 4'd7 && EP07_ISOCHRONOUS) ||
                    (endp == 4'd8 && EP08_ISOCHRONOUS) ||
                    (endp == 4'd9 && EP09_ISOCHRONOUS) ||
                    (endp == 4'hA && EP0A_ISOCHRONOUS) ||                                            //
                    (endp == 4'hB && EP0B_ISOCHRONOUS) ||                                            //
                    (endp == 4'hC && EP0C_ISOCHRONOUS) ||                                            //
                    (endp == 4'hD && EP0D_ISOCHRONOUS) )                                             //     if this recv data packet corresponds to a ISOCHRONOUS OUT endpoint.
                    tp_sta <= 1'b0;                                                                  //     do not send ACK.
            end                                                                                      //
        end                                                                                          //
        if (tp_byte_req) begin
            tp_fin_n <= 1'b0;
            if ( (tp_cnt != 10'h0) && ep8x_valid[endp] ) begin
                tp_cnt <= tp_cnt - 10'd1;
                tp_fin_n <= 1'b1;
                tp_byte <= ep8x_data[endp];
                if (endp == 4'd0)
                    ep00_resp_idx <= ep00_resp_idx + 9'd1;
            end
        end
    end



//-------------------------------------------------------------------------------------------------------------------------------------
// when tp_byte_req=1 , endpoint number matching, and there is data to send, then the IN endpoint is ready to send a data
//-------------------------------------------------------------------------------------------------------------------------------------
assign ep81_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'd1));
assign ep82_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'd2));
assign ep83_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'd3));
assign ep84_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'd4));
assign ep85_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'h5));
assign ep86_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'd6));
assign ep87_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'd7));
assign ep88_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'd8));
assign ep89_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'd9));
assign ep8A_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'hA));
assign ep8B_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'hB));
assign ep8C_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'hC));
assign ep8D_ready = (tp_byte_req && (tp_cnt != 10'h0) && (endp == 4'hD));

//-------------------------------------------------------------------------------------------------------------------------------------
// response IN data on endpoint 0 (control endpoint)
//-------------------------------------------------------------------------------------------------------------------------------------
localparam [31:0] DESCRIPTOR_STR0 = 32'h04_03_09_04;


always @ (posedge clk)
    casex(ep00_setup_cmd[31:0])
        32'hXXXX_08_80  : ep00_data <= (ep00_resp_idx>=  9'd1) ? 8'h00 : 8'h01;                                                   // GetConfiguration -> response configuration 1
        32'h01XX_06_80  : begin
            if ( Mode_Select[0] == 1'b1 ) // A pressed
                ep00_data <= (ep00_resp_idx>= 9'd18) ? 8'h00 : DESCRIPTOR_DEVICE_GCNSO[ (18 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response device descriptor
            else if ( Mode_Select[2] == 1'b1 ) // X pressed
                ep00_data <= (ep00_resp_idx>= 9'd18) ? 8'h00 : DESCRIPTOR_DEVICE_XBOX[ (18 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response device descriptor
            else if ( Mode_Select[3] == 1'b1 ) // Y pressed
                ep00_data <= (ep00_resp_idx>= 9'd18) ? 8'h00 : DESCRIPTOR_DEVICE_HORI2[ (18 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response device descriptor
            else
                ep00_data <= (ep00_resp_idx>= 9'd18) ? 8'h00 : DESCRIPTOR_DEVICE_GCA[ (18 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response device descriptor
        end
        32'h02XX_06_80  : begin
             if ( Mode_Select[0] == 1'b1 ) // A pressed
                ep00_data <=  DESCRIPTOR_CONFIG_GCNSO[ (512- 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response configuration descriptor
            else if ( Mode_Select[2] == 1'b1 ) // X pressed
                ep00_data <=  DESCRIPTOR_CONFIG_XBOX[ (8'hA9 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response configuration descriptor
            else if ( Mode_Select[3] == 1'b1 ) // Y pressed
                ep00_data <=  DESCRIPTOR_CONFIG_HORI2[ (8'h89 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response configuration descriptor
            else 
                ep00_data <=  DESCRIPTOR_CONFIG_GCA[ (8'h29 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response configuration descriptor
        end
        32'h0300_06_80  : ep00_data <= (ep00_resp_idx>=  9'd4) ? 8'h00 : DESCRIPTOR_STR0  [ (4  - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 0
        32'h0301_06_80  : ep00_data <= (ep00_resp_idx>= 9'd64) ? 8'h00 : DESCRIPTOR_STR1  [ (64 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 1
        32'h0302_06_80  : ep00_data <= (ep00_resp_idx>= 9'd42) ? 8'h00 : DESCRIPTOR_STR2  [ (42 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 2
        32'h0303_06_80  : ep00_data <= (ep00_resp_idx>= 9'd40) ? 8'h00 : DESCRIPTOR_STR3  [ (8'd40 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 3
        32'h0304_06_80  : ep00_data <= (ep00_resp_idx>= 9'd64) ? 8'h00 : DESCRIPTOR_STR4  [ (64 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 4
        32'h0305_06_80  : ep00_data <= (ep00_resp_idx>= 9'd64) ? 8'h00 : DESCRIPTOR_STR5  [ (64 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 5
        32'h0306_06_80  : ep00_data <= (ep00_resp_idx>= 9'd64) ? 8'h00 : DESCRIPTOR_STR6  [ (64 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 6
        32'h0000_AF_C0  : begin
            if ( Mode_Select[2] == 1'b1 ) // X pressed 
                ep00_data <= (ep00_resp_idx>= 9'd64) ? 8'h00 : DESCRIPTOR_STR7XBOX  [ (64 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 7 for WINUSB
            else 
                ep00_data <= (ep00_resp_idx>= 9'd64) ? 8'h00 : DESCRIPTOR_STR7gc  [ (64 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 7 for WINUSB
        end
        32'h0000_02_C0  : ep00_data <= (ep00_resp_idx>= 9'd64) ? 8'h00 : DESCRIPTOR_STR8  [ (64 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 8 for Nintendo Switch Pro
        32'h0000_03_C0  : ep00_data <= (ep00_resp_idx>= 9'd64) ? 8'h00 : DESCRIPTOR_STR10 [ (64 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 1 for Nintendo Switch GC Classic
        32'h30EE_06_80  : ep00_data <= (ep00_resp_idx>= 9'd18) ? 8'h00 : DESCRIPTOR_STREE [ (18 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 1 for Nintendo Switch GC Classic
        32'h0F00_06_80  : ep00_data <= (ep00_resp_idx>= 10'd512) ? 8'h00 : DESCRIPTOR_STR9  [ (512 - 1 - ep00_resp_idx) * 8 +: 8 ];  // GetDescriptor -> response string descriptor 9 for Nintendo Switch Pro
//        32'h0001_09_00  : The Nintendo Switch 2 asks for this but Pro1 Controller responds empty
        32'h0600_06_80  : ep00_data <=ep00_resp;//need to STALL
        32'hXXXX_05_00  : address_setup <= ep00_setup_cmd[22:16];//( address_setup != 8'h00 ? address_setup : ep00_setup_cmd[23:16] );  //Set address checker
        //32'hXXXX_01_02  : clear_status//clear status on certain endpoint, need more bytes to determine which endpoint
        default          : ep00_data <= ep00_resp;                                                                                 // other : response by user
    endcase



//-------------------------------------------------------------------------------------------------------------------------------------
// process OUT data
//-------------------------------------------------------------------------------------------------------------------------------------
always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        ep00_setup_cmd <= 64'h0;
        ep01_data  <= 8'h0;        ep01_valid <= 1'b0;
        ep02_data  <= 8'h0;        ep02_valid <= 1'b0;
        ep03_data  <= 8'h0;        ep03_valid <= 1'b0;
        ep04_data  <= 8'h0;        ep04_valid <= 1'b0;
        ep05_data  <= 8'h0;        ep05_valid <= 1'b0;
        ep06_data  <= 8'h0;        ep06_valid <= 1'b0;
        ep07_data  <= 8'h0;        ep07_valid <= 1'b0;
        ep08_data  <= 8'h0;        ep08_valid <= 1'b0;
        ep09_data  <= 8'h0;        ep09_valid <= 1'b0;
        ep0A_data  <= 8'h0;        ep0A_valid <= 1'b0;
        ep0B_data  <= 8'h0;        ep0B_valid <= 1'b0;
        ep0C_data  <= 8'h0;        ep0C_valid <= 1'b0;
        ep0D_data  <= 8'h0;        ep0D_valid <= 1'b0;
    end else begin
        ep01_data  <= 8'h0;        ep01_valid <= 1'b0;
        ep02_data  <= 8'h0;        ep02_valid <= 1'b0;
        ep03_data  <= 8'h0;        ep03_valid <= 1'b0;
        ep04_data  <= 8'h0;        ep04_valid <= 1'b0;
        ep05_data  <= 8'h0;        ep05_valid <= 1'b0;
        ep06_data  <= 8'h0;        ep06_valid <= 1'b0;
        ep07_data  <= 8'h0;        ep07_valid <= 1'b0;
        ep08_data  <= 8'h0;        ep08_valid <= 1'b0;
        ep09_data  <= 8'h0;        ep09_valid <= 1'b0;
        ep0A_data  <= 8'h0;        ep0A_valid <= 1'b0;
        ep0B_data  <= 8'h0;        ep0B_valid <= 1'b0;
        ep0C_data  <= 8'h0;        ep0C_valid <= 1'b0;
        ep0D_data  <= 8'h0;        ep0D_valid <= 1'b0;
        if (rp_byte_en) begin
            if (endp == 4'd0) begin                                        // endpoint 0 OUT -> SETUP command
                if (ep00_setup)
                    ep00_setup_cmd <= {rp_byte, ep00_setup_cmd[63:8]};     // save 8 bytes SETUP command
            end else if (endp == 4'd1) begin                               // endpoint 01 OUT
                ep01_data  <= rp_byte;
                ep01_valid <= 1'b1;
            end else if (endp == 4'd2) begin                               // endpoint 02 OUT
                ep02_data  <= rp_byte;
                ep02_valid <= 1'b1;
            end else if (endp == 4'd3) begin                               // endpoint 03 OUT
                ep03_data  <= rp_byte;
                ep03_valid <= 1'b1;
            end else if (endp == 4'd4) begin                               // endpoint 04 OUT
                ep04_data  <= rp_byte;
                ep04_valid <= 1'b1;
            end else if (endp == 4'd5) begin                               // endpoint 05 OUT
                ep05_data  <= rp_byte;
                ep05_valid <= 1'b1;
            end else if (endp == 4'd6) begin                               // endpoint 06 OUT
                ep06_data  <= rp_byte;
                ep06_valid <= 1'b1;
            end else if (endp == 4'd7) begin                               // endpoint 07 OUT
                ep07_data  <= rp_byte;
                ep07_valid <= 1'b1;
            end else if (endp == 4'd8) begin                               // endpoint 08 OUT
                ep08_data  <= rp_byte;
                ep08_valid <= 1'b1;
            end else if (endp == 4'd9) begin                               // endpoint 09 OUT
                ep09_data  <= rp_byte;
                ep09_valid <= 1'b1;
            end else if (endp == 4'hA) begin                               // endpoint 0A OUT
                ep0A_data  <= rp_byte;
                ep0A_valid <= 1'b1;
            end else if (endp == 4'hB) begin                               // endpoint 0B OUT
                ep0B_data  <= rp_byte;
                ep0B_valid <= 1'b1;
            end else if (endp == 4'hC) begin                               // endpoint 0C OUT
                ep0C_data  <= rp_byte;
                ep0C_valid <= 1'b1;
            end else if (endp == 4'hD) begin                               // endpoint 0D OUT
                ep0D_data  <= rp_byte;
                ep0D_valid <= 1'b1;
            end
        end
    end



//-------------------------------------------------------------------------------------------------------------------------------------
// detect the IN/OUT packet border and the SOF
//-------------------------------------------------------------------------------------------------------------------------------------
always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        sot <= 1'b0;
        sof <= 1'b0;
    end else begin
        sot <= 1'b0;
        sof <= 1'b0;
        if (rp_fin & rp_okay) begin
            if (rp_endp == 4'd0)
                sot <= (rp_pid == PID_SETUP);
            else
                sot <= (rp_pid == PID_IN || rp_pid == PID_OUT);
                sof <= (rp_pid == PID_SOF);
        end
    end



endmodule