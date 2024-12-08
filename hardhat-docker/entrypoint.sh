#!/bin/bash
set -e

ls -la /tmp/vulnerable_contracts/
ls /usr/src/app
echo $PWD

# Copy mounted files to container folders
cp -r /tmp/vulnerable_contracts/* ./contracts/
cp -r /tmp/mal_contracts/* ./contracts/
cp -r /tmp/tests/* ./test/

# Initialize Hardhat project if not already initialized
if [ ! -d "./node_modules" ]; then
  hardhat init --force
fi

# Compile the contracts
echo "Compiling contracts..."
npx hardhat compile

# Run tests
echo "Running tests..."
npx hardhat test
