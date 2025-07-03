# Benchmark builder
Bash scripts that build OpenMP offload benchmarks included in HeCBench suite (https://github.com/zjin-lcf/HeCBench) on AMD GPUs hardware.

## Requirements
Bash shell v4.4, OpenMP 4.5, Clang 19.1.7, AMD ROCm 6.0.2, Flux 0.75

## Instructions
First step, customize to your file system 'builder.sh' variables section. At a minimum set folder locations 'jobs_dir' to store Flux job outputs , 'outputs_dir' to store builder config files, and 'hecbench_install_dir' to clone benchmark repository. Next step, edit or remove content in config folder files 'amdgcn-amd-amdhsa.cfg' and 'rocprof-input.txt'. To run the builder execute each step in a Flux environment in order:
1. `builder.sh clean`
2. `builder.sh get`
3. `builder.sh build`
4. `builder.sh run`

*Note: steps 3 and 4 are batch submissions and can be monitored using `flux top`

## Authors
See the [CODEOWNERS](CODEOWNERS) file for details.

## License
hecbench-openmp-builder is distributed under the terms of the MIT license. All new constributions must be made under the MIT license. See [LICENSE](LICENSE), [NOTICE](NOTICE), and [COPYRIGHT](COPYRIGHT) for details.

SPDX-License-Identifier: MIT

## Release
LLNL-CODE-2006347