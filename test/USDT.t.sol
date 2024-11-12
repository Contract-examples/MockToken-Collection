// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Bank.sol";
import "../src/USDT.sol";

contract USDTTest is Test {
    Bank public bank;
    TetherToken public usdt;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        usdt = new TetherToken(1_000_000 * 10 ** 6, "Tether USD", "USDT", 6);

        bank = new Bank();

        vm.prank(address(this)); // owner
        usdt.transfer(alice, 1000 * 10 ** 6); // 1000 USDT
    }

    function testUnsafeTransfer() public {
        uint256 aliceInitialBalance = usdt.balanceOf(alice);
        uint256 bobInitialBalance = usdt.balanceOf(bob);

        vm.startPrank(alice);

        // approve bank
        usdt.approve(address(bank), type(uint256).max);

        // try to transfer more than balance
        // USDT will revert when transfer fails
        vm.expectRevert(); // expect revert
        bank.unsafeTransfer(address(usdt), bob, 2000 * 10 ** 6); // try to transfer 2000 USDT

        vm.stopPrank();

        // check balance - should not change
        assertEq(usdt.balanceOf(bob), bobInitialBalance, "Bob's balance should not change");
        assertEq(usdt.balanceOf(alice), aliceInitialBalance, "Alice's balance should not change");
    }

    function testSafeTransferFail() public {
        vm.startPrank(alice);

        usdt.approve(address(bank), type(uint256).max);

        // try to transfer more than balance
        // USDT will revert when transfer fails
        vm.expectRevert(); // expect revert
        bank.safeTransfer(address(usdt), bob, 2000 * 10 ** 6);

        vm.stopPrank();
    }

    function testSafeTransferSuccess() public {
        uint256 aliceInitialBalance = usdt.balanceOf(alice);
        uint256 bobInitialBalance = usdt.balanceOf(bob);

        vm.startPrank(alice);

        // approve bank
        usdt.approve(address(bank), type(uint256).max);

        // transfer 100 USDT to bob
        bank.safeTransfer(address(usdt), bob, 100 * 10 ** 6);

        vm.stopPrank();

        // check balance
        assertEq(usdt.balanceOf(bob), bobInitialBalance + 100 * 10 ** 6, "Bob's balance should increase by 100 USDT");
        assertEq(
            usdt.balanceOf(alice), aliceInitialBalance - 100 * 10 ** 6, "Alice's balance should decrease by 100 USDT"
        );
    }

    // add helper function to check current state
    function testInitialSetup() public {
        console.log("Owner balance:", usdt.balanceOf(address(this)));
        console.log("Alice balance:", usdt.balanceOf(alice));
        console.log("Bob balance:", usdt.balanceOf(bob));

        assertEq(usdt.balanceOf(alice), 1000 * 10 ** 6, "Alice should have 1000 USDT");
        assertEq(usdt.balanceOf(bob), 0, "Bob should have 0 USDT");
    }

    receive() external payable { }
}
