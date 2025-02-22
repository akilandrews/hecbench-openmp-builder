# Benchmark builder
Bash scripts that build OpenMP offload benchmarks included in HeCBench suite (https://github.com/zjin-lcf/HeCBench) on AMD GPUs hardware.

## Requirements
Bash shell, LLVM OpenMP, LLVM Clang, AMD ROCm, Flux

## Instructions
First customize to your file system 'builder.sh' variables section (hecbench_source, output_dir, clang_config, rocprof_input) and Clang configuration 'config/amdgcn-amd-amdhsa.cfg'. Then to run builder execute each step in order:
1. `builder.sh clean`
2. `builder.sh get`
3. `builder.sh build`
4. `builder.sh run`

*Note: steps 3 and 4 are batch submissions and can be monitored using `flux top`
