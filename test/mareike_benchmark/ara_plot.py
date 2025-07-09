# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import csv
import argparse
import matplotlib.pyplot as plt
from collections import defaultdict
import random

def main():
    """Plot a csv. python3 ara_plot.py res-ara"""
    
    parser = argparse.ArgumentParser("MesonParser")
    parser.add_argument("InputFile", help="Path to .csv file.", type=str)
    parser.add_argument("--save", help="Path to save the plot.", type=str)
    args = parser.parse_args()
    
    input = args.InputFile
    data = defaultdict(list)
    stats = defaultdict(list)
    timeout = 1000
    color_map = {
        'tasks': '#00faff',
        'labels': '#0000ff',
        'angle': '#02ff00',
        'mixed': '#0a5b00',
        'angle-ideal': "#ff0100",
        'angle-worst': "#ff00c5",
        'angle-notimes': "#433474"
    }

    print(f"Parsing: \"{input}\".")

    with open(input, mode="r", newline="") as file:
        next(file)  # skip first line
        reader = csv.reader(file)
        for row in reader:
            print(row)

            if row[2] == "Timeout":
                timeout = int(float(row[3]))-1
            else:
                data[row[0]].append((int(row[1]),float(row[3])))
            if row[4] == "True":
                stats[row[0]].append((int(row[1]), int(row[7]), int(row[8])))

    # Plot duration
    plt.style.use("bmh")
    plt.title("Automotive Benchmark - ARA Processing Time")
    plt.xlabel("Number of different activation periods")
    plt.ylabel("Duration of analysis in [s]")
    # plt.ylim(0, timeout)
    print(f"Found {len(data)} benchmarks, timeout is {timeout}:")
    for k,v in data.items():
        v.sort(key=lambda x: x[0])  # sort by first 
        print(f"\t{k} {v}")

        x, y = zip(*v)
        plt.plot(x, [i + random.uniform(-0.1, 0.1) for i in y], label=k, marker="x", color=color_map[k])
    plt.legend()
    if args.save:
        path: str = args.save
        plt.savefig(path+"-dur.png", dpi=300)
        print(f"Plot written to \"{path}-dur.png\".")
        plt.close()
    else:
        plt.show()

    # Plot Sps
    plt.style.use("bmh")
    plt.title("Automotive Benchmark - ARA SynchronisationPoints")
    plt.xlabel("Number of different activation periods")
    plt.ylabel("Number of SPs in MSTG")
    plt.xticks(range(0,10))
    print(f"Found {len(stats)} benchmarks:")
    for k,v in stats.items():
        v.sort(key=lambda x: x[0])  # sort by first 
        print(f"\t{k} {v}")

        x, y, _ = zip(*v)
        plt.plot(x, [i + random.uniform(-0.1, 0.1) for i in y], label=k, marker="x", color=color_map[k])
    plt.legend()
    if args.save:
        path: str = args.save
        plt.savefig(path+"-sps.png", dpi=300)
        print(f"Plot written to \"{path}-sps.png\".")
        plt.close()
    else:
        plt.show()

    # Plot Sps
    plt.style.use("bmh")
    plt.title("Automotive Benchmark - ARA LocalCoreAbstractSystemStates")
    plt.xlabel("Number of different activation periods")
    plt.ylabel("Number of LAbSS in MSTG")
    plt.xticks(range(0,10))
    for k,v in stats.items():
        v.sort(key=lambda x: x[0])  # sort by first 

        x, _, y = zip(*v)
        plt.plot(x, [i + random.uniform(-0.1, 0.1) for i in y], label=k, marker="x", color=color_map[k])
    plt.legend()
    if args.save:
        path: str = args.save
        plt.savefig(path+"-labsss.png", dpi=300)
        print(f"Plot written to \"{path}-labsss.png\".")
        plt.close()
    else:
        plt.show()

if __name__ == "__main__":
    main()
