import datetime
import subprocess
import os
import csv
from versuchung.experiment import Experiment
from versuchung.types import String
from versuchung.files import File

# current dir starts in Experiment subfolder inside test/xen-eval
parrot_dir = "/../../../../../"

class HyperSSE(Experiment):
    inputs = {
        "change_hash": String("0"),
        # "input_value": String("default value")
        }
    outputs = {
        "result-csv": File("res-ara.csv")
        }

    def run(self):

        cwd = os.getcwd()

        print("Running meson testsuite")
        meson_testuite_cmd = ["meson", "test", "--suite", "ara-xen-eval"]
        build_path = cwd + parrot_dir + "build/"
        subprocess.run(meson_testuite_cmd, cwd=build_path, stdout=None)

        print("Parsing meson testlog")
        parse_cmd = ["python3", "../ara_meson_parser.py", "../../../../../build/meson-logs/testlog.txt", "res-ara.csv"]
        subprocess.run(parse_cmd, stdout=None)

        print("Getting dot files")
        names = []
        with open('res-ara.csv', newline='') as csvfile:
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
                print(svg_cmd)
                subprocess.run(svg_cmd, shell=True)


               


if __name__ == "__main__":
    import sys
    experiment = HyperSSE()
    dirname = experiment(["--change_hash", str(datetime.datetime.now())])

    print(dirname)