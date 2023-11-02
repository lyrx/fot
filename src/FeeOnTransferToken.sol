// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from  "@openzeppelin-contracts@5.0.0/token/ERC20/ERC20.sol";

/// @title Marco's cool fee on transfer token
/// @author Alexander Weinmann
/// @notice This contract implements a token with a transfer fee
/// @dev Inherits from OpenZeppelin's ERC20 contract
contract FeeOnTransferToken is ERC20 {
    uint256 private constant BASIS_POINTS_DENOMINATOR = 100;
    uint256 private constant DEFAULT_TRANSFER_FEE_PERCENTAGE = 1; // 1% fee
    uint256 public transferFeePercentage;
    address public feeRecipientAddress; // Address to receive the fee

    /// @notice Creates a new Fot token
    /// @param _initialSupply The initial supply of tokens
    /// @param _feeRecipientAddress The address to receive the fee
    /// @param _transferFeePercentage The transfer fee percentage
    /// @dev The constructor sets the initial supply, fee recipient address, and transfer fee percentage
    constructor(uint256 _initialSupply, address _feeRecipientAddress, uint256 _transferFeePercentage) ERC20("Marco's cool fee on transfer token", "FOT") {
        require(_feeRecipientAddress != address(0), "FeeOnTransferToken: Fee recipient cannot be the zero address");
        _mint(msg.sender, _initialSupply);
        feeRecipientAddress = _feeRecipientAddress; // Set the fee recipient address
        transferFeePercentage = _transferFeePercentage == 0 ? DEFAULT_TRANSFER_FEE_PERCENTAGE : _transferFeePercentage; // Set the transfer fee percentage
    }

    /// @notice Transfer tokens with fee
    /// @param _recipient The address receiving the tokens
    /// @param _amount The amount of tokens being transferred
    /// @return success True if the transfer was successful
    function transfer(address _recipient, uint256 _amount) public override returns (bool success) {
        require(_amount > 0, "FeeOnTransferToken: Transfer amount must be greater than zero");
        uint256 fee = (_amount * transferFeePercentage) / BASIS_POINTS_DENOMINATOR;
        uint256 amountAfterFee = _amount - fee;
        super.transfer(_recipient, amountAfterFee);
        super.transfer(feeRecipientAddress, fee);
        return true;
    }

    /// @notice Transfer tokens from one address to another with fee
    /// @param _sender The address sending the tokens
    /// @param _recipient The address receiving the tokens
    /// @param _amount The amount of tokens being transferred
    /// @return success True if the transfer was successful
    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool success) {
        require(_amount > 0, "FeeOnTransferToken: Transfer amount must be greater than zero");
        uint256 fee = (_amount * transferFeePercentage) / BASIS_POINTS_DENOMINATOR;
        uint256 amountAfterFee = _amount - fee;
        super.transferFrom(_sender, _recipient, amountAfterFee);
        super.transferFrom(_sender, feeRecipientAddress, fee);
        return true;
    }
}
