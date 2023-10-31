// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Fot is ERC20 {
    uint256 public transferFeePercentage = 1; // 1% fee
    address public feeRecipient; // Address to receive the fee

    constructor(uint256 initialSupply, address _feeRecipient) ERC20("Marco's cool fee on transfer token", "FOT") {
        require(_feeRecipient != address(0), "Fee recipient cannot be the zero address");
        _mint(msg.sender, initialSupply);
        feeRecipient = _feeRecipient; // Set the fee recipient address
    }

    function _update(address sender, address recipient, uint256 amount) internal override {
        if (sender != address(0) && recipient != address(0)) { // Exclude minting and burning
            uint256 fee = (amount * transferFeePercentage) / 100;
            uint256 amountAfterFee = amount - fee;

            super._update(sender, recipient, amountAfterFee);
            super._update(sender, feeRecipient, fee); // Transfer fee to the specified fee recipient
        } else {
            super._update(sender, recipient, amount);
        }
    }
}
