// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@solady/utils/SafeTransferLib.sol";

contract Bank {
    //using SafeERC20 for IERC20;
    using SafeTransferLib for address;

    // unsafe transfer
    function unsafeTransfer(address token, address to, uint256 amount) external {
        // this method is not recommended, because it may fail without error
        // transfer token to bank first
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer to bank failed");
        // then transfer token from bank
        require(IERC20(token).transfer(to, amount), "Transfer from bank failed");
    }

    // safe transfer
    function safeTransfer(address token, address to, uint256 amount) external {
        // use SafeERC20's safeTransfer
        // if transfer fails, it will revert automatically
        // transfer token to bank first
        token.safeTransferFrom(msg.sender, address(this), amount);
        // then transfer token from bank
        token.safeTransfer(to, amount);
    }

    // unsafe transferFrom
    function unsafeTransferFrom(address token, address from, address to, uint256 amount) external {
        // this method is not recommended, because it may fail without error
        require(IERC20(token).transferFrom(from, to, amount), "TransferFrom failed");
    }

    // safe transferFrom
    function safeTransferFrom(address token, address from, address to, uint256 amount) external {
        // use SafeERC20's safeTransferFrom
        token.safeTransferFrom(from, to, amount);
    }

    receive() external payable { }
}
