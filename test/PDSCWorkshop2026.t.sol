// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {PDSCWorkshop2026} from "../src/PDSCWorkshop2026.sol";

contract PDSCWorkshop2026Test is Test {
    PDSCWorkshop2026 public workshop;

    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 public constant DEFAULT_FEE = 0.000001 ether;

    function setUp() public {
        workshop = new PDSCWorkshop2026(admin);
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function test_ConstructorSetsDefaultFeeAndOwner() public view {
        assertEq(workshop.owner(), admin);
        assertEq(workshop.joiningFee(), DEFAULT_FEE);
        assertEq(workshop.DEFAULT_JOINING_FEE(), DEFAULT_FEE);
        assertEq(workshop.usersCount(), 0);
    }

    function test_Join() public {
        vm.prank(alice);
        workshop.join{value: DEFAULT_FEE}();

        assertTrue(workshop.isRegistered(alice));
        assertEq(workshop.amountPaid(alice), DEFAULT_FEE);
        assertEq(workshop.usersCount(), 1);
        assertEq(workshop.registrantByIndex(0), alice);
        assertEq(workshop.totalFeesCollected(), DEFAULT_FEE);
        assertEq(address(workshop).balance, DEFAULT_FEE);
    }

    function test_Join_RevertIfAlreadyRegistered() public {
        vm.startPrank(alice);
        workshop.join{value: DEFAULT_FEE}();
        vm.expectRevert(PDSCWorkshop2026.AlreadyRegistered.selector);
        workshop.join{value: DEFAULT_FEE}();
        vm.stopPrank();
    }

    function test_Join_RevertIfIncorrectFee() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(PDSCWorkshop2026.IncorrectJoiningFee.selector, DEFAULT_FEE, 1 wei));
        workshop.join{value: 1 wei}();
    }

    function test_MultipleUsersJoin() public {
        vm.prank(alice);
        workshop.join{value: DEFAULT_FEE}();

        vm.prank(bob);
        workshop.join{value: DEFAULT_FEE}();

        assertEq(workshop.usersCount(), 2);
        assertEq(workshop.registrantByIndex(0), alice);
        assertEq(workshop.registrantByIndex(1), bob);
        assertEq(workshop.totalFeesCollected(), DEFAULT_FEE * 2);
    }

    function test_SetJoiningFee() public {
        uint256 newFee = 0.001 ether;

        vm.prank(admin);
        workshop.setJoiningFee(newFee);

        assertEq(workshop.joiningFee(), newFee);

        vm.deal(alice, newFee);
        vm.prank(alice);
        workshop.join{value: newFee}();

        assertTrue(workshop.isRegistered(alice));
        assertEq(workshop.amountPaid(alice), newFee);
    }

    function test_SetJoiningFee_RevertIfNotOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        workshop.setJoiningFee(1 ether);
    }

    function test_WithdrawFees() public {
        vm.prank(alice);
        workshop.join{value: DEFAULT_FEE}();

        uint256 adminBefore = admin.balance;

        vm.prank(admin);
        workshop.withdrawFees(payable(admin), DEFAULT_FEE);

        assertEq(admin.balance, adminBefore + DEFAULT_FEE);
        assertEq(address(workshop).balance, 0);
    }

    function test_WithdrawAll() public {
        vm.prank(alice);
        workshop.join{value: DEFAULT_FEE}();
        vm.prank(bob);
        workshop.join{value: DEFAULT_FEE}();

        uint256 adminBefore = admin.balance;

        vm.prank(admin);
        workshop.withdrawAll();

        assertEq(admin.balance, adminBefore + DEFAULT_FEE * 2);
        assertEq(address(workshop).balance, 0);
    }

    function test_WithdrawFees_RevertIfNotOwner() public {
        vm.prank(alice);
        workshop.join{value: DEFAULT_FEE}();

        vm.prank(alice);
        vm.expectRevert();
        workshop.withdrawFees(payable(alice), DEFAULT_FEE);
    }
}
