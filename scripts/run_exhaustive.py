#!/usr/bin/env python3
"""Bounded ALU smoke, exhaustive WIDTH=8 and optional measured wave run."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


def executable(name):
    prefix = os.environ.get("MODELSIM_BIN")
    candidates = ([str(Path(prefix) / (name + ".exe")), str(Path(prefix) / name)]
                  if prefix else []) + [name, name + ".exe"]
    for candidate in candidates:
        found = shutil.which(candidate)
        if found:
            return found
    raise RuntimeError("Missing required simulator: " + name)


def run(argv, cwd, logfile, timeout=120):
    try:
        proc = subprocess.run(argv, cwd=cwd, capture_output=True, timeout=timeout,
                              check=False)
    except subprocess.TimeoutExpired as exc:
        logfile.write_bytes((exc.stdout or b"") + (exc.stderr or b""))
        raise RuntimeError("Timed out after %d seconds: %s" % (timeout, argv[0])) from exc
    data = proc.stdout + proc.stderr
    logfile.write_bytes(data)
    return proc.returncode, data.decode("utf-8", errors="replace")


def clean(code, log):
    return code == 0 and not re.search(r"\*\*\s+(?:Fatal|Error):", log) \
        and "# Errors: 0, Warnings: 0" in log and "$finish" in log


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--rtl", type=Path, help="Disposable fault source override")
    parser.add_argument("--capture-wave", action="store_true")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    out = args.output_dir.resolve()
    if out.exists():
        raise RuntimeError("Output directory exists: " + str(out))
    out.mkdir(parents=True)
    rtl = (args.rtl or root / "rtl/design.sv").resolve()
    files = [rtl, root / "tb/tb_portable.sv", root / "tb/tb_exhaustive.sv"]
    report = {
        "repository": "ALU-RTL-Verification",
        "source_revision": subprocess.check_output(["git", "-C", str(root), "rev-parse", "HEAD"],
                                                    text=True).strip(),
        "source_dirty": bool(subprocess.check_output(["git", "-C", str(root),
                                                        "status", "--porcelain"])),
        "sources": [{"path": str(p), "sha256": hashlib.sha256(p.read_bytes()).hexdigest()}
                    for p in files],
        "seed": "none; deterministic two-state enumeration",
        "timeout_seconds_per_command": 120,
        "simulations": [], "overall": "FAIL"
    }
    started = time.monotonic()
    try:
        vlib, vlog, vsim = (executable(n) for n in ("vlib", "vlog", "vsim"))
        report["simulator_version"] = run([vsim, "-version"], out,
                                           out / "version.log")[1].strip()
        if run([vlib, "work"], out, out / "library.log")[0]:
            raise RuntimeError("vlib failed")
        compile_code, compile_log = run([vlog, "-sv"] + [str(p) for p in files],
                                        out, out / "compile.log")
        if compile_code or "Errors: 0, Warnings: 0" not in compile_log:
            raise RuntimeError("vlog failed or reported diagnostics")
        cases = [("portable", "tb_alu_portable", [], "PORTABLE_TEST_PASS ALU checks=1380"),
                 ("exhaustive", "tb_alu_exhaustive", [],
                  "ALU_EXHAUSTIVE_PASS tuples=524288 directed=254 identities=1792 comparisons=1579002")]
        if args.capture_wave:
            do = "vcd file alu-directed.vcd; " + "; ".join(
                "vcd add /tb_alu_exhaustive/" + s for s in
                "a b op y carry zero".split()) + "; run -all; quit -code 0"
            cases.append(("wave", "tb_alu_exhaustive", ["+WAVE_ONLY"],
                          "ALU_WAVE_PASS directed=14 comparisons=42"))
        for label, top, extra, marker in cases:
            command_do = do if label == "wave" else "run -all; quit -code 0"
            argv = [vsim, "-c", "-onfinish", "exit", top, *extra, "-do", command_do]
            code, log = run(argv, out, out / (label + ".log"))
            result = {"name": label, "top": top, "argv": argv,
                      "simulator_exit_code": code, "status": "FAIL"}
            report["simulations"].append(result)
            if not clean(code, log) or len(re.findall(re.escape(marker), log)) != 1:
                raise RuntimeError(label + " simulation failed or exact marker/count missing")
            result["status"] = "PASS"
            result["marker"] = marker
            print("PASS " + label + " " + marker)
        if args.capture_wave:
            vcd = out / "alu-directed.vcd"
            if not vcd.is_file() or not vcd.stat().st_size:
                raise RuntimeError("Requested VCD missing or empty")
            report["waveform"] = {"path": str(vcd),
                                  "sha256": hashlib.sha256(vcd.read_bytes()).hexdigest()}
            signals = ["tb_alu_exhaustive." + s for s in "a b op".split()]
            signals += ["tb_alu_exhaustive.y*", "tb_alu_exhaustive.carry",
                        "tb_alu_exhaustive.zero"]
            argv = [sys.executable, str(root / "tools/vcd_to_svg.py"), "--vcd", str(vcd),
                    "--signals", *signals, "--output", str(out / "alu-directed.svg"),
                    "--origin", "simulator", "--title", "Measured ALU directed vectors"]
            if run(argv, out, out / "render.log")[0]:
                raise RuntimeError("VCD render failed")
        report["overall"] = "PASS"
    except Exception as exc:
        report["error"] = str(exc)
        print("FAIL: " + str(exc), file=sys.stderr)
    finally:
        report["elapsed_seconds"] = round(time.monotonic() - started, 3)
        (out / "results.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    return 0 if report["overall"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
