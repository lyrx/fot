# Contract: `FeeOnTransferToken` 

## Overview

`FeeOnTransferToken` is a Solidity smart contract designed for the Ethereum blockchain. It is built to delegate transfer calls to another ERC20 token while maintaining the ERC20 interface. This contract charges a fee on each transfer, sending the fee to a specified recipient address.

## Contract Details

### `FeeOnTransferToken` Contract

- **Title:** Marco's Cool Fee on Transfer Token
- **SPDX-License-Identifier:** MIT
- **Solidity Version:** 0.8.20
- **OpenZeppelin Libraries:** 
  - `IERC20` from `@openzeppelin-contracts@5.0.0/token/ERC20/IERC20.sol`
  - `Ownable` from `@openzeppelin-contracts@5.0.0/access/Ownable.sol`

### Constructor

- **Purpose:** Creates a new `FeeOnTransferToken`.
- **Parameters:**
  - `_delegateTokenAddress` (address): The ERC20 token address to delegate transfers to.
  - `_feeRecipientAddress` (address): The address to receive the fee.
  - `_transferFeePercentage` (uint256): The transfer fee percentage.
  - `initialOwner` (address): Address of the initial owner of the contract.

### State Variables

- `BASIS_POINTS_DENOMINATOR`: A constant used for fee calculation. Set to 100.
- `feeRecipientAddress` (address): Publicly accessible address that receives the transfer fee.
- `delegateToken` (IERC20): Public ERC20 token to which transfer calls are delegated.
- `transferFeePercentage` (uint256): Public variable indicating the fee percentage on each transfer.

### Functions

#### `transfer`

- **Purpose:** Delegates a transfer to another ERC20 token with a fee.
- **Parameters:**
  - `_recipient` (address): The address receiving the tokens.
  - `_amount` (uint256): The amount of tokens being transferred.
- **Returns:** `success` (bool) - True if the transfer was successful.

#### `transferFrom`

- **Purpose:** Delegates a `transferFrom` call to another ERC20 token with a fee.
- **Parameters:**
  - `_sender` (address): The address sending the tokens.
  - `_recipient` (address): The address receiving the tokens.
  - `_amount` (uint256): The amount of tokens being transferred.
- **Returns:** `success` (bool) - True if the transfer was successful.

#### `totalSupply`

- **Purpose:** Gets the total supply of the delegated token.
- **Returns:** The total supply of the delegated token (uint256).

#### `balanceOf`

- **Purpose:** Gets the balance of an account.
- **Parameters:**
  - `account` (address): The address of the token holder.
- **Returns:** The balance of the account (uint256).

#### `getDelegateToken`

- **Purpose:** Gets the address of the delegate token. Only callable by the owner.
- **Returns:** The address of the delegate token (IERC20).

## Conclusion

The `FeeOnTransferToken` contract provides a mechanism to charge a fee on token transfers, forwarding this fee to a designated address. It utilizes OpenZeppelin's `IERC20` and `Ownable` contracts to ensure standard compliance and secure ownership management.

# Contract: `BondingCurve` #

The Bonding Curve contract is a Solidity-based smart contract designed for Ethereum. It implements a linear bonding curve where the price of the token increases with the total supply. The contract now includes enhanced security features to protect against sandwich attacks.

## Protection Against Sandwich Attacks in Bonding Curve Contract ##

The updated Solidity contract for the Bonding Curve introduces several security measures to mitigate the risks associated with sandwich attacks. A sandwich attack involves a malicious actor placing transactions before and after a victim's legitimate transaction to exploit price movements for profit. The following strategies have been implemented in the contract to counter such attacks:

### Slippage Protection ###

To protect against significant unexpected price changes during a transaction, the contract now includes a slippage protection mechanism. Users specify a maximum price (`maxPrice`) they are willing to pay for buying tokens or a minimum revenue (`minRevenue`) they are willing to accept when selling tokens.

#### Implementation: ####

- In both `buyToken` and `sellToken` functions, additional parameters (`maxPrice` and `minRevenue`, respectively) are introduced.
- The actual cost or revenue is compared against these user-provided values.
- If the actual price deviates more than a predefined slippage percentage from the user's expectation, the transaction is reverted.

### Validating Slippage ###

The contract includes a `validateSlippage` function to calculate and validate the percentage difference (slippage) between the expected and actual values of a transaction.

#### Implementation: ####

- The `validateSlippage` function calculates the slippage percentage based on the provided values.
- It ensures that the slippage does not exceed a predefined maximum limit (set by `MAX_SLIPPAGE` constant).
- If the slippage is within the acceptable range, the transaction proceeds; otherwise, it is reverted.

### Controlled Price Adjustment ###

The contract controls how the price per token is adjusted based on the total supply of tokens, thereby reducing the potential impact of rapid and manipulative price changes.

#### Implementation: ####

- The `calculatePrice` function determines the price per token linearly based on the total supply.
- This controlled price adjustment mechanism ensures more predictable and stable pricing, reducing the effectiveness of sandwich attacks.

### Conclusion ###

By implementing slippage protection and controlled price adjustments, the Bonding Curve contract significantly reduces the vulnerability to sandwich attacks. Users have control over the price limits for their transactions, and unpredictable, significant price changes are less likely to affect them adversely. However, it's important to note that while these measures improve security, they cannot guarantee absolute protection against all forms of attacks.

