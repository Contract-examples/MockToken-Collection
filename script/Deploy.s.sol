// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/USDT.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

contract DeployUSDTScript is Script {
    bytes32 constant SALT = bytes32(uint256(0x0000000000000000000000000000000000000000d3bf2663da51c10215000003));

    function run() public {
        // TODO: encrypt your private key
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        TetherToken usdt = new TetherToken{ salt: SALT }(
            1_000_000 * 10 ** 6, // usdt's decimals is 6
            "FTether",
            "FUSDT",
            6 // decimals is 6
        );
        console2.log("Bank deployed to:", address(usdt));

        console2.log("Deployed by:", deployerAddress);

        vm.stopBroadcast();
    }

    // The contract can receive ether to enable `payable` constructor calls if needed.
    receive() external payable { }
}
