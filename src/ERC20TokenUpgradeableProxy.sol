// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC20TokenUpgradeable} from "./ERC20TokenUpgradeable.sol";
import {Brick} from "./Brick.sol";

contract ERC20TokenUpgradeableProxy is Proxy, Initializable {
    constructor() {
        ERC1967Utils.upgradeToAndCall(address(new Brick()), "");
    }

    function initialize(
        address _impl,
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _supplyOwner,
        address _owner
    ) public initializer {
        ERC1967Utils.upgradeToAndCall(
            _impl,
            abi.encodeWithSelector(
                ERC20TokenUpgradeable.initialize.selector, _name, _symbol, _initialSupply, _supplyOwner, _owner
            )
        );
    }

    function _implementation() internal view virtual override returns (address) {
        return ERC1967Utils.getImplementation();
    }

    receive() external payable {}
}
