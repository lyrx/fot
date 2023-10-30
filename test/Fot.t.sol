// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "ds-test/test.sol";
import "../src/Fot.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/Test.sol";

contract FotTest is DSTest, Test {
    Fot fot;
    address alice = address(0x1);
    address bob = address(0x2);
    uint256 constant INITIAL_SUPPLY = 1000 * 10 ** 18;
    uint256 constant TRANSFER_AMOUNT = 200 * 10 ** 18;

    function setUp() public {
        fot = new Fot(INITIAL_SUPPLY);
        fot.transfer(alice, TRANSFER_AMOUNT);
        fot.transfer(bob, TRANSFER_AMOUNT);

        vm.prank(alice);
        fot.approve(address(this), type(uint256).max);
    }

    function testInitialSupply() public {
        assertEq(fot.totalSupply(), INITIAL_SUPPLY);
    }

    function testInitialBalances() public {

        uint256 fee = (TRANSFER_AMOUNT * fot.transferFeePercentage()) / 100;
        uint256 amountAfterFee = TRANSFER_AMOUNT - fee;

        uint256 actualBalanceThis = fot.balanceOf(address(this));
        uint256 actualBalanceAlice = fot.balanceOf(alice);
        uint256 actualBalanceBob = fot.balanceOf(bob);

        assertEq(actualBalanceThis, INITIAL_SUPPLY - 2 * TRANSFER_AMOUNT);
        assertEq(actualBalanceAlice, amountAfterFee);
        assertEq(actualBalanceBob, amountAfterFee);
    }

    function testTransferWithFee() public {
        uint256 aliceInitialBalance = fot.balanceOf(alice);
        uint256 bobInitialBalance = fot.balanceOf(bob);
        uint256 contractInitialBalance = fot.balanceOf(address(fot));

        uint256 amount = TRANSFER_AMOUNT / 2;
        uint256 fee = (amount * fot.transferFeePercentage()) / 100;
        uint256 amountAfterFee = amount - fee;

        fot.transferFrom(alice, bob, amount);

        assertEq(fot.balanceOf(alice), aliceInitialBalance - amount);
        assertEq(fot.balanceOf(bob), bobInitialBalance + amountAfterFee);
        assertEq(fot.balanceOf(address(fot)), contractInitialBalance + fee);
    }

    function testFailTransferMoreThanBalance() public {
        uint256 amount = INITIAL_SUPPLY; // More than Alice's balance
        fot.transferFrom(alice, bob, amount);
    }
}
