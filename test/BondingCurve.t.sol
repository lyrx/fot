// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "ds-test/test.sol";
import "../src/BondingCurve.sol";
import "forge-std/Test.sol";

contract BondingCurveTest is DSTest, Test {
    BondingCurve bondingCurve;
    address owner;
    address private constant ALICE = address(0x9);

    function setUp() public {
        owner = address(this); // Sets the test contract as the owner
        bondingCurve = new BondingCurve(owner);
    }

    function testBuyTokenSuccess() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 1.05 ether;
        // Simulates sending Ether to the contract and calls buyToken
        bondingCurve.buyToken{value: 1 ether}(numTokens, maxPrice);
        // Checks if the token count has been correctly increased
        assertEq(bondingCurve.totalSupply(), numTokens);
    }

    function testFailBuyTokenNotEnoughEther() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 1.05 ether;
        bondingCurve.buyToken{value: 0.5 ether}(numTokens, maxPrice);
    }

    function testFailBuyTokenExceedsMaxPrice() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 0.5 ether;
        bondingCurve.buyToken{value: 0.5 ether}(numTokens, maxPrice);
    }
    function testFailBuyTokenLowerThanMaxPrice() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 2 ether;
        bondingCurve.buyToken{value: 2 ether}(numTokens, maxPrice);
    }

    function testFailBuyTokenSlippageTooHigh() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 1.1 ether;
        bondingCurve.buyToken{value: 1.05 ether}(numTokens, maxPrice);
    }
    function testFailBuyTokenSlippageTooLow() public {
        uint256 numTokens = 1;
        uint256 maxPrice = 0.5 ether;
        bondingCurve.buyToken{value: 1.05 ether}(numTokens, maxPrice);
    }

    function testSellTokenSuccess() public {
        bondingCurve.buyToken{value: 1.05 ether}(1, 1.05 ether);
        uint256 minRevenue = 0.99 ether;
        bondingCurve.sellToken(1, minRevenue);
        // Checks if the token count has been correctly reduced
        assertEq(bondingCurve.totalSupply(), 0);
    }

    function testFailSellTokenNotEnoughTokens() public {
        uint256 minRevenue = 0.99 ether;
        vm.prank(ALICE);
        bondingCurve.sellToken(1, minRevenue);
    }

    function testFailSellTokenNotEnoughRevenue() public {
        bondingCurve.buyToken{value: 1 ether}(1, 1 ether);
        bondingCurve.sellToken(1, 1.1 ether);
    }

    function testFailSellTokenSlippageTooHigh() public {
        bondingCurve.buyToken{value: 1.05 ether}(1, 1.05 ether);
        bondingCurve.sellToken(1, 1.15 ether);
    }

    function testFailSellTokenSlippageTooLow() public {
        bondingCurve.buyToken{value: 1.05 ether}(1, 1.05 ether);
        bondingCurve.sellToken(1, 0.15 ether);
    }

    function testCalculatePrice() public {
        uint256 price = bondingCurve.calculatePrice(1);
        assertEq(price, 1 ether);
    }
}
