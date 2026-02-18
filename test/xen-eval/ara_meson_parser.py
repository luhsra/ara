# SPDX-FileCopyrightText: 2026 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import csv
import argparse
from datetime import datetime
from typing import List

class Testcase:

    def __init__(self):
        self.sps = []
        self.labsss = []
        self.vertices = []
        self.edges = []

    name: str
    status: str
    duration: float
    
    # MSTGStats, last entry is HyperSSE
    sps: List[int]       # Synchronisation Point
    labsss: List[int]    # Local-Core Abstract System State
    vertices: List[int]
    edges: List[int]

    def __str__(self):
        attributes = ', '.join(f'{key}={value}' for key, value in vars(self).items())
        return f'{self.__class__.__name__}({attributes})'


def parse():
    """Parses the output of meson into a csv.
    python3 ara_meson_parser.py ../../../../build/meson-logs/testlog.txt res-ara.csv
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
                if "ara-xen-eval - ara:ara-xen-eval-" not in t:
                    print(f"Wrong benchmark data: \"{t}\" does not contain \"ara:ara-xen-eval / ara-xen-eval-\"")
                    print("Stopping!")
                    exit(1)
                t = t.removeprefix("ara-xen-eval - ara:ara-xen-eval-")
                current.name = t
            elif line.startswith("duration:"):
                d = line.removeprefix("duration:").strip().removesuffix("s")
                current.duration = d
            elif line.startswith("result:"):
                r = line.removeprefix("result:").strip()
                if r == "exit status 0":
                    current.status = "True"
                elif r == "exit status 1":
                    current.status = "ERROR"
                elif r == "killed by signal 15 SIGTERM":
                    current.status = "Timeout"
                else:
                    current.status = "Unknown"
            elif "Number of vertices" in line:
                v = line.split(":")[1].strip()
                current.vertices.append(v)
            elif "Number of edges" in line:
                e = line.split(":")[1].strip()
                current.edges.append(e)
            elif "Number of SPs" in line:
                s = line.split(":")[1].strip()
                current.sps.append(s)
            elif "Number of LAbSSs" in line:
                l = line.split(":")[1].strip()
                current.labsss.append(l)
            elif line.startswith(seperator):
                cases.append(current)
                current = Testcase()
  
    with open(out, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([datetime.today().strftime('%Y-%m-%dT%H:%M:%S')+"-Testcase", "Finished", 
                         "AnalysisDuration[s]", 
                         "#LocalAbSS-XEN", "#SP-XEN", "#Edges-XEN", "#Vertices-XEN",
                         "#LocalAbSS-dom1", "#SP-dom1", "#Edges-dom1", "#Vertices-dom1",
                         "#LocalAbSS-dom2", "#SP-dom2", "#Edges-dom2", "#Vertices-dom2",
                         "#LocalAbSS-domX", "#SP-domX", "#Edges-domX", "#Vertices-domX"])
        rows = []
        for i in cases:
            # print(f"{i}")
            if i.status == "True" and i.labsss and i.sps and i.edges and i.vertices:
                row = [i.name, i.status, i.duration, i.labsss[-1], i.sps[-1], i.edges[-1], i.vertices[-1]]

                # iterate over all except the last entry
                for j in range(0, len(i.labsss) - 1):
                    row += [i.labsss[j], i.sps[j], i.edges[j], i.vertices[j]]
            else:
                row = [i.name, i.status, i.duration, "-", "-", "-", "-"]
            
            rows.append(row)
        for row in sorted(rows, key=lambda row: row[0]):
            writer.writerow(row)


    print(f"Done, wrote {len(cases)} lines.")

if __name__ == "__main__":
    parse()
