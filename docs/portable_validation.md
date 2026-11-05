# Portable ALU regression — 5 November 2026

## Scope and provenance

The original RTL, constrained-random `tb/tb_top.sv`, scripts and historical logs remain byte-for-byte unchanged from `hdl-labs` commit `df8d6f66898a08df75cd2071ddac7bbba9ba9b16`. This run used the published extraction base commit `2ad155dc81e91245cdb83e39d044fbc64f8084e1` plus the new portable testbench and wrapper on this PR branch. The DUT has **no reset input**, so a reset test is not applicable.

The original environment failed at `randomize()` with `vsim-7099` in ModelSim 2020.1 and again with an `svverification` licence checkout failure in Questa Altera Starter FPGA Edition 2025.2. The portable bench does not replace or alter that environment.

## Command and actual outcome

Simulator: ModelSim Intel FPGA Starter Edition `vsim 2020.1 Simulator 2020.02 Feb 28 2020`; compiler: `vlog 2020.1 Compiler 2020.02 Feb 28 2020`.

From the repository root in PowerShell, with `C:\intelFPGA\20.1\modelsim_ase\win32aloem` prepended to PATH:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/run_portable.ps1
```

The recorded invocation supplied `-OutputDir C:\R_MIGRATION_BACKUP\Roohan_GitHub_Launch_Kit\Roohan_GitHub_Launch_Kit\build\test-runs\2026-11-05\portable-alu-verification-modelsim2020` so the original repository logs stayed untouched. The wrapper's exit code was **0**. Its raw [compile log](../reports/portable-2026-11-05/compile.log) and [simulation log](../reports/portable-2026-11-05/simulation.log) show zero errors, `$finish`, and `PORTABLE_TEST_PASS ALU checks=1380`.

The bench uses hand-calculated examples for all eight opcodes, then an independent integer-based expected-result model over 13 deterministic operand values for each opcode. Directed checks include addition carry and wrap, subtraction underflow and zero, and shift amounts 0–7. Every check compares `y`, `carry`, and `zero` with four-state mismatch detection. A time limit and `$fatal(1)` stop on failure; the wrapper also rejects error/fatal log lines or a missing completion marker. A temporary, **uncommitted** carry-output mutation produced an ALU mismatch and wrapper exit code **1**, confirming failure propagation.

These checks are not exhaustive over all 8-bit operand pairs, do not measure code or functional coverage, and do not establish that the original constrained-random checks pass. No synthesis, timing or hardware result is claimed.
