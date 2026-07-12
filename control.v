module control(
    input clk,
    input [7:0] code,
    output reg [7:0] imm,
    output reg [2:0] regsel1,   // feeds ALU input 'a'
    output reg [2:0] regsel2,   // feeds ALU input 'b'
    output reg [2:0] writereg,
    output reg       writeenable,
    output reg [2:0] aluop,    
    output reg       compmux,   
    output reg       immux
    );

    localparam [2:0] ACC_ADDR = 3'b000;   // accumulator register address
    localparam [2:0] G_ADDR   = 3'b110;   // hard-wired constant = 8'd1
    localparam [2:0] H_ADDR   = 3'b111;   // hard-wired constant = 8'd0 
    localparam [2:0] ALU_ADD  = 3'b001;
    localparam [1:0] S_DECODE    = 2'b00;
    localparam [1:0] S_FETCH_IMM = 2'b01;
    localparam [1:0] S_EXECUTE   = 2'b10;

    reg [1:0] state;
    always @(*) begin
        writeenable = (state == S_EXECUTE);
    end

    initial begin
        state    = S_DECODE;
        imm      = 8'd0;
        regsel1  = 3'd0;
        regsel2  = 3'd0;
        writereg = 3'd0;
        aluop    = 3'd0;
        compmux  = 1'b0;
        immux    = 1'b0;
    end

    always @(posedge clk) begin
        case (state)
            S_DECODE: begin
                compmux <= 1'b0; 

                case (code[7:6])

                    2'b00: begin // mov reg <- reg
                        regsel1  <= code[2:0];   // source -> 'a'
                        regsel2  <= H_ADDR;      // constant 0 -> 'b'
                        writereg <= code[5:3];   // destination
                        aluop    <= ALU_ADD;     // a+0 = pass-through
                        immux    <= 1'b0;        // 'a' comes from regsel1
                        state    <= S_EXECUTE;
                    end

                    2'b01: begin // mov reg <- immediate
                        writereg <= code[5:3];   
                        regsel1  <= 3'd0;        
                        regsel2  <= H_ADDR;      // constant 0 -> 'b'
                        aluop    <= ALU_ADD;     // imm+0 = pass-through
                        immux    <= 1'b1;        // 'a' comes from imm
                        state    <= S_FETCH_IMM; // next byte is data, not an opcode
                    end

                    2'b10: begin
                    regsel1  <= ACC_ADDR;    // 'a' operand is always the accumulator
                    writereg <= ACC_ADDR;    // result always written back to accumulator
                    immux    <= 1'b0;
                    aluop    <= code[2:0];   // opcode bits ARE the ALU operation directly

                    case (code[2:0])
                        3'b001: regsel2 <= code[5:3];  // ADD  : ACC + R
                        3'b010: regsel2 <= G_ADDR;     // INC  : ACC + 1   (G = const 1)
                        3'b011: regsel2 <= G_ADDR;     // DEC  : ACC - 1   (ALU does the subtraction internally)
                        3'b100: regsel2 <= code[5:3];  // XOR  : ACC ^ R
                        3'b101: regsel2 <= code[5:3];  // AND  : ACC & R
                        3'b110: regsel2 <= code[5:3];  // OR   : ACC | R
                        3'b111: regsel2 <= H_ADDR;     // NOT  : ~ACC       (unary, 'b' unused -> const 0)
                        default: regsel2 <= code[5:3];
                    endcase

                    state <= S_EXECUTE;
                    end

                   default : state <= S_DECODE;

                endcase
            end
            S_FETCH_IMM: begin
                imm   <= code;
                state <= S_EXECUTE;
            end
            S_EXECUTE: begin
                state <= S_DECODE;
            end

            default: state <= S_DECODE;
        endcase
    end
endmodule