// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";

import {ERC20TokenUpgradeable} from "../src/ERC20TokenUpgradeable.sol";
import {ERC20TokenUpgradeableProxy} from "../src/ERC20TokenUpgradeableProxy.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {WrappedNativeToken} from "../src/WrappedNativeToken.sol";

contract DeployFactory is Script {
    function run() external {
        vm.startBroadcast();

        ERC20TokenUpgradeableProxy proxy = new ERC20TokenUpgradeableProxy();
        ERC20TokenUpgradeable token = new ERC20TokenUpgradeable();

        new TokenFactory(address(proxy), address(token));

        vm.stopBroadcast();
    }
}
