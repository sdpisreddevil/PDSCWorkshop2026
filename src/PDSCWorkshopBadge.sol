// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {PDSCWorkshop2026} from "./PDSCWorkshop2026.sol";

/// @title PDSCWorkshopBadge
/// @notice Attendance NFT badge for PDSC Workshop 2026.
/// @dev Registered attendees can claim one badge; owner can also mint.
contract PDSCWorkshopBadge is ERC721, ERC721Burnable, Ownable {
    error NotRegistered();
    error AlreadyClaimed();
    error ZeroAddress();

    PDSCWorkshop2026 public immutable workshop;

    uint256 private _nextTokenId;
    mapping(address => bool) public hasClaimed;
    mapping(address => uint256) public badgeOf;

    event BadgeClaimed(address indexed user, uint256 tokenId);

    constructor(address workshop_, address initialOwner)
        ERC721("PDSC Workshop 2026 Badge", "PDSCB")
        Ownable(initialOwner)
    {
        if (workshop_ == address(0) || initialOwner == address(0)) {
            revert ZeroAddress();
        }
        workshop = PDSCWorkshop2026(workshop_);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://images.lumacdn.com/cdn-cgi/image/format=auto,fit=cover,dpr=2,background=white,quality=75,width=400,height=400/uploads/gr/d8cba194-bef3-484b-be34-4bdd80827afe.png";
    }

    /// @notice Registered workshop attendees claim a one-time attendance badge.
    function claimBadge() external returns (uint256 tokenId) {
        if (!workshop.isRegistered(msg.sender)) revert NotRegistered();
        if (hasClaimed[msg.sender]) revert AlreadyClaimed();

        tokenId = _nextTokenId++;
        hasClaimed[msg.sender] = true;
        badgeOf[msg.sender] = tokenId;

        _safeMint(msg.sender, tokenId);
        emit BadgeClaimed(msg.sender, tokenId);
    }

    function safeMint(address to) public onlyOwner returns (uint256 tokenId) {
        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }
}
