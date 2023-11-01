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
    address feeRecipient = address(0x3);
    address nullAddress = address(0x0);
    uint256 constant INITIAL_SUPPLY = 1000 * 10 ** 18;
    uint256 constant TRANSFER_AMOUNT = 200 * 10 ** 18;

    function setUp() public {
        fot = new Fot(INITIAL_SUPPLY, feeRecipient); // Include fee recipient in constructor
        fot.transfer(alice, TRANSFER_AMOUNT);
        fot.transfer(bob, TRANSFER_AMOUNT);
        vm.prank(alice);
        fot.approve(address(this), type(uint256).max);
    }

    function testInitialSupply() public {
        assertEq(fot.totalSupply(), INITIAL_SUPPLY);
    }

    function assertInitialBalances() public {
        (uint256 amountAfterFee,) = calculateFeeAndAmountAfterFee(TRANSFER_AMOUNT);

        uint256 actualBalanceThis = fot.balanceOf(address(this));
        uint256 actualBalanceAlice = fot.balanceOf(alice);
        uint256 actualBalanceBob = fot.balanceOf(bob);

        assertEq(actualBalanceThis, INITIAL_SUPPLY - 2 * TRANSFER_AMOUNT);
        assertEq(actualBalanceAlice, amountAfterFee);
        assertEq(actualBalanceBob, amountAfterFee);
    }

    function testInitialBalances() public {
        assertInitialBalances();
    }

    function testTransferFromWithFee() public {
        testTransferWithFeeInternal(alice, bob, TRANSFER_AMOUNT / 2,true);
    }

    function testTransferWithFee() public {

        testTransferWithFeeInternal(alice, bob, TRANSFER_AMOUNT / 2,false);
    }

    function testTransferWithFeeInternal(address from, address to, uint256 amount, bool useFrom) internal {
        uint256 initialBalanceFrom = fot.balanceOf(from);
        uint256 initialBalanceTo = fot.balanceOf(to);
        uint256 initialBalanceFeeRecipient = fot.balanceOf(feeRecipient);

        (uint256 amountAfterFee, uint256 fee) = calculateFeeAndAmountAfterFee(amount);

        if(useFrom){
            fot.transferFrom(from, to, amount);
        }
        else {
            vm.prank(from);
            fot.transfer(to, amount);
        }


        assertEq(fot.balanceOf(from), initialBalanceFrom - amount);
        assertEq(fot.balanceOf(to), initialBalanceTo + amountAfterFee);
        assertEq(fot.balanceOf(feeRecipient), initialBalanceFeeRecipient + fee);
    }

    function calculateFeeAndAmountAfterFee(uint256 amount) internal view returns (uint256 amountAfterFee, uint256 fee) {
        fee = (amount * fot.transferFeePercentage()) / 100;
        amountAfterFee = amount - fee;
        return (amountAfterFee, fee);
    }

    function testFailTransferMoreThanBalance() public {
        fot.transferFrom(alice, bob, INITIAL_SUPPLY);
        assertInitialBalances();
    }

    function testNullAddress() public {
        vm.expectRevert();
        fot.transferFrom(nullAddress, nullAddress, INITIAL_SUPPLY);
    }
}
