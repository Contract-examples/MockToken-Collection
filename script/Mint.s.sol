// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/USDT.sol";

contract MintUSDTScript is Script {
    // USDT contract address on Arbitrum Sepolia
    address constant USDT_ADDRESS = 0xf821850f4093A471CF12f3A5Ee22Bf3EA582CEb2;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        TetherToken usdt = TetherToken(USDT_ADDRESS);

        // Mint 1,000,000 USDT (remember decimals is 6)
        uint256 mintAmount = 1_000_000 * 10 ** 6;
        usdt.issue(mintAmount);

        // Log balances
        console2.log("Owner balance after mint:", usdt.balanceOf(deployerAddress));
        console2.log("Total supply after mint:", usdt.totalSupply());

        vm.stopBroadcast();
    }
}
