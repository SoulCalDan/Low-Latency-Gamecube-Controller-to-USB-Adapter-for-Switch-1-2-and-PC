module GC_PollGen ( input clk , input ready , input oktosend , 
    output reg GC_poll , output reg GC_enable , input RUMBLE , input [2:0] connection_type
);
    //reg [99:0] Origin  = 
    //reg [99:0] Sync    = 
	reg [99:0] Data    = 100'b0001_0111_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0111_0111_0001_0001_0001_0001_0001_0001_0001_0001_0111;

	parameter bits = 8; 
    parameter delay = 511;
	reg [bits:0] bit_counter = delay;//bits_reset; 
	reg [6:0] clk_counter = 0; reg [6:0] readycnt;

always @ ( posedge clk ) begin //divide the 60MHz clk to 1MHz
    
    if ( connection_type == 1 ) begin
        Data[99:0] <= 100'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_0001_0111_0001_0001_0001_0001_0001_0111_0111; //36'b0001_0111_0001_0001_0001_0001_0001_0111_0111;    //Just easier to waste registers instead of having to change timing, only need 37 bits
    end
    else if ( connection_type == 0 ) begin
        Data[99:0] <= 100'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_0001_0001_0001_0001_0001_0001_0001_0001_0111; //36'b0001_0001_0001_0001_0001_0001_0001_0001_0111;      //Just easier to waste registers instead of having to change timing, only need 37 bits
    end
    else begin
        Data[99:0] <= 100'b0001_0111_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0111_0111_0001_0001_0001_0001_0001_0001_0001_0001_0111;
    end

    if ( ready ) begin      //This if/else controls when the polling of the GC controller begins, and sends the request to the controller
        readycnt <= 0;
        clk_counter <= 0;
        bit_counter <= delay;
    end
    else begin
        if ( oktosend ) begin
            readycnt <= readycnt + 1'b1;
        end
        if ( readycnt > 50 ) begin 
            readycnt <= 121;
            clk_counter <= clk_counter + 1'b1;
            if ( clk_counter == 78 ) begin 
                clk_counter <= 0;
                if ( bit_counter == 0 ) begin
                    GC_enable <= 1;         
                    bit_counter <= delay;
                end
                else if ( bit_counter < 100 && bit_counter > 0 ) begin
                    GC_enable <= 0;
                    if ( (bit_counter == 5 || bit_counter == 6) && connection_type == 3'b010 ) begin
                        GC_poll <= RUMBLE;
                    end
                    else begin
                        GC_poll <= Data[bit_counter];                        
                    end
                    bit_counter <= bit_counter - 1'b1;
                end
                else begin
                    GC_enable <= 1;
                    bit_counter <= bit_counter - 1'b1;
                end
            end
        end
    end

end

endmodule