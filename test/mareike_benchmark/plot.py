# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import csv
import argparse
import matplotlib.pyplot as plt
from collections import defaultdict

def main():
    """Plot a csv. python3 pllot.py res.csv"""
    
    parser = argparse.ArgumentParser("MesonParser")
    parser.add_argument("InputFile", help="Path to .csv file.", type=str)
    parser.add_argument("--save", help="Path to save the plot.", type=str)
    args = parser.parse_args()
    
    input = args.InputFile
    data = defaultdict(list)
    timeout = 60
    color_map = {
        'tasks': '#348ABD',
        'labels': '#467821',
        'angle': '#7A68A6',
        'mixed': '#A60628'
    }

    print(f"Parsing: \"{input}\".")

    with open(input, mode="r", newline="") as file:
        next(file)  # skip first line
        reader = csv.reader(file)
        for row in reader:
            print(row)
            data[row[0]].append((int(row[1]),float(row[3])))

            if row[3] == 'Timeout':
                timeout = int(row[3])-1

    plt.style.use("bmh")
    plt.title("Automotive Benchmark")
    print(f"Found variants, timeout is {timeout}:")
    for k,v in data.items():
        v.sort(key=lambda x: x[0])  # sort by first 
        print(f"\t{k} {v}")

        x, y = zip(*v)
        plt.plot(x, y, label=k, marker="x", color=color_map[k])
        plt.xlabel("Number of Tasks")
        plt.ylabel("Duration of analysis in [s]")

    plt.ylim(0, timeout)
    plt.legend()

    if args.save:
        path: str = args.save
        plt.savefig(path, dpi=300)
        print(f"Plot written to {path}.")
    else:
        plt.show()


if __name__ == "__main__":
    main()
