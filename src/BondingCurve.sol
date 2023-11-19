// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin-contracts@5.0.0/access/Ownable.sol";
import "forge-std/console.sol";

/// @title A secure linear bonding curve contract resistant to sandwich attacks
/// @notice Implements a bonding curve with protections against price manipulation through sandwich attacks
/// This contract uses a linear bonding curve to manage the price of its tokens, which increases with each token sold.
contract BondingCurve is Ownable {
    uint256 public totalSupply; // Total supply of tokens in circulation
    uint256 private constant INITIAL_PRICE = 1 ether; // Initial price per token, set to 1 ETH
    uint256 private constant PRICE_INCREMENT = 0.01 ether; // Incremental price increase per token, set to 0.01 ETH
    uint256 private constant MAX_SLIPPAGE = 5; // Maximum allowed slippage in percentage, set to 5%

    mapping(address => uint256) public balances; // Mapping of addresses to their token balances

    /// @notice Constructor to set the initial owner of the contract
    /// @param initialOwner The address of the contract's initial owner
    constructor(address initialOwner) Ownable(initialOwner) {}

    /// @notice Allows users to buy tokens at the current price, subject to max price limit
    /// @param numTokens Number of tokens to be bought
    /// @param maxPrice Maximum price the user is willing to pay for the tokens
    /// @return The cost for the purchased tokens
    /// The function calculates the cost of the requested number of tokens and ensures that the transaction meets the user's max price condition.
    function buyToken(uint256 numTokens, uint256 maxPrice) public payable returns (uint256) {
        uint256 cost = calculatePrice(numTokens);
        // Reverts if the calculated cost exceeds the user's maximum price limit.
        if (cost > maxPrice) revert("BondingCurve: Market price exceeds maxPrice");
        // Reverts if the sent Ether value is less than the cost of the tokens.
        if (msg.value < cost) revert("BondingCurve: Not enough Ether sent.");

        bool slippage = validateSlippage(cost, maxPrice);
        // Reverts if the slippage is too high, indicating a significant price change that might not be favorable to the user.
        if (!slippage) revert("BondingCurve: Slippage too high");

        totalSupply += numTokens;
        balances[msg.sender] += numTokens;

        return cost;
    }

    /// @notice Allows users to sell tokens at the current price, subject to minimum revenue limit
    /// @param numTokens Number of tokens to be sold
    /// @param minRevenue Minimum revenue expected from the sale
    /// @return The revenue received from selling the tokens
    /// Users can sell tokens back to the contract at the current price, with a check to ensure they receive at least their minimum expected revenue.
    function sellToken(uint256 numTokens, uint256 minRevenue) public returns (uint256) {
        // Reverts if the user does not have enough tokens to sell.
        if (balances[msg.sender] < numTokens) revert("BondingCurve: Not enough tokens.");

        uint256 revenue = calculatePrice(numTokens);
        // Reverts if the revenue from selling the tokens is less than the user's minimum expected revenue.
        if (revenue < minRevenue) revert("BondingCurve: Revenue less than minRevenue");

        // Reverts if the slippage is too high when selling, which protects the user from unfavorable price changes.
        if (!validateSlippage(revenue, minRevenue)) revert("BondingCurve: Slippage too high");

        totalSupply -= numTokens;
        balances[msg.sender] -= numTokens;

        payable(msg.sender).call{value: revenue};

        return revenue;
    }

    /// @notice Calculates the price for a given number of tokens
    /// @param numTokens Number of tokens for which the price is to be calculated
    /// @return Price for the specified number of tokens
    /// This function calculates the price for a given number of tokens based on the initial price and the total supply, reflecting the linear bonding curve.
    function calculatePrice(uint256 numTokens) public view returns (uint256) {
        return (INITIAL_PRICE + PRICE_INCREMENT * totalSupply) * numTokens;
    }

    /// @notice Validates whether the slippage is within the acceptable range
    /// @param actualValue Actual value or price of the transaction
    /// @param expectedValue Expected value or price of the transaction
    /// @return True if the slippage is within the acceptable range, false otherwise
    /// This function calculates the slippage percentage and returns true if it's within the allowed threshold, helping prevent large, unexpected price movements.
    function validateSlippage(uint256 actualValue, uint256 expectedValue) private pure returns (bool) {
        uint256 slippage = (actualValue > expectedValue) ?
            ((actualValue - expectedValue) * 100) / expectedValue :
            ((expectedValue - actualValue) * 100) / expectedValue;

        return slippage <= MAX_SLIPPAGE;
    }
}
