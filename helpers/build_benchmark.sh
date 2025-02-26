#!/bin/bash
  
set -e

if [[ -z "$1" ]]
then
    echo "Usage: $0 <project_dir clang_config>"
    exit 1
fi

project_dir=$(awk '{ printf("%s", $1) }' <<< "$1")
clang_config=$(awk '{ printf("%s", $2) }' <<< "$1")

cd $project_dir
export EXTRA_CFLAGS="--config $clang_config"
rm -f main *.o
make -f Makefile.aomp clean 2>&1 >/dev/null
make -f Makefile.aomp &> compile_results.txt
