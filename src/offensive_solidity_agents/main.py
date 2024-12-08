#!/usr/bin/env python
import json
import os
import re
import subprocess
import sys

from offensive_solidity_agents.crew import OffensiveSolidityAgentsCrew

from offensive_solidity_agents.DataWrangler import DataWrangler

# This main file is intended to be a way for your to run your
# crew locally, so refrain from adding necessary logic into this file.
# Replace with inputs you want to test with, it will automatically
# interpolate any tasks and agents information


malicious_contract_path = 'malicious_contract.sol'
test_suite_path = 'test_suite.js'

def run():
    """
    Run the crew.
    """
    # Delete the malicious contract and test suite files if they exist
    if os.path.exists(malicious_contract_path):
        os.remove(malicious_contract_path)
    if os.path.exists(test_suite_path):
        os.remove(test_suite_path)
    success, traceback = _run_loop()
    i = 0
    while not success and i < 11:
        success, traceback = _run_loop(traceback)
        print(traceback)
        print('Iteration %s finished' % i)
        i += 1

    print('End Result: %s' % success)
    print('Latest traceback %s' % traceback)


def _run_loop(traceback=None) -> (bool, str):
    _run_crew(traceback)
    _wrangle_data()
    return _start_docker()

def _run_crew(traceback=None):
    print(os.getcwd())
    contract_path = 'src/offensive_solidity_agents/contract.sol'
    example_contract_path = 'src/offensive_solidity_agents/ex_contract.sol'
    example_contract_result_path = 'src/offensive_solidity_agents/ex_contract_exploit.test.js'
    hardhat_config_path = 'hardhat-docker/hardhat.config.js'
    hardhat_package_json_path = 'hardhat-docker/package.json'
    solidity_version = '0.4.25'
    with open(contract_path) as f:
        contract = f.read()
        # Fetch solidity version by regex
        solidity_version = re.search(r"pragma solidity (.*);", contract).group(1)
        subprocess.run(
            ['solc-select', 'install', solidity_version], stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        subprocess.run(
            ['solc-select', 'use', solidity_version], stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        result = subprocess.run(
            ['slither', contract_path, '--json', 'slither-output.json'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        # If slither file is not created, log the error
        if not os.path.exists('slither-output.json'):
            print('ERROR: Slither output file not created')
            slither_output = None
        else:
            with open('slither-output.json') as f:
                slither_output = json.load(f)
            os.remove('slither-output.json')

    with open(example_contract_path) as f:
        example_contract = f.read()

    with open(example_contract_result_path) as f:
        example_contract_result = f.read()

    with open(hardhat_config_path) as f:
        hardhat_config = f.read()

    with open(hardhat_package_json_path) as f:
        hardhat_package_json = f.read()

    malicious_contract_previous_execution = None
    if os.path.exists(malicious_contract_path):
        with open(malicious_contract_path) as f:
            malicious_contract_previous_execution = f.read()

    test_suite_previous_execution = None
    if os.path.exists(test_suite_path):
        with open(test_suite_path) as f:
            test_suite_previous_execution = f.read()

    inputs = {
        'code': contract,
        'solidity_version': solidity_version,
        'slither_output': slither_output,
        'example_contract': example_contract,
        'example_contract_result': example_contract_result,
        'traceback_previous_execution': traceback,
        'hardhat_config': hardhat_config,
        'hardhat_package_json': hardhat_package_json,
        'malicious_contract_previous_contract': malicious_contract_previous_execution,
        'test_suite_previous_execution': test_suite_previous_execution
    }
    results = OffensiveSolidityAgentsCrew().crew().kickoff(inputs=inputs)
    with open('results.txt', 'w') as f:
        f.write(str(results))


def _wrangle_data():
    # Start to wrangle data
    print('Start data wrangling')
    data_wrangler = DataWrangler()
    data_wrangler.copy_code_markdown_results()


def _start_docker() -> (bool, str):
    # Start docker and get tracebook in case of issue
    result = subprocess.run(
        ['docker-compose', '-f', './hardhat-docker/docker-compose.yml', 'up'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    # Get to know if the docker-compose up was successful
    output = result.stdout + result.stderr
    print("OUTPUT: %s" % output)
    regex = r"(\d+)\s*failing"
    syntax_error_pattern = r'SyntaxError|Unexpected\s+identifier'
    match_syntax_error = re.search(syntax_error_pattern, output)
    success = re.search(regex, output) is None and match_syntax_error is None
    return success, output


def train():
    """
    Train the crew for a given number of iterations.
    """
    contract_path = 'src/offensive_solidity_agents/contract.sol'
    example_contract_path = 'src/offensive_solidity_agents/ex_contract.sol'
    example_contract_result_path = 'src/offensive_solidity_agents/ex_contract_exploit.test.js'
    solidity_version = '0.4.25'
    with open(contract_path) as f:
        contract = f.read()
        # Fetch solidity version by regex
        solidity_version = re.search(r"pragma solidity (.*);", contract).group(1)
        subprocess.run(
            ['solc-select', 'install', solidity_version], stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        subprocess.run(
            ['solc-select', 'use', solidity_version], stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        result = subprocess.run(
            ['slither', contract_path, '--json', 'slither-output.json'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        with open('slither-output.json') as f:
            slither_output = json.load(f)

        os.remove('slither-output.json')

    with open(example_contract_path) as f:
        example_contract = f.read()

    with open(example_contract_result_path) as f:
        example_contract_result = f.read()

    inputs = {
        'code': contract,
        'solidity_version': solidity_version,
        'slither_output': slither_output,
        'example_contract': example_contract,
        'example_contract_result': example_contract_result,
        'traceback_previous_execution': None
    }
    try:
        OffensiveSolidityAgentsCrew().crew().train(n_iterations=int(sys.argv[1]), filename=sys.argv[2], inputs=inputs)

    except Exception as e:
        raise Exception(f"An error occurred while training the crew: {e}")

def replay():
    """
    Replay the crew execution from a specific task.
    """
    try:
        OffensiveSolidityAgentsCrew().crew().replay(task_id=sys.argv[1])

    except Exception as e:
        raise Exception(f"An error occurred while replaying the crew: {e}")

def test():
    """
    Test the crew execution and returns the results.
    """
    inputs = {
        "topic": "AI LLMs"
    }
    try:
        OffensiveSolidityAgentsCrew().crew().test(n_iterations=int(sys.argv[1]), openai_model_name=sys.argv[2], inputs=inputs)

    except Exception as e:
        raise Exception(f"An error occurred while replaying the crew: {e}")
