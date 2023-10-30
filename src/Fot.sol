// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Fot is ERC20 {
    uint256 public transferFeePercentage = 1; // 1% fee

    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }

    function _update(address sender, address recipient, uint256 amount) internal override {
        uint256 fee = (amount * transferFeePercentage) / 100;
        uint256 amountAfterFee = amount - fee;

        super._transfer(sender, recipient, amountAfterFee);
        super._transfer(sender, address(this), fee); // Transfer fee to the contract
    }
}
