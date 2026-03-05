# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import datetime
import subprocess
import os
import csv
import filecmp
import multiprocessing
import logging
import shutil
from versuchung.experiment import Experiment
from versuchung.types import String, Integer, Bool
from versuchung.files import File

# logger config similar to ara
logger = logging.getLogger(__name__)

# current dir starts in newly created experiment subfolder inside ara/test/xen-eval
parrot_dir = "/../../../../../"
res_file = 'res-ara.csv'

# parrot contains multiple git-repos, each one can influence the test result
repo_list = [
    "parrot",
    "parrot/subprojects/ara",
    "parrot/subprojects/ara-zephyr-apps"
]

# relative to parrots location, e.g. the two folders should be in the same folder
# parent-dir
# ├── parrot
#       ├── build
#       ├── ...
#       └── subprojects
# └── ecrts-hypersse
#       ├── fig
#       └── ...
# paper_repo = "../ecrts-hypersse/fig"
paper_repo = "NONE"

class HyperSSE(Experiment):
# class MCAnalyzer(Experiment):

    inputs = {"log": String("INFO"),
              "cpus": Integer(multiprocessing.cpu_count() - 4),
              "rebuild": Bool(False),
              "git_hash": String("0"),
              "cleangit": Bool(False),
              "timeout": Integer(3),
        }
    outputs = {"result-csv": File("res-ara.csv")}

    def run(self):

        thing = self.title

        cpus = self.inputs.cpus.value
        rebuild = self.inputs.rebuild.value
        # limit for how long ara should try to analyse 1 application. Currently all finish in ~50s, 95% in ~5s.
        # it sets the meson option of ara: "test_timeout", which is used in "ara/test/xen-eval/meson.build"
        timeout = self.inputs.timeout
        cleangit = self.inputs.cleangit.value
        logger.setLevel(getattr(logging, self.inputs.log.value.upper(), logging.INFO))
        logger.warning(f"Starting thesis.py for \"{thing}\" with log: {logging.getLevelName(logger.level)}, "
                       f"cpus: {cpus}, rebuild: {rebuild}, git_hash: {{ {self.inputs.git_hash} }}, test-timeout: {timeout}, clean_git: {cleangit}")

        cwd = os.getcwd()

        if cleangit:
            git_cmd = ["git", "status", "--porcelain"]
            for repo in repo_list:
                path = cwd + parrot_dir + "../" + repo
                res = subprocess.run(git_cmd, cwd=path, check=True, capture_output=True, encoding="UTF-8")
                if res.stdout.rstrip():
                    logger.warning(f"Repo: {repo} is dirty, aborting:")
                    logger.info(res.stdout.rstrip())
                    exit(1)
            logger.info(f"All {len(repo_list)} repos have a clean working tree.")


        if rebuild:
            # could also delete ara/appl here, but would need to keep generated json files
            folder = cwd + parrot_dir + "build/subprojects/ara-zephyr-apps/appl"
            if os.path.isdir(folder):
                logger.warning("Cleaning build dir")
                cmd = ["rm", "-dr", folder]
                build_path = cwd + parrot_dir
                subprocess.run(cmd, cwd=build_path, check=True)

        
        logger.info(f"Setup test timeout to: \"{timeout}\", might need to wait for meson to reconfigure.")
        cmd = ["meson", "configure", f"-Dara:test_timeout={timeout}"]
        build_path = cwd + parrot_dir + "build/"
        subprocess.run(cmd, cwd=build_path, check=True)
        # this is needed for meson configure to take effect. And it moves the (long) ouput from meson to debug.
        ninja_out = subprocess.run("ninja", cwd=build_path, check=True, capture_output=True, encoding="UTF-8")
        logger.debug(ninja_out.stdout.rstrip())

        logger.info(f"Building ll-files for Autosar, Zephyr, BareMetal. This might take a moment.")
        ninja_cmd = ["ninja", "subprojects/ara/appl/Xen/xen-ara-autosar", "-j" , f"{cpus}"]
        subprocess.run(ninja_cmd, cwd=build_path, check=True)

        logger.info("Running meson testsuite.")
        meson_testuite_cmd = ["meson", "test", "--suite", "ara-xen-eval", "-j" , f"{cpus}"]
        subprocess.run(meson_testuite_cmd, cwd=build_path)

        logger.info("Parsing meson testlog into csv.")
        parse_cmd = ["python3", "../ara_meson_parser.py", "../../../../../build/meson-logs/testlog.txt", "res-ara.csv"]
        subprocess.run(parse_cmd, cwd=cwd, check=True)


        logger.info("Importing dot files from dump. Creating svgs.")
        names = []
        with open(res_file, newline='') as csvfile:
            csvreader = csv.reader(csvfile, delimiter=',')
            next(csvreader)
            for row in csvreader:
                names.append(row[0])

        logger.debug(f"Found {len(names)} testcases: {names}")
        dumps = cwd + parrot_dir + "build/dumps"
        files = os.listdir(dumps)
        logger.debug(f"Found files: {files}")
        hstgs = [hstg for hstg in files if (hstg.startswith(f"{thing}.") and hstg.endswith(".hstg.dot"))]

        logger.debug(f"Found Hstgs: {hstgs}.")
        for hstg in hstgs:
            name = hstg.split(".")[1]
            if name in names:
                logger.debug(f"Creating svg: {thing}.{name}.hstg.dot > {thing}.{name}.hstg.svg")
                shutil.copy(dumps + "/" + hstg, cwd + "/" + hstg)
                svg_cmd = f"dot -Gfontname=sans -Efontname=sans -Nfontname=sans -Tsvg {thing}.{name}.hstg.dot > {thing}.{name}.hstg.svg"
                subprocess.run(svg_cmd, shell=True, cwd=cwd)

                # option to also create pngs
                # png_cmd = f"dot -Tpng {thing}.{name}.hstg.dot > {thing}.{name}.hstg.png"
                # subprocess.run(png_cmd, shell=True, cwd=cwd, check=True)


        logger.info(f"------------ Comparing {len(names)} graphs to last graph in repo ------------")
        compare = []
        for name in names:
            if "braking" in name:
                file_path = cwd + "/../../../appl/Xen/" + "braking" + "/" + f"HyperSSE." + name + ".hstg.dot"
            else:
                file_path = cwd + "/../../../appl/Xen/" + name + "/" + f"HyperSSE." + name + ".hstg.dot"
            hstg_name = f"{thing}.{name}.hstg.dot"
            if os.path.exists(file_path) and os.path.exists(hstg_name):
                
                if filecmp.cmp(file_path, hstg_name):
                    print(f"\t{name:<22} Same \U0001F44D")
                    compare.append("correct")
                else:
                    print(f"\t{name:<22} Differs \u274c")
                    compare.append("differs")

                    diff_cmd = ["diff", file_path, hstg_name]
                    diff = subprocess.run(diff_cmd, cwd=cwd, capture_output=True, encoding="UTF-8")
                    if len(diff.stdout.rstrip().splitlines()) < 5:
                        for l in diff.stdout.rstrip().splitlines():
                            print(f"\t\t\t\t:{l}")
                    else:
                        print(f"\t\t\t\tVery different")

            else:
                print(f"\t{name:<22} has no verified solution")
                compare.append("no-target")
                
        logger.info("---------------------------------------------------------")


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


        path = cwd + parrot_dir + paper_repo
        if os.path.isdir(path):
            logger.info(f"Copy svgs to paper-repo: \"{paper_repo}\"")
            versions = os.listdir(path)
            logger.debug(f"Folder contains: {versions}")
            num = 0
            for v in versions:
                if v.startswith(thing) and "-" in v:
                    num = max(num, int(v.split("-")[1]) + 1)
            logger.debug(f"Next version is: {num}")
            target = path + "/" + thing + "-" + str(num)
            logger.debug(f"Copying: {cwd} -> {target}")
            shutil.copytree(cwd, target)
            logger.info(f"Creating folder: {thing + "-" + str(num)}")
        else:
            logger.info("No paper-repo, data not copied.")

        return
        
if __name__ == "__main__":
    import sys

    # setup logger, disable root logger from versuchung
    logging.basicConfig(format="%(levelname)s\t: %(message)s", level=logging.WARNING)
    logging.addLevelName(logging.WARNING, "\033[1;33m%s\033[1;0m" % logging.getLevelName(logging.WARNING))
    logging.addLevelName(logging.ERROR, "\033[1;41m%s\033[1;0m" % logging.getLevelName(logging.ERROR))
    logging.addLevelName(logging.DEBUG, "\033[1;32m%s\033[1;0m" % logging.getLevelName(logging.DEBUG))
    logging.addLevelName(logging.INFO, "\033[1;34m%s\033[1;0m" % logging.getLevelName(logging.INFO))

    # check state of all relevant ara repos 
    git_cmd = ["git", "rev-parse", "--short", "HEAD"]
    git_hash = ""
    for repo in repo_list:
        res = subprocess.run(git_cmd, cwd=os.getcwd() + parrot_dir + repo, check=True, capture_output=True, encoding="UTF-8")
        git_hash += repo.split('/')[-1] + ":" + res.stdout.rstrip() + " "

    experiment = HyperSSE()
    # experiment = MCAnalyzer()

    dirname = experiment(["--git_hash", git_hash] + sys.argv[1:])
    # dirname = experiment(["--change_hash", str(datetime.datetime.now())])

    print(f"Wrote to: {dirname}")