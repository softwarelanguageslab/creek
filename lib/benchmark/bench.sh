#!/usr/bin/env bash
set -e
# Update git.
git fetch --all 

# Run the regular benchmark.
git checkout master
# git checkout -b master_benchmarks

# Run benches.
python3 lib/benchmark/run_benchmark.py 

# Save results. 
# git add -A :/ 
# git commit -m "$(date) Benchmark results"

# Do the non-meta benchmarks.
git checkout creek--
# git checkout -b creek--_benchmarks

# Run benches.
python3 lib/benchmark/run_benchmark.py 

# Save results. 
# git add -A :/ 
# git commit -m "$(date) Benchmark results"

git checkout master