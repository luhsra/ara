# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import csv
import argparse
import matplotlib.pyplot as plt
from collections import defaultdict
import random

def main():
    """Plot a csv. python3 pi_plot.py res-pi"""
    
    parser = argparse.ArgumentParser("MesonParser")
    parser.add_argument("InputFile", help="Path to .csv file.", type=str)
    parser.add_argument("--save", help="Path to save the plot.", type=str)
    args = parser.parse_args()
    
    input = args.InputFile
    data = defaultdict(list)
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

            if row[2] == "False":
                data[row[0]].append((int(row[1]),float(row[5]),float(row[6])))
                
    # Plot duration
    plt.style.use("bmh")
    plt.title("Automotive Benchmark - Load on Pi")
    plt.xlabel("Number of different activation periods")
    plt.ylabel("Measured Percentage not Idel [%]")
    plt.xticks(range(0,10))
    print(f"Found {len(data)} benchmarks:")
    for k,v in data.items():
        v.sort(key=lambda x: x[0])  # sort by first 
        print(f"\t{k} {v}")

        x, y, _ = zip(*v)
        plt.plot(x, [i + random.uniform(-0.1, 0.1) for i in y], label=k, marker="x", color=color_map[k])
    plt.legend()
    if args.save:
        path: str = args.save
        plt.savefig(path+"-load.png", dpi=300)
        print(f"Plot written to \"{path}-load.png\".")
        plt.close()
    else:
        plt.show()   

    # Plot offset
    plt.style.use("bmh")
    plt.title("Automotive Benchmark - Difference to theoretical task load")
    plt.xlabel("Number of different activation periods")
    plt.ylabel("Measured Percentage Increase [%]")
    plt.xticks(range(0,10))
    print(f"Found {len(data)} benchmarks:")
    for k,v in data.items():
        v.sort(key=lambda x: x[0])  # sort by first 
        print(f"\t{k} {v}")

        x, _, y = zip(*v)
        plt.plot(x, [i + random.uniform(-0.1, 0.1) for i in y], label=k, marker="x", color=color_map[k])
    plt.legend()
    if args.save:
        path: str = args.save
        plt.savefig(path+"-offset.png", dpi=300)
        print(f"Plot written to \"{path}-offset.png\".")
        plt.close()
    else:
        plt.show()

if __name__ == "__main__":
    main()
