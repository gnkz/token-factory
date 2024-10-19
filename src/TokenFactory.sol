// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

import {ERC20TokenUpgradeable} from "./ERC20TokenUpgradeable.sol";
import {ERC20TokenUpgradeableProxy} from "./ERC20TokenUpgradeableProxy.sol";

contract TokenFactory {
    event Deployment(address indexed deployer, uint256 indexed nonce, address indexed tokenAddress);

    address public immutable proxyImplementation;
    address public immutable tokenImplementation;

    mapping(address => uint256) internal _nonces;

    constructor(address _proxyImplementation, address _tokenImplementation) {
        proxyImplementation = _proxyImplementation;
        tokenImplementation = _tokenImplementation;
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

        bytes32 salt = _salt(msg.sender, currentNonce);

        ERC20TokenUpgradeableProxy proxy =
            ERC20TokenUpgradeableProxy(payable(Clones.cloneDeterministic(proxyImplementation, salt)));

        proxy.initialize(tokenImplementation, _name, _symbol, _initialSupply, _supplyOwner, _owner);

        emit Deployment(msg.sender, currentNonce, address(proxy));

        return address(proxy);
    }

    function nonce(address _addr) external view returns (uint256) {
        return _nonces[_addr];
    }

    function predictTokenAddress(address _addr, uint256 _nonce) public view returns (address) {
        return Clones.predictDeterministicAddress(proxyImplementation, _salt(_addr, _nonce), address(this));
    }

    function predictNextTokenAddress(address _addr) public view returns (address) {
        return Clones.predictDeterministicAddress(proxyImplementation, _salt(_addr, _nonces[_addr]), address(this));
    }

    function _salt(address _sender, uint256 _nonce) internal pure returns (bytes32) {
        return keccak256(abi.encode(_sender, _nonce));
    }
}
