# New executable ALU result — 7 November 2026

Source and test runner commit: `d2cb521cd367cb1b3ce6038459a9415546783e9c`.
Simulator: ModelSim Intel FPGA Starter Edition `vsim 2020.1 Simulator
2020.02 Feb 28 2020`. [Machine-readable passing result](../reports/technical-completion-2026-11-07/passing/results.json)
records clean source, source-file SHA-256 hashes, exact commands and a
120-second wall-clock bound. The wrapper exited 0.

| Simulation | Observed result |
| --- | --- |
| Preserved portable `tb_alu_portable` | 1,380 checks, PASS |
| New `tb_alu_exhaustive` | 524,288 tuples, 254 directed vectors, 1,792 identity vectors, 1,579,002 output comparisons, PASS |
| Short selected-signal `+WAVE_ONLY` | 14 hand vectors, 42 output comparisons, PASS; measured VCD/SVG published |

Reproduce from a clean checkout with a new output directory:

```powershell
$env:MODELSIM_BIN = 'C:\intelFPGA\20.1\modelsim_ase\win32aloem'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/run_regression.ps1 -OutputDir C:\short\alu-exhaustive-unique -CaptureWave
```

The [fault run](../reports/technical-completion-2026-11-07/carry-fault/)
used a disposable source that suppressed ADD carry when A=`81`. The prior
portable bench still passed, but the unchanged new oracle reported
`ALU_EXHAUSTIVE_MISMATCH`; wrapper exit was 1. The fault is retained only in
the report. This demonstrates sensitivity for that defect, not coverage of
all possible bugs.

The [measured wave](../reports/technical-completion-2026-11-07/passing/alu-directed.svg)
uses [raw VCD](../reports/technical-completion-2026-11-07/passing/alu-directed.vcd)
with a 1 ps timebase and selected `a`, `b`, `op`, `y`, `carry`, and `zero`
signals. The [renderer metadata](../reports/technical-completion-2026-11-07/passing/alu-directed.json)
contains the source hash; rendering does not independently verify arithmetic.
The advanced original suite remains licence-blocked and NOT RUN.
