// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ERC20Token} from "../src/ERC20Token.sol";
import {WrappedNativeToken} from "../src/WrappedNativeToken.sol";

contract TokensScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        new ERC20Token("Dummy USD", "dUSD", 1_000_000_000_000 ether, msg.sender, msg.sender);
        new WrappedNativeToken("Wrapped ETH", "wETH");

        vm.stopBroadcast();
    }
}
