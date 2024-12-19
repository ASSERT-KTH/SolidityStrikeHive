import os
import re

BASE_DIR = './tmp_dataset'

class DataWrangler:

    def copy_code_markdown_results(self):
        """
        Copies the code from markdown results to the database folder
        """
        # Empty the dataset folder first
        for filename in os.listdir(f'{BASE_DIR}/vulnerable_contracts'):
            os.remove(f'{BASE_DIR}/vulnerable_contracts/{filename}')

        with open('./malicious_contract.sol', 'r') as file:
            mal_contract = file.read()

        # Copy files from vulnerable_contract_files folder to dataset folder
        for filename in os.listdir('./vulnerable_contract_files'):
            with open(f'./vulnerable_contract_files/{filename}', 'r') as file:
                content = file.read()

                with open(f'{BASE_DIR}/vulnerable_contracts/{filename}', 'w') as f:
                    f.write(content)

        with open('./test_suite.js', 'r') as file:
            tests = file.read()

        # Just grab the code from the file and remove all AI explanations
        mal_code = self._extract_code(mal_contract, 'solidity')
        test_code = self._extract_code(tests, 'javascript')

        with open(f'{BASE_DIR}/mal_contracts/mal_contract.sol', 'w') as f:
            f.write(mal_code)

        with open(f'{BASE_DIR}/tests/tests.js', 'w') as f:
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
