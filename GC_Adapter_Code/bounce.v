module bounce (
    input clk , line , enable , 
    output reg debounced = 0
    ); //This module fixes the inconsistent polling of the GC or GC adapter for use in other modules

reg [1:0] low = 2'b0; reg [1:0] high = 2'b0; 

always @ ( posedge clk ) begin
    if ( enable == 1 ) begin
        if ( line == 1 ) begin
            high <= high + 1'b1; low <= 2'b00;
        end
        if ( line == 0 ) begin
            low <= low + 1'b1; high <= 2'b00;
        end
        if ( high == 2'b11 ) begin
            debounced <= 1;
        end
        if ( low == 2'b11 ) begin
            debounced <= 0;
        end
    end
    else begin
        low <= 2'b00; high <= 2'b00;
    end
end

endmodule