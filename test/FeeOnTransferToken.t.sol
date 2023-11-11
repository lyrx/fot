// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "ds-test/test.sol";
import "../src/FeeOnTransferToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/Test.sol";

/// @title Mock DelegateToken to simulate the external ERC20 token interaction
contract MockDelegateToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Delegate Token", "DLGT") {
        _mint(msg.sender, initialSupply);
    }
}

/// @title Tests for the FeeOnTransferToken contract
contract FeeOnTransferTokenTest is DSTest, Test {
    FeeOnTransferToken private _fot;
    MockDelegateToken private _delegateToken;

    address private constant ALICE = address(0x1);
    address private constant BOB = address(0x2);
    address private constant FEE_RECIPIENT = address(0x3);

    uint256 private constant INITIAL_SUPPLY = 1000 * 10 ** 18;
    uint256 private constant TRANSFER_AMOUNT = 200 * 10 ** 18;
    uint256 private constant DEFAULT_TRANSFER_FEE_PERCENTAGE = 1; // 1% fee

    /// @notice Sets up the test environment
    function setUp() public {
        _delegateToken = new MockDelegateToken(INITIAL_SUPPLY);
        _fot = new FeeOnTransferToken(
            address(_delegateToken),
            FEE_RECIPIENT,
            DEFAULT_TRANSFER_FEE_PERCENTAGE,
            address(this)
        );

        _delegateToken.transfer(address(_fot), _delegateToken.totalSupply());

        IERC20(_delegateToken).approve(address(_fot), type(uint256).max);
    }

    /// @notice Asserts initial balances of Alice and Bob
    function assertInitialBalances() public {
        uint256 actualBalanceAlice = _fot.balanceOf(ALICE);
        uint256 actualBalanceBob = _fot.balanceOf(BOB);

        assertEq(actualBalanceAlice, 0, "Alice's initial balance should be 0");
        assertEq(actualBalanceBob, 0, "Bob's initial balance should be 0");
    }

    /// @notice Calculates fee and amount after applying the fee
    function calculateFeeAndAmountAfterFee(uint256 amount) internal pure returns (uint256 amountAfterFee, uint256 fee) {
        fee = (amount * DEFAULT_TRANSFER_FEE_PERCENTAGE) / 100;
        amountAfterFee = amount - fee;
        return (amountAfterFee, fee);
    }

    /// @notice Tests the total supply of the token
    function testInitialSupply() public {
        assertEq(_fot.totalSupply(), INITIAL_SUPPLY, "Total supply should match initial supply");
    }

    /// @notice Tests initial balances of Alice and Bob
    function testInitialBalances() public {
        assertInitialBalances();
    }

    /// @notice Tests transfer from Alice to Bob with fee
    function testTransferFromWithFee() public {
        uint256 amount = TRANSFER_AMOUNT;
        _fot.transfer(ALICE, amount);
        uint256 transferAmount = amount / 2;
        vm.prank(ALICE);
        _delegateToken.approve(address(_fot), transferAmount);
        _fot.transferFrom(ALICE, BOB, transferAmount);

        (uint256 amountAfterFee,) = calculateFeeAndAmountAfterFee(transferAmount);
        assertEq(_fot.balanceOf(BOB), amountAfterFee, "Bob's balance should equal amount after fee");
    }

    /// @notice Tests transfer with fee
    function testTransferWithFee() public {
        uint256 amount = TRANSFER_AMOUNT;

        _fot.transfer(ALICE, amount);
        _fot.transfer(BOB, amount / 2);
        (uint256 amountAfterFee,) = calculateFeeAndAmountAfterFee(amount / 2);
        assertEq(_fot.balanceOf(BOB), amountAfterFee, "Bob's balance should equal amount after fee");
    }

    /// @notice Tests failure on attempting to transfer more than balance
    function testFailTransferMoreThanBalance() public {
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        _fot.transfer(BOB, INITIAL_SUPPLY);
    }

    /// @notice Tests transfer of zero tokens
    function testZeroTransfer() public {
        _fot.transfer(BOB, 0);
    }

    /// @notice Tests transfer from Alice to Bob of zero tokens
    function testZeroTransferFrom() public {
        _fot.transferFrom(ALICE, BOB, 0);
    }

    /// @notice Tests getDelegateToken
   function testGetDelegateToken() public {
       IERC20  r = _fot.getDelegateToken();

       assertEq(address(r),address(_delegateToken) );
    }
}
