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
//reg erro;
reg sinal_o;
wire complemento;
wire erro;

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
    if((EA == 2'd0 || EA == 2'd2 || start == 1'b1) && EA != 2'd1)
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
        2'd0 : begin //COLOCANDO O VALOR NOS REGISTRADORES
            mantissa_a <= data_a[22:0];
            mantissa_b <= data_b[22:0];
            expoente_a <= data_a[30:23];
            expoente_b <= data_b[30:23];
            if(expoente_a > 127)
            begin
                mantissa_a[23] <= 1'b1;
            end
            else
            begin
                mantissa_a[23] <= 1'b0;
            end
            if(expoente_b > 127)
            begin
                mantissa_b[23] <= 1'b1;
            end
            else
            begin
                mantissa_b[23] <= 1'b0;
            end
        end
        2'd1 : begin //EXECUÇÃO DA PRÉ-SOMA
            if(complemento == 1'b1)
            begin
                if(expoente_a > expoente_b)
                begin
                    mantissa_b <= (~mantissa_b + 1'b1) >> expoente_calculo;
                end
                else
                begin
                    mantissa_a <= (~mantissa_a + 1'b1) >> expoente_calculo;
                end
            end
            else
            begin
            if(expoente_a > expoente_b)
            begin
                mantissa_b <= mantissa_b >> expoente_calculo;
            end
            else
            begin
                mantissa_a <= mantissa_a >> expoente_calculo;
            end
            end
        end
        2'd2 : begin //SOMA
            mantissa_soma <= mantissa_a + mantissa_b;   
        
        end
        2'd3 : begin //AJUSTE DOS ERROS
        if(complemento == 1'b1)
            begin   
                    if(mantissa_a > mantissa_b)
                    begin
                        sinal_o <= data_a[31];
                    end
                    else
                    begin
                        sinal_o <= data_b[31];
                    end
            end
            else if(complemento == 1'b0)
            begin           
            sinal_o <= data_a[31];
            end
            if(mantissa_soma[24] == 1'b1)
            begin
                expoente_o <= expoente_o + 1'd1;
                if(complemento == 1'b1)
                begin
                    mantissa_o <= mantissa_soma[23:1] - erro;
                end
                else
                begin
                    mantissa_o <= mantissa_soma[23:1] + erro;

                end

            end
            else
            begin
                if(complemento == 1'b1)
                begin
                    mantissa_o <= mantissa_soma[22:0] - erro;
                end
                else
                begin
                    mantissa_o <= mantissa_soma[22:0] + erro;
                end
            end
            if(expoente_a > expoente_b)
            begin
                expoente_o <= expoente_a;
            end
            else
            begin
                expoente_o <= expoente_b;
            end 
        end
        endcase
    end
end

assign data_o[31] = (EA == 2'd2) ? sinal_o : 1'b0;
assign data_o[30:23] = (EA == 2'd2) ? expoente_o : 8'd0;
assign data_o[22:0] = (EA == 2'd2) ? mantissa_o : 8'd0;
assign expoente_calculo = (expoente_a > expoente_b) ? (expoente_a - expoente_b) : (expoente_b > expoente_a) ? (expoente_b - expoente_a) : 8'd0;
assign busy = (EA == 2'd1) ? 1'b1 : 1'b0;
assign ready = (EA == 2'd2) ? 1'b1 : 1'b0;
assign complemento = ((op == 1'b1 && data_a[31] == data_b[31]) || (op == 1'b0 && data_a[31] != data_b[31])) ? 1'b1 : 1'b0;
assign erro = (expoente_a > expoente_b) ? mantissa_b[expoente_calculo] : mantissa_a[expoente_calculo];

endmodule