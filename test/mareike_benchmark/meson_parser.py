# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import csv
import argparse

def main():
    """Parses the output of meson into a csv. python3 meson_parser.py testlog.txt res.csv"""
    
    parser = argparse.ArgumentParser("MesonParser")
    parser.add_argument("InputFile", help="Path to meson testlog.txt.", type=str)
    parser.add_argument("OutputFile", help="Path to resulting .csv file.", type=str)
    args = parser.parse_args()
    
    logs = args.InputFile
    out = args.OutputFile
    case, variant, duration, result = [], [], [], []

    print(f"Parsing: \"{logs}\" to \"{out}\".")

    with open(logs, "r") as file:
        for line in file:
            
            if line.startswith("test:"):
                t = line.removeprefix("test:").strip().removeprefix("ara:automotive_benchmark / ara_")
                case.append(t.split("_")[0])
                variant.append(t.split("_")[1])
            elif line.startswith("duration:"):
                d = line.removeprefix("duration:").strip().removesuffix("s")
                duration.append(d)
            elif line.startswith("result:"):
                r = line.removeprefix("result:").strip()
                if r == "exit status 0":
                    result.append("Passed")
                elif r == "killed by signal 15 SIGTERM":
                    result.append("Timeout")
                else:
                    result.append("Unknown")
  
    assert len(case) == len(duration) == len(result), "Invalid logs!"     

    with open(out, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Testcase", "Variant", "AnalysisStatus", "AnalysisDuration[s]"])
        for i in range(len(case)):
            writer.writerow([case[i], variant[i], result[i], duration[i]])


    print(f"Done, wrote {len(case)} lines.")


if __name__ == "__main__":
    main()
