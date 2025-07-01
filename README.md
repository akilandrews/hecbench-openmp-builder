# Benchmark builder
Bash scripts that build OpenMP offload benchmarks included in HeCBench suite (https://github.com/zjin-lcf/HeCBench) on AMD GPUs hardware.

## Requirements
Bash shell v4.4, OpenMP 4.5, Clang 19.1.7, AMD ROCm 6.0.2, Flux 0.75

## Instructions
First customize to your file system 'builder.sh' variables section (hecbench_source, config_dir, and output_dir) and configuration files in config folder, 'amdgcn-amd-amdhsa.cfg' and 'rocprof-input.txt'. Start a Flux interactive job on a single compute node. To run builder execute each step in order:
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