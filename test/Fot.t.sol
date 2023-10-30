// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "ds-test/test.sol";
import "../src/Fot.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FotTest is DSTest {
    Fot fot;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        fot = new Fot(1000 * 10 ** 18); // Initial supply of 1000 FOT
        fot.transfer(alice, 500 * 10 ** 18); // Transfer 500 FOT to Alice
    }

    function testInitialSupply() public {
        assertEq(fot.totalSupply(), 1000 * 10 ** 18);
    }

    function testInitialBalances() public {
        assertEq(fot.balanceOf(address(this)), 500 * 10 ** 18);
        assertEq(fot.balanceOf(alice), 500 * 10 ** 18);
    }

    function testTransferWithFee() public {
        uint256 aliceInitialBalance = fot.balanceOf(alice);
        uint256 bobInitialBalance = fot.balanceOf(bob);
        uint256 contractInitialBalance = fot.balanceOf(address(fot));

        uint256 amount = 100 * 10 ** 18;
        uint256 fee = (amount * fot.transferFeePercentage()) / 100;
        uint256 amountAfterFee = amount - fee;

        fot.transferFrom(alice, bob, amount);

        assertEq(fot.balanceOf(alice), aliceInitialBalance - amount);
        assertEq(fot.balanceOf(bob), bobInitialBalance + amountAfterFee);
        assertEq(fot.balanceOf(address(fot)), contractInitialBalance + fee);
    }

    function testFailTransferMoreThanBalance() public {
        uint256 amount = 600 * 10 ** 18; // More than Alice's balance
        fot.transferFrom(alice, bob, amount);
    }
}
