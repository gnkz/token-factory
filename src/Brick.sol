// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Brick is UUPSUpgradeable {
    function _authorizeUpgrade(address) internal virtual override {
        revert("Bricked");
    }
}
