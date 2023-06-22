module top(
    input start, op, reset, clock,
    input [31:0] data_a, data_b,
    output busy, ready,
    output [31:0] data_o
);

reg [1:0] EA;
reg [23:0] mantissa_a, mantissa_b;
reg [22:0] mantissa_o;
reg [24:0] mantissa_soma;
reg [7:0] expoente_a, expoente_b, expoente_o;
wire[7:0] expoente_calculo;
reg [1:0] count;
wire start_ed;
reg erro;

edge_detector start_ed_detector(.clock(clock), .reset(reset), .din(start), .rising(start_ed));

//--------------------------------------//
//         MÁQUINA DE ESTADOS           //
//--------------------------------------//

//LEGENDA:
//2'd0 : IDLE
//2'd1 : OPERAÇÃO
//2'd2 : READY

always @(posedge clock or posedge reset)
begin
    if(reset == 1'b1)
    begin
        EA <= 2'd0;
    end
    else
    begin
        case(EA)
            2'd0 : begin
                if(start == 1'b1)
                begin
                    EA <= 2'd1;
                end
            end
            2'd1 : begin
                if(count == 2'd3)
                begin
                    EA <= 2'd2;
                end
            end
            2'd2 : begin
                if(start == 1'b1)
                begin
                    EA <= 2'd0;
                end
            end
        endcase   
    end
end

always @(posedge clock)
begin
    if((EA == 2'd0 || EA == 2'd2 || start_ed == 1'b1) && EA != 2'd1)
    begin
        count = 2'd0;
    end
    else
    begin
        count <= count + 1'd1;
    end
end

always @(posedge clock or posedge reset)
begin
    if(reset == 1'b1)
    begin
        mantissa_a <= 23'd0;
        mantissa_b <= 23'd0;
        mantissa_o <= 23'd0;
        expoente_a <= 8'd0;
        expoente_b <= 8'd0;
        expoente_o <= 8'd0;
    end
    else
    begin
        case(count)
        2'd0 : begin
            mantissa_a <= data_a[22:0];
            mantissa_b <= data_b[22:0];
            mantissa_a[23] <= 1'b1;
            mantissa_b[23] <= 1'b1;
            expoente_a <= data_a[30:23] - 8'd127;
            expoente_b <= data_b[30:23] - 8'd127; 
        end
        2'd1 : begin
            if(expoente_a > expoente_b)
            begin
                mantissa_b <= mantissa_b >> expoente_calculo;
                erro <= data_b[expoente_calculo];
                expoente_o <= expoente_a;
            end
            else
            begin
                mantissa_a <= mantissa_a >> expoente_calculo;
                 erro <= data_a[expoente_calculo];
            end
        end
        2'd2 : begin
            mantissa_soma <= mantissa_a + mantissa_b;
        end
        2'd3 : begin
            if(mantissa_soma[24] == 1'b1)
            begin
                mantissa_o <= mantissa_soma[23:1] + erro;

                expoente_o <= expoente_o + 1'd1;
            end
            else
            begin
                mantissa_o <= mantissa_soma[22:0] + erro;
            end
        end
        endcase
    end
end

//assign data_o[31] = (data_a && data_b == 1'b0 && EA == 2'd2 && op == 1'b0) ? 1'b0 : 1'b0;
assign data_o[31] = (EA == 2'd2 && data_a[31] == 1'b0 && data_b[31] == 1'b0 && op == 1'b0) ? 1'b0 : 1'b0;
assign data_o[30:23] = (EA == 2'd2) ? expoente_o : 8'd0;
assign data_o[22:0] = (EA == 2'd2) ? mantissa_o : 8'd0;
assign expoente_calculo = (expoente_a > expoente_b) ? (expoente_a - expoente_b) : (expoente_b > expoente_a) ? (expoente_b - expoente_a) : 8'd0;
assign busy = (EA == 2'd1) ? 1'b1 : 1'b0;
assign ready = (EA == 2'd2) ? 1'b1 : 1'b0;

endmodule