`timescale 1ns/1ps

// Plain deterministic tests for the existing 8-bit combinational ALU.
// The original class-based, constrained-random environment remains in tb_top.sv.
module tb_alu_portable;
    reg  [7:0] a, b;
    reg  [2:0] op;
    wire [7:0] y;
    wire       carry, zero;
    reg  [7:0] vectors [0:12];
    integer checks = 0;
    integer i, j, k;

    alu #(.WIDTH(8)) dut (.a(a), .b(b), .op(op), .y(y), .carry(carry), .zero(zero));

    // An independent integer-based oracle. The fixed examples below also
    // check the oracle's basic arithmetic and bit-pattern expectations.
    function automatic [8:0] model;
        input [7:0] aa, bb;
        input [2:0] code;
        integer lhs, rhs, wide;
        reg [7:0] result;
        reg cy;
        begin
            lhs = aa;
            rhs = bb;
            wide = 0;
            result = 8'h00;
            cy = 1'b0;
            case (code)
                3'd0: begin wide = lhs + rhs; result = wide & 255; cy = (wide > 255); end
                3'd1: result = (lhs - rhs) & 255;
                3'd2: result = lhs & rhs;
                3'd3: result = lhs | rhs;
                3'd4: result = lhs ^ rhs;
                3'd5: result = (lhs << (rhs & 7)) & 255;
                3'd6: result = lhs >> (rhs & 7);
                3'd7: result = ~(lhs ^ rhs) & 255;
            endcase
            model = {cy, result};
        end
    endfunction

    task automatic check_expected;
        input [7:0] aa, bb;
        input [2:0] code;
        input [7:0] expected_y;
        input expected_carry;
        begin
            a = aa;
            b = bb;
            op = code;
            #1;
            if (y !== expected_y || carry !== expected_carry ||
                zero !== (expected_y == 8'h00))
                $fatal(1, "ALU mismatch op=%0d a=%02h b=%02h got=%02h/%b/%b expected=%02h/%b/%b",
                       code, aa, bb, y, carry, zero, expected_y,
                       expected_carry, (expected_y == 8'h00));
            checks = checks + 1;
        end
    endtask

    task automatic check_model;
        input [7:0] aa, bb;
        input [2:0] code;
        reg [8:0] expected;
        begin
            expected = model(aa, bb, code);
            check_expected(aa, bb, code, expected[7:0], expected[8]);
        end
    endtask

    initial begin
        #100000;
        $fatal(1, "ALU portable test timeout");
    end

    initial begin
        // Hand-calculated reference examples for every implemented operation.
        check_expected(8'hA5, 8'h3C, 3'd0, 8'hE1, 1'b0);
        check_expected(8'hA5, 8'h3C, 3'd1, 8'h69, 1'b0);
        check_expected(8'hA5, 8'h3C, 3'd2, 8'h24, 1'b0);
        check_expected(8'hA5, 8'h3C, 3'd3, 8'hBD, 1'b0);
        check_expected(8'hA5, 8'h3C, 3'd4, 8'h99, 1'b0);
        check_expected(8'hA5, 8'h3C, 3'd5, 8'h50, 1'b0);
        check_expected(8'hA5, 8'h3C, 3'd6, 8'h0A, 1'b0);
        check_expected(8'hA5, 8'h3C, 3'd7, 8'h66, 1'b0);

        // Wrap, carry, zero, subtraction underflow and full shift range.
        check_expected(8'hFF, 8'h01, 3'd0, 8'h00, 1'b1);
        check_expected(8'hFF, 8'hFF, 3'd0, 8'hFE, 1'b1);
        check_expected(8'h00, 8'h01, 3'd1, 8'hFF, 1'b0);
        check_expected(8'h55, 8'h55, 3'd1, 8'h00, 1'b0);
        for (k = 0; k < 8; k = k + 1) begin
            check_model(8'h81, k, 3'd5);
            check_model(8'h81, k, 3'd6);
        end

        vectors[0]=8'h00; vectors[1]=8'h01; vectors[2]=8'h02;
        vectors[3]=8'h07; vectors[4]=8'h08; vectors[5]=8'h0F;
        vectors[6]=8'h10; vectors[7]=8'h55; vectors[8]=8'h7F;
        vectors[9]=8'h80; vectors[10]=8'hAA; vectors[11]=8'hFE;
        vectors[12]=8'hFF;
        for (k = 0; k < 8; k = k + 1)
            for (i = 0; i < 13; i = i + 1)
                for (j = 0; j < 13; j = j + 1)
                    check_model(vectors[i], vectors[j], k);

        $display("PORTABLE_TEST_PASS ALU checks=%0d", checks);
        $finish;
    end
endmodule
