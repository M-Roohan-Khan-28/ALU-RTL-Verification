# Bounded WIDTH=8 ALU contract

The combinational `alu` takes 8-bit `a` and `b` and 3-bit `op`; it emits an
8-bit `y`, one-bit `carry`, and one-bit `zero`. It has no clock or reset port.
The tested contract is two-state input data at `WIDTH=8`. Other parameter
widths and X/Z input semantics are outside this validation.

| `op` | Result `y` | Carry |
| --- | --- | --- |
| 0 | `(a + b) & 8'hFF` | ninth sum bit |
| 1 | `(a - b) & 8'hFF` | 0 |
| 2 | `a & b` | 0 |
| 3 | `a \| b` | 0 |
| 4 | `a ^ b` | 0 |
| 5 | `(a << b[2:0]) & 8'hFF` | 0 |
| 6 | `a >> b[2:0]` | 0 |
| 7 | `~(a ^ b) & 8'hFF` | 0 |

`zero` is one exactly when `y` is zero. Shifts ignore every `b` bit above
bit 2. The output is checked after a deterministic 1 ns settle delay in the
portable test environment. This contract does not assign a subtraction
borrow/carry flag.
