from enum import Enum


class RESOURCE_PATH:
    """Contains path to resource directory"""
    res_path = "../"

    def get():
        return RESOURCE_PATH.res_path

    def set(path: str):
        RESOURCE_PATH.res_path = path


class StepMode:
    DEFAULT = 1
    TRACE = 2
