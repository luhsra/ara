import datetime
import subprocess
import os
import csv
import filecmp
from versuchung.experiment import Experiment
from versuchung.types import String
from versuchung.files import File

# current dir starts in newly created experiment subfolder inside ara/test/xen-eval
parrot_dir = "/../../../../../"
res_file = 'res-ara.csv'

class HyperSSE(Experiment):
    inputs = {
        "change_hash": String("0"),
        }
    outputs = {
        "result-csv": File("res-ara.csv")
        }

    def run(self):

        cwd = os.getcwd()

        # TODO: Automato build zephyr 

        # Force Rebuild by deleting build folder, VERY SLOW!!!
        # meson_testuite_cmd = ["rm", "-dr", "appl"]
        # build_path = cwd + parrot_dir + "build/subprojects/ara-zephyr-apps/"
        # subprocess.run(meson_testuite_cmd, cwd=build_path, stdout=None)

        # THIS IS VERY VERY SLOW:
        # print("(Re)build Zephyr apps")
        # meson_testuite_cmd = ["ninja", "ara-zephyr-apps@@build-zephyr-apps"]
        # build_path = cwd + parrot_dir + "build/"
        # subprocess.run(meson_testuite_cmd, cwd=build_path, stdout=None)

        # THIS IS SLOW:
        # meson_testuite_cmd = ["ninja", "sse-native_sim-zephyr-min-1", "sse-native_sim-zephyr-min-2", 
        #                     "sse-native_sim-zephyr-min-3", "sse-native_sim-zephyr-min-4",
        #                     "sse-native_sim-zephyr-hc-1", "sse-native_sim-zephyr-hc-2", 
        #                     "sse-native_sim-zephyr-hc-3", "sse-native_sim-zephyr-hc-4",
        #                     "sse-native_sim-zephyr-hc-5", "sse-native_sim-zephyr-hc-6",
        #                     "sse-native_sim-zephyr-sleep"]
        # build_path = cwd + parrot_dir + "build/"
        # subprocess.run(meson_testuite_cmd, cwd=build_path, stdout=None)


        # print("Running meson testsuite")
        meson_testuite_cmd = ["meson", "test", "--suite", "ara-xen-eval"]
        build_path = cwd + parrot_dir + "build/"
        subprocess.run(meson_testuite_cmd, cwd=build_path, stdout=None)

        print("Parsing meson testlog")
        parse_cmd = ["python3", "../ara_meson_parser.py", "../../../../../build/meson-logs/testlog.txt", "res-ara.csv"]
        subprocess.run(parse_cmd, stdout=None)

        print("Getting dot files")
        names = []
        with open(res_file, newline='') as csvfile:
            csvreader = csv.reader(csvfile, delimiter=',')
            next(csvreader)
            for row in csvreader:
                names.append(row[0])

        dumps = cwd + parrot_dir + "build/dumps"
        files = os.listdir(dumps)
        hstgs = [hstg for hstg in files if hstg.startswith('HyperSSE')]

        for hstg in hstgs:
            name = hstg.split(".")[1]
            if name in names:
                os.rename(dumps + "/" + hstg, cwd + "/" + hstg)
                svg_cmd = f"dot -Tsvg HyperSSE.{name}.hstg.dot > {name}.svg"
                subprocess.run(svg_cmd, shell=True)

        print("------------ Compare to Sample ------------")
        compare = []
        for name in names:
            file_path = cwd + "/../../../appl/Xen/" + name + "/" + "HyperSSE." + name + ".hstg.dot"
            if os.path.exists(file_path) and os.path.exists(f"HyperSSE.{name}.hstg.dot"):
                
                if filecmp.cmp(file_path, f"HyperSSE.{name}.hstg.dot"):
                    print(f"{name:<20} Matched \U0001F44D")
                    compare.append("correct")
                else:
                    print(f"{name:<20} Differs \u274c")
                    compare.append("differs")
            else:
                print(f"{name:<20} has no verified solution")
                compare.append("no-target")
                
        print("------------------------------------------")

        # Read csv, insert verification, write
        with open(res_file, 'r') as file:
            reader = csv.reader(file)
            data = list(reader)

        data[0].insert(2, "Compared")
        for i in range(1, len(data)):
            data[i].insert(2, compare[i-1])

        with open(res_file, 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerows(data)

        
if __name__ == "__main__":
    import sys
    experiment = HyperSSE()
    dirname = experiment()
    # dirname = experiment(["--change_hash", str(datetime.datetime.now())])

    print(dirname)