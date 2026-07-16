// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {PDSCWorkshop2026} from "../src/PDSCWorkshop2026.sol";
import {PDSCWorkshopItems} from "../src/PDSCWorkshopItems.sol";

contract PDSCWorkshopItemsTest is Test {
    PDSCWorkshop2026 public workshop;
    PDSCWorkshopItems public items;

    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 public constant JOIN_FEE = 0.000001 ether;

    function setUp() public {
        workshop = new PDSCWorkshop2026(admin);
        items = new PDSCWorkshopItems(address(workshop), admin);

        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function test_MetadataAndIds() public view {
        assertEq(items.uri(1), "https://pdsc.workshop/2026/items/{id}.json");
        assertEq(items.ATTENDEE_PASS(), 1);
        assertEq(items.SWAG_VOUCHER(), 2);
        assertEq(items.CERTIFICATE(), 3);
        assertEq(address(items.workshop()), address(workshop));
        assertEq(items.owner(), admin);
    }

    function test_ClaimStarterPack_OnlyIfRegistered() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();

        vm.prank(alice);
        items.claimStarterPack();

        assertTrue(items.hasClaimedPack(alice));
        assertEq(items.balanceOf(alice, items.ATTENDEE_PASS()), 1);
        assertEq(items.balanceOf(alice, items.SWAG_VOUCHER()), 1);
        assertEq(items.balanceOf(alice, items.CERTIFICATE()), 1);
        assertEq(items.totalSupply(items.ATTENDEE_PASS()), 1);
    }

    function test_ClaimStarterPack_RevertIfNotRegistered() public {
        vm.prank(alice);
        vm.expectRevert(PDSCWorkshopItems.NotRegistered.selector);
        items.claimStarterPack();
    }

    function test_ClaimStarterPack_RevertIfAlreadyClaimed() public {
        vm.startPrank(alice);
        workshop.join{value: JOIN_FEE}();
        items.claimStarterPack();
        vm.expectRevert(PDSCWorkshopItems.AlreadyClaimed.selector);
        items.claimStarterPack();
        vm.stopPrank();
    }

    function test_SafeTransferFrom() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();
        vm.prank(alice);
        items.claimStarterPack();

        uint256 swagId = items.SWAG_VOUCHER();
        uint256 passId = items.ATTENDEE_PASS();

        vm.prank(alice);
        items.safeTransferFrom(alice, bob, swagId, 1, "");

        assertEq(items.balanceOf(alice, swagId), 0);
        assertEq(items.balanceOf(bob, swagId), 1);
        assertEq(items.balanceOf(alice, passId), 1);
    }

    function test_SafeBatchTransferFrom() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();
        vm.prank(alice);
        items.claimStarterPack();

        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = items.ATTENDEE_PASS();
        ids[1] = items.CERTIFICATE();
        amounts[0] = 1;
        amounts[1] = 1;

        vm.prank(alice);
        items.safeBatchTransferFrom(alice, bob, ids, amounts, "");

        assertEq(items.balanceOf(bob, items.ATTENDEE_PASS()), 1);
        assertEq(items.balanceOf(bob, items.CERTIFICATE()), 1);
        assertEq(items.balanceOf(alice, items.SWAG_VOUCHER()), 1);
    }

    function test_Mint_OnlyOwner() public {
        uint256 swagId = items.SWAG_VOUCHER();

        vm.prank(admin);
        items.mint(bob, swagId, 5, "");

        assertEq(items.balanceOf(bob, swagId), 5);
        assertEq(items.totalSupply(swagId), 5);

        vm.prank(alice);
        vm.expectRevert();
        items.mint(alice, swagId, 1, "");
    }

    function test_MintBatch_OnlyOwner() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = items.ATTENDEE_PASS();
        ids[1] = items.CERTIFICATE();
        amounts[0] = 2;
        amounts[1] = 3;

        vm.prank(admin);
        items.mintBatch(bob, ids, amounts, "");

        assertEq(items.balanceOf(bob, items.ATTENDEE_PASS()), 2);
        assertEq(items.balanceOf(bob, items.CERTIFICATE()), 3);
    }

    function test_Burn() public {
        vm.prank(alice);
        workshop.join{value: JOIN_FEE}();
        vm.prank(alice);
        items.claimStarterPack();

        uint256 swagId = items.SWAG_VOUCHER();

        vm.prank(alice);
        items.burn(alice, swagId, 1);

        assertEq(items.balanceOf(alice, swagId), 0);
        assertEq(items.totalSupply(swagId), 0);
    }

    function test_SetURI_OnlyOwner() public {
        string memory newUri = "https://pdsc.workshop/2026/v2/{id}.json";

        vm.prank(admin);
        items.setURI(newUri);
        assertEq(items.uri(1), newUri);

        vm.prank(alice);
        vm.expectRevert();
        items.setURI("https://evil.example/{id}.json");
    }
}
