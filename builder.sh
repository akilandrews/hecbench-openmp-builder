#!/bin/bash
# Copyright (c) 2025 Lawrence Livermore National Security, LLC and other
# hecbench-openmp-builder project developers. See the top-level COPYRIGHT
# file for details.
#
# SPDX-License-Identifier: MIT
  
set -e

parameters="<clean|get|build|run>"
if [[ -z "$1" ]]
then
  echo "Usage: $0 $parameters"
  exit 1
else
  wf_type=$1
fi

source ./config/env.sh

# Variables *note customize to your file system
root_dir="$(pwd)"
hecbench_source=$(readlink -f "$root_dir/../HeCBench/src")
output_dir=$(readlink -f "$root_dir/../jobs")
config_dir=$(readlink -f "$root_dir/../configs")
clang_config="$root_dir/config/amdgcn-amd-amdhsa.cfg"
rocprof_input="$root_dir/config/rocprof-input.txt"

# Begin workflow
echo "--INFO-- Begin workflow $wf_type"
start_time=$(date '+%s')
[[ ! -f "$config_dir" ]] && mkdir -p ${config_dir}
[[ ! -f "$output_dir" ]] && mkdir -p ${output_dir}
case $wf_type in

  # Clean available omp benchmark directories
  "clean")
    echo "--INFO-- Remove prior results and any core dump files"
    rm -f ${output_dir}/* ${config_dir}/*
    omp_projects="$hecbench_source/*-omp"
    find ${omp_projects} -maxdepth 1 -type d -name 'results'                    \
      | xargs --no-run-if-empty rm -rf
    find ${omp_projects} -maxdepth 1 -type f -name '*.core'                     \
      | xargs --no-run-if-empty rm
    find ${omp_projects} -maxdepth 1 -type f -name 'compile_results.txt'        \
      | xargs --no-run-if-empty rm
    find ${omp_projects} -maxdepth 1 -type f -name 'run_results.txt'            \
      | xargs --no-run-if-empty rm
    find ${omp_projects} -maxdepth 1 -type f -name 'rocprof.*'                  \
      | xargs --no-run-if-empty rm
    ;;
  
  # Get available omp benchmarks
  "get")
    helpers/get_benchmarks.sh "$hecbench_source $config_dir"
    ;;
  
  # Build and execute available omp benchmarks using Flux submit run 
  "build" | "run")
    source ${config_dir}/projects.txt
    num_projects=${#makefile_paths[@]}
    source ${config_dir}/run-cmds.txt
    for (( i=0; i<num_projects; i++ ));
    do
      project_dir=$(sed -n "s/\/Makefile.aomp//p" <<< "${makefile_paths[$i]}")
      project=$(awk 'BEGIN {FS="/"} {print $7}' <<< "$project_dir")
      if [[ $wf_type == "build" ]]
      then
        flux submit -n 1 -c 1 --quiet -o mpibind=off -o cpu-affinity=per-task   \
	        helpers/build_benchmark.sh "$project_dir $clang_config"
      else
        flux submit -n 1 -c 1 -g 1 --quiet -o mpibind=off                       \
          -o cpu-affinity=per-task -o gpu-affinity=per-task                     \
          --output=$output_dir/job-$project-{{id}}.out                          \
          helpers/run_benchmark.sh "$project_dir $rocprof_input ${run_cmds[$i]}"
      fi
      printf "%d %s\n" "$i" "$project"
    done
    ;;

  # Default error
  *)
    echo "--ERROR-- Usage: $0 $parameters"
    ;;
esac

# Display total execution time
end_time=$(date '+%s')
total_time=$(bc -l <<< "($end_time - $start_time) / 60")
printf "%s Completed workflow $wf_type in %.2f mins\n" "--INFO--" "$total_time"