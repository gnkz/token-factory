// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract WrappedNativeToken is ERC20Permit {
    event Deposit(address indexed _sender, uint256 _amount);
    event Withdrawal(address indexed _sender, uint256 _amount);

    error NotEnoughBalance();

    constructor(string memory _name, string memory _symbol) ERC20Permit(_name) ERC20(_name, _symbol) {}

    function deposit() public payable {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        if (balanceOf(msg.sender) < _amount) {
            revert NotEnoughBalance();
        }

        _burn(msg.sender, _amount);

        payable(msg.sender).transfer(_amount);

        emit Withdrawal(msg.sender, _amount);
    }

    receive() external payable {
        deposit();
    }
}
