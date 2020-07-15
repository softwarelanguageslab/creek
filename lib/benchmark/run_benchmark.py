#!/usr/bin/env python3 

import time 
import os 
import subprocess

# Check if its a debug run.

debug = False 
if 'DEBUG' in os.environ and os.environ['DEBUG'] == "true": 
    debug = True 
    print("Using debugging values!")

################################################################################
# Fixed values, varying DAG size.

now = time.asctime(time.localtime(time.time())).replace(" ", "").replace(":","_")
output = "results/regular/{}_fixedval_vardag.csv".format(now)
graph = "results/regular/{}_fixedval_vardag.pdf".format(now)

# Write header of csv file.
with open(output, 'x') as f:
    f.write("nodes,vals,max,min,mean,stddev,ci+,ci-\n")

# Benchmark loop.
values = 250 
max_nodes = 2000 if not(debug) else 10

for nodes in range(0, max_nodes + 1, 250):
    os.environ['VALS'] = str(values)
    os.environ['NODES'] = str(nodes) 
    os.environ['CSV'] = output
    print("fixed load, varying dag size {} {} {}".format(values, nodes, output))

    subprocess.Popen("mix run lib/benchmark/run.exs > /dev/null 2>&1", shell=True).wait()

################################################################################
# Fixed DAG size, varying load.

now = time.asctime(time.localtime(time.time())).replace(" ", "").replace(":","_")
output = "results/regular/{}_fixeddag_varload.csv".format(now)
graph = "results/regular/{}_fixeddag_varload.pdf".format(now)

# Write header of csv file.
with open(output, 'x') as f:
    f.write("nodes,vals,max,min,mean,stddev,ci+,ci-\n")
    
# Benchmark loop.
max_values = 10000 if not(debug) else 100 
nodes = 100

for values in range(0, max_values + 1, 1000):
    os.environ['VALS'] = str(values)
    os.environ['NODES'] = str(nodes) 
    os.environ['CSV'] = output
    print("fixed dag size, varying load {} {} {}".format(values, nodes, output))

    subprocess.Popen("mix run lib/benchmark/run.exs > /dev/null 2>&1", shell=True).wait()