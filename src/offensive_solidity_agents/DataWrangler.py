import os
import re


class DataWrangler:

    def copy_code_markdown_results(self):
        """
        Copies the code from markdown results to the database folder
        """
        print(os.path)
        with open('./malicious_contract.sol', 'r') as file:
            mal_contract = file.read()

        with open('./src/offensive_solidity_agents/contract.sol', 'r') as file:
            ben_contract = file.read()

        with open('./test_suite.js', 'r') as file:
            tests = file.read()

        # Just grab the code from the file and remove all AI explanations
        mal_code = self._extract_code(mal_contract, 'solidity')
        ben_code = self._extract_code(ben_contract, 'solidity')
        test_code = self._extract_code(tests, 'javascript')

        with open('./dataset/vulnerable_contracts/vulnerable_contract.sol', 'w') as f:
            f.write(ben_code)

        with open('./dataset/mal_contracts/mal_contract.sol', 'w') as f:
            f.write(mal_code)

        with open('./dataset/tests/tests.js', 'w') as f:
            f.write(test_code)


    def _extract_code(self, file_content, language):
        pattern = rf"```{language}\n(.*?)```"
        match = re.search(pattern, file_content, re.DOTALL)

        if match:
            return match.group(1).strip()
        else:
            return file_content # Return file content by default and try it out


if __name__ == '__main__':
    DataWrangler().copy_code_markdown_results()