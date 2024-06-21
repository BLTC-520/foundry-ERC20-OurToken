// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;  

    function setUp() public {
    deployer = new DeployOurToken();
    ourToken = deployer.run();
    
    vm.prank(msg.sender);
    ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend his tokens 
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount); // if .transfer auto set the sender (whoever is calling)

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob) , STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {    
        uint256 amount = 10;

        vm.prank(bob);
        ourToken.transfer(alice, amount);
        
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - amount);
        assertEq(ourToken.balanceOf(alice), amount);
    }

    // function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
    //     uint256 currentAllowance = allowance(owner, spender);
    //     if (currentAllowance != type(uint256).max) {
    //         if (currentAllowance < value) {
    //             revert ERC20InsufficientAllowance(spender, currentAllowance, value);
    //         }
    //         unchecked {
    //             _approve(owner, spender, currentAllowance - value, false);
    //         }
    //     }
    // }

    function testSpendAllowance() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend his tokens 
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        // Successful allowance spend
        vm.prank(alice);
        ourToken.testSpendAllowance(bob, alice, transferAmount);

        uint256 remainingAllowance = ourToken.allowance(bob, alice);
        assertEq(remainingAllowance, initialAllowance - transferAmount);
    }

    function testSpendAllowanceRevertsIfValueExceeded() public {
    
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend his tokens 
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = initialAllowance;

        // Unsuccessful allowance spend
        vm.expectRevert();
        vm.prank(alice);
        ourToken.testSpendAllowance(bob, alice, transferAmount + 1);
    }
}
