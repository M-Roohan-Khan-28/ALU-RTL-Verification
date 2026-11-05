# Eight-operation ALU & verification

**Verilog / SystemVerilog · RTL and verification exercise**

This standalone repository preserves the original `alu` exercise from my `hdl-labs` collection. Original RTL, testbench, simulator scripts and existing evidence are preserved byte-for-byte. This packaging step is not a new simulation or a claim of full protocol compliance.

## Overview and original documentation

Extract original RTL and testbench. Re-run arithmetic, logic, and boundary tests; record any randomization licence requirement.

See [the original exercise README](SOURCE_README.md) for its existing specification, source layout and tool instructions. The text above identifies review goals; it does not claim that new enhancements have already been implemented.

## Run

From the repository root, with the required ModelSim/Questa executables and appropriate licence available:

```bash
bash sim/run.sh
```

Existing Windows instructions, where supplied, are retained in `scripts/`. Do not assume the testbench will run in every edition of a simulator. Check [the retained validation report](source-docs/VALIDATION.md) and the original README.

### Portable deterministic regression

With `vlib`, `vlog`, and `vsim` on PATH, run from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/run_portable.ps1
```

This compiles only the unchanged RTL and [plain testbench](tb/tb_portable.sv), writing fresh output to the ignored `portable-results/` directory. It checks all eight implemented 8-bit operations using fixed examples, boundary vectors and an independent integer-based expected-result model. The ALU has no reset port, so reset behavior is not applicable. See [portable validation](docs/portable_validation.md) and its [fresh logs](reports/portable-2026-11-05/). The original constrained-random testbench and its licence limitation remain as they were; the portable checks are not equivalent coverage.

## Verification status

The original `reports/compile.log` and `reports/simulation.log` are historical evidence copied from the source repository. The extraction script performed no simulation. The separately recorded portable run passed its stated deterministic checks; the original constrained-random environment remains blocked by a verification-feature licence in the tested Starter editions. No functional coverage is claimed.

## Provenance and changes

Source commit: `df8d6f66898a08df75cd2071ddac7bbba9ba9b16`. Source path: `projects/alu`.

[SOURCE_PROVENANCE.json](SOURCE_PROVENANCE.json) records checksums of every original file. `SOURCE_README.md` is the unchanged original README. No RTL or testbench functionality was changed during extraction. Source history remains available in the original repository; this is a snapshot, not a rewrite of its authorship.

## Next engineering work

Review the specification and implementation, run the supplied tests, add independently justified checks, and record actual results and known limitations. Waveform screenshots can be added later; no fabricated screenshots or coverage figures are needed.
