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
    op = 1'b1;
    data_a = 32'b01011001111111010011110110010111;
    data_b = 32'b01010001111001011111010010111110;
    #80;
    start  = 1'b1;
    #8;
    start = 1'b0;
    #8;
    start = 1'b1;
    #8;
    start = 1'b0;


  end

  top DUT(.reset(reset), .clock(clock), .start(start), .op(op), .data_a(data_a), .data_b(data_b), .busy(busy), .ready(ready), .data_o(data_o));

endmodule 