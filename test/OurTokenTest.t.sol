//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

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

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
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

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testTransferFuzz(uint64 transferAmount) external {
        vm.assume(transferAmount >= 0 && transferAmount <= 90);
        //uint256 transferAmount = 90 ether;

        // Alice transfers 100 tokens to Bob
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        // Check balances
        uint256 aliceBalance = ourToken.balanceOf(alice);
        uint256 bobBalance = ourToken.balanceOf(bob);
        assertEq(aliceBalance, transferAmount);
        assertEq(bobBalance, BOB_STARTING_BALANCE - transferAmount);
    }

    function testCannotTransferMoreThanAvailable() public {
        uint256 transferAmount = 10000 ether;
        vm.expectRevert();
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);
    }
}
