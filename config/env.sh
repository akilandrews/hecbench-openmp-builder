#!/bin/bash

module load rocm/6.0.2

export HSA_IGNORE_SRAMECC_MISREPORT=1 # radeon vii gfx906
export LIBOMPTARGET_INFO=$((0x1 | 0x10))