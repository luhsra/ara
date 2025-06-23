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
    status: str
    duration: float

    # MSTGStats
    stats: bool = False
    sps: int        # Synchronisation Point
    labsss: int     # Local-Core Abstract System State
    vertices: int
    edges: int


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
                if "ara:automotive_benchmark_ara / ara_" not in t:
                    print(f"Wrong benchmark data: \"{t}\" does not contain \"ara:automotive_benchmark_ara / ara_\"")
                    print("Stopping!")
                    exit(1)
                t = t.removeprefix("ara:automotive_benchmark_ara / ara_")
                current.name = t.split("_")[0]
                current.variant = t.split("_")[1]
            elif line.startswith("duration:"):
                d = line.removeprefix("duration:").strip().removesuffix("s")
                current.duration = d
            elif line.startswith("result:"):
                r = line.removeprefix("result:").strip()
                if r == "exit status 0":
                    current.status = "Passed"
                elif r == "killed by signal 15 SIGTERM":
                    current.status = "Timeout"
                else:
                    current.status = "Unknown"
            elif "Number of vertices" in line:
                v = line.split(":")[3].strip()
                current.vertices = int(v)
                current.stats = True
            elif "Number of edges" in line:
                e = line.split(":")[3].strip()
                current.edges = int(e)
            elif "Number of SPs" in line:
                s = line.split(":")[3].strip()
                current.sps = int(s)
            elif "Number of LAbSSs" in line:
                l = line.split(":")[3].strip()
                current.labsss = int(l)
            elif line.startswith(seperator):
                cases.append(current)
                current = Testcase()
  
    with open(out, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([datetime.today().strftime('%Y-%m-%dT%H:%M:%S')+"-Testcase", "Variant", "AnalysisStatus", "AnalysisDuration[s]", 
                         "HasStats", "#Vertices", "#Edges", "#SynchronisationPoints", 
                         "#LocalCoreAbstractSystemState"])
        for i in cases:
            if i.stats:
                writer.writerow([i.name, i.variant, i.status, i.duration, i.stats, i.vertices, i.edges, i.sps, i.labsss])
            else:
                writer.writerow([i.name, i.variant, i.status, i.duration, i.stats])

    print(f"Done, wrote {len(cases)} lines.")

if __name__ == "__main__":
    main()
