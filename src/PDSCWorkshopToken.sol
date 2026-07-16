// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {PDSCWorkshop2026} from "./PDSCWorkshop2026.sol";

/// @title PDSCWorkshopToken
/// @notice Fungible token for PDSC Workshop 2026.
/// @dev Registered attendees can claim a one-time reward; owner can mint extra supply.
contract PDSCWorkshopToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    error NotRegistered();
    error AlreadyClaimed();
    error ZeroAddress();

    PDSCWorkshop2026 public immutable workshop;
    uint256 public immutable claimAmount;

    mapping(address => bool) public hasClaimed;

    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address workshop_, address recipient, address initialOwner, uint256 claimAmount_)
        ERC20("PDSC Workshop 2026", "PDSC")
        Ownable(initialOwner)
        ERC20Permit("PDSC Workshop 2026")
    {
        if (workshop_ == address(0) || recipient == address(0) || initialOwner == address(0)) {
            revert ZeroAddress();
        }

        workshop = PDSCWorkshop2026(workshop_);
        claimAmount = claimAmount_;
        _mint(initialOwner, 1_000_000 ether);
    }

    /// @notice Registered workshop attendees claim a one-time token reward.
    function claimReward() external {
        if (!workshop.isRegistered(msg.sender)) revert NotRegistered();
        if (hasClaimed[msg.sender]) revert AlreadyClaimed();

        hasClaimed[msg.sender] = true;
        _mint(msg.sender, claimAmount);

        emit RewardClaimed(msg.sender, claimAmount);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
