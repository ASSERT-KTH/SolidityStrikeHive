import json
import os
import subprocess
from typing import Any, Type

from crewai_tools import BaseTool
from pydantic import BaseModel, Field


class SlitherAnalysisToolSchema(BaseModel):
    """Input for SlitherAnalysisTool."""

    solidity_code: str = Field(
        "", description="Mandatory solidity code you want to run slither analysis on"
    )


class SlitherAnalysisTool(BaseTool):
    name: str = "Slither analysis tool"
    description: str = (
        "This is a tool to run slither analysis on a Solidity smart contract you give via the argument 'solidity_code'. "
        "Slither is a "
        "static analysis tool for Solidity smart contracts. It runs a suite of vulnerability "
        "detectors, prints visual information about the contract, and provides an API to easily "
        "write custom analyses. You can find more information about Slither at "
        "https://github.com/crytic/slither . Please give me the complete Solidity code of the "
        "smart contract you want to analyze."
    )
    args_schema: Type[BaseModel] = SlitherAnalysisToolSchema

    def _run(self,
        **kwargs: Any) -> str:
        print(kwargs)
        solidity_code = kwargs.get("solidity_code")
        if not solidity_code:
            return "No Solidity code provided"

        # Write the solidity code to a file
        contract_path = 'contract.sol'
        with open(contract_path, 'w') as f:
            f.write(solidity_code)

        result = subprocess.run(
            ['slither', contract_path, '--json', 'slither-output.json'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        if result.returncode != 0:
            print("Error running Slither:", result.stderr)
            return "None"
        with open('slither-output.json') as f:
            slither_output = json.load(f)

        # Clean up
        os.remove(contract_path)
        return slither_output
