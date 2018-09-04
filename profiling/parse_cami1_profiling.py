import os
from shutil import copyfile
from collections import defaultdict


DIR_PATH = '/home/myusername/cami/firstchallenge_evaluation/profiling/data/submissions_evaluation/'


dnames = next(os.walk(DIR_PATH))[1]
pool_to_truth_type_to_tool_to_path = defaultdict(lambda: defaultdict(dict))

for dir_name in dnames:
    with open(os.path.join(DIR_PATH, dir_name, 'description.properties')) as f:
        desc = {}
        for line in f:
            k, v = line.strip('\n').split('=')
            desc[k] = v
    pool_to_truth_type_to_tool_to_path[desc['pool_name']][desc['_truth_type']][desc['method_name']] = os.path.join(DIR_PATH, dir_name)

for pool in pool_to_truth_type_to_tool_to_path:
    os.makedirs(os.path.join('cami1', pool))
    for truth_type in pool_to_truth_type_to_tool_to_path[pool]:
        for tool in pool_to_truth_type_to_tool_to_path[pool][truth_type]:
            src = os.path.join(pool_to_truth_type_to_tool_to_path[pool][truth_type][tool], 'output', 'metrics.txt')
            dst = os.path.join('cami1', pool, tool + '_' + truth_type + '.txt')
            copyfile(src, dst)
