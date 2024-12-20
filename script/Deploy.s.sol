// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/USDTFactory.sol";
import "../src/USDT.sol";

contract DeployUSDTScript is Script {
    bytes32 constant SALT = bytes32(uint256(0x0000000000000000000000000000000000000000d3bf2663da51c10215000001));

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // first deploy factory
        USDTFactory factory = new USDTFactory();

        // deploy usdt using factory
        address usdt = factory.deploy(SALT, 1_000_000 * 10 ** 6, "FTether", "FUSDT", 6);

        console2.log("Token deployed to:", usdt);
        console2.log("Deployed by:", deployerAddress);
        console2.log("Token owner:", TetherToken(usdt).owner());

        vm.stopBroadcast();
    }
}
