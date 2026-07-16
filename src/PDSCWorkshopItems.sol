// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {PDSCWorkshop2026} from "./PDSCWorkshop2026.sol";

/// @title PDSCWorkshopItems
/// @notice Multi-token (ERC-1155) collectibles for PDSC Workshop 2026.
/// @dev Registered attendees claim a starter pack once; owner can mint more.
contract PDSCWorkshopItems is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
    /// @dev Token type ids used in the workshop demo.
    uint256 public constant ATTENDEE_PASS = 1;
    uint256 public constant SWAG_VOUCHER = 2;
    uint256 public constant CERTIFICATE = 3;

    error NotRegistered();
    error AlreadyClaimed();
    error ZeroAddress();

    PDSCWorkshop2026 public immutable workshop;

    mapping(address => bool) public hasClaimedPack;

    event StarterPackClaimed(address indexed user, uint256[] ids, uint256[] amounts);

    constructor(address workshop_, address initialOwner)
        ERC1155("https://pdsc.workshop/2026/items/{id}.json")
        Ownable(initialOwner)
    {
        if (workshop_ == address(0) || initialOwner == address(0)) revert ZeroAddress();
        workshop = PDSCWorkshop2026(workshop_);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    /// @notice Registered attendees claim one of each starter item (pass, swag, certificate).
    function claimStarterPack() external {
        if (!workshop.isRegistered(msg.sender)) revert NotRegistered();
        if (hasClaimedPack[msg.sender]) revert AlreadyClaimed();

        hasClaimedPack[msg.sender] = true;

        uint256[] memory ids = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        ids[0] = ATTENDEE_PASS;
        ids[1] = SWAG_VOUCHER;
        ids[2] = CERTIFICATE;
        amounts[0] = 1;
        amounts[1] = 1;
        amounts[2] = 1;

        _mintBatch(msg.sender, ids, amounts, "");
        emit StarterPackClaimed(msg.sender, ids, amounts);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}
