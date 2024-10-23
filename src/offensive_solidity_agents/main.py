#!/usr/bin/env python
import json
import os
import subprocess
import sys
from offensive_solidity_agents.crew import OffensiveSolidityAgentsCrew

# This main file is intended to be a way for your to run your
# crew locally, so refrain from adding necessary logic into this file.
# Replace with inputs you want to test with, it will automatically
# interpolate any tasks and agents information

def run():
    """
    Run the crew.
    """
    contract_path = 'src/offensive_solidity_agents/contract.sol'
    example_contract_path = 'src/offensive_solidity_agents/ex_contract.sol'
    example_contract_result_path = 'src/offensive_solidity_agents/ex_contract_exploit.test.js'
    solidity_version = '0.4.25'
    with open(contract_path) as f:
        contract = f.read()
        subprocess.run(
            ['solc-select', 'install', solidity_version], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        subprocess.run(
            ['solc-select', 'use', solidity_version], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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
        'example_contract_result': example_contract_result
    }
    results = OffensiveSolidityAgentsCrew().crew().kickoff(inputs=inputs)
    with open('results.txt', 'w') as f:
        f.write(str(results))


def train():
    """
    Train the crew for a given number of iterations.
    """
    inputs = {
        "topic": "AI LLMs"
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
