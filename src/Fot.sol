// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/// @title Marco's cool fee on transfer token
/// @author Alexander Weinmann
/// @notice This contract implements a token with a transfer fee
/// @dev Inherits from OpenZeppelin's ERC20 contract
contract Fot is ERC20 {
    uint256 private constant BASIS_POINTS_DENOMINATOR = 100;
    uint256 public transferFeePercentage = 1; // 1% fee
    address public feeRecipient; // Address to receive the fee

    /// @notice Creates a new Fot token
    /// @param initialSupply The initial supply of tokens
    /// @param _feeRecipient The address to receive the fee
    /// @dev The constructor sets the initial supply and fee recipient address
    constructor(uint256 initialSupply, address _feeRecipient) ERC20("Marco's cool fee on transfer token", "FOT") {
        require(_feeRecipient != address(0), "Fot: Fee recipient cannot be the zero address");
        _mint(msg.sender, initialSupply);
        feeRecipient = _feeRecipient; // Set the fee recipient address
    }

    /// @notice Internal function to update balances with fee
    /// @param sender The address sending the tokens
    /// @param recipient The address receiving the tokens
    /// @param amount The amount of tokens being transferred
    /// @dev Calculates and applies the transfer fee, excluding minting and burning
    function _update(address sender, address recipient, uint256 amount) internal override {
        if (sender != address(0) && recipient != address(0)) { // Exclude minting and burning
            uint256 fee = (amount * transferFeePercentage) / BASIS_POINTS_DENOMINATOR;
            uint256 amountAfterFee = amount - fee;

            super._update(sender, recipient, amountAfterFee);
            super._update(sender, feeRecipient, fee); // Transfer fee to the specified fee recipient
        } else {
            super._update(sender, recipient, amount);
        }
    }
}
