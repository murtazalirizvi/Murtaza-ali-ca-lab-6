module alu (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUControl, // Fixed to 4 bits
    output reg [31:0] ALUResult,
    output Zero
);

always @(*) begin
    case (ALUControl)
        4'b0000: ALUResult = A & B;                        // AND
        4'b0001: ALUResult = A | B;                        // OR
        4'b0010: ALUResult = A + B;                        // ADD
        4'b0011: ALUResult = A ^ B;                        // XOR
        4'b0100: ALUResult = A << B[4:0];                  // SLL
        4'b0101: ALUResult = A >> B[4:0];                  // SRL
        4'b0110: ALUResult = A - B;                        // SUB
        4'b0111: ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
        4'b1000: ALUResult = (A < B) ? 32'd1 : 32'd0;      // SLTU
        4'b1001: ALUResult = A;                            // PASS A
        4'b1010: ALUResult = B;                            // PASS B
        4'b1100: ALUResult = ~(A | B);                     // NOR
        default: ALUResult = 32'b0;
    endcase
end

assign Zero = (ALUResult == 32'b0);

endmodule