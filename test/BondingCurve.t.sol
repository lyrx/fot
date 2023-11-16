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

        uint256 numTokens = 4;
        uint256 maxPrice = 1.05 ether;
        vm.expectRevert("BondingCurve: Not enough Ether sent.");
        bondingCurve.buyToken{value: 0.5 ether}(numTokens, maxPrice);
    }

    function testFailBuyTokenSlippage() public {
        vm.expectRevert("BondingCurve: Slippage too high");
        uint256 numTokens = 1;
        uint256 maxPrice = 1 ether;

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
        // vm.expectRevert("BondingCurve: Not enough tokens.");
        bondingCurve.sellToken(1, minRevenue);
    }

    function testFailSellTokenSlippage() public {
        bondingCurve.buyToken{value: 1.05 ether}(1, 1.05 ether);

        uint256 minRevenue = 1.15 ether;
        vm.expectRevert("BondingCurve: Slippage too high");
        bondingCurve.sellToken(1, minRevenue);
    }

    function testCalculatePrice() public {
        uint256 price = bondingCurve.calculatePrice(1);
        assertEq(price, 1 ether);
    }
}
