// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin-contracts@5.0.0/access/Ownable.sol";
import "forge-std/console.sol";


/// @title A secure linear bonding curve contract resistant to sandwich attacks
/// @notice Implements a bonding curve with protections against price manipulation through sandwich attacks
contract BondingCurve is Ownable {
    uint256 public totalSupply;
    uint256 private constant INITIAL_PRICE = 1 ether;
    uint256 private constant PRICE_INCREMENT = 0.01 ether;
    uint256 private constant MAX_SLIPPAGE = 5; // Max slippage in percentage

    mapping(address => uint256) public balances;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function buyToken(uint256 numTokens, uint256 maxPrice) public payable returns (uint256) {
        uint256 cost = calculatePrice(numTokens);
        require(cost <= maxPrice, "BondingCurve: Price exceeded maxPrice");
        require(msg.value >= cost, "BondingCurve: Not enough Ether sent.");

        // Slippage protection
        require(validateSlippage(cost, maxPrice), "BondingCurve: Slippage too high");

        totalSupply += numTokens;
        balances[msg.sender] += numTokens;

        return cost;
    }

    function sellToken(uint256 numTokens, uint256 minRevenue) public returns (uint256) {
        require(balances[msg.sender] >= numTokens, "BondingCurve: Not enough tokens.");

        uint256 revenue = calculatePrice(numTokens);
        console.log("Revenue", revenue);
        require(revenue >= minRevenue, "BondingCurve: Revenue less than minRevenue");

        // Slippage protection
        require(validateSlippage(revenue, minRevenue), "BondingCurve: Slippage too high");

        totalSupply -= numTokens;
        balances[msg.sender] -= numTokens;
        payable(msg.sender).transfer(revenue);

        return revenue;
    }

    function calculatePrice(uint256 numTokens) public view returns (uint256) {
        return (INITIAL_PRICE + PRICE_INCREMENT * totalSupply) * numTokens;
    }

    function validateSlippage(uint256 actualValue, uint256 expectedValue) private pure returns (bool) {
        uint256 slippage = (actualValue > expectedValue) ?
            ((actualValue - expectedValue) * 100) / expectedValue :
            ((expectedValue - actualValue) * 100) / actualValue;
        return slippage <= MAX_SLIPPAGE;
    }
}
