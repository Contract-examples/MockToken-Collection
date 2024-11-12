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
    function testInitialSetup() public view {
        console.log("Owner balance:", usdt.balanceOf(address(this)));
        console.log("Alice balance:", usdt.balanceOf(alice));
        console.log("Bob balance:", usdt.balanceOf(bob));

        assert(usdt.balanceOf(alice) == 1000 * 10 ** 6);
        assert(usdt.balanceOf(bob) == 0);
    }

    function testBlackList() public {
        vm.startPrank(address(this)); // owner
        usdt.transfer(alice, 1000 * 10 ** 6);
        usdt.transfer(bob, 500 * 10 ** 6);
        vm.stopPrank();

        // check initial blacklist status
        assertFalse(usdt.getBlackListStatus(alice));
        assertFalse(usdt.getBlackListStatus(bob));

        // test non-owner cannot add blacklist
        vm.startPrank(alice);
        vm.expectRevert();
        usdt.addBlackList(bob);
        vm.stopPrank();

        // owner add alice to blacklist
        vm.startPrank(address(this));
        usdt.addBlackList(alice);
        vm.stopPrank();

        // check alice is in blacklist
        assertTrue(usdt.getBlackListStatus(alice));

        // check alice cannot transfer
        uint256 aliceBalance = usdt.balanceOf(alice);
        vm.startPrank(alice);
        vm.expectRevert();
        usdt.transfer(bob, 100 * 10 ** 6);
        vm.stopPrank();

        // check balance not changed
        assertEq(usdt.balanceOf(alice), aliceBalance);

        // destroy alice's funds
        vm.startPrank(address(this));
        uint256 totalSupplyBefore = usdt.totalSupply();
        uint256 aliceFunds = usdt.balanceOf(alice);

        usdt.destroyBlackFunds(alice);

        // check alice's funds are destroyed
        assertEq(usdt.balanceOf(alice), 0);
        assertEq(usdt.totalSupply(), totalSupplyBefore - aliceFunds);
        vm.stopPrank();

        // remove alice from blacklist
        vm.startPrank(address(this));
        usdt.removeBlackList(alice);
        vm.stopPrank();

        // check alice is removed from blacklist
        assertFalse(usdt.getBlackListStatus(alice));

        // check alice can receive again
        vm.startPrank(address(this));
        usdt.transfer(alice, 100 * 10 ** 6);
        vm.stopPrank();

        // alice can transfer now
        vm.startPrank(alice);
        usdt.transfer(bob, 50 * 10 ** 6);
        vm.stopPrank();

        // check transfer success
        assertEq(usdt.balanceOf(alice), 50 * 10 ** 6);
        assertEq(usdt.balanceOf(bob), 550 * 10 ** 6);
    }

    function testBlackListOnlyOwner() public {
        vm.startPrank(alice);

        // test non-owner cannot add blacklist
        vm.expectRevert();
        usdt.addBlackList(bob);

        // test non-owner cannot remove blacklist
        vm.expectRevert();
        usdt.removeBlackList(bob);

        // test non-owner cannot destroy funds
        vm.expectRevert();
        usdt.destroyBlackFunds(bob);

        vm.stopPrank();
    }

    function testDestroyNonBlacklistedFunds() public {
        vm.startPrank(address(this));

        // try to destroy non-blacklisted funds
        vm.expectRevert();
        usdt.destroyBlackFunds(alice);

        vm.stopPrank();
    }

    receive() external payable { }
}
