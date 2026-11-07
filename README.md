# 8-Bit ALU RTL and Verification

**SystemVerilog · Eight operations · Directed simulation**

An 8-bit combinational arithmetic and logic unit with eight opcodes, result, carry, and zero outputs. The standalone project includes a deterministic self-checking testbench, an independent expected-result model, and reproducible ModelSim scripts.

The preserved portable regression passed **1,380 checks**. A new exhaustive
WIDTH=8 run passed **524,288 two-state operand/opcode tuples** and
**1,579,002 independent output comparisons**; see the [new results](docs/RESULTS.md).
The original constrained-random environment is retained separately and
requires a compatible verification licence. See [portable validation](docs/portable_validation.md)
for that earlier tested configuration and scope.

The original design, testbench, and historical evidence are preserved from the HDL collection. [Original source documentation](SOURCE_README.md) and the provenance section below identify that baseline.

## Run

From the repository root, with Python 3.9+ and compatible ModelSim/Questa
executables available, run the complete portable and exhaustive suite into a
new output directory:

```powershell
$env:MODELSIM_BIN = 'C:\intelFPGA\20.1\modelsim_ase\win32aloem'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/run_regression.ps1 -OutputDir C:\short\alu-exhaustive-unique -CaptureWave
```

The new runner uses isolated compilation/output, rejects existing output
directories, checks exact result markers and simulator diagnostics, and has
120-second subprocess timeouts. The older `sim/run.sh` and
`scripts/run_portable.ps1` remain as historical entry points; their separate
status is documented below. Check the [retained validation report](source-docs/VALIDATION.md)
for extraction-time evidence.

### Portable deterministic regression

With `vlib`, `vlog`, and `vsim` on PATH, run from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/run_portable.ps1
```

This compiles only the unchanged RTL and [plain testbench](tb/tb_portable.sv), writing fresh output to the ignored `portable-results/` directory. It checks all eight implemented 8-bit operations using fixed examples, boundary vectors and an independent integer-based expected-result model. The ALU has no reset port, so reset behavior is not applicable. See [portable validation](docs/portable_validation.md) and its [fresh logs](reports/portable-2026-11-05/). The original constrained-random testbench and its licence limitation remain as they were; the portable checks are not equivalent coverage.

## Verification status

The original `reports/compile.log` and `reports/simulation.log` are historical
evidence copied from the source repository. New [raw passing logs and JSON](reports/technical-completion-2026-11-07/passing/)
at tested source `d2cb521cd367cb1b3ce6038459a9415546783e9c` show
1,380 portable checks plus 524,288 exhaustive tuples, 254 directed vectors,
1,792 identity vectors and 1,579,002 individual output comparisons, all
wrapper exit 0 under ModelSim Intel FPGA Starter Edition 2020.1. A
[disposable carry fault](reports/technical-completion-2026-11-07/carry-fault/)
passed the old portable test but caused the new oracle to fatal and the wrapper
to exit 1. The original RTL was unchanged.

The [measured 14-vector waveform](reports/technical-completion-2026-11-07/passing/alu-directed.svg)
was rendered from the [actual VCD](reports/technical-completion-2026-11-07/passing/alu-directed.vcd),
with [timebase and hash metadata](reports/technical-completion-2026-11-07/passing/alu-directed.json).
It is a short directed capture, not a trace of all exhaustive tuples. The
[bounded specification](docs/SPECIFICATION.md) and [verification plan](docs/verification_plan.md)
give opcode and test details.

The original constrained-random suite remains licence-blocked and NOT RUN.
Starter did not execute the probed randomization, covergroups, SVA, or UVM
flows. Passing tuples are not code/functional coverage closure, and other
parameter widths, X/Z behavior, synthesis, timing, FPGA and hardware are not
established.

## Provenance and changes

Source commit: `df8d6f66898a08df75cd2071ddac7bbba9ba9b16`. Source path: `projects/alu`.

[SOURCE_PROVENANCE.json](SOURCE_PROVENANCE.json) records checksums of every original file. `SOURCE_README.md` is the unchanged original README. No RTL or testbench functionality was changed during extraction. Source history remains available in the original repository; this is a snapshot, not a rewrite of its authorship.

## Next engineering work

The next separate milestone is licensed advanced verification and measured
coverage, followed by target-specific implementation evidence if needed.
