// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {PDSCWorkshop2026} from "../src/PDSCWorkshop2026.sol";
import {PDSCWorkshopBadge} from "../src/PDSCWorkshopBadge.sol";

contract PDSCWorkshopBadgeTest is Test {
    PDSCWorkshop2026 public workshop;
    PDSCWorkshopBadge public badge;

    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 public constant JOIN_FEE = 0.000001 ether;

    function setUp() public {
        workshop = new PDSCWorkshop2026(admin);
        badge = new PDSCWorkshopBadge(address(workshop), admin);

        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function test_Metadata() public view {
        assertEq(badge.name(), "PDSC Workshop 2026 Badge");
        assertEq(badge.symbol(), "PDSCB");
        assertEq(badge.owner(), admin);
        assertEq(address(badge.workshop()), address(workshop));
    }

    function test_ClaimBadge_OnlyIfRegistered() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();

        vm.prank(alice);
        uint256 tokenId = badge.claimBadge();

        assertEq(tokenId, 0);
        assertEq(badge.ownerOf(0), alice);
        assertTrue(badge.hasClaimed(alice));
        assertEq(badge.badgeOf(alice), 0);
        assertEq(badge.tokenURI(0), "https://pdsc.workshop/2026/nft/0");
    }

    function test_ClaimBadge_RevertIfNotRegistered() public {
        vm.prank(alice);
        vm.expectRevert(PDSCWorkshopBadge.NotRegistered.selector);
        badge.claimBadge();
    }

    function test_ClaimBadge_RevertIfAlreadyClaimed() public {
        vm.startPrank(alice);
        workshop.join{value: JOIN_FEE}();
        badge.claimBadge();
        vm.expectRevert(PDSCWorkshopBadge.AlreadyClaimed.selector);
        badge.claimBadge();
        vm.stopPrank();
    }

    function test_MultipleAttendeesGetIncrementalIds() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();
        vm.prank(bob);
        workshop.join{value: JOIN_FEE}();

        vm.prank(alice);
        assertEq(badge.claimBadge(), 0);
        vm.prank(bob);
        assertEq(badge.claimBadge(), 1);

        assertEq(badge.ownerOf(0), alice);
        assertEq(badge.ownerOf(1), bob);
    }

    function test_TransferFrom() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();
        vm.prank(alice);
        badge.claimBadge();

        vm.prank(alice);
        badge.transferFrom(alice, bob, 0);

        assertEq(badge.ownerOf(0), bob);
    }

    function test_ApproveAndTransferFrom() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();
        vm.prank(alice);
        badge.claimBadge();

        vm.prank(alice);
        badge.approve(bob, 0);

        vm.prank(bob);
        badge.transferFrom(alice, bob, 0);

        assertEq(badge.ownerOf(0), bob);
    }

    function test_SafeMint_OnlyOwner() public {
        vm.prank(admin);
        uint256 tokenId = badge.safeMint(bob);
        assertEq(tokenId, 0);
        assertEq(badge.ownerOf(0), bob);

        vm.prank(alice);
        vm.expectRevert();
        badge.safeMint(alice);
    }

    function test_Burn() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();
        vm.prank(alice);
        badge.claimBadge();

        vm.prank(alice);
        badge.burn(0);

        assertEq(badge.balanceOf(alice), 0);
        vm.expectRevert();
        badge.ownerOf(0);
    }
}
