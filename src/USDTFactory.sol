// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./USDT.sol";

contract USDTFactory {
    function deploy(
        bytes32 salt,
        uint256 initialSupply,
        string memory name,
        string memory symbol,
        uint256 decimals
    )
        external
        returns (address)
    {
        // deploy new usdt contract
        TetherToken usdt = new TetherToken{ salt: salt }(initialSupply, name, symbol, decimals);

        // transfer ownership to caller
        usdt.transferOwnership(msg.sender);

        return address(usdt);
    }
}
