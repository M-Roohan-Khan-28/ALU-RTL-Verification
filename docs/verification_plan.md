# ALU verification plan

The original class-based [advanced bench](../tb/tb_top.sv) and its historical
logs remain unchanged and NOT RUN without the required verification-feature
licence. The prior [portable bench](../tb/tb_portable.sv) checks 1,380 fixed
and sampled combinations. The new [exhaustive bench](../tb/tb_exhaustive.sv)
uses a separate integer reference model, explicit 8-bit masking, 9-bit ADD
carry, four-state result comparisons, and 1 ns settle steps. No DUT result is
used as the expected value.

| Requirement | New test |
| --- | --- |
| Eight opcodes and all 8-bit operand pairs | 8 x 256 x 256 = 524,288 two-state tuples |
| Carry, zero, subtraction wrap | 14 hand-calculated directed vectors and explicit result/carry/zero comparison on every tuple |
| Shift counts and high-B aliases | 5 operand classes x 8 counts x 3 high-bit variants x 2 directions |
| Logic/arithmetic identities | Seven identities for every 8-bit A value, 1,792 identity vectors |
| Bounded progress | 900,000 ns bench watchdog; 120-second process timeout per command |

The committed source `d2cb521cd367cb1b3ce6038459a9415546783e9c`
passed 524,288 tuples, 254 directed vectors, 1,792 identity vectors and
1,579,002 individual output comparisons, alongside the existing 1,380
portable checks. The [passing JSON and logs](../reports/technical-completion-2026-11-07/passing/)
record exact commands, source hashes, tool version and real exits. A
[disposable carry fault](../reports/technical-completion-2026-11-07/carry-fault/fault-summary.json)
for A=`81` passed the old portable bench but triggered
`ALU_EXHAUSTIVE_MISMATCH` and wrapper exit 1. The original RTL is unchanged.

The short `+WAVE_ONLY` mode reruns the 14 hand vectors with selected-signal
VCD capture; it does not claim to depict all 524,288 tuples. The
[measured figure](../reports/technical-completion-2026-11-07/passing/alu-directed.svg),
[raw VCD](../reports/technical-completion-2026-11-07/passing/alu-directed.vcd)
and [metadata](../reports/technical-completion-2026-11-07/passing/alu-directed.json)
are from the same tested source. A passing vector count is not functional or
code coverage. No UVM, SVA, covergroup, synthesis, timing, FPGA, or hardware
result is claimed.

