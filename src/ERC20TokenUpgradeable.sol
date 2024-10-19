// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ERC20PermitUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ERC20TokenUpgradeable is UUPSUpgradeable, ERC20PermitUpgradeable, OwnableUpgradeable {
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _supplyReceiver,
        address _owner
    ) external onlyInitializing {
        __UUPSUpgradeable_init();
        __ERC20_init(_name, _symbol);
        __ERC20Permit_init(_name);
        __Ownable_init(_owner);

        _mint(_supplyReceiver, _initialSupply);
    }

    function _authorizeUpgrade(address _newImplementation) internal override onlyOwner {}
}
