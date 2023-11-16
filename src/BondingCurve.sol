// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin-contracts@5.0.0/access/Ownable.sol";
import "forge-std/console.sol";

/// @title A secure linear bonding curve contract resistant to sandwich attacks
/// @notice Implements a bonding curve with protections against price manipulation through sandwich attacks
contract BondingCurve is Ownable {
    uint256 public totalSupply; // Total supply of tokens in circulation
    uint256 private constant INITIAL_PRICE = 1 ether; // Initial price per token
    uint256 private constant PRICE_INCREMENT = 0.01 ether; // Incremental price increase per token
    uint256 private constant MAX_SLIPPAGE = 5; // Maximum allowed slippage in percentage

    mapping(address => uint256) public balances; // Mapping of addresses to their token balances

    /// @notice Constructor to set the initial owner of the contract
    /// @param initialOwner The address of the contract's initial owner
    constructor(address initialOwner) Ownable(initialOwner) {}

    /// @notice Allows users to buy tokens at the current price, subject to max price limit
    /// @param numTokens Number of tokens to be bought
    /// @param maxPrice Maximum price the user is willing to pay for the tokens
    /// @return The cost for the purchased tokens
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

    /// @notice Allows users to sell tokens at the current price, subject to minimum revenue limit
    /// @param numTokens Number of tokens to be sold
    /// @param minRevenue Minimum revenue expected from the sale
    /// @return The revenue received from selling the tokens
    function sellToken(uint256 numTokens, uint256 minRevenue) public returns (uint256) {

        require( (balances[msg.sender] >= numTokens), "BondingCurve: Not enough tokens.");

        uint256 revenue = calculatePrice(numTokens);
        require(revenue >= minRevenue, "BondingCurve: Revenue less than minRevenue");

        // Slippage protection
        require(validateSlippage(revenue, minRevenue), "BondingCurve: Slippage too high");


        totalSupply -= numTokens;
        balances[msg.sender] -= numTokens;


        payable(msg.sender).call{value: revenue};

        return revenue;
    }

    /// @notice Calculates the price for a given number of tokens
    /// @param numTokens Number of tokens for which the price is to be calculated
    /// @return Price for the specified number of tokens
    function calculatePrice(uint256 numTokens) public view returns (uint256) {
        return (INITIAL_PRICE + PRICE_INCREMENT * totalSupply) * numTokens;
    }

    /// @notice Validates whether the slippage is within the acceptable range
    /// @param actualValue Actual value or price of the transaction
    /// @param expectedValue Expected value or price of the transaction
    /// @return True if the slippage is within the acceptable range, false otherwise
    function validateSlippage(uint256 actualValue, uint256 expectedValue) private pure returns (bool) {
        uint256 slippage = (actualValue > expectedValue) ?
            ((actualValue - expectedValue) * 100) / expectedValue :
            ((expectedValue - actualValue) * 100) / actualValue;
        return slippage <= MAX_SLIPPAGE;
    }
}
