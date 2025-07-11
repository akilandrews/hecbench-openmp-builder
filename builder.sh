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

# Directories for build and installation (*Note customize to your file system)
root_dir="$(pwd)"
config_dir="$root_dir/config"
source $config_dir/env.sh
clang_config="$config_dir/amdgcn-amd-amdhsa.cfg"
rocprof_input="$config_dir/rocprof-input.txt"
jobs_dir=$(readlink -f "$root_dir/../jobs")
outputs_dir=$(readlink -f "$root_dir/../hob-configs")
hecbench_install_dir=$(readlink -f "$root_dir/../")

# Create directories and clone HecBench suite
[[ ! -f "$jobs_dir" ]] && mkdir -p ${jobs_dir}
[[ ! -f "$outputs_dir" ]] && mkdir -p ${outputs_dir}
if [[ ! -d ${hecbench_install_dir}/HeCBench ]]
then
    cd $hecbench_install_dir
    git clone https://github.com/zjin-lcf/HeCBench.git
    cd $root_dir
fi
hecbench_source=$hecbench_install_dir/HeCBench/src
echo "--INFO-- HeCBench project directory $hecbench_source"

# Begin workflow type
echo "--INFO-- Begin workflow $wf_type"
start_time=$(date '+%s')
case $wf_type in

  # Clean available omp benchmark directories
  "clean")
    echo "--INFO-- Remove prior results and any core dump files"
    rm -f ${jobs_dir}/* ${outputs_dir}/*
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
    helpers/get_benchmarks.sh "$hecbench_source $outputs_dir"
    ;;
  
  # Build and execute available omp benchmarks using Flux submit 
  "build" | "run")
    source ${outputs_dir}/projects.txt
    num_projects=${#makefile_paths[@]}
    source ${outputs_dir}/run-cmds.txt
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
          --output=$jobs_dir/job-$project-{{id}}.out                            \
          helpers/run_benchmark.sh "$project_dir $rocprof_input ${run_cmds[$i]}"
      fi
      printf "%3d %s\n" "$i" "$project"
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
