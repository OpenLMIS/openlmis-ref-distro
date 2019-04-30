import os
import sys
import yaml
import json
from functools import reduce

variables_map = {'${DATABASE_USERNAME}': os.environ.get('DATABASE_USERNAME'), 
                 '${DATABASE_HOST}': os.environ.get('DATABASE_HOST'), 
                 '${DATABASE_PORT}': os.environ.get('DATABASE_PORT'), 
                 '${DATABASE_NAME}': os.environ.get('DATABASE_NAME')}

def replace_file_variables(file):
    file_data = open(file, 'r').read()
        
    with open(file, 'w') as f:
        f.write(reduce(lambda match, kv: match.replace(*kv), variables_map.items(), file_data))

def handle_datasources_dashboards(files):
    for i in files:
        replace_file_variables(i)

files = sys.argv[1:]
handle_datasources_dashboards(files)