
//--------------------------------------------------------------------------------------------------------
// Module  : SwitchWiiU_Adapter
// Type    : synthesizable, IP's top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: A USB Full Speed (12Mbps) device, act as a USB HID keyboard
//--------------------------------------------------------------------------------------------------------

module SwitchWiiU_Adapter #(
    parameter          DEBUG = "FALSE" , // whether to output USB debug info, "TRUE" or "FALSE"
    parameter          byte_cnt = 8'd37 //Added this param to control the number of bits in a controller USB packet
) (
    input  wire        rstn,          // active-low reset, reset when rstn=0 (USB will unplug when reset), normally set to 1
    input  wire        clk,           // 60MHz is required
    // USB signals
    output wire        usb_dp_pull,   // connect to USB D+ by an 1.5k resistor
    output wire        sof,
    inout              usb_dp,        // USB D+
    inout              usb_dn,        // USB D-
    // USB reset output
    output wire        usb_rstn,      // 1: connected , 0: disconnected (when USB cable unplug, or when system reset (rstn=0))
    // HID keyboard press signal
    input  wire [295:0] key_value,     // Indicates which key to press, NOT ASCII code! see https://www.usb.org/sites/default/files/hut1_21_0.pdf section 10.
    // debug output info, only for USB developers, can be ignored for normally use. Please set DEBUG="TRUE" to enable these signals
    output wire        debug_en,      // when debug_en=1 pulses, a byte of debug info appears on debug_data
    output wire [ 7:0] debug_data,    // 
    output wire        debug_uart_tx,  // debug_uart_tx is the signal after converting {debug_en,debug_data} to UART (format: 115200,8,n,1). If you want to transmit debug info via UART, you can use this signal. If you want to transmit debug info via other custom protocols, please ignore this signal and use {debug_en,debug_data}.
    output reg RUMBLE1=0 ,    output reg RUMBLE2 ,    output reg RUMBLE3 ,    output reg RUMBLE4 , output reg oktosend = 0
    
);

wire [7:0] controllers_receive_data; wire out_valid; wire in_ready;

//-------------------------------------------------------------------------------------------------------------------------------------
// HID Rumble Output Detection
//-------------------------------------------------------------------------------------------------------------------------------------

reg [2:0]  out_count = 3'h0; //
reg [39:0] out_host_data = 40'h0;
reg        out_host_en = 1'b0;

always @ (posedge clk or negedge usb_rstn) begin

    if (~usb_rstn) begin
        out_count <= 3'h0;
        out_host_data <= 40'h0;
        out_host_en <= 1'b0;
    end 

    else begin
        out_host_en <= 1'b0;
        if (sof) begin          // reset at start of a new frame
            out_count <= 3'h0;
        end 
        else if (out_valid) begin
            out_count <= out_count + 3'd1;
            out_host_data[39:0] <= {controllers_receive_data,out_host_data[39:8]};
            out_host_en <= (out_count == 3'd4); //get 5 bytes of OUT data from Host (Nintendo Switch)
        end
        if ( out_host_en && (out_host_data[7:0] == 8'h11 ) ) begin
            RUMBLE1 <= out_host_data[8];
            RUMBLE2 <= out_host_data[16];
            RUMBLE3 <= out_host_data[24];
            RUMBLE4 <= out_host_data[32];
        end
    end
end

//-------------------------------------------------------------------------------------------------------------------------------------
// Gamecube Adapter IN data packet process
//-------------------------------------------------------------------------------------------------------------------------------------
reg  [303:0] in_data = 304'b0; //key_value plus 8 bits 
reg         in_valid = 1'b0;
reg  [ 8:0] in_cnt = 9'b0;

always @ (posedge clk or negedge usb_rstn)
    if (~usb_rstn) begin
        in_data <= 304'b0;
        in_valid <= 1'b0;
        in_cnt <= 9'b0;
        oktosend <= 0;
    end else begin
        if (sof) begin
            in_data <= { key_value[295:288] , key_value[287:0] , 8'h0}; //start at beginning of in_data for receiving new controller data since only passing 1 byte at a time
        end
        if (in_cnt == 8'd00) begin
            in_data <= { key_value[295:288] , key_value[287:0] , 8'h0}; //start at beginning of in_data for receiving new controller data since only passing 1 byte at a time
                in_valid <= 1'b1;
                in_cnt <= 9'd1;
        end else if (in_cnt < (byte_cnt + 1)) begin //5'd37) begin    This counter is how many bytes to send plus one??? Not very flexible code.
            if (in_ready) begin
                in_data <= in_data << 8;
                in_cnt <= in_cnt + 9'd1;
                oktosend <= 1;
            end
        end else begin
            in_valid <= 1'b0;
            in_cnt <= 9'd0;
        end
    end

//-------------------------------------------------------------------------------------------------------------------------------------
// endpoint 00 (control endpoint) command response : HID descriptor
//-------------------------------------------------------------------------------------------------------------------------------------
wire [63:0] ep00_setup_cmd;
wire [ 8:0] ep00_resp_idx;
reg  [ 7:0] ep00_resp;

//localparam [63*8-1:0] DESCRIPTOR_HID =
localparam [214*8-1:0] DESCRIPTOR_HID = {512'h05_05_09_00_a1_01_85_11_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_05_91_00_c0_a1_01_85_21_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_25_81_00_c0_a1_01_85_12_19_00_2a_ff_00_15_00_26_FF_00_75_08_95_01, //First bytes sent for HID descriptor
                                        512'h91_00_c0_a1_01_85_22_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_19_81_00_c0_a1_01_85_13_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_01_91_00_c0_a1_01_85_23_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_02_81, //Second byte set
                                        512'h00_c0_a1_01_85_14_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_01_91_00_c0_a1_01_85_24_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_02_81_00_c0_a1_01_85_15_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_01_91_00,
                                        176'hc0_a1_01_85_25_19_00_2a_ff_00_15_00_26_FF_00_75_08_95_02_81_00_c0
};
                                       //504'h05_01_09_06_a1_01_05_07_19_e0_29_e7_15_00_25_01_75_01_95_08_81_02_95_01_75_08_81_03_95_05_75_01_05_08_19_01_29_05_91_02_95_01_75_03_91_03_95_06_75_08_15_00_25_ff_05_07_19_00_29_65_81_00_c0;
                                     //00_05_03_00_00_00_00_00 for Nintendo Switch?
always @ (posedge clk)
    if (ep00_setup_cmd[15:0] == 16'h0681)
        //ep00_resp <= DESCRIPTOR_HID[ (63 - 1 - ep00_resp_idx) * 8 +: 8 ];
        ep00_resp <= DESCRIPTOR_HID[ (214 - 1 - ep00_resp_idx) * 8 +: 8 ];
    else
        ep00_resp <= 8'h0;

//-------------------------------------------------------------------------------------------------------------------------------------
// USB full-speed core
//-------------------------------------------------------------------------------------------------------------------------------------
usbfs_core_top #(
    .DESCRIPTOR_DEVICE  ( {  //  18 bytes available
         144'h12_01_10_01_00_00_00_08_7e_05_37_03_00_01_01_02_03_01  //WiiU Adapter default, but sent as 3 separate 8 byte chunks for ep00 setup
         //144'h12_01_00_02_00_00_00_40_7e_05_37_03_00_01_01_02_03_01  //WiiU Adapter modified for 64byte transfers
    } ),
    .DESCRIPTOR_STR1    ( {  //  64 bytes available 
        304'h26_03_4E_00_69_00_6E_00_74_00_65_00_6E_00_64_00_6F_00_53_00_77_00_69_00_74_00_63_00_68_00_4D_00_6F_00_64_00_65_00 , 208'h0
    } ), 
    .DESCRIPTOR_STR2    ( {  //  64 bytes available
        256'h20_03_53_00_6F_00_75_00_6C_00_43_00_61_00_6C_00_20_00_41_00_64_00_61_00_70_00_74_00_65_00_72_00 , 256'h0 // SoulCal Adapter
    } ),
    .DESCRIPTOR_STR3    ( {  //  64 bytes available
         //176'h16_03_31_00_35_00_2f_00_30_00_37_00_2f_00_32_00_30_00_31_00_34_00, 336'h0 //  15/07/2014 - probably the date of manufacture
        320'h28_03_49_00_73_00_61_00_61_00_63_00_20_00_4D_00_61_00_6B_00_65_00_20_00_55_00_73_00_20_00_57_00_68_00_6F_00_6C_00_65_00 , 192'h0
    } ),
    .DESCRIPTOR_CONFIG  ( {  // 512 bytes available     
            72'h09_02_29_00_01_01_00_E0_FA ,  72'h09_04_00_00_02_03_00_00_00 ,
            72'h09_21_10_01_00_01_22_D6_00 ,  56'h07_05_81_03_25_00_01 ,
            56'h07_05_02_03_05_00_01 , 3768'h0
    } ),
    .EP81_MAXPKTSIZE    ( byte_cnt           ), //( 10'h08           ), //USB packet length? Will need to change this to match the XBOX360 controller data or Nintendo Switch adapter
    .DEBUG              ( DEBUG            )
) u_usbfs_core (
    .rstn               ( rstn             ),
    .clk                ( clk              ),
    .usb_dp_pull        ( usb_dp_pull      ),
    .usb_dp             ( usb_dp           ),
    .usb_dn             ( usb_dn           ),
    .usb_rstn           ( usb_rstn         ),
    .sot                (                  ),
    .sof                ( sof                 ),
    .ep00_setup_cmd     ( ep00_setup_cmd   ),
    .ep00_resp_idx      ( ep00_resp_idx    ),
    .ep00_resp          ( ep00_resp        ),
    .ep81_data          ( in_data[303:296]     ), //( in_data[7:0]     ),
    .ep81_valid         ( in_valid         ),
    .ep81_ready         ( in_ready         ),
    .ep82_data          ( 8'h0             ),
    .ep82_valid         ( 1'b0             ),
    .ep82_ready         (                  ),
    .ep83_data          ( 8'h0             ),
    .ep83_valid         ( 1'b0             ),
    .ep83_ready         (                  ),
    .ep84_data          ( 8'h0             ),
    .ep84_valid         ( 1'b0             ),
    .ep84_ready         (                  ),
    .ep01_data          (                  ),
    .ep01_valid         (         ),
    .ep02_data          ( controllers_receive_data                 ),
    .ep02_valid         (  out_valid                ),
    .ep03_data          (                  ),
    .ep03_valid         (                  ),
    .ep04_data          (                  ),
    .ep04_valid         (                  ),
    .debug_en           ( debug_en         ),
    .debug_data         ( debug_data       ),
    .debug_uart_tx      ( debug_uart_tx    )
);


endmodule
