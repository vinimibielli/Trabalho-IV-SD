`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module tb;

  reg clock, reset, start, op;
  reg [31:0] data_a, data_b;
  wire busy, ready;
  wire [31:0] data_o;

  localparam PERIOD_100MHZ = 8;  

  initial
  begin
    clock = 1'b1;
    forever #(PERIOD_100MHZ/2) clock = ~clock;
  end

  initial
  begin
    reset = 1'b1;
    #30;
    reset = 1'b0;
    start = 1'b0;
    //SOMA++
    op = 1'b0;
    data_a = 32'b01010011100100100100000100100100;
    data_b = 32'b01001001101101010011000010011000;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SOMA--
    op = 1'b0;
    data_a = 32'b11100010010011110101011001011001;
    data_b = 32'b11011110101000001111111001111001;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SOMA-+
    op = 1'b0;
    data_a = 32'b01011011100001110011010101010100;
    data_b = 32'b11010110111101000101001100011101;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SUB++
    op = 1'b1;
    data_a = 32'b01011000111010010110011011110100;
    data_b = 32'b01100010100101001110111111110100;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SUB--
    op = 1'b1;
    data_a = 32'b11010101001001010101001010111011;
    data_b = 32'b11001101111010111100011001101001;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SUB+-
    op = 1'b1;
    data_a = 32'b01100010110010100101001100011011;
    data_b = 32'b11010010100001011101010110110001;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SOMA++
    op = 1'b0;
    data_a = 32'b00011111110001010101101110010101;
    data_b = 32'b00011010101100110111100011001010;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SOMA--
    op = 1'b0;
    data_a = 32'b10100010110011010001101010011011;
    data_b = 32'b10101110100011010111011100110010;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SOMA-+
    op = 1'b0;
    data_a = 32'b00100110111001110001101101100110;
    data_b = 32'b10101111100110101100111011101011;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SUB++
    op = 1'b1;
    data_a = 32'b00100110111001110001101101100110;
    data_b = 32'b00101001110111000100101010101110;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SUB--
    op = 1'b1;
    data_a = 32'b10011110101100111101011110101001;
    data_b = 32'b10011010100110110101011010100011;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
    //SUB+-
    op = 1'b1;
    data_a = 32'b10110001110010100001001111011010;
    data_b = 32'b00110101111111000000101100101011;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    wait (busy != 1'b1);
    #10;
  end

  top DUT(.reset(reset), .clock(clock), .start(start), .op(op), .data_a(data_a), .data_b(data_b), .busy(busy), .ready(ready), .data_o(data_o));

endmodule 