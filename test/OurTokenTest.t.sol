//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;
    address public deployerAddress;
    address bob;
    address alice;
    uint256 public constant BOB_STARTING_BALANCE = 100 ether;

    function setUp() public {
        // Deploy the contract
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        bob = makeAddr("bob");
        alice = makeAddr("alice");
        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);

        ourToken.transfer(bob, BOB_STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(BOB_STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        //Bob allowing alice to spend his tokens
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAllowance = 500;
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAllowance);

        assertEq(ourToken.balanceOf(alice), transferAllowance);
        assertEq(
            ourToken.balanceOf(bob),
            BOB_STARTING_BALANCE - transferAllowance
        );
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }
}
