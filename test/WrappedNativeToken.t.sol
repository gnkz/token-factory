// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";

import {WrappedNativeToken} from "../src/WrappedNativeToken.sol";

contract WrappedNativeTokenTest is Test {
    WrappedNativeToken wETH;
    address user;

    function setUp() public {
        user = makeAddr("USER");

        wETH = new WrappedNativeToken("Test Wrapped ETH", "twETH");

        deal(user, 1 ether);
    }

    function testUserCanDeposit() public {
        vm.prank(user);

        wETH.deposit{value: 1 ether}();

        vm.assertEq(wETH.balanceOf(user), 1 ether);
        vm.assertEq(wETH.totalSupply(), 1 ether);
        vm.assertEq(address(wETH).balance, 1 ether);
        vm.assertEq(user.balance, 0);
    }

    function testUserCanDepositBySendingEth() public {
        vm.prank(user);

        (bool transferred,) = payable(address(wETH)).call{value: 1 ether}("");

        vm.assertTrue(transferred);
        vm.assertEq(wETH.balanceOf(user), 1 ether);
        vm.assertEq(wETH.totalSupply(), 1 ether);
        vm.assertEq(address(wETH).balance, 1 ether);
        vm.assertEq(user.balance, 0);
    }

    function testUserCanWithdraw() public {
        vm.prank(user);

        wETH.deposit{value: 1 ether}();

        vm.assertEq(wETH.balanceOf(user), 1 ether);
        vm.assertEq(wETH.totalSupply(), 1 ether);
        vm.assertEq(address(wETH).balance, 1 ether);
        vm.assertEq(user.balance, 0);

        vm.prank(user);

        wETH.withdraw(1 ether);

        vm.assertEq(wETH.balanceOf(user), 0);
        vm.assertEq(wETH.totalSupply(), 0);
        vm.assertEq(address(wETH).balance, 0);
        vm.assertEq(user.balance, 1 ether);
    }

    function testUserCanPartiallyWithdraw() public {
        vm.prank(user);

        wETH.deposit{value: 1 ether}();

        vm.assertEq(wETH.balanceOf(user), 1 ether);
        vm.assertEq(wETH.totalSupply(), 1 ether);
        vm.assertEq(address(wETH).balance, 1 ether);
        vm.assertEq(user.balance, 0);

        vm.prank(user);

        wETH.withdraw(0.5 ether);

        vm.assertEq(wETH.balanceOf(user), 0.5 ether);
        vm.assertEq(wETH.totalSupply(), 0.5 ether);
        vm.assertEq(address(wETH).balance, 0.5 ether);
        vm.assertEq(user.balance, 0.5 ether);
    }

    function testUserCanDepositZeroValue() public {
        vm.prank(user);

        wETH.deposit{value: 0}();

        vm.assertEq(wETH.balanceOf(user), 0);
        vm.assertEq(wETH.totalSupply(), 0);
        vm.assertEq(address(wETH).balance, 0);
        vm.assertEq(user.balance, 1 ether);
    }
}
