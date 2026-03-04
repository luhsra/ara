# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import csv
import argparse
from dataclasses import dataclass
from datetime import datetime

class Testcase:
    name: str
    variant: str
    duration: float             # runtime of testcase

    skipped: bool = False

    passed: bool
    expected_load: float        # in %
    angle_expected_load: float  # in %
    load: float                 # in %
    diff: float                 # in %


def main():
    """Parses the output of meson into a csv.
    python3 pi_meson_parser.py ../../../../build/meson-logs/testlog.txt res-pi.csv
    """
    
    parser = argparse.ArgumentParser("MesonParser")
    parser.add_argument("InputFile", help="Path to meson testlog.txt.", type=str)
    parser.add_argument("OutputFile", help="Path to resulting .csv file.", type=str)
    args = parser.parse_args()
    
    logs = args.InputFile
    out = args.OutputFile
    seperator = "=============================================================================="
    cases: list[Testcase] = []
    current = Testcase()

    print(f"Parsing: \"{logs}\" to \"{out}\".")

    with open(logs, "r") as file:
        for line in file:
            
            if line.startswith("test:"):
                t = line.removeprefix("test:").strip()
                name_prefix = "automotive_benchmark_pi - ara:"
                if name_prefix not in t:
                    print(f"Wrong benchmark data: \"{t}\" does not contain \"{name_prefix}\"")
                    print("Stopping!")
                    exit(1)
                t = t.removeprefix("ara:automotive_benchmark_pi / pi_")
                current.name = t.split(":")[1].split("_")[1]
                current.variant = t.split(":")[1].split("_")[2]
            elif line.startswith("duration:"):
                d = line.removeprefix("duration:").strip().removesuffix("s")
                current.duration = d
            
            elif line.startswith("SKIPPED!"):
                current.skipped = True

            elif line.startswith("- All task finished, passed!"):
                current.passed = True
            elif line.startswith("- Task(s) got blocked, failed!"):
                current.passed = False

            elif line.startswith("- Expected load was:"):
                d = line.removeprefix("- Expected load was:").strip()
                current.expected_load = d.split("%")[0]
                # Check estimation with angle sync
                # if d.split("%")[1].startswith("	(w-Angle: "):
                #     e = d.split("%")[1].removeprefix("	(w-Angle: ").removesuffix("%")
                #     current.angle_expected_load = e
            elif line.startswith("- Actual load was:"):
                current.load = line.removeprefix("- Actual load was:").strip().removesuffix("%")
            elif line.startswith("- Difference is:"):
                d = line.removeprefix("- Difference is:").strip()
                current.diff = d.split("%")[0]

            elif line.startswith(seperator):
                cases.append(current)
                current = Testcase()
  
    with open(out, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([datetime.today().strftime('%Y-%m-%dT%H:%M:%S')+"-Testcase", "Variant", "Skipped", "Passed", 
                         "Expected-Load [%]", "Load[%]", "Diff[%]"])
        for i in cases:
            if not i.skipped:
                writer.writerow([i.name, i.variant, i.skipped, i.passed, i.expected_load, i.load, i.diff])
            else:
                writer.writerow([i.name, i.variant, i.skipped])

    print(f"Done, wrote {len(cases)} lines.")

if __name__ == "__main__":
    main()
