// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


import {IERC20} from  "@openzeppelin-contracts@5.0.0/token/ERC20/IERC20.sol";

/// @title Marco's cool fee on transfer token
/// @notice This contract delegates transfer calls to another ERC20 token while maintaining ERC20 interface
contract FeeOnTransferToken {
    uint256 private constant BASIS_POINTS_DENOMINATOR = 100;
    address public feeRecipientAddress; // Address to receive the fee
    IERC20 public delegateToken;

    /// @notice Creates a new Fot token
    /// @param _delegateTokenAddress The ERC20 token address to delegate transfers to
    /// @param _feeRecipientAddress The address to receive the fee
    /// @param _transferFeePercentage The transfer fee percentage
    constructor(
        address _delegateTokenAddress,
        address _feeRecipientAddress,
        uint256 _transferFeePercentage
    )  {
        require(_delegateTokenAddress != address(0), "FeeOnTransferToken: Delegate token cannot be the zero address");
        require(_feeRecipientAddress != address(0), "FeeOnTransferToken: Fee recipient cannot be the zero address");

        delegateToken = IERC20(_delegateTokenAddress);
        feeRecipientAddress = _feeRecipientAddress;
        transferFeePercentage = _transferFeePercentage;
    }

    uint256 public transferFeePercentage;

    /// @notice Delegate transfer to another ERC20 token with fee
    /// @param _recipient The address receiving the tokens
    /// @param _amount The amount of tokens being transferred
    /// @return success True if the transfer was successful
    function transfer(address _recipient, uint256 _amount) public returns (bool success) {
        uint256 fee = (_amount * transferFeePercentage) / BASIS_POINTS_DENOMINATOR;
        uint256 amountAfterFee = _amount - fee;

        delegateToken.transfer(_recipient, amountAfterFee);
        delegateToken.transfer(feeRecipientAddress, fee);

        return true;
    }

    /// @notice Delegate transferFrom to another ERC20 token with fee
    /// @param _sender The address sending the tokens
    /// @param _recipient The address receiving the tokens
    /// @param _amount The amount of tokens being transferred
    /// @return success True if the transfer was successful
    function transferFrom(address _sender, address _recipient, uint256 _amount) public returns (bool success) {
        uint256 fee = (_amount * transferFeePercentage) / BASIS_POINTS_DENOMINATOR;
        uint256 amountAfterFee = _amount - fee;

        delegateToken.transferFrom(_sender, _recipient, amountAfterFee);
        delegateToken.transferFrom(_sender, feeRecipientAddress, fee);

        return true;
    }

    /// @notice Gets the total supply of the delegated token
    /// @return The total supply of the delegated token
    function totalSupply() public view returns (uint256) {
        return delegateToken.totalSupply();
    }

    /// @notice Get the balance of an account
    /// @param account The address of the token holder
    /// @return The balance of the account
    function balanceOf(address account) public view returns (uint256) {
        return delegateToken.balanceOf(account);
    }


}
