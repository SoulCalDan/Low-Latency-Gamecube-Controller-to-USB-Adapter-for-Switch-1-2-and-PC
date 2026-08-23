module PollGen ( input clk , input ready ,
    output reg GC_poll , output reg GC_enable , input RUMBLE , input [2:0] connection_type
);
    //reg [99:0] Origin  = 
    //reg [99:0] Sync    = 
	reg [103:0] Data    = 104'b1111_0001_0111_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0111_0111_0001_0001_0001_0001_0001_0001_0001_0001_0111;
	parameter bits = 8; 
	reg [bits:0] bit_counter = 511; 
	reg [6:0] clk_counter = 0; reg [6:0] readycnt;

always @ ( posedge clk ) begin
    
    if ( (connection_type == 3'b001) || (connection_type == 3'b011) ) begin
        Data[103:0] <= 104'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_0001_0111_0001_0001_0001_0001_0001_0111_0111; //36'b0001_0111_0001_0001_0001_0001_0001_0111_0111;
    end
    else if ( (connection_type == 3'b000) || (connection_type == 3'b010) ) begin
        Data[103:0] <= 104'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_0001_0001_0001_0001_0001_0001_0001_0001_0111; //36'b0001_0001_0001_0001_0001_0001_0001_0001_0111; 
    end
    else begin
        Data[103:0] <= 104'b1111_0001_0111_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0111_0111_0001_0001_0001_0001_0001_0001_0001_0001_0111;
    end

    if ( ready ) begin      //This if/else controls when the polling of the GC controller begins, and sends the request to the controller
        readycnt <= 0;
        clk_counter <= 0;
        bit_counter <= 511;
    end
    else begin
        readycnt <= readycnt + 1'b1;
        if ( readycnt > 50 ) begin 
            readycnt <= 121;
            clk_counter <= clk_counter + 1'b1;
            if ( clk_counter == 78 || (clk_counter == 39 && bit_counter == 2) ) begin //force stop bit to end early
                clk_counter <= 0;
                if ( bit_counter == 1 ) begin
                    GC_enable <= 1;         
                    bit_counter <= 511;
                end
                else if ( bit_counter < 100 && bit_counter > 0 ) begin
                    GC_enable <= 0;
                    if ( (bit_counter == 5 || bit_counter == 6) && connection_type > 3'b011 ) begin
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