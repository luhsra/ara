# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import datetime
import time
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
build_folder = "build"
res_file = 'res-ara.csv'

# parrot contains multiple git-repos, each one can influence the test result
repo_list = [
    "parrot",
    "parrot/subprojects/ara",
    "parrot/subprojects/ara-zephyr-apps"
]

# [Automatic copy to paper repository]
# relative to parrots location, e.g. the two folders should be in the same folder
# parent-dir
# ├── parrot
#       ├── build
#       ├── ...
#       └── subprojects
# └── ecrts-hypersse
#       ├── fig
#       └── ...

paper_repo = "../ecrts-hypersse/fig"
# paper_repo = "NONE"

class HyperSSE(Experiment):
# class MCAnalyzer(Experiment):

    inputs = {"log": String("INFO"),
              "cpus": Integer(multiprocessing.cpu_count() - 4),
              "rebuild": Bool(False),
              "git_hash": String("0"),
              "cleangit": Bool(False),
              "ecrts26": Bool(False)            # flag to create graphs for ecrts26 paper
        }
    outputs = {"result-csv": File("res-ara.csv")}

    def run(self):

        thing = self.title

        cpus = self.inputs.cpus.value
        rebuild = self.inputs.rebuild.value
        cleangit = self.inputs.cleangit.value
        logger.setLevel(getattr(logging, self.inputs.log.value.upper(), logging.INFO))
        logger.warning(f"Starting thesis.py for \"{thing}\" with log: {logging.getLevelName(logger.level)}, "
                       f"cpus: {cpus}, rebuild: {rebuild}, git_hash: {{ {self.inputs.git_hash} }}, clean_git: {cleangit}")

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
            folder = cwd + parrot_dir + build_folder + "/subprojects/ara-zephyr-apps/appl"
            if os.path.isdir(folder):
                logger.warning("Cleaning build dir")
                cmd = ["rm", "-dr", folder]
                build_path = cwd + parrot_dir
                subprocess.run(cmd, cwd=build_path, check=True)

        
        logger.info(f"Setup meson options, might need to wait for meson to reconfigure.")
        cmd = ["meson", "configure", f"-Denable_posix=true", f"-Denable_arm=true", f"-Dbuild_hypersse_xen=true"]
        build_path = cwd + parrot_dir + build_folder + "/"
        subprocess.run(cmd, cwd=build_path, check=True)
        # this is needed for meson configure to take effect. And it moves the (long) ouput from meson to debug.
        ninja_out = subprocess.run("ninja", cwd=build_path, check=True, capture_output=True, encoding="UTF-8")
        logger.debug(ninja_out.stdout.rstrip())

        logger.info(f"Building ll-files for Autosar, Zephyr, BareMetal. This might take a moment.")
        ninja_cmd = ["ninja", "subprojects/ara/appl/Xen/xen-ara-autosar", "-j" , f"{cpus}"]
        subprocess.run(ninja_cmd, cwd=build_path, check=True)

        start_time = time.time()

        if self.inputs.ecrts26.value:
            meson_testuite_cmd = ["meson", "test", "--suite", "hypersse_xen_full", "-j" , f"{cpus}"]
            logger.info("Running complete meson testsuite.")
        else:
            meson_testuite_cmd = ["meson", "test", "--suite", "hypersse_xen", "-j" , f"{cpus}"]
            logger.info("Running 99% meson testsuite.")
        subprocess.run(meson_testuite_cmd, cwd=build_path, check=True)

        # Check that a new log was created and its not parsing old data
        log_time = os.path.getctime("../../../../../" + build_folder + "/meson-logs/testlog.txt")
        if log_time <= start_time:
            logger.error("Meson testlog.txt was not written to, was there an error with meson?")
            exit(1)

        logger.info("Parsing meson testlog into csv.")
        parse_cmd = ["python3", "../ara_meson_parser.py", "../../../../../" + build_folder + "/meson-logs/testlog.txt", "res-ara.csv"]
        subprocess.run(parse_cmd, cwd=cwd, check=True)


        logger.info("Importing dot files from dump. Creating svgs.")
        names = []
        with open(res_file, newline='') as csvfile:
            csvreader = csv.reader(csvfile, delimiter=',')
            next(csvreader)
            for row in csvreader:
                names.append(row[0])

        logger.debug(f"Found {len(names)} testcases: {names}")
        dumps = cwd + parrot_dir + build_folder + "/dumps"
        files = os.listdir(dumps)
        # Filter files from previouse benchmark runs (in case there is some error and no new file is created)
        new_files = [f for f in files if (start_time <= os.path.getctime(cwd + parrot_dir + build_folder + "/dumps/" + f))]
        logger.debug(f"Found files: {files}\nNew files: {new_files}")
        logger.info(f"Found {len(files)} files, of which {len(new_files)} were created since start of test.")
        hstgs = [hstg for hstg in new_files if (hstg.startswith(f"{thing}.") and hstg.endswith(".hstg.dot"))]

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
                    if len(diff.stdout.rstrip().splitlines()) < 50:
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


        # Use typst to create overview-pdf
        experiment_folder = cwd.split('/')[-1]
        output_name =  "eval-grid.pdf"
        typst_cmd = ["typst", "compile", "../eval-grid.typ", "--input", f"path={experiment_folder}", output_name]
        try:
            res = subprocess.run(typst_cmd, cwd=cwd, capture_output=True, encoding="UTF-8")
            if res.stderr.rstrip():
                logger.warning(res.stderr.rstrip())
            else:
                logger.info(f"Created overview, click to open: \"{cwd}/{output_name}.")
        except Exception as e:
            logger.warning("Overview failed, maybe typst is not available:")
            logger.warning(e)
            
        # Create ecrts26 pdfs/results
        if self.inputs.ecrts26.value:
            results = []
            output_name =  "ecrts26-eval-grid.pdf"
            typst_cmd = ["typst", "compile", "../ecrts26-eval-grid.typ", "--input", f"path={experiment_folder}", output_name]
            try:
                res = subprocess.run(typst_cmd, cwd=cwd, capture_output=True, encoding="UTF-8")
                if res.stderr.rstrip():
                    logger.warning(res.stderr.rstrip())
                else:
                    logger.info(f"Ecrts26: created eval-grid, click to open: \"{cwd}/{output_name}.")
                    results.append(output_name)
            except Exception as e:
                logger.warning(f"{output_name} failed, maybe typst is not available:")
                logger.warning(e)

            output_name =  "ecrts26-hstg.pdf"
            typst_cmd = ["typst", "compile", "../ecrts26-hstg.typ", "--input", f"path={experiment_folder}", output_name]
            try:
                res = subprocess.run(typst_cmd, cwd=cwd, capture_output=True, encoding="UTF-8")
                if res.stderr.rstrip():
                    logger.warning(res.stderr.rstrip())
                else:
                    logger.info(f"Ecrts26: Created large hstg, click to open: \"{cwd}/{output_name}.")
                    results.append(output_name)
            except Exception as e:
                logger.warning(f"{output_name} failed, maybe typst is not available:")
                logger.warning(e)

            # output_name =  "HyperSSE.brakingCheck.pdf"
            # cmd = ["dot", "-Tpdf", "HyperSSE.brakingCheck.hstg.dot", ">", output_name]
            # logger.error(cmd)
            # logger.error(cwd)
            # try:
            #     res = subprocess.run(cmd, cwd=cwd, shell=True)
            #     pass
            # except Exception as e:
            #     logger.warning(f"{output_name} failed, maybe dot is not available:")
            #     logger.warning(e)
            
            results.append("res-ara.csv")

            # Copy ecrts26 results if folder is set and exists
            target = cwd + parrot_dir + paper_repo 
            if os.path.isdir(target):
                logger.info(f"Copy results to paper-repo: \"{paper_repo}\"")
                for f in results:
                    shutil.copyfile(cwd + "/" + f, target + "/" + f)
            else:
                logger.warning("Paper-repo not, data not copied automatically.")


        logger.info("Done with paper.py.")
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