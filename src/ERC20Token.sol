// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Token is ERC20, Ownable {
    constructor(string memory _name, string memory _symbol, uint256 _supply, address _supplyReceiver, address _owner)
        Ownable(_owner)
        ERC20(_name, _symbol)
    {
        _mint(_supplyReceiver, _supply);
    }
}
