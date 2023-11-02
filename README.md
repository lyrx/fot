# Fee-on-Transfer ERC20 Token and Tests

This repository contains a Solidity smart contract for an ERC20 token with a fee-on-transfer feature. Additionally, it includes Foundry tests to ensure the contract's functionality and correctness.

1. RareSkills post about "Solidity Coding Standards": [here](https://www.rareskills.io/post/solidity-style-guide)
2. Solidity Style Guide: [here](https://docs.soliditylang.org/en/latest/style-guide.html)
3. Clean NatSpec Comments: [here](https://docs.soliditylang.org/en/latest/natspec-format.html#natspec)
4. RareSkills Post about unit testing in Foundry: [here](https://www.rareskills.io/post/foundry-testing-solidity)
5. RareSkills Post about Coverage Visualization: [here](https://www.rareskills.io/post/foundry-forge-coverage)

## Overview

The `Fot` contract is an ERC20 token that charges a fee on each transfer. The fee is sent to a specified address, which is determined at the time of contract deployment. This README provides instructions on how to deploy the contract and run the tests using Foundry.

### Contract: `Fot`

The `Fot` contract is an ERC20 token with a 1% fee on each transfer. The fee is sent to an address specified in the contract's constructor.

### Test: `FotTest`

The `FotTest` contract includes several tests to ensure the correct behavior of the `Fot` contract, particularly focusing on the fee-on-transfer feature and the initial token setup.

## Prerequisites

- [Foundry](https://github.com/gakonst/foundry): Ensure you have Foundry installed. You can install it using the following command:

```
curl -L https://foundry.paradigm.xyz | bash
foundryup

```

## Installation

1. Clone the repository: `git clone <repository-url>`
2. Navigate to the project directory: `cd <project-directory>`

## Running Tests

To run the tests, use the following command in the project directory:

```
forge test
```

## Checking Test Coverage

To check the line coverage of the tests, use the `forge coverage` command:

```
forge coverage
```

After running this command, you can view a summary of the coverage in the terminal.

| File        | % Lines      | % Statements   | % Branches   | % Funcs       |
|-------------|--------------|----------------|--------------|---------------|
| src/Fot.sol | 83.33% (5/6) | 91.67% (11/12) | 50.00% (1/2) | 100.00% (1/1) |

## Contract Deployment

To deploy the `Fot` contract, use the following command, replacing `<initial-supply>` and `<fee-recipient-address>` with your desired initial supply and fee recipient address:

`forge create Fot --constructor-args <initial-supply> <fee-recipient-address>`
