# -*- coding: utf-8 -*-
"""
Created on Thu Apr  1 05:08:30 2021

@author: tianz
"""

# Producing Cython lib
# Commandline: build_ext --inplace
from setuptools import setup
from Cython.Build import cythonize

setup(
    #ext_modules = cythonize("LinkedList.pyx")
    ext_modules = cythonize("SynchroCacheIterator.pyx")
)
