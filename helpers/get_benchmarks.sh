#!/bin/bash
# Copyright (c) 2025 Lawrence Livermore National Security, LLC and other
# hecbench-openmp-builder project developers. See the top-level COPYRIGHT
# file for details.
#
# SPDX-License-Identifier: MIT
  
set -e

if [[ -z "$1" ]]
then
    echo "Usage: $0 <hecbench_source config_dir>"
    exit 1
fi

hecbench_source=$(awk '{ printf("%s", $1) }' <<< "$1")
config_dir=$(awk '{ printf("%s", $2) }' <<< "$1")

# Get benchmarks Makefiles.aomp
hec_projects=$(find ${hecbench_source} -type f -name "Makefile.aomp"            \
  -printf '%p\n' | sort -g)
num_hec_projects=$(grep -o "Makefile.aomp" <<< "$hec_projects" | wc -l)
echo "--INFO-- Total benchmarks available: $num_hec_projects"

# Issue: Makefile.aomp - clang++, "program = main", $(LAUCHER), includes
declare -a remove_projects=("aes-omp" "ans-omp" "b+tree-omp" "che-omp"          \
  "compute-score-omp" "face-omp" "fdtd3d-omp" "grep-omp" "heartwall-omp"        \
  "histogram-omp" "hybridsort-omp" "kmeans-omp" "leukocyte-omp" "miniFE-omp"    \
  "miniWeather-omp" "mcmd-omp" "multimaterial-omp" "myocyte-omp" "srad-omp"     \
  "tridiagonal-omp" "streamcluster-omp" "slu-omp" "testSNAP-omp"                \
  "zeropoint-omp")

# Issue: llvm
remove_projects+=("atomicIntrinsics-omp" "atomicReduction-omp"                  \
  "babelstream-omp" "channelSum-omp" "cm-omp" "dp-omp" "expdist-omp"            \
  "feynman-kac-omp" "fhd-omp" "gpp-omp" "hausdorff-omp" "jacobi-omp"            \
  "lanczos-omp" "lebesgue-omp" "lulesh-omp" "metropolis-omp" "norm2-omp"        \
  "rsbench-omp" "wordcount-omp")

# Issue: c++
remove_projects+=("langford-omp" "memcpy-omp" "minibude-omp" "permutate-omp"    \
  "prna-omp" "sad-omp" "sptrsv-omp" "ntt-omp" "s3d-omp")

# Issue: libBlasLapack.a
remove_projects+=("axhelm-omp")

# Issue: ld.lld
remove_projects+=("extend2-omp" "lci-omp" "michalewicz-omp" "wsm5-omp")

# Issue: failed to run baseline
remove_projects+=("asmooth-omp" "asta-omp" "atomicPerf-omp"                     \
  "bezier-surface-omp" "bfs-omp" "binomial-omp" "bn-omp" "bsearch-omp"          \
  "ccs-omp" "cfd-omp" "clink-omp" "cmp-omp" "columnarSolver-omp" "d2q9-bgk-omp" \
  "debayer-omp" "deredundancy-omp" "diamond-omp" "fft-omp" "fpc-omp" "fpdc-omp" \
  "frechet-omp" "frna-omp" "gc-omp" "gd-omp" "geodesic-omp" "gmm-omp"           \
  "grrt-omp" "haversine-omp" "heat2d-omp" "henry-omp" "hogbom-omp"              \
  "hotspot3D-omp" "hypterm-omp" "idivide-omp" "linearprobing-omp" "lr-omp"      \
  "mcpr-omp" "meanshift-omp" "merge-omp" "minimap2-omp" "mis-omp" "mriQ-omp"    \
  "mt-omp" "nn-omp" "particles-omp" "pns-omp" "pointwise-omp" "urng-omp"        \
  "qtclustering-omp" "quicksort-omp" "sobel-omp" "sort-omp" "ss-omp"            \
  "svd3x3-omp" "thomas-omp" "tonemapping-omp" "tqs-omp" "triad-omp" "tsp-omp"   \
  "vmc-omp" "xlqc-omp" "kernelLaunch-omp" "pnpoly-omp" "quantBnB-omp"           \
  "easyWave-omp" "snake-omp" "adamw-omp")

# Issue: long run times
remove_projects+=("affine-omp" "all-pairs-distance-omp" "atomicCost-omp"        \
  "attention-omp" "boxfilter-omp" "car-omp" "chacha20-omp" "colorwheel-omp"     \
  "contract-omp" "convolution1D-omp" "degrid-omp" "divergence-omp"              \
  "entropy-omp" "epistasis-omp" "fresnel-omp" "glu-omp" "interval-omp"          \
  "ldpc-omp" "lid-driven-cavity-omp" "lrn-omp" "match-omp" "matern-omp"         \
  "maxFlops-omp" "mdh-omp" "morphology-omp" "nlll-omp" "nqueen-omp"             \
  "openmp-omp" "overlay-omp" "p4-omp" "phmm-omp" "present-omp" "qrg-omp"        \
  "reverse-omp" "rtm8-omp" "scan-omp" "sheath-omp" "spm-omp" "stddev-omp"       \
  "sw4ck-omp" "channelShuffle-omp")

# Issue: failed generate LIBOMPTARGET outputs
remove_projects+=("mallocFree-omp")

# Issue: core dumps for instructed launch params
remove_projects+=("adv-omp" "convolutionSeparable-omp" "hwt1d-omp"              \
  "loopback-omp" "lud-omp" "nw-omp" "radixsort-omp" "reaction-omp" "rfs-omp"    \
  "rng-wallace-omp" "scan2-omp" "shmembench-omp" "split-omp" "vol2col-omp"      \
  "zmddft-omp")

# Remove benchmarks with issues
echo "--INFO-- Remove benchmarks with issues"
num_remove_projects=${#remove_projects[@]}
removed=""
for (( i=0; i<num_remove_projects; i++ ));
do
  removed+="${remove_projects[$i]} "
  replace_str=$(sed 's;/;\\/;g' <<< "$hecbench_source/${remove_projects[$i]}")
  replace_str="/$replace_str/d"  
  hec_projects=$(sed "$replace_str" <<< "$hec_projects")
done
[[ ! -z "$removed" ]] && echo "$removed"
declare -a makefile_paths=()
for makefile_path in $hec_projects;
do
  makefile_paths+=($makefile_path)
done
num_projects=${#makefile_paths[@]}
message="$num_projects ($num_hec_projects - $num_remove_projects)"
echo "--INFO-- Total benchmarks available: $message"

# Modify variables in each Makefile.aomp
echo "--INFO-- Modify variables in each Makefile.aomp"
declare -a options=(
  [0]="CC"
  [1]="OPTIMIZE"
  [2]="DEBUG"
  [3]="DEVICE"
  [4]="ARCH"
  [5]="LAUNCHER"
  [6]="VERIFY"
  [7]="DUMP"
  [8]="program"
)
for (( i=0; i<num_projects; i++ ));
do
  project_makefile=${makefile_paths[$i]}
  sed -i -e "s/${options[0]}.*=.*/${options[0]} = clang++/"                     \
    -e "s/${options[1]}.*=.*/${options[1]} = /"                                 \
    -e "s/${options[2]}.*=.*/${options[2]} = /"                                 \
    -e "s/${options[3]}.*=.*/${options[3]} = /"                                 \
    -e "s/${options[4]}.*=.*/${options[4]} = /"                                 \
    -e "s/${options[5]}.*=.*/${options[5]} = /"                                 \
    -e "s/${options[6]}.*=.*/${options[6]} = /"                                 \
    -e "s/${options[7]}.*=.*/${options[7]} = /"                                 \
    -e "s/${options[8]}.*=.*/${options[8]} = main/"                             \
    -e "/CFLAGS.*+=.*-qopenmp/d"                                                \
    -e "/CFLAGS.*+=.*-fopenmp/d" ${project_makefile}
done

# Create files 'projects.txt' and 'run-cmds.txt'
echo "--INFO-- Create files 'projects.txt' and 'run-cmds.txt'"
declare -a run_cmds
for (( i=0; i<num_projects; i++ ));
do
  option="0,/\$(LAUNCHER) *\.\/\$(program)/{s/\$(LAUNCHER) *\.\/\$(program)//p}"
  has_option=$(sed -n "$option" ${makefile_paths[$i]})
  
  # Replace "../" since running executable in run# folders not project path
  replace_str=$(sed 's;/;\\/;g' <<< "$hecbench_source")
  option="s/ \.\.\// $replace_str\//g" # replace_str="0,/$replace_str/{s///}"
  has_option=$(sed "$option" <<< "$has_option")
  
  # Replace "./"
  project_dir=$(awk 'BEGIN {FS="/"} {for(i=1;i<=9;i++) printf("%s%s",$i,FS);}'  \
    <<< "${makefile_paths[$i]}")
  replace_str=$(sed 's;/;\\/;g' <<< "$project_dir")
  option="s/ \.\// $replace_str\//g" # replace_str="0,/$replace_str/{s///}"
  has_option=$(sed "$option" <<< "$has_option")
  
  # Store benchmark run command with parameters
  exec_full_path=$(sed -n "s/Makefile.aomp/main/p" <<< "${makefile_paths[$i]}")
  run_cmds+=("$exec_full_path $has_option")
  project=$(awk 'BEGIN {FS="/"} {print $7}' <<< "$exec_full_path")
  printf "%d %s\n" "$i" "$project"
done

# Verify array sizes and output to file
if [ "${#makefile_paths[@]}" -ne "${#run_cmds[@]}" ]
then
    printf "%s%d" "--ERROR-- num projects " "${#makefile_paths[@]}"
    printf "%s%d\n" " != num cmds " "${#run_cmds[@]}"
    echo "--ERROR-- Exiting!"
    exit 1
fi
declare -p run_cmds > ${config_dir}/run-cmds.txt
declare -p makefile_paths > ${config_dir}/projects.txt