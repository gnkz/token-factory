// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Token is ERC20 {
    constructor(string memory _name, string memory _symbol, uint256 _supply, address _supplyReceiver)
        ERC20(_name, _symbol)
    {
        _mint(_supplyReceiver, _supply);
    }
}
