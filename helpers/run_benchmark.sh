#!/bin/bash
# Copyright (c) 2025 Lawrence Livermore National Security, LLC and other
# hecbench-openmp-builder project developers. See the top-level COPYRIGHT
# file for details.
#
# SPDX-License-Identifier: MIT
  
set -e

if [[ -z "$1" ]]
then
    echo "Usage: $0 <project_dir rocprof_input run_cmd>"
    exit 1
fi

project_dir=$(awk '{ printf("%s", $1) }' <<< "$1")
project=$(awk 'BEGIN {FS="/"} {print $7}' <<< "$project_dir")
rocprof_input=$(awk '{ printf("%s", $2) }' <<< "$1")
run_cmd=$(awk '{for(i=3;i<=NF;i++) printf("%s%s",$i,(i==NF)?"\n":OFS);}'        \
    <<< "$1")

cd $project_dir
cmd="bash -c 'rocprof --stats -i $rocprof_input -o rocprof.csv $run_cmd"        \
cmd+=" &> run_results.txt'"
eval $cmd
if [[ $? -ne 0 ]] # Output exit code if fail
then
    printf "%d %s" "$?" "$project"
fi
