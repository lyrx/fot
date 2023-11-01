// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


import {ERC20} from  "@openzeppelin-contracts@5.0.0/token/ERC20/ERC20.sol";

/// @title Marco's cool fee on transfer token
/// @author Alexander Weinmann
/// @notice This contract implements a token with a transfer fee
/// @dev Inherits from OpenZeppelin's ERC20 contract
contract Fot is ERC20 {
    uint256 private constant BASIS_POINTS_DENOMINATOR = 100;
    uint256 public transferFeePercentage = 1; // 1% fee
    address public feeRecipient; // Address to receive the fee

    /// @notice Creates a new Fot token
    /// @param initialSupply The initial supply of tokens
    /// @param _feeRecipient The address to receive the fee
    /// @dev The constructor sets the initial supply and fee recipient address
    constructor(uint256 initialSupply, address _feeRecipient) ERC20("Marco's cool fee on transfer token", "FOT") {
        require(_feeRecipient != address(0), "Fot: Fee recipient cannot be the zero address");
        _mint(msg.sender, initialSupply);
        feeRecipient = _feeRecipient; // Set the fee recipient address
    }

    /// @notice Transfer tokens with fee
    /// @param recipient The address receiving the tokens
    /// @param amount The amount of tokens being transferred
    /// @return success True if the transfer was successful
    function transfer(address recipient, uint256 amount) public override returns (bool success) {
        uint256 fee = (amount * transferFeePercentage) / BASIS_POINTS_DENOMINATOR;
        uint256 amountAfterFee = amount - fee;
        super.transfer(recipient, amountAfterFee);
        super.transfer(feeRecipient, fee);
        return true;
    }

    /// @notice Transfer tokens from one address to another with fee
    /// @param sender The address sending the tokens
    /// @param recipient The address receiving the tokens
    /// @param amount The amount of tokens being transferred
    /// @return success True if the transfer was successful
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool success) {
        uint256 fee = (amount * transferFeePercentage) / BASIS_POINTS_DENOMINATOR;
        uint256 amountAfterFee = amount - fee;
        super.transferFrom(sender, recipient, amountAfterFee);
        super.transferFrom(sender, feeRecipient, fee);
        return true;
    }
}
