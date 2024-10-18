// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC20TokenUpgradeable} from "./ERC20TokenUpgradeable.sol";

contract ERC20Factory {
    event Deployment(address indexed deployer, uint256 indexed nonce, address indexed tokenAddress);

    address public immutable implementation;

    mapping(address => uint256) internal _nonces;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function deploy(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _supplyOwner,
        address _owner
    ) external returns (address) {
        uint256 currentNonce = _nonces[msg.sender];

        _nonces[msg.sender]++;

        ERC20TokenUpgradeable token = ERC20TokenUpgradeable(
            Clones.cloneDeterministic(implementation, keccak256(abi.encode(msg.sender, currentNonce)))
        );

        token.initialize(_name, _symbol, _initialSupply, _supplyOwner, _owner);

        emit Deployment(msg.sender, currentNonce, address(token));

        return address(token);
    }

    function nonce(address _addr) external view returns (uint256) {
        return _nonces[_addr];
    }

    function predictTokenAddress(address _addr, uint256 _nonce) public view returns (address) {
        return Clones.predictDeterministicAddress(implementation, _salt(_addr, _nonce), address(this));
    }

    function predictNextTokenAddress(address _addr) public view returns (address) {
        return Clones.predictDeterministicAddress(implementation, _salt(_addr, _nonces[_addr]), address(this));
    }

    function _salt(address _sender, uint256 _nonce) internal pure returns (bytes32) {
        return keccak256(abi.encode(_sender, _nonce));
    }
}
