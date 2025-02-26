#!/bin/bash
  
set -e

if [[ -z "$1" ]]
then
    echo "Usage: $0 <<build|run> output_dir>"
    exit 1
fi

wf_type=$(awk '{ printf("%s", $1) }' <<< "$1")
output_dir=$(awk '{ printf("%s", $2) }' <<< "$1")

echo "--INFO-- Searching benchmarks $wf_type"
source ${output_dir}/projects.txt
num_projects=${#makefile_paths[@]}
source ${output_dir}/run-cmds.txt
num_failed=0
num_success=0
failed_projects=""
msg_success="'rocprof.csv' is generating"
for (( i=0; i<num_projects; i++ ));
do
    project_dir=$(sed -n "s/\/Makefile.aomp//p" <<< "${makefile_paths[$i]}")
    project=$(awk 'BEGIN {FS="/"} {print $8}' <<< "$project_dir")
    if [[ $wf_type == "build" ]]
    then
        if [[ -f "$project_dir/main" ]]
        then
            num_success=$((num_success + 1))
        else
            num_failed=$((num_failed + 1))
            failed_projects+=" \"$project\""
        fi
    else
        if [[ -f "$project_dir/run_results.txt" ]]
        then
            passed=$(sed -n "/$msg_success/p" $project_dir/run_results.txt)
            if [[ ! -z "$passed" ]]
            then
                num_success=$((num_success + 1))
            else
                num_failed=$((num_failed + 1))
                failed_projects+=" \"$project\""
            fi
        else
            num_failed=$((num_failed + 1))
            failed_projects+=" \"$project\""
        fi       
    fi
done
echo "--INFO-- Benchmark $wf_type success=$num_success failed=$num_failed"
echo $failed_projects
