// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {PDSCWorkshop2026} from "../src/PDSCWorkshop2026.sol";
import {PDSCWorkshopToken} from "../src/PDSCWorkshopToken.sol";

contract PDSCWorkshopTokenTest is Test {
    PDSCWorkshop2026 public workshop;
    PDSCWorkshopToken public token;

    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 public constant PREMINT = 1_000_000 ether;
    uint256 public constant CLAIM_AMOUNT = 100 ether;
    uint256 public constant JOIN_FEE = 0.000001 ether;

    function setUp() public {
        workshop = new PDSCWorkshop2026(admin);
        token = new PDSCWorkshopToken(address(workshop), admin, admin, CLAIM_AMOUNT);

        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function test_MetadataAndPremint() public view {
        assertEq(token.name(), "PDSC Workshop 2026");
        assertEq(token.symbol(), "PDSC");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), PREMINT);
        assertEq(token.balanceOf(admin), PREMINT);
        assertEq(address(token.workshop()), address(workshop));
        assertEq(token.claimAmount(), CLAIM_AMOUNT);
    }

    function test_Transfer() public {
        vm.prank(admin);
        token.transfer(alice, 50 ether);

        assertEq(token.balanceOf(alice), 50 ether);
        assertEq(token.balanceOf(admin), PREMINT - 50 ether);
    }

    function test_ApproveAndTransferFrom() public {
        vm.prank(admin);
        token.transfer(alice, 200 ether);

        vm.prank(alice);
        token.approve(bob, 75 ether);

        vm.prank(bob);
        token.transferFrom(alice, bob, 75 ether);

        assertEq(token.balanceOf(bob), 75 ether);
        assertEq(token.balanceOf(alice), 125 ether);
    }

    function test_ClaimReward_OnlyIfRegistered() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();

        vm.prank(alice);
        token.claimReward();

        assertTrue(token.hasClaimed(alice));
        assertEq(token.balanceOf(alice), CLAIM_AMOUNT);
        assertEq(token.totalSupply(), PREMINT + CLAIM_AMOUNT);
    }

    function test_ClaimReward_RevertIfNotRegistered() public {
        vm.prank(alice);
        vm.expectRevert(PDSCWorkshopToken.NotRegistered.selector);
        token.claimReward();
    }

    function test_ClaimReward_RevertIfAlreadyClaimed() public {
        vm.startPrank(alice);
        workshop.join{value: JOIN_FEE}();
        token.claimReward();
        vm.expectRevert(PDSCWorkshopToken.AlreadyClaimed.selector);
        token.claimReward();
        vm.stopPrank();
    }

    function test_Mint_OnlyOwner() public {
        vm.prank(admin);
        token.mint(bob, 10 ether);
        assertEq(token.balanceOf(bob), 10 ether);

        vm.prank(alice);
        vm.expectRevert();
        token.mint(alice, 1 ether);
    }

    function test_Burn() public {
        vm.prank(admin);
        token.transfer(alice, 40 ether);

        vm.prank(alice);
        token.burn(15 ether);

        assertEq(token.balanceOf(alice), 25 ether);
        assertEq(token.totalSupply(), PREMINT - 15 ether);
    }
}
