module SME(
    // Input signals
    clk,
    rst_n,
    chardata,
    isstring,
    ispattern,
    // Output signals
    out_valid,
    match,
    match_index
);
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input clk;
input rst_n;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg out_valid;


endmodule