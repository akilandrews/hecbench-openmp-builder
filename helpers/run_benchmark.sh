#!/bin/bash
  
set -e

if [[ -z "$1" ]]
then
    echo "Usage: $0 <project_dir rocprof_input run_cmd>"
    exit 1
fi

project_dir=$(awk '{ printf("%s", $1) }' <<< "$1")
rocprof_input=$(awk '{ printf("%s", $2) }' <<< "$1")
run_cmd=$(awk '{for(i=3;i<=NF;i++) printf("%s%s",$i,(i==NF)?"\n":OFS);}'        \
    <<< "$1")

cd $project_dir
cmd="bash -c 'rocprof --stats -i $rocprof_input -o rocprof.csv $run_cmd" 	    \
cmd+=" &> run_results.txt'"
eval $cmd

