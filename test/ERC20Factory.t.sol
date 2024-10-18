// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {ERC20Factory} from "../src/ERC20Factory.sol";
import {ERC20TokenUpgradeable} from "../src/ERC20TokenUpgradeable.sol";

contract ERC20FactoryTest is Test {
    ERC20Factory factory;
    address owner;

    function setUp() external {
        ERC20TokenUpgradeable implementation = new ERC20TokenUpgradeable();

        factory = new ERC20Factory(address(implementation));

        owner = makeAddr("OWNER");
    }

    function testItDeploysCorrectly() public {
        string memory tokenName = "Upgradeable Token";
        string memory tokenSymbol = "uToken";
        uint256 initialSupply = 1_000_000 ether;

        ERC20TokenUpgradeable token =
            ERC20TokenUpgradeable(factory.deploy(tokenName, tokenSymbol, initialSupply, owner, owner));

        vm.assertEq(token.name(), tokenName);
        vm.assertEq(token.symbol(), tokenSymbol);
        vm.assertEq(token.totalSupply(), initialSupply);
        vm.assertEq(token.balanceOf(owner), initialSupply);
        vm.assertEq(token.owner(), owner);
    }

    function testTokenAddressCanBePredicted() public {
        string memory tokenName = "Upgradeable Token";
        string memory tokenSymbol = "uToken";
        uint256 initialSupply = 1_000_000 ether;

        address predictedTokenAddress = factory.predictNextTokenAddress(address(this));

        ERC20TokenUpgradeable token =
            ERC20TokenUpgradeable(factory.deploy(tokenName, tokenSymbol, initialSupply, owner, owner));

        vm.assertEq(address(token), predictedTokenAddress);

        predictedTokenAddress = factory.predictNextTokenAddress(address(this));

        token = ERC20TokenUpgradeable(factory.deploy(tokenName, tokenSymbol, initialSupply, owner, owner));

        vm.assertEq(address(token), predictedTokenAddress);
    }

    function testNoncesAreIncresed() public {
        string memory tokenName = "Upgradeable Token";
        string memory tokenSymbol = "uToken";
        uint256 initialSupply = 1_000_000 ether;

        uint256 initialNonce = factory.nonce(address(this));

        address predictedTokenAddress = factory.predictNextTokenAddress(address(this));

        ERC20TokenUpgradeable token =
            ERC20TokenUpgradeable(factory.deploy(tokenName, tokenSymbol, initialSupply, owner, owner));

        vm.assertEq(address(token), predictedTokenAddress);
        vm.assertEq(factory.nonce(address(this)), initialNonce + 1);
    }

    function testTokenCantBeInitializedAgain() public {
        string memory tokenName = "Upgradeable Token";
        string memory tokenSymbol = "uToken";
        uint256 initialSupply = 1_000_000 ether;

        ERC20TokenUpgradeable token =
            ERC20TokenUpgradeable(factory.deploy(tokenName, tokenSymbol, initialSupply, owner, owner));

        vm.expectRevert(Initializable.InvalidInitialization.selector);
        token.initialize(tokenName, tokenSymbol, initialSupply, owner, owner);
    }
}
