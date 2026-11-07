`timescale 1ns/1ps
// WIDTH=8 two-state enumeration; expected values are derived independently.
module tb_alu_exhaustive;
  logic [7:0] a=0,b=0;
  logic [2:0] op=0;
  wire [7:0] y;
  wire carry,zero;
  alu #(.WIDTH(8)) dut(.*);
  int tuples=0,directed=0,identities=0,comparisons=0;
  bit wave_only;

  function automatic logic [8:0] reference(input int unsigned lhs,
                                            input int unsigned rhs,
                                            input int unsigned code);
    int unsigned value;
    bit cy;
    value=0; cy=0;
    case(code)
      0: begin value=lhs+rhs; cy=(value>255); end
      1: value=(lhs-rhs)&255;
      2: value=lhs&rhs;
      3: value=lhs|rhs;
      4: value=lhs^rhs;
      5: value=(lhs << (rhs&7))&255;
      6: value=lhs >> (rhs&7);
      7: value=(~(lhs^rhs))&255;
    endcase
    return {cy,value[7:0]};
  endfunction

  task automatic check_exact(input int unsigned lhs,input int unsigned rhs,
                             input int unsigned code,input logic [7:0] wanted_y,
                             input bit wanted_carry,input string label);
    a=lhs[7:0]; b=rhs[7:0]; op=code[2:0];
    #1;
    if(y !== wanted_y || carry !== wanted_carry || zero !== (wanted_y==0))
      $fatal(1,"ALU_EXHAUSTIVE_MISMATCH %s op=%0d a=%02h b=%02h expected=%02h/%b/%b observed=%02h/%b/%b",
             label,code,lhs,rhs,wanted_y,wanted_carry,(wanted_y==0),y,carry,zero);
    comparisons+=3;
  endtask
  task automatic check_reference(input int unsigned lhs,input int unsigned rhs,
                                 input int unsigned code,input string label);
    logic [8:0] wanted;
    wanted=reference(lhs,rhs,code);
    check_exact(lhs,rhs,code,wanted[7:0],wanted[8],label);
  endtask

  initial begin
    wave_only=$test$plusargs("WAVE_ONLY");
    // Hand-calculated boundaries independent of the general reference function.
    check_exact('hA5,'h3C,0,'hE1,0,"add sample"); directed++;
    check_exact('hA5,'h3C,1,'h69,0,"sub sample"); directed++;
    check_exact('hA5,'h3C,2,'h24,0,"and sample"); directed++;
    check_exact('hA5,'h3C,3,'hBD,0,"or sample"); directed++;
    check_exact('hA5,'h3C,4,'h99,0,"xor sample"); directed++;
    check_exact('hA5,'h3C,5,'h50,0,"left sample"); directed++;
    check_exact('hA5,'h3C,6,'h0A,0,"right sample"); directed++;
    check_exact('hA5,'h3C,7,'h66,0,"xnor sample"); directed++;
    check_exact('hFF,'h01,0,'h00,1,"add carry zero"); directed++;
    check_exact('hFF,'hFF,0,'hFE,1,"add carry nonzero"); directed++;
    check_exact('h00,'h01,1,'hFF,0,"sub underflow"); directed++;
    check_exact('h55,'h55,1,'h00,0,"sub zero"); directed++;
    check_exact('h7F,'h01,0,'h80,0,"signed boundary no carry"); directed++;
    check_exact('h80,'h80,0,'h00,1,"double high bit"); directed++;
    if(wave_only) begin
      $display("ALU_WAVE_PASS directed=%0d comparisons=%0d",directed,comparisons);
      $finish;
    end

    // Every two-state operand pair at every opcode, exactly once.
    for(int code=0;code<8;code++)
      for(int lhs=0;lhs<256;lhs++)
        for(int rhs=0;rhs<256;rhs++) begin
          check_reference(lhs,rhs,code,"exhaustive"); tuples++;
        end

    // Independently hand-derived algebraic identities across all operand A.
    for(int lhs=0;lhs<256;lhs++) begin
      check_exact(lhs,lhs,4,0,0,"xor self"); identities++;
      check_exact(lhs,lhs,7,'hFF,0,"xnor self"); identities++;
      check_exact(lhs,lhs,1,0,0,"sub self"); identities++;
      check_exact(lhs,0,2,0,0,"and zero"); identities++;
      check_exact(lhs,0,3,lhs[7:0],0,"or zero"); identities++;
      check_exact(lhs,'hFF,2,lhs[7:0],0,"and ones"); identities++;
      check_exact(lhs,'hFF,3,'hFF,0,"or ones"); identities++;
    end

    // All shift counts with high B bits varied; those bits must be ignored.
    for(int lhs_case=0;lhs_case<5;lhs_case++) begin
      int unsigned lhs;
      case(lhs_case)
        0:lhs=0; 1:lhs=1; 2:lhs='h80; 3:lhs='h81; 4:lhs='hFF;
      endcase
      for(int shift=0;shift<8;shift++)
        for(int high=0;high<3;high++) begin
          int unsigned rhs;
          case(high)
            0:rhs=shift; 1:rhs=shift|'h08; 2:rhs=shift|'hF8;
          endcase
          check_reference(lhs,rhs,5,"left high-bit alias"); directed++;
          check_reference(lhs,rhs,6,"right high-bit alias"); directed++;
        end
    end
    if(tuples != 524288) $fatal(1,"ALU_TUPLE_COUNT wanted=524288 observed=%0d",tuples);
    $display("ALU_EXHAUSTIVE_PASS tuples=%0d directed=%0d identities=%0d comparisons=%0d",
             tuples,directed,identities,comparisons);
    $finish;
  end
  initial begin #900000; $fatal(1,"ALU_EXHAUSTIVE_TIMEOUT"); end
endmodule
