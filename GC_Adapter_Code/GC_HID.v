
module GC_HID #(
    parameter DEBUG = "FALSE" , // whether to output USB debug info, "TRUE" or "FALSE"
    parameter GC_NSO_cnt = 8'd64,       //Controls the number of bits in a controller USB packet
    parameter GC_Adapter_cnt = 8'd37,   //Controls the number of bits in a controller USB packet
    parameter XBOX360_cnt = 8'd20,      //Controls the number of bits in a controller USB packet
    parameter HORI2_cnt = 8'd8          //Controls the number of bits in a controller USB packet
) (
    input  wire        rstn,          // active-low reset, reset when rstn=0 (USB will unplug when reset), normally set to 1
    input  wire        clk,           // 60MHz is required
    // USB signals
    output wire        usb_dp_pull,   // connect to USB D+ by an 1.5k resistor
    inout              usb_dp,        // USB D+
    inout              usb_dn,        // USB D-
    // USB reset output
    output wire        usb_rstn,      // 1: connected , 0: disconnected (when USB cable unplug, or when system reset (rstn=0))
    // HID inputs
    input  wire [295:0] GC_Adapter_Data,    input  wire [511:0] Gamecube_NSO1,
    input  wire [63:0]  HORI2_Pro1,         input  wire [63:0]  HORI2_Pro2,     input  wire [63:0]  HORI2_Pro3,     input  wire [63:0]  HORI2_Pro4,
    input  wire [159:0] XBOX360_1,          input  wire [159:0] XBOX360_2,      input  wire [159:0] XBOX360_3,      input  wire [159:0] XBOX360_4,     
    input wire [3:0]   Mode_Select,
    // debug output info, only for USB developers, can be ignored for normally use. Please set DEBUG="TRUE" to enable these signals
    output wire        debug_en,      // when debug_en=1 pulses, a byte of debug info appears on debug_data
    output wire [ 7:0] debug_data,    // 
    output wire        debug_uart_tx,  // debug_uart_tx is the signal after converting {debug_en,debug_data} to UART (format: 115200,8,n,1). If you want to transmit debug info via UART, you can use this signal. If you want to transmit debug info via other custom protocols, please ignore this signal and use {debug_en,debug_data}.
    output wire sof,
    output reg RUMBLE1 , output reg RUMBLE2 , output reg RUMBLE3 , output reg RUMBLE4 , output wire controller_count_start
);

wire in_ready1;                             wire in_ready2;                             wire in_ready3;                             wire in_ready4;                         wire in_ready5;                             wire in_ready6;                             wire in_ready7;                             wire in_ready8;                             wire in_ready9;
wire in_readyA;                             wire in_readyB;                             wire in_readyC;                             wire in_readyD;
wire [7:0] controller_receive_data1;        wire [7:0] controllers_receive_data2;       wire [7:0] controller_receive_data3;        wire [7:0] controller_receive_data4;    wire [7:0] controller_receive_data5;        wire [7:0] controller_receive_data6;        wire [7:0] controller_receive_data7;        wire [7:0] controller_receive_data8;        wire [7:0] controller_receive_data9;        
wire [7:0] controller_receive_dataA;        wire [7:0] controller_receive_dataB;        wire [7:0] controller_receive_dataC;        wire [7:0] controller_receive_dataD;
wire out_valid1;                            wire out_valid2;                            wire out_valid3;                            wire out_valid4;                        wire out_valid5;                            wire out_valid6;                            wire out_valid7;                            wire out_valid8;                            wire out_valid9;
wire out_validA;                            wire out_validB;                            wire out_validC;                            wire out_validD;

//-------------------------------------------------------------------------------------------------------------------------------------
// HID Rumble Output Detection
//-------------------------------------------------------------------------------------------------------------------------------------

reg [2:0]  out_count1 = 5'h0;           reg [7:0]  out_count2 = 8'h0;           reg [2:0]  out_count3 = 5'h0;           reg [2:0]  out_count4 = 5'h0;           reg [7:0]  out_count5 = 8'h0;           reg [7:0]  out_count6 = 8'h0;           reg [2:0]  out_count7 = 5'h0;           reg [2:0]  out_count8 = 5'h0;           reg [7:0]  out_count9 = 8'h0;
reg [7:0]  out_countA = 8'h0;           reg [7:0]  out_countB = 8'h0;           reg [2:0]  out_countC = 5'h0;           reg [7:0]  out_countD = 8'h0; 
reg [255:0] out_host_data1 = 256'h0;    
reg [255:0] out_host_data2 = 256'h0;    reg [255:0] out_host_data3 = 256'h0;    reg [255:0] out_host_data4 = 256'h0;    reg [255:0] out_host_data5 = 256'h0;
reg [255:0] out_host_data6 = 256'h0;    reg [255:0] out_host_data7 = 256'h0;    reg [255:0] out_host_data8 = 256'h0;    reg [255:0] out_host_data9 = 256'h0;
reg [511:0] out_host_dataA = 512'h0;    reg [255:0] out_host_dataB = 256'h0;
reg out_host_en1 = 1'b0;        
reg out_host_en2 = 1'b0;        reg out_host_en3 = 1'b0;        reg out_host_en4 = 1'b0;        reg out_host_en5 = 1'b0;       
reg out_host_en6 = 1'b0;        reg out_host_en7 = 1'b0;        reg out_host_en8 = 1'b0;        reg out_host_en9 = 1'b0;
reg out_host_enA = 1'b0;        reg out_host_enB = 1'b0;        reg out_host_enC = 1'b0;        reg out_host_enD = 1'b0;
reg [GC_Adapter_cnt*8 + 8: 0]   in_data1 = { 296'h0, 8'h0 };    
reg [HORI2_cnt*8 + 8: 0]        in_datah1 = { 64'h0 , 8'h0 };    
reg [HORI2_cnt*8 + 8: 0]        in_datah2 = { 64'h0 , 8'h0 };  
reg [HORI2_cnt*8 + 8: 0]        in_datah3 = { 64'h0 , 8'h0 };
reg [HORI2_cnt*8 + 8: 0]        in_datah4 = { 64'h0 , 8'h0 };
reg [XBOX360_cnt*8 + 8: 0]      in_datax1= { 160'h0, 8'h0 };
reg [XBOX360_cnt*8 + 8: 0]      in_datax2 = { 160'h0, 8'h0 };
reg [XBOX360_cnt*8 + 8: 0]      in_datax3 = { 160'h0, 8'h0 };
reg [XBOX360_cnt*8 + 8: 0]      in_datax4 = { 160'h0, 8'h0 };
reg [GC_NSO_cnt*8 + 8: 0]       in_dataA = { 512'h0, 8'h0 }; 
reg [647: 0] in_dataB = {96'h03_01_00_0D_00_F8_00_00_01_00_00_00 , 552'h0};
reg [647: 0] in_dataBtemp = {96'h03_01_00_0D_00_F8_00_00_01_00_00_00 , 552'h0};

reg in_valid1 = 1'b0;           
reg in_valid2 = 1'b0;           reg in_valid3 = 1'b0;           reg in_valid4 = 1'b0;           reg in_valid5 = 1'b0;
reg in_valid6 = 1'b0;           reg in_valid7 = 1'b0;           reg in_valid8 = 1'b0;           reg in_valid9 = 1'b0;
reg in_validA = 1'b0;           reg in_validB = 1'b0;
reg  [ 7:0] in_cnt1 = 8'h00;    
reg  [ 7:0] in_cnt2 = 8'h00;    reg  [ 7:0] in_cnt3 = 8'h00;    reg  [ 7:0] in_cnt4 = 8'h00;    reg  [ 7:0] in_cnt5 = 8'h00;
reg  [ 7:0] in_cnt6 = 8'h00;    reg  [ 7:0] in_cnt7 = 8'h00;    reg  [ 7:0] in_cnt8 = 8'h00;    reg  [ 7:0] in_cnt9 = 8'h00;    
reg  [ 7:0] in_cntA = 8'h00;    reg  [ 7:0] in_cntB = 8'h00;

reg [7:0] EP1data = 8'b0;       reg [7:0] EP2data = 8'b0;       reg [7:0] EP3data = 8'b0;       reg [7:0] EP4data = 8'b0;
reg [7:0] EP_cnt = 8'b0;

reg [7:0] EP81INsize = 8'd37;
localparam EP8BOUTsize = 8'd15;
reg [7:0] EP8BINsize = 8'd5;    reg [4:0] EP8Btype = 5'd0;

always @ (posedge clk or negedge usb_rstn) begin

    if (~usb_rstn) begin
        out_count1 <= 3'h0;     out_count2 <= 8'h0;     out_count3 <= 3'h0;     out_count4 <= 3'h0;     out_count5 <= 8'h0;     out_count6 <= 8'h0;     out_count7 <= 3'h0;     out_count8 <= 3'h0;     out_count9 <= 8'h0;
        out_countA <= 8'h0;     out_countB <= 8'h0;     out_countC <= 8'h0;     out_countD <= 8'h0;
        out_host_data1 <= 1'b0; out_host_data2 <= 1'b0; out_host_data3 <= 1'b0; out_host_data4 <= 1'b0; out_host_data5 <= 1'b0; out_host_data6 <= 1'b0; out_host_data7 <= 1'b0; out_host_data8 <= 1'b0; out_host_data9 <= 1'b0;
        out_host_dataA <= 1'b0; out_host_dataB <= 1'b0;
        out_host_en1 <= 1'b0;   out_host_en2 <= 1'b0;   out_host_en3 <= 1'b0;   out_host_en4 <= 1'b0;   out_host_en5 <= 1'b0;   out_host_en6 <= 1'b0;   out_host_en7 <= 1'b0;   out_host_en8 <= 1'b0;   out_host_en9 <= 1'b0;
        out_host_enA <= 1'b0;   out_host_enB <= 1'b0;   out_host_enC <= 1'b0;   out_host_enD <= 1'b0;
    end 

    else begin
        //out_host_en1 <= 1'b0; //Might need this to reset each interval
        if (sof) begin // reset at start of a new frame
            out_count1 <= 8'h0;    out_count2 <= 8'h0;    out_count3 <= 8'h0;    out_count4 <= 8'h0;    out_count5 <= 8'h0;    out_count6 <= 8'h0;    out_count7 <= 8'h0;    out_count8 <= 8'h0;    out_count9 <= 8'h0;
            out_countA <= 8'h0;    out_countB <= 8'h0;    out_countC <= 8'h0;    out_countD <= 8'h0;
        end 
        else if (out_valid2) begin
            if ( Mode_Select[2] == 1'b1 ) begin
                out_count5 <= out_count5 + 3'd1;
                out_host_data5[63:0] <= {controllers_receive_data2,out_host_data5[63:8]}; //using data5 since it isn't used otherwise
                out_host_en5 <= (out_count5 == 3'd7); //get 8 bytes of OUT data from Host for XBOX Controller
            end else begin
                out_count2 <= out_count2 + 3'd1;
                out_host_data2[39:0] <= {controllers_receive_data2,out_host_data2[39:8]};
                out_host_en2 <= (out_count2 == 3'd4); //get 5 bytes of OUT data from Host (Nintendo Switch) for GC Adapter
            end
        end
        if ( out_host_en2 && (out_host_data2[7:0] == 8'h11 ) ) begin //Gamecube Adapter Rumble requests
            RUMBLE1 <= out_host_data2[8];
            RUMBLE2 <= out_host_data2[16];
            RUMBLE3 <= out_host_data2[24];
            RUMBLE4 <= out_host_data2[32];
        end
        if ( out_host_en5 && (out_host_data5[15:0] == 16'h0800 ) ) begin
            RUMBLE2 <= out_host_data5[31];
        end

        if (out_valid1) begin
            out_count1 <= out_count1 + 3'd1;
            out_host_data1[63:0] <= {controller_receive_data1,out_host_data1[63:8]};
            out_host_en1 <= (out_count1 == 3'd7); //get 8 bytes of OUT data from Host
            //RUMBLE1 <= out_host_data1[63];
        end
        if ( out_host_en1 && (out_host_data1[15:0] == 16'h0800 ) ) begin
            RUMBLE1 <= out_host_data1[31];
        end
        if (out_valid3) begin
            out_count3 <= out_count3 + 3'd1;
            out_host_data3[63:0] <= {controller_receive_data3,out_host_data3[63:8]};
            out_host_en3 <= (out_count3 == 3'd7); //get 8 bytes of OUT data from Host
            //RUMBLE3 <= out_host_data3[63];
        end
        if ( out_host_en3 && (out_host_data3[15:0] == 16'h0800 ) ) begin
            RUMBLE3 <= out_host_data3[31];
        end
        if (out_valid4) begin
            out_count4 <= out_count4 + 3'd1;
            out_host_data4[63:0] <= {controller_receive_data4,out_host_data4[63:8]};
            out_host_en4 <= (out_count4 == 3'd7); //get 8 bytes of OUT data from Host
            //RUMBLE4 <= out_host_data4[63];
        end
        if ( out_host_en4 && (out_host_data4[15:0] == 16'h0800 ) ) begin
            RUMBLE4 <= out_host_data4[31];
        end
//GCNSO RUMBLE
        if (out_validA) begin
            out_countA <= out_countA + 8'd1;
            out_host_dataA[511:0] <= {out_host_dataA[503:0],controller_receive_dataA}; //DATA IN MSB ORDER
            out_host_enA <= (out_countA == 8'd63); //get 64 bytes of OUT data from Host
            //RUMBLE1 <= out_host_dataA[480];
        end
        if ( out_host_enA && (out_host_dataA[511:504] == 8'h03 ) ) begin
            RUMBLE1 <= (out_host_dataA[480] | out_host_dataA[481]);
        end
//GCNSO Data

        if (out_validB) begin
            out_countB <= out_countB + 8'd1;
            out_host_dataB[255:0] <= {out_host_dataB[247:0],controller_receive_dataB}; //DATA IN MSB ORDER
            out_host_enB <= (out_countB == EP8BOUTsize); //get EP8BOUTsize bytes of OUT data from Host
        end

        if    ( out_host_dataB[63:0] ==  64'h03_91_00_0D_00_08_00_00 ) begin
        //if ( out_host_dataB[127:0] == 128'h03_91_00_0D_00_08_00_00_01_00_93_CD_29_55_E2_98 ) begin
            in_dataBtemp <= {96'h03_01_00_0D_00_F8_00_00_01_00_00_00 , 424'h0 , 128'h0 };
            EP8BINsize <= 8'd12;
        end
        if ( out_host_dataB[63:0] == 64'h07_91_00_01_00_00_00_00 ) begin
            in_dataBtemp <= {72'h07_01_00_01_00_F8_00_00_00 , 448'h0 , 128'h0 };
            EP8BINsize <= 8'd9;         
        end
        if ( out_host_dataB[63:0] == 64'h16_91_00_01_00_00_00_00 ) begin
            in_dataBtemp <= {256'h16_01_00_01_00_F8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00 , 264'h0, 128'h0 }; 
            EP8BINsize <= 8'd29;
        end
        //if ( out_host_dataB[95:0] == 96'h0B_91_00_07_00_04_00_00_00_00_00_00 ) begin
        if   ( out_host_dataB[63:0] == 64'h0B_91_00_07_00_04_00_00 ) begin
            in_dataBtemp <= {64'h0B_01_00_07_00_F8_00_00 , 456'h0 , 128'h0 };
            EP8BINsize <= 8'd8;         
        end
        //if ( out_host_dataB[175:0] == 176'h15_91_00_01_00_0E_00_00_00_02_93_CD_29_55_E2_98_92_CD_29_55_E2_98 ) begin
        if ( out_host_dataB[63:0] ==     64'h15_91_00_01_00_0E_00_00 ) begin
            in_dataBtemp <= {136'h15_01_00_01_00_F8_00_00_01_04_01_5C_9D_5F_AB_A9_3C , 384'h0 , 128'h0 }; 
            EP8BINsize <= 8'd17;         
        end
        //if ( out_host_dataB[71:0] == 72'h15_91_00_02_00_11_00_00_00 ) begin
        if ( out_host_dataB[63:0] ==   64'h15_91_00_02_00_11_00_00 ) begin
            in_dataBtemp <= {200'h15_01_00_02_00_F8_00_00_01_8C_F3_94_CB_57_18_CD_62_BA_71_F5_8A_08_51_EF_E1 , 320'h0 , 128'h0 };
            EP8BINsize <= 8'd25;         
        end
        //if ( out_host_dataB[71:0] == 72'h15_91_00_03_00_11_00_00_00 ) begin
        if ( out_host_dataB[63:0] ==   64'h15_91_00_03_00_11_00_00 ) begin
            in_dataBtemp <= {72'h15_01_00_03_00_F8_00_00_01 , 448'h0 , 128'h0 }; 
            EP8BINsize <= 8'd9;         
        end           
        //if ( out_host_dataB[127:0]==128'h09_91_00_07_00_08_00_00_00_00_00_00_00_00_00_00 ) begin
        if ( out_host_dataB[63:0] ==   64'h09_91_00_01_00_00_00_00 ) begin
            in_dataBtemp <= {64'h09_01_00_01_00_F8_00_00 , 456'h0 , 128'h0 }; 
            EP8BINsize <= 8'd8;         
        end
        if ( out_host_dataB[63:0] ==   64'h09_91_00_02_00_00_00_00 ) begin
            in_dataBtemp <= {64'h09_01_00_02_00_F8_00_00 , 456'h0 , 128'h0 }; 
            EP8BINsize <= 8'd8;         
        end
        if ( out_host_dataB[63:0] ==   64'h09_91_00_03_00_00_00_00 ) begin
            in_dataBtemp <= {64'h09_01_00_03_00_F8_00_00 , 456'h0 , 128'h0 }; 
            EP8BINsize <= 8'd8;         
        end
        if ( out_host_dataB[63:0] ==   64'h09_91_00_04_00_00_00_00 ) begin
            in_dataBtemp <= {64'h09_01_00_04_00_F8_00_00 , 456'h0 , 128'h0 }; 
            EP8BINsize <= 8'd8;         
        end
        if ( out_host_dataB[63:0] ==   64'h09_91_00_05_00_00_00_00 ) begin
            in_dataBtemp <= {64'h09_01_00_05_00_F8_00_00 , 456'h0 , 128'h0 }; 
            EP8BINsize <= 8'd8;         
        end
        if ( out_host_dataB[63:0] ==   64'h09_91_00_06_00_00_00_00 ) begin
            in_dataBtemp <= {64'h09_01_00_06_00_F8_00_00 , 456'h0 , 128'h0 }; 
            EP8BINsize <= 8'd8;         
        end
        if ( out_host_dataB[63:0] ==   64'h09_91_00_07_00_04_00_00 ) begin
            in_dataBtemp <= {64'h09_01_00_07_00_F8_00_00 , 456'h0 , 128'h0 }; 
            EP8BINsize <= 8'd8;         
        end
        if ( out_host_dataB[63:0] ==   64'h09_91_00_08_00_04_00_00 ) begin
            in_dataBtemp <= {64'h09_01_00_08_00_F8_00_00 , 456'h0 , 128'h0 }; 
            EP8BINsize <= 8'd8;         
        end
        //if ( out_host_dataB[95:0] == 96'h0C_91_00_02_00_04_00_00_27_00_00_00 ) begin
        if ( out_host_dataB[63:0] ==   64'h0C_91_00_02_00_04_00_00 ) begin
            in_dataBtemp <= {96'h0C_01_00_02_00_F8_00_00_00_00_00_00 , 424'h0 , 128'h0 };
            EP8BINsize <= 8'd12;         
        end
        //if ( out_host_dataB[127:0] == 128'h02_91_00_04_00_08_00_00_40_7E_00_00_80_30_01_00 ) begin
        if ( out_host_dataB[63:0] ==     64'h40_7E_00_00_80_30_01_00 ) begin
                if ( EP8Btype == 5'd0 ) begin
                    //in_dataBtemp <= {512'h02_01_00_04_00_F8_00_00_40_00_00_00_80_30_01_00_FF_47_79_94_B8_86_B6_A0_00_0A_A0_00_0A_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_BE_E3_3B_BE_E3_3B_06_65_50_06_65_50_0A_FF_FF_59_78_81_BE_F4_4A_CC_34 , 128'h51_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 8'h0 }; 
                    in_dataBtemp <= {512'h02_01_00_04_00_F8_00_00_40_00_00_00_80_30_01_00_FF_47_79_94_B8_86_B6_A0_00_0A_A0_00_0A_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_BE_E3_3B_BE_E3_3B_06_65_50_06_65_50_0A_FF_FF_7F_FF_FF_C1_15_C1_DC_C7 , 128'h7D_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 8'h0 }; 
                    EP8BINsize <= 8'd64; 
                end else begin
                    in_dataBtemp <= {128'h51_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 8'h0 ,512'h0 }; 
                    EP8BINsize <= 8'd16;
                end
        end
//        if ( out_host_dataB[127:0] == 128'h02_91_00_04_00_08_00_00_40_7E_00_00_C0_30_01_00 ) begin
        if ( out_host_dataB[63:0] ==     64'h40_7E_00_00_C0_30_01_00 ) begin
                if ( EP8Btype == 5'd0 ) begin
                    //in_dataBtemp <= {512'h02_01_00_04_00_F8_00_00_40_00_00_00_C0_30_01_00_FF_47_79_94_B8_86_6B_A0_00_0A_A0_00_0A_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_18_83_31_18_83_31_5F_F4_45_5F_F4_45_0A_FF_FF_6E_68_7F_51_54_44_7D_44 , 128'h49_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 8'h0  };
                    in_dataBtemp <= {512'h02_01_00_04_00_F8_00_00_40_00_00_00_C0_30_01_00_FF_47_79_94_B8_86_6B_A0_00_0A_A0_00_0A_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_18_83_31_18_83_31_5F_F4_45_5F_F4_45_0A_FF_FF_7F_FF_FF_C1_15_C1_DC_C7 , 128'h7D_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 8'h0  };
                    EP8BINsize <= 8'd64; 
                end else begin
                    in_dataBtemp <= {128'h49_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 8'h0 ,512'h0 }; 
                    EP8BINsize <= 8'd16;
                end 
        end
//        if ( out_host_dataB[127:0] == 128'h02_91_00_04_00_08_00_00_40_7E_00_00_40_C0_1F_00 ) begin
        if ( out_host_dataB[63:0] ==     64'h40_7E_00_00_40_C0_1F_00 ) begin
                if ( EP8Btype == 5'd0 ) begin
                    in_dataBtemp <= {512'h02_01_00_04_00_F8_00_00_40_00_00_00_40_C0_1F_00_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 128'hFF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 8'h0  };
                    EP8BINsize <= 8'd64; 
                end else begin
                    in_dataBtemp <= {128'hFF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 8'h0 ,512'h0 }; 
                    EP8BINsize <= 8'd16;
                end
        end
//        if ( out_host_dataB[127:0] == 128'h02_91_00_04_00_08_00_00_10_7E_00_00_40_30_01_00 ) begin
        if ( out_host_dataB[63:0] ==     64'h10_7E_00_00_40_30_01_00 ) begin
                     in_dataBtemp <= {256'h02_01_00_04_00_F8_00_00_10_00_00_00_40_30_01_00_7C_FF_D3_41_FD_4C_D0_BB_6E_75_B3_BC_86_89_8D_3B , 8'h0 , 384'h0 }; 
            EP8BINsize <= 8'd32;         
        end
//        if ( out_host_dataB[127:0] == 128'h02_91_00_04_00_08_00_00_18_7E_00_00_00_31_01_00 ) begin
        if ( out_host_dataB[63:0] ==     64'h18_7E_00_00_00_31_01_00 ) begin
                     in_dataBtemp <= {320'h02_01_00_04_00_F8_00_00_18_00_00_00_00_31_01_00_00_00_00_00_00_00_00_00_00_00_00_00_A7_E1_7B_BE_95_02_9B_BE_E9_4B_23_41 , 200'h0 , 128'h0 };
            EP8BINsize <= 8'd40;         
        end
        if ( out_host_dataB[63:0] == 64'h11_91_00_01_00_00_00_00 ) begin
                   in_dataBtemp <= {96'h11_01_00_01_00_F8_00_00_01_00_00_00 , 424'h0 , 128'h0 };  
            EP8BINsize <= 8'd12;         
        end
        if ( out_host_dataB[63:0] == 64'h11_91_00_03_00_00_00_00 ) begin
                   in_dataBtemp <= {296'h11_01_00_03_00_F8_00_00_01_20_03_00_00_0A_E8_1C_3B_79_7D_8B_3A_0A_E8_9C_42_58_A0_0B_42_0A_E8_9C_41_58_A0_0B_41 , 224'h0 , 128'h0 };  
            EP8BINsize <= 8'd37;         
        end
//        if ( out_host_dataB[127:0] == 128'h02_91_00_04_00_08_00_00_02_7E_00_00_40_31_01_00 ) begin
        if ( out_host_dataB[63:0] ==     64'h02_7E_00_00_40_31_01_00 ) begin
                    in_dataBtemp <= { 144'h02_01_00_04_00_F8_00_00_02_00_00_00_40_31_01_00_24_21 , 376'h0 , 128'h0  };	
            EP8BINsize <= 8'd18;         
        end
//        if ( out_host_dataB[127:0] == 128'h02_91_00_04_00_08_00_00_20_7E_00_00_60_30_01_00 ) begin
        if ( out_host_dataB[63:0] ==     64'h20_7E_00_00_60_30_01_00 ) begin
                    in_dataBtemp <= { 384'h02_01_00_04_00_F8_00_00_20_00_00_00_60_30_01_00_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF , 136'h0 , 128'h0  };	 
            EP8BINsize <= 8'd48;         
        end
//        if ( out_host_dataB[223:0] == 224'h0A_91_00_08_00_14_00_00_01_FF_FF_FF_FF_FF_FF_FF_FF_35_00_46_00_00_00_00_00_00_00_00 ) begin
        if ( out_host_dataB[63:0] ==    64'h0A_91_00_08_00_14_00_00 ) begin
                    in_dataBtemp <= {  64'h0A_04_00_08_00_F8_00_00 , 456'h0 , 128'h0 };  
            EP8BINsize <= 8'd8;         
        end
//        if ( out_host_dataB[95:0] ==  96'h0C_91_00_04_00_04_00_00_27_00_00_00 ) begin
        if ( out_host_dataB[63:0] ==  64'h0C_91_00_04_00_04_00_00 ) begin
                    in_dataBtemp <= { 96'h0C_01_00_04_00_F8_00_00_00_00_00_00 , 424'h0 , 128'h0  }; 
            EP8BINsize <= 8'd12;         
        end
//        if ( out_host_dataB[95:0] ==  96'h03_91_00_0A_00_04_00_00_0A_00_00_00 ) begin
        if ( out_host_dataB[63:0] ==    64'h03_91_00_0A_00_04_00_00 ) begin
                    in_dataBtemp <= { 64'h03_01_00_0A_00_F8_00_00 , 456'h0 , 128'h0  }; 
            EP8BINsize <= 8'd8;         
        end
        if ( out_host_dataB[63:0] ==  64'h10_91_00_01_00_00_00_00 ) begin
                    in_dataBtemp <= {160'h10_01_00_01_00_F8_00_00_01_01_02_03_0C_00_00_00_FF_FF_FF_FF, 360'h0 , 128'h0  };
            EP8BINsize <= 8'd20;         
        end
        if ( out_host_dataB[63:0] == 64'h01_91_00_0C_00_00_00_00 ) begin
                    in_dataBtemp <= {64'h01_00_00_0C_00_F8_00_00 , 456'h0 , 128'h0  }; 
            EP8BINsize <= 8'd8;         
        end
        if    ( out_host_dataB[63:0] ==  64'h03_91_00_0C_00_04_00_00 ) begin
        //if ( out_host_dataB[127:0] == 128'h03_91_00_0D_00_08_00_00_01_00_93_CD_29_55_E2_98 ) begin
            in_dataBtemp <= {64'h03_01_00_0C_00_F8_00_00 , 456'h0 , 128'h0 };
            EP8BINsize <= 8'd12;
        end
    end
//end

//-------------------------------------------------------------------------------------------------------------------------------------
// HID XBOX CONTROLLER IN data packet process
//-------------------------------------------------------------------------------------------------------------------------------------

//always @ (posedge clk or negedge usb_rstn) begin
    if (~usb_rstn) begin
        in_data1 <= 304'h0; // GC Adapter     
        in_datax1 <= 72'h0;  in_datax2 <= 72'h0;  in_datax3 <= 72'h0;  in_datax4 <= 72'h0;// HORI2 Pro Controllers
        in_datah1 <= 168'h0; in_datah2 <= 168'h0; in_datah3 <= 168'h0; in_datah4 <= 168'h0; // XBOX360 Controllers     
        in_dataA <= {512'h0 , 8'h0}; //GC NSO Controller
        in_valid1 <= 1'b0;
        in_valid2 <= 1'b0;       in_valid3 <= 1'b0;       in_valid4 <= 1'b0;       in_valid5 <= 1'b0;
        in_valid6 <= 1'b0;       in_valid7 <= 1'b0;       in_valid8 <= 1'b0;       in_valid9 <= 1'b0;
        in_validA <= 1'b0;
        in_cnt1 <= 8'h00;
        in_cnt2 <= 8'h00;        in_cnt3 <= 8'h00;        in_cnt4 <= 8'h00;        in_cnt5 <= 8'h00;
        in_cnt6 <= 8'h00;        in_cnt7 <= 8'h00;        in_cnt8 <= 8'h00;        in_cnt9 <= 8'h00;
        in_cntA <= 8'h00;
        EP_cnt <= 8'h0;
    end else begin
        if (sof) begin
            in_data1 <= { GC_Adapter_Data[295:288], GC_Adapter_Data[287:0] , 8'h0};
            in_datah1 <= { HORI2_Pro1[63:56], HORI2_Pro1[55:0] , 8'h0};
            in_datah2 <= { HORI2_Pro2[63:56], HORI2_Pro2[55:0] , 8'h0};
            in_datah3 <= { HORI2_Pro3[63:56], HORI2_Pro3[55:0] , 8'h0};
            in_datah4 <= { HORI2_Pro4[63:56], HORI2_Pro4[55:0] , 8'h0};
            in_datax1 <= { XBOX360_1[159:152],XBOX360_1[151:0] , 8'h0 };
            in_datax2 <= { XBOX360_2[159:152],XBOX360_2[151:0] , 8'h0 };
            in_datax3 <= { XBOX360_3[159:152],XBOX360_3[151:0] , 8'h0 };
            in_datax4 <= { XBOX360_4[159:152],XBOX360_4[151:0] , 8'h0 };
            in_dataA <= { Gamecube_NSO1[511:504],Gamecube_NSO1[503:0] , 8'h0 };
        end

//GC Adapter Endpoint Start, XBOX360 controller 1
        if ( Mode_Select[2] == 1'b1 ) begin
            EP81INsize <= XBOX360_cnt;
            EP1data <= in_datax1[167:160];
        end else begin
            EP81INsize <= GC_Adapter_cnt;
            EP1data <= in_data1[303:296];
        end
        if (in_cnt1 == 8'd00) begin
            in_data1 <= { GC_Adapter_Data[295:288], GC_Adapter_Data[287:0] , 8'h0 };
            in_datax1 <= { XBOX360_1[159:152],XBOX360_1[151:0] , 8'h0 };
            in_valid1 <= 1'b1;
            in_cnt1 <= 8'd1;
        end else if ( in_cnt1 < EP81INsize + 1 ) begin 
            if (in_ready1) begin
                in_data1 <= in_data1 << 8;
                in_cnt1 <= in_cnt1 + 8'd1;
                in_datax1 <= in_datax1 << 8;
            end
        end else begin
            in_valid1 <= 1'b0;
            in_cnt1 <= 8'd0;
        end
// XBOX360 Endpoints
        if (in_cnt2 == 8'd00) begin
            in_datax2 <= { XBOX360_2[159:152],XBOX360_2[151:0] , 8'h0 };
            in_valid2 <= 1'b1;
            in_cnt2 <= 8'd1;
        end else if ( in_cnt2 < XBOX360_cnt + 1 ) begin 
            if (in_ready2) begin
                in_datax2 <= in_datax2 << 8;
                in_cnt2 <= in_cnt2 + 8'd1;
            end
        end else begin
            in_valid2 <= 1'b0;
            in_cnt2 <= 8'd0;
        end

        if (in_cnt3 == 8'd00) begin
            in_datax3 <= { XBOX360_3[159:152],XBOX360_3[151:0] , 8'h0 };
            in_valid3 <= 1'b1;
            in_cnt3 <= 8'd1;
        end else if ( in_cnt3 < XBOX360_cnt + 1 ) begin 
            if (in_ready3) begin
                in_datax3 <= in_datax3 << 8;
                in_cnt3 <= in_cnt3 + 8'd1;
            end
        end else begin
            in_valid3 <= 1'b0;
            in_cnt3 <= 8'd0;
        end

        if (in_cnt4 == 8'd00) begin
            in_datax4 <= { XBOX360_4[159:152],XBOX360_4[151:0] , 8'h0 };
            in_valid4 <= 1'b1;
            in_cnt4 <= 8'd1;
        end else if ( in_cnt4 < XBOX360_cnt + 1 ) begin 
            if (in_ready4) begin
                in_datax4 <= in_datax4 << 8;
                in_cnt4 <= in_cnt4 + 8'd1;
            end
        end else begin
            in_valid4 <= 1'b0;
            in_cnt4 <= 8'd0;
        end

//        if (in_cnt5 == 8'd00) begin
//            in_data5 <= { GC_Adapter_Data[295:288], GC_Adapter_Data[287:0] , 8'h0};
//            in_valid5 <= 1'b1;
//            in_cnt5 <= 8'd1;
//        end else if ( in_cnt5 < GC_Adapter_cnt + 1 ) begin 
//            if (in_ready5) begin
//                in_data5 <= in_data5 << 8;
//                in_cnt5 <= in_cnt5 + 8'd1;
//            end
//        end else begin
//            in_valid5 <= 1'b0;
//            in_cnt5 <= 8'd0;
//        end

// HORI2_Pro Endpoints

        if (in_cnt6 == 8'd00) begin
            in_datah1 <= { HORI2_Pro1[63:56], HORI2_Pro1[55:0] , 8'h0};
            in_valid6 <= 1'b1;
            in_cnt6 <= 8'd1;
        end else if (in_cnt6 < HORI2_cnt + 1 ) begin 
            if (in_ready6) begin
                in_datah1 <= in_datah1 << 8;
                in_cnt6 <= in_cnt6 + 8'd1;
            end
        end else begin
            in_valid6 <= 1'b0;
            in_cnt6 <= 8'd0;
        end

        if (in_cnt7 == 8'd00) begin
            in_datah2 <= { HORI2_Pro2[63:56], HORI2_Pro2[55:0] , 8'h0};
            in_valid7 <= 1'b1;
            in_cnt7 <= 8'd1;
        end else if (in_cnt7 < HORI2_cnt + 1 ) begin 
            if (in_ready7) begin
                in_datah2 <= in_datah2 << 8;
                in_cnt7 <= in_cnt7 + 8'd1;
            end
        end else begin
            in_valid7 <= 1'b0;
            in_cnt7 <= 8'd0;
        end

        if (in_cnt8 == 8'd00) begin
            in_datah3 <= { HORI2_Pro3[63:56], HORI2_Pro3[55:0] , 8'h0};
            in_valid8 <= 1'b1;
            in_cnt8 <= 8'd1;
        end else if (in_cnt8 < HORI2_cnt + 1 ) begin 
            if (in_ready8) begin
                in_datah3 <= in_datah3 << 8;
                in_cnt8 <= in_cnt8 + 8'd1;
            end
        end else begin
            in_valid8 <= 1'b0;
            in_cnt8 <= 8'd0;
        end

        if (in_cnt9 == 8'd00) begin
            in_datah4 <= { HORI2_Pro4[63:56], HORI2_Pro4[55:0] , 8'h0};
            in_valid9 <= 1'b1;
            in_cnt9 <= 8'd1;
        end else if (in_cnt9 < HORI2_cnt + 1 ) begin 
            if (in_ready9) begin
                in_datah4 <= in_datah4 << 8;
                in_cnt9 <= in_cnt9 + 8'd1;
            end
        end else begin
            in_valid9 <= 1'b0;
            in_cnt9 <= 8'd0;
        end

//Gamecube NSO Endpoints
        if (in_cntA == 8'd00) begin
            in_dataA <= { Gamecube_NSO1[511:504], Gamecube_NSO1[503:0] , 8'h0};
            in_validA <= 1'b1;
            in_cntA <= 8'd1;
        end else if (in_cntA < GC_NSO_cnt + 1 ) begin
            if (in_readyA) begin
                in_dataA <= in_dataA << 8;
                in_cntA <= in_cntA + 8'd1;
            end
        end else begin
            in_validA <= 1'b0;
            in_cntA <= 8'd0;
        end

        if (in_cntB == 8'd00) begin
            in_validB <= 1'b1;
            in_cntB <= 8'd1;
        end 
        else if (in_cntB < EP8BINsize + 1 ) begin 
            if (in_readyB) begin
                in_dataB <= in_dataB << 8;
                in_cntB <= in_cntB + 8'd1;
            end 
            else begin
                if ( in_cntB == 8'd1 ) begin
                    in_dataB <= in_dataBtemp; 
                end 
            end
        end 
        else begin
            in_validB <= 1'b0;
            in_cntB <= 8'd0;
        end
        if ( in_cntB == 8'd65 ) begin
            EP8Btype <= 5'd1;
        end
        if ( in_cntB == 8'd17 ) begin
            EP8Btype <= 5'd0;
        end

    end
end

//-------------------------------------------------------------------------------------------------------------------------------------
// endpoint 00 (control endpoint) command response : HID descriptor
//-------------------------------------------------------------------------------------------------------------------------------------
wire [63:0] ep00_setup_cmd;
wire [ 8:0] ep00_resp_idx;
reg  [ 7:0] ep00_resp;
localparam HID_Size_GCA = 8'd214;
localparam HID_Size_XBOX = 8'd63;
localparam HID_Size_GCNSO = 8'h61;
localparam HID_Size_HORI2 = 8'd116;                                                  

localparam [HID_Size_XBOX*8-1:0] DESCRIPTOR_HID_XBOX =   {504'h05_01_09_06_a1_01_05_07_19_e0_29_e7_15_00_25_01_75_01_95_08_81_02_95_01_75_08_81_03_95_05_75_01_05_08_19_01_29_05_91_02_95_01_75_03_91_03_95_06_75_08_15_00_25_ff_05_07_19_00_29_65_81_00_c0
};

localparam [HID_Size_HORI2*8-1:0] DESCRIPTOR_HID_HORI2 = {512'h05_01_09_05_A1_01_15_00_25_01_35_00_45_01_75_01_95_0E_05_09_19_01_29_0E_81_02_95_02_81_01_05_01_25_07_46_3B_01_75_04_95_01_65_14_09_39_81_42_65_00_75_03_95_01_81_01_05_09_09_0F_15_00_25_01_35 , 416'h00_45_01_75_01_95_01_81_02_05_01_26_FF_00_46_FF_00_09_30_09_31_09_32_09_35_75_08_95_04_81_02_75_08_95_01_81_01_0A_4F_48_75_08_95_08_B1_02_0A_4F_48_91_02_C0
};

localparam [HID_Size_GCA*8-1:0] DESCRIPTOR_HID_GCA =   {32'h05_05_09_00,
                                                        168'ha1_01_85_11_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_05_91_00_c0,// Report 1 — Output, Report ID 0x11
                                                        168'ha1_01_85_21_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_25_81_00_c0,// Report 2 — Input, Report ID 0x21
                                                        168'ha1_01_85_12_19_00_2a_ff_00_15_00_26_FF_00_75_08_95_01_91_00_c0,// Report 3 — Output, Report ID 0x12
                                                        168'ha1_01_85_22_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_19_81_00_c0,// Report 4 — Input, Report ID 0x22
                                                        168'ha1_01_85_13_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_01_91_00_c0,// Report 5 — Output, Report ID 0x13
                                                        168'ha1_01_85_23_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_02_81_00_c0,// Report 6 — Input, Report ID 0x23
                                                        168'ha1_01_85_14_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_01_91_00_c0,// Report 7 — Output, Report ID 0x14
                                                        168'ha1_01_85_24_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_02_81_00_c0,// Report 8 — Input, Report ID 0x24
                                                        168'ha1_01_85_15_19_00_2a_ff_00_15_00_26_ff_00_75_08_95_01_91_00_c0,// Report 9 — Output, Report ID 0x15
                                                        168'ha1_01_85_25_19_00_2a_ff_00_15_00_26_FF_00_75_08_95_02_81_00_c0 // Report 10 — Input, Report ID 0x25

};

localparam [HID_Size_GCNSO*8-1:0] DESCRIPTOR_HID_GCNSO= {512'h05_01_09_05_A1_01_85_05_05_FF_09_01_15_00_26_FF_00_95_3F_75_08_81_02_85_0A_09_01_95_02_81_02_05_09_19_01_29_15_25_01_95_15_75_01_81_02_95_01_75_03_81_03_05_01_09_01_A1_00_09_30_09_31_09_33_09,
                                                        264'h35_26_FF_0F_95_04_75_0C_81_02_C0_05_FF_09_02_26_FF_00_95_34_75_08_81_02_85_03_09_01_95_3F_91_02_C0
};

always @ ( posedge clk ) begin
    if ( ep00_setup_cmd[15:0] == 16'h0681 ) begin
        if ( Mode_Select[0] == 1'b1 ) begin
            ep00_resp <= DESCRIPTOR_HID_GCNSO[ (HID_Size_GCNSO - 1 - ep00_resp_idx) * 8 +: 8 ];
        end else if ( Mode_Select[2] == 1'b1 ) begin
            ep00_resp <= DESCRIPTOR_HID_XBOX[ (HID_Size_XBOX - 1 - ep00_resp_idx) * 8 +: 8 ];
        end else if ( Mode_Select[3] == 1'b1 ) begin
            ep00_resp <= DESCRIPTOR_HID_HORI2[ (HID_Size_HORI2 - 1 - ep00_resp_idx) * 8 +: 8 ];
        end else begin
            ep00_resp <= DESCRIPTOR_HID_GCA[ (HID_Size_GCA - 1 - ep00_resp_idx) * 8 +: 8 ];
        end
    end
    else begin
        ep00_resp <= 8'h0;
    end
end



//-------------------------------------------------------------------------------------------------------------------------------------
// USB full-speed core
//-------------------------------------------------------------------------------------------------------------------------------------
usbfs_core_top #(
    .DESCRIPTOR_DEVICE_GCNSO  ( {  //  18 bytes available
      144'h12_01_00_02_EF_02_01_40_7E_05_73_20_01_01_01_02_03_01 // GC NSO 
    }),
    .DESCRIPTOR_DEVICE_XBOX   ( {  //  18 bytes available
        144'h12_01_00_02_FF_FF_FF_40_5E_04_8E_02_00_01_01_02_03_01 // XBOX360 
    }),
    .DESCRIPTOR_DEVICE_HORI2   ( {  //  18 bytes available
        144'h12_01_00_02_00_00_00_40_0D_0F_02_02_14_01_01_02_00_01 // HORI2 Pro Pad
    }),
    .DESCRIPTOR_DEVICE_GCA  ( {  //  18 bytes available
         144'h12_01_00_02_00_00_00_40_7E_05_37_03_00_01_01_02_03_01 //WiiU Adapter 
    }),
    .DESCRIPTOR_STR1    ( {  //  64 bytes available
        448'h3A_03_47_00_61_00_6D_00_65_00_63_00_75_00_62_00_65_00_20_00_41_00_64_00_61_00_70_00_74_00_65_00_72_00_20_00_62_00_79_00_20_00_53_00_6F_00_75_00_6C_00_43_00_61_00_6C_00 , 64'h0 //Gamecube Adapter by SoulCal
    }),
    .DESCRIPTOR_STR2    ( {  //  64 bytes available
        336'h2A03_4600_5000_4700_4100_2000_4700_6100_6D00_6500_6300_7500_6200_6500_2000_4400_6500_7600_6900_6300_6500 // FPGA Gamecube Device
    }),
    .DESCRIPTOR_STR3    ( {  //  64 bytes available
        320'h28_03_4900_7300_6100_6100_6300_2000_4D00_6100_6B00_6500_2000_5500_7300_2000_5700_6800_6F00_6C00_6500 
    }),
    .DESCRIPTOR_STR7gc    ( {  //  64 bytes available     
          320'h28_00_00_00_00_01_04_00_01_00_00_00_00_00_00_00_00_01_57_49_4E_55_53_42_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00, 192'h0 //WINUSB setup, only for USB 2.0 devices - must set 2.0 in DESCRIPTOR_DEVICE
    }),
    .DESCRIPTOR_STR7XBOX    ( {  //  64 bytes available  
          320'h28_00_00_00_00_01_04_00_01_00_00_00_00_00_00_00_00_01_58_55_53_42_31_30_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00, 192'h0 //XBOX PACKET setup, only for USB 2.0 devices - must set 2.0 in DESCRIPTOR_DEVICE
    }),
    .DESCRIPTOR_STR8    ( {  //  64 bytes available     C0_02_00_00_00_00_10_00
        128'h01_01_02_00_00_00_0C_00_00_00_B2_E8_5F_AB_A9_3C , 384'h0 
    }),
    .DESCRIPTOR_STR10    ( {  //  64 bytes available    C0_03_00_00_00_00_40_00
         200'h01_00_48_48_57_35_30_30_30_31_39_34_38_34_38_31_00_00_7E_05_73_20_01_04_01 , 312'hFF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF  //For GC NSO
    }),
    .DESCRIPTOR_STREE    ( {  //  64 bytes available    C0_03_00_00_00_00_40_00
          144'h12_03_4D_00_53_00_46_00_54_00_31_00_30_00_30_00_20_00
    }),
    .DESCRIPTOR_CONFIG_GCNSO  ( {  // 512 bytes available
// CONFIGURATION DESCRIPTOR
        72'h09_02_50_00_02_01_04_C0_FA ,   // CONFIGURATION: bLength=9, bDescriptorType=CONFIGURATION, wTotalLength, bNumInterfaces, bConfigurationValue=1, iConfiguration=4, bmAttributes=0xC0 (self powered), bMaxPower=0xFA (500mA)
// IAD #0 — HID Function (Interface 0)
        64'h08_0B_00_01_03_00_00_00 ,      // IAD, FirstInterface=0, InterfaceCount=1, FunctionClass=HID (0x03)
// Interface 0 — HID
        72'h09_04_00_00_02_03_00_00_05 ,   // INTERFACE 0, bNumEndpoints=2, bInterfaceClass=HID
        72'h09_21_11_01_00_01_22_61_00 ,   // HID Descriptor, HID v1.11, Report Descriptor Length=0x0061 (97 bytes)
        56'h07_05_8A_03_40_00_01 ,         // EP1 IN, Interrupt, MaxPacket=64, bInterval=4 → 1ms (High-Speed)
        56'h07_05_0A_03_40_00_01 ,         // EP1 OUT, Interrupt, MaxPacket=64, bInterval=4 → 1ms (High-Speed)
// IAD #1 — Vendor-Specific Function (Interface 1)
        64'h08_0B_01_01_FF_00_00_00 ,      // IAD, FirstInterface=1, InterfaceCount=1, FunctionClass=Vendor-Specific (0xFF)
// ------------------------------------------------------------
// Interface 1 — Vendor-Specific
        72'h09_04_01_00_02_FF_00_00_06 ,   // INTERFACE 1, bNumEndpoints=2, bInterfaceClass=Vendor-Specific
        56'h07_05_0B_02_40_00_00 ,         // EP2 OUT, Bulk, MaxPacket=64
        56'h07_05_8B_02_40_00_00 ,         // EP2 IN, Bulk, MaxPacket=80
        3456'h0
    }),    

    .DESCRIPTOR_CONFIG_HORI2  ( {  // 512 bytes available

        72'h09_02_89_00_04_01_00_80_FA ,
        72'h09_04_00_00_02_03_00_00_00 ,    72'h09_21_11_01_00_01_22_74_00 ,
        56'h07_05_06_03_40_00_01 ,          56'h07_05_86_03_40_00_01 ,
        72'h09_04_01_00_02_03_00_00_00 ,    72'h09_21_11_01_00_01_22_74_00 ,
        56'h07_05_07_03_40_00_01 ,          56'h07_05_87_03_40_00_01 ,
        72'h09_04_02_00_02_03_00_00_00 ,    72'h09_21_11_01_00_01_22_74_00 ,
        56'h07_05_08_03_40_00_01 ,          56'h07_05_88_03_40_00_01 ,
        72'h09_04_03_00_02_03_00_00_00 ,    72'h09_21_11_01_00_01_22_74_00 ,
        56'h07_05_09_03_40_00_01 ,          56'h07_05_89_03_40_00_01 //Switch 2 HORI
    }),

    .DESCRIPTOR_CONFIG_XBOX  ( {  // 512 bytes available
    // Configuration Descriptor (9 bytes)
        72'h09_02_A9_00_04_01_00_80_FA,  
    // Interface Descriptor CONTROLLER 1
        72'h09_04_00_00_02_FF_5D_01_00,  
       136'h11_21_10_01_01_25_81_14_03_03_03_04_13_01_08_03_03, // Class-specific descriptor (17 bytes)
        56'h07_05_81_03_20_00_01,  // IN Endpoint 1 (7 bytes)
        56'h07_05_01_03_20_00_01,  // OUT Endpoint 1 (7 bytes)
    // Interface Descriptor CONTROLLER 2
        72'h09_04_01_00_02_FF_5D_01_00,  
       136'h11_21_10_01_01_25_82_14_03_03_03_04_13_02_08_03_03, // Class-specific descriptor (17 bytes)
        56'h07_05_82_03_20_00_01,  // IN Endpoint 7 (7 bytes)
        56'h07_05_02_03_20_00_01,  // OUT Endpoint 7 (7 bytes)
    // Interface Descriptor CONTROLLER 3
        72'h09_04_02_00_02_FF_5D_01_00,  
       136'h11_21_10_01_01_25_83_14_03_03_03_04_13_03_08_03_03, // Class-specific descriptor (17 bytes)
        56'h07_05_83_03_20_00_01,  // IN Endpoint 8 (7 bytes)
        56'h07_05_03_03_20_00_01,  // OUT Endpoint 8 (7 bytes)
    // Interface Descriptor CONTROLLER 4
        72'h09_04_03_00_02_FF_5D_01_00,  
       136'h11_21_10_01_01_25_84_14_03_03_03_04_13_04_08_03_03, // Class-specific descriptor (17 bytes)
        56'h07_05_84_03_20_00_01,  // IN Endpoint 9 (7 bytes)
        56'h07_05_04_03_20_00_01  // OUT Endpoint 9 (7 bytes) 
    }),

    .DESCRIPTOR_CONFIG_GCA  ( {  // 512 bytes available
        72'h09_02_29_00_01_01_00_E0_FA ,  72'h09_04_00_00_02_03_00_00_00 ,
        72'h09_21_10_01_00_01_22_D6_00 ,  56'h07_05_81_03_25_00_01 ,
        56'h07_05_02_03_05_00_01 

} ),
    .EP81_MAXPKTSIZE    ( GC_Adapter_cnt ),
    .EP82_MAXPKTSIZE    ( XBOX360_cnt ),
    .EP83_MAXPKTSIZE    ( XBOX360_cnt ),
    .EP84_MAXPKTSIZE    ( XBOX360_cnt ),
    .EP85_MAXPKTSIZE    ( HORI2_cnt ),
    .EP86_MAXPKTSIZE    ( HORI2_cnt ),
    .EP87_MAXPKTSIZE    ( HORI2_cnt ),
    .EP88_MAXPKTSIZE    ( HORI2_cnt ),
    .EP89_MAXPKTSIZE    ( HORI2_cnt ),
    .EP8A_MAXPKTSIZE    ( GC_NSO_cnt           ),
    .EP8B_MAXPKTSIZE    ( 8'd64           ),
    .EP8C_MAXPKTSIZE    ( GC_NSO_cnt           ),
    .EP8D_MAXPKTSIZE    ( GC_NSO_cnt           ),
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
    .ep81_data          ( EP1data ),
    .ep81_size          ( EP81INsize[7:0]  ),
    .ep81_valid         ( in_valid1        ),
    .ep81_ready         ( in_ready1        ),
    .ep82_data          ( in_datax2[167:160] ),
    .ep82_valid         ( in_valid2        ),
    .ep82_ready         ( in_ready2        ),
    .ep83_data          ( in_datax3[167:160] ),
    .ep83_valid         ( in_valid3        ),
    .ep83_ready         ( in_ready3        ),
    .ep84_data          ( in_datax4[167:160] ),
    .ep84_valid         ( in_valid4        ),
    .ep84_ready         ( in_ready4        ),
    .ep85_data          ( 8'h0 ),
    .ep85_valid         ( in_valid5        ),
    .ep85_ready         ( in_ready5        ),
    .ep86_data          ( in_datah1[71:64] ),
    .ep86_valid         ( in_valid6        ),
    .ep86_ready         ( in_ready6        ),
    .ep87_data          ( in_datah2[71:64] ),
    .ep87_valid         ( in_valid7        ),
    .ep87_ready         ( in_ready7        ),
    .ep88_data          ( in_datah3[71:64] ),
    .ep88_valid         ( in_valid8        ),
    .ep88_ready         ( in_ready8        ),
    .ep89_data          ( in_datah4[71:64] ),
    .ep89_valid         ( in_valid9        ),
    .ep89_ready         ( in_ready9        ),
    .ep8A_data          ( in_dataA[519:512]),
    .ep8A_valid         ( in_validA        ),
    .ep8A_ready         ( in_readyA        ),
    .ep8B_data          ( in_dataB[647:640]),
    .ep8B_size          ( EP8BINsize[7:0]  ),
    .ep8B_valid         ( in_validB        ),
    .ep8B_ready         ( in_readyB        ),
    .ep8C_data          ( 8'h0 ),
    .ep8C_valid         ( in_validC        ),
    .ep8C_ready         ( in_readyC        ),
    .ep8D_data          ( 8'h0 ),
    .ep8D_valid         ( in_validD        ),
    .ep8D_ready         ( in_readyD        ),
    .ep01_data          ( controller_receive_data1 ),
    .ep01_valid         ( out_valid1       ),
    .ep02_data          ( controllers_receive_data2 ),
    .ep02_valid         ( out_valid2       ),
    .ep03_data          ( controller_receive_data3 ),
    .ep03_valid         ( out_valid3       ),
    .ep04_data          ( controller_receive_data4 ),
    .ep04_valid         ( out_valid4       ),
    .ep05_data          ( controller_receive_data5 ),
    .ep05_valid         ( out_valid5       ),
    .ep06_data          ( controller_receive_data6 ),
    .ep06_valid         ( out_valid6       ),
    .ep07_data          ( controller_receive_data7 ),
    .ep07_valid         ( out_valid7       ),
    .ep08_data          ( controller_receive_data8 ),
    .ep08_valid         ( out_valid8       ),
    .ep09_data          ( controller_receive_data9 ),
    .ep09_valid         ( out_valid9       ),
    .ep0A_data          ( controller_receive_dataA ),
    .ep0A_valid         ( out_validA       ),
    .ep0B_data          ( controller_receive_dataB ),
    .ep0B_valid         ( out_validB       ),
    .ep0C_data          ( controller_receive_dataC ),
    .ep0C_valid         ( out_validC       ),    
    .ep0D_data          ( controller_receive_dataD ),
    .ep0D_valid         ( out_validD       ),
    .Mode_Select        ( Mode_Select ),
.controller_count_start ( controller_count_start),
    .debug_en           ( debug_en         ),
    .debug_data         ( debug_data       ),
    .debug_uart_tx      ( debug_uart_tx    )
);


endmodule
