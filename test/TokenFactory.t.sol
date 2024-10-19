// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {TokenFactory} from "../src/TokenFactory.sol";
import {ERC20TokenUpgradeable} from "../src/ERC20TokenUpgradeable.sol";
import {ERC20TokenUpgradeableProxy} from "../src/ERC20TokenUpgradeableProxy.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract TokenFactoryTest is Test {
    TokenFactory factory;
    ERC20TokenUpgradeable upgradeableToken;
    ERC20TokenUpgradeableProxy upgradeableTokenProxy;

    address owner;

    function setUp() external {
        upgradeableToken = new ERC20TokenUpgradeable();
        upgradeableTokenProxy = new ERC20TokenUpgradeableProxy();

        factory = new TokenFactory(address(upgradeableTokenProxy), address(upgradeableToken));

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

    function testDeployedProxyCannotBeInitializedAgain() public {
        string memory tokenName = "Upgradeable Token";
        string memory tokenSymbol = "uToken";
        uint256 initialSupply = 1_000_000 ether;

        address tokenProxy = factory.deploy(tokenName, tokenSymbol, initialSupply, owner, owner);

        vm.expectRevert(Initializable.InvalidInitialization.selector);
        ERC20TokenUpgradeableProxy(payable(tokenProxy)).initialize(
            address(upgradeableToken), tokenName, tokenSymbol, initialSupply, owner, owner
        );

        vm.expectRevert(Initializable.NotInitializing.selector);
        ERC20TokenUpgradeable(tokenProxy).initialize(tokenName, tokenSymbol, initialSupply, owner, owner);
    }

    function testTokenCantBeInitializedAgain() public {
        string memory tokenName = "Upgradeable Token";
        string memory tokenSymbol = "uToken";
        uint256 initialSupply = 1_000_000 ether;

        ERC20TokenUpgradeable token =
            ERC20TokenUpgradeable(factory.deploy(tokenName, tokenSymbol, initialSupply, owner, owner));

        vm.expectRevert(Initializable.NotInitializing.selector);
        token.initialize(tokenName, tokenSymbol, initialSupply, owner, owner);
    }

    function testDeployedProxyCannotBeUpgradedByUnauthorizedAccount() public {
        string memory tokenName = "Upgradeable Token";
        string memory tokenSymbol = "uToken";
        uint256 initialSupply = 1_000_000 ether;

        ERC20TokenUpgradeable tokenProxy =
            ERC20TokenUpgradeable(factory.deploy(tokenName, tokenSymbol, initialSupply, owner, owner));

        ERC20TokenUpgradeable newToken = new ERC20TokenUpgradeable();

        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, address(this)));
        tokenProxy.upgradeToAndCall(address(newToken), "");
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
}
