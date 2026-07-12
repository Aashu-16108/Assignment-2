timescale 1ns/1ps

module eight_bit_alu_tb;
reg [7:0]a,b;
reg [2:0]sel;
wire [7:0]o;
wire c;
eight_bit_alu out(
    .a(a),
    .b(b),
    .sel(sel),
    .o(o),
    .c(c)
);
initial begin

    $monitor("a=%H b=%H o=%H c=%b",a,b,o,c);

    $dumpfile("eight_bit_tb.vcd");
    $dumpvars(0,out);

    a=8'HFF;b=8'HF0;sel=3'b000; #100;
    a=8'H0A;b=8'HF0;sel=3'b001; #100;
    a=8'H8D;b=8'HF0;sel=3'b010;  #100;
    a=8'H3E;b=8'HF0;sel=3'b011;  #100;
    a=8'H3E;b=8'HF0;sel=3'b100;  #100;
    a=8'H3E;b=8'HF0;sel=3'b101;  #100;
    a=8'H3E;b=8'HF0;sel=3'b110;  #100;
    a=8'H3E;b=8'HF0;sel=3'b111;  #100;
    $finish;    
end
endmodule
