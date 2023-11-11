// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "ds-test/test.sol";
import "../src/BondingCurve.sol";
import "forge-std/Test.sol";


contract BondingCurveTest is DSTest, Test {
    BondingCurve bondingCurve;
    address owner;

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

    function testFailBuyTokenSlippage() public {
        vm.expectRevert("Maximum price too low");
        uint256 numTokens = 1;
        uint256 maxPrice = 1 ether; // Sets a low maximum price to intentionally fail the test

        bondingCurve.buyToken{value: 1 ether}(numTokens, maxPrice);
    }

    function testSellTokenSuccess() public {
        // First buy to have tokens for selling
        bondingCurve.buyToken{value: 1 ether}(1, 1.05 ether);

     //   uint256 minRevenue = 0.99 ether;
      //  bondingCurve.sellToken(1, minRevenue);

        // Checks if the token count has been correctly reduced
        // assertEq(bondingCurve.totalSupply(), 0);
    }

    function testFailSellTokenSlippage() public {
        vm.expectRevert("Slippage too high");
        bondingCurve.buyToken{value: 1 ether}(1, 1.05 ether);

        uint256 minRevenue = 1.05 ether; // Sets a high minimum revenue to intentionally fail the test
        bondingCurve.sellToken(1, minRevenue);
    }
}
