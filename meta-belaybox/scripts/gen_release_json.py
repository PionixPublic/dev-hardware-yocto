#!/usr/bin/python3

import os
import re
import sys
import json
import argparse
from datetime import datetime

import re

def ends_with_revision(s):
    # Define the regular expression pattern
    pattern = r'-r\d+$'
    match = re.search(pattern, s)
    # Return True if a match is found, False otherwise
    return bool(match)

def remove_recipe_name(recipes):
    # If a map contains the key "recipe_name", remove it
    _ = [recipe.pop("recipe_name", None) for recipe in recipes]

def parse_recipeinfo_file(filepath):
    recipeinfo = {}
    with open(filepath, 'r', encoding="utf-8") as file:
        for line in file:
            match = re.match(r'^(\w+):\s*(.*)$', line.strip())
            if match:
                key, value = match.group(1), match.group(2)
                recipeinfo[key] = value
    return recipeinfo

def find_recipeinfo_files(root_dir, recipes):
    for dirpath, _, filenames in os.walk(root_dir):
        if 'recipeinfo' in filenames:
            filepath = os.path.join(dirpath, 'recipeinfo')
            parsed_recipeinfo = parse_recipeinfo_file(filepath)

            package_name = os.path.basename(dirpath)
            package_version = parsed_recipeinfo['PV']

            # Check if package already exists in recipes
            package_exists = False
            for recipe in recipes:
                if recipe['recipe_name'] == package_name:
                    # theoretically we can have a package multiple times but with a different version
                    # the version might or might not contain the revision, we need to compare apples with apples
                    if ends_with_revision(recipe['version']):
                        package_version = parsed_recipeinfo['PV'] + '-' + parsed_recipeinfo['PR']
                    else:
                        package_version = parsed_recipeinfo['PV']
                    if recipe['version'] == package_version:
                        package_exists = True
                        # if we found it and it doesnt contain the revision, add it for uniformity
                        if not ends_with_revision(recipe['version']):
                            recipe['version'] = parsed_recipeinfo['PV'] + '-' + parsed_recipeinfo['PR']
            
            # Add new entry if package does not exist, we add it with the revision
            if not package_exists:
                recipes.append({
                    'name': package_name,
                    'version': parsed_recipeinfo['PV'] + '-' + parsed_recipeinfo['PR'],
                    'recipe_name': package_name,
                    'manifest': 'no',
                    'license': parsed_recipeinfo['LICENSE'],
                })
    return recipes

def parse_recipeinfo(path, recipes):
    with open(path, 'r', encoding="utf-8") as manifest_file:
        while True:
            # Read 5 lines
            package_info = [manifest_file.readline().strip() for _ in range(5)]
            
            # Check if reached end of file
            if not package_info[0]:
                break
            
            # Extract package information
            package_name = package_info[0].split(': ')[1]
            package_version = package_info[1].split(': ')[1]
            recipe_name = package_info[2].split(': ')[1]
            package_license = package_info[3].split(': ')[1]
            
            recipes.append({
                'name': package_name,
                'version': package_version,
                'recipe_name': recipe_name,
                'manifest': 'yes',
                'license': package_license,
            })
    return recipes

def main():
    parser = argparse.ArgumentParser(description='Parse recipeinfo files in a directory tree')
    parser.add_argument('--dir', type=str, help='Root directory to search for recipeinfo files')
    parser.add_argument('--manifest', type=str, help='Path to license manifest file')
    parser.add_argument('--output', type=str, help='Path output JSON file')
    args = parser.parse_args()

    recipes = []
    recipes = parse_recipeinfo(args.manifest, recipes)
    recipes = find_recipeinfo_files(args.dir, recipes)

    # List of important package names
    important_packages = set([
        'date',
        'everest-core', 
        'everest-framework',
        'mbedtls',
        'openv2g',
        'googletest',
        'libcurl',
        'libevse-security',
        'everest-cmake', 
        'fmt-everest',
        'libfsm',
        'liblog'
        'libmodbus-everest', 
        'libocpp', 
        'libslac', 
        'libsunspec', 
        'libtimer', 
        'libwebsockets',
        'mqttc',
        'nlohmann-json',
        'json-schema-validator',
        'pugixml',
        'python3-pybind11',
        'python3-pybind11-json',
        'rapidyaml',
        'sigslot',
        'websocketpp',
        'python3-iso15118'
    ])
    # clean up the recipe_name
    remove_recipe_name(recipes)
    # sort the list
    sorted_recipes = sorted(recipes, key=lambda x: x['name'] not in important_packages)
    # prepare to output the json file
    release = {}
    release['channel'] = os.environ.get('BELAYBOX_UPDATE_CHANNEL', "unknown")
    release['datetime'] = datetime.now().isoformat("T") + "Z"
    release['version'] = next((recipe['version'] for recipe in recipes if recipe['name'] == 'everest-core'), '')
    release['components'] = sorted_recipes

    if args.output:
        with open(args.output, "w", encoding="utf-8") as json_file:
            json.dump(release, json_file, indent=2)
    else:
        print(json.dumps(release, indent=2))

if __name__ == "__main__":
    main()
    sys.exit(0)
