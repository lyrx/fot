// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "ds-test/test.sol";
import "../src/FeeOnTransferToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/Test.sol";

// Mock DelegateToken to simulate the external ERC20 token interaction
contract MockDelegateToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Delegate Token", "DLGT") {
        _mint(msg.sender, initialSupply);
    }
}

contract FeeOnTransferTokenTest is DSTest, Test {
    FeeOnTransferToken private fot;
    MockDelegateToken private delegateToken;
    address private alice = address(0x1);
    address private bob = address(0x2);
    address private feeRecipient = address(0x3);
    uint256 private constant INITIAL_SUPPLY = 1000 * 10 ** 18;
    uint256 private constant TRANSFER_AMOUNT = 200 * 10 ** 18;
    uint256 private constant DEFAULT_TRANSFER_FEE_PERCENTAGE = 1; // 1% fee

    function setUp() public {
        delegateToken = new MockDelegateToken(INITIAL_SUPPLY); // A larger initial supply for the delegate token
        fot = new FeeOnTransferToken(address(delegateToken), feeRecipient, DEFAULT_TRANSFER_FEE_PERCENTAGE,address(this));

        delegateToken.transfer(address(fot), delegateToken.totalSupply()); // Transfer delegate tokens to FeeOnTransferToken


        IERC20 adelegate = fot.getDelegateToken();
        vm.prank(alice);
        adelegate.approve(address(fot), type(uint256).max);


    }

    function assertInitialBalances() public {


        uint256 actualBalanceAlice = fot.balanceOf(alice);
        uint256 actualBalanceBob = fot.balanceOf(bob);

        // The contract's balance is not relevant here because we are checking Alice and Bob's balances
        assertEq(actualBalanceAlice, 0);
        assertEq(actualBalanceBob, 0);
    }

    function calculateFeeAndAmountAfterFee(uint256 amount) internal pure returns (uint256 amountAfterFee, uint256 fee) {
        fee = (amount * DEFAULT_TRANSFER_FEE_PERCENTAGE) / 100;
        amountAfterFee = amount - fee;
        return (amountAfterFee, fee);
    }

    function testInitialSupply() public {
        assertEq(fot.totalSupply(), INITIAL_SUPPLY);
    }


    function testInitialBalances() public {
        assertInitialBalances();
    }

    function testTransferFromWithFee() public {
        uint256 amount = TRANSFER_AMOUNT;

        fot.transfer(alice, amount);
        fot.transferFrom(alice, bob, amount / 2);
        (uint256 amountAfterFee, ) = calculateFeeAndAmountAfterFee(amount / 2);
        assertEq(fot.balanceOf(bob), amountAfterFee);
    }

    function testTransferWithFee() public {
        uint256 amount = TRANSFER_AMOUNT;

        fot.transfer(alice, amount);
        vm.prank(alice);
        fot.transfer(bob, amount / 2);
        (uint256 amountAfterFee, ) = calculateFeeAndAmountAfterFee(amount / 2);
        assertEq(fot.balanceOf(bob), amountAfterFee);
    }


    function testFailTransferMoreThanBalance() public {
        vm.prank(alice);
        vm.expectRevert();
        fot.transfer(bob, INITIAL_SUPPLY); // This should fail
    }


    function testZeroTransfer() public {
        vm.prank(alice);
        fot.transfer(bob, 0);
    }

    function testZeroTransferFrom() public {

        fot.transferFrom(alice, bob, 0);
    }
}
