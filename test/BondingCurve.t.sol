// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "ds-test/test.sol";
import "../src/BondingCurve.sol";
import "forge-std/Test.sol";

/// @title Tests for the BondingCurve contract
/// @notice This suite of tests ensures the correct functioning of the BondingCurve contract
contract BondingCurveTest is DSTest, Test {
    BondingCurve bondingCurve;
    address owner;
    address private constant ALICE = address(0x9); // A test address for simulating external interactions

    function setUp() public {
        owner = address(this); // Sets the test contract itself as the owner of the BondingCurve contract
        bondingCurve = new BondingCurve(owner); // Creates a new instance of BondingCurve for testing
    }

    /// Test successful token purchase
    function testBuyTokenSuccess() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 1.05 ether;
        // Simulates sending Ether to the contract and calls buyToken
        bondingCurve.buyToken{value: 1 ether}(numTokens, maxPrice);
        // Asserts if the totalSupply of the bondingCurve has correctly increased by the number of tokens bought
        assertEq(bondingCurve.totalSupply(), numTokens);
    }

    /// Test token purchase failure due to insufficient Ether sent
    function testFailBuyTokenNotEnoughEther() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 1.05 ether;
        // Should fail because the Ether sent is less than the cost of numTokens
        bondingCurve.buyToken{value: 0.5 ether}(numTokens, maxPrice);
    }

    /// Test token purchase failure when the market price exceeds user's max price
    function testFailBuyTokenExceedsMaxPrice() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 0.5 ether;
        // Should fail because the market price is higher than the maxPrice specified by the user
        bondingCurve.buyToken{value: 0.5 ether}(numTokens, maxPrice);
    }

    /// Test token purchase failure due to slippage being too high
    function testFailBuyTokenSlippageTooHigh() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 1.1 ether;
        // Should fail because the slippage exceeds the maximum allowed
        bondingCurve.buyToken{value: 1.05 ether}(numTokens, maxPrice);
    }

    /// Test successful token sale
    function testSellTokenSuccess() public {
        // First buy a token to sell
        bondingCurve.buyToken{value: 1.05 ether}(1, 1.05 ether);
        uint256 minRevenue = 0.99 ether;
        // Sell the token
        bondingCurve.sellToken(1, minRevenue);
        // Asserts if the totalSupply of the bondingCurve has correctly reduced to 0
        assertEq(bondingCurve.totalSupply(), 0);
    }

    /// Test token sale failure due to insufficient token balance
    function testFailSellTokenNotEnoughTokens() public {
        uint256 minRevenue = 0.99 ether;
        // Alice attempts to sell a token she does not own, should fail
        vm.prank(ALICE);
        bondingCurve.sellToken(1, minRevenue);
    }

    /// Test token sale failure due to revenue being less than minimum expected
    function testFailSellTokenNotEnoughRevenue() public {
        // First buy a token to sell
        bondingCurve.buyToken{value: 1 ether}(1, 1 ether);
        // Attempt to sell the token for more than its worth, should fail
        bondingCurve.sellToken(1, 1.1 ether);
    }

    /// Test token sale failure due to slippage being too high
    function testFailSellTokenSlippageTooHigh() public {
        // First buy a token to sell
        bondingCurve.buyToken{value: 1.05 ether}(1, 1.05 ether);
        // Attempt to sell the token with a minimum revenue that causes too high slippage, should fail
        bondingCurve.sellToken(1, 1.15 ether);
    }

    /// Test correct calculation of token price
    function testCalculatePrice() public {
        // Check the price calculation for 1 token
        uint256 price = bondingCurve.calculatePrice(1);
        // Asserts that the price of 1 token is equal to 1 ether
        assertEq(price, 1 ether);
    }
}
