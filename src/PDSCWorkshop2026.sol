// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title PDSCWorkshop2026
/// @notice Workshop registration with an admin-configurable joining fee.
contract PDSCWorkshop2026 is Ownable {
    uint256 public constant DEFAULT_JOINING_FEE = 0.000001 ether;

    error AlreadyRegistered();
    error IncorrectJoiningFee(uint256 expected, uint256 sent);
    error TransferFailed();
    error ZeroAddress();

    mapping(address => bool) public isRegistered;
    mapping(address => uint256) public amountPaid;
    mapping(uint256 => address) public registrantByIndex;

    uint256 public joiningFee;
    uint256 public usersCount;
    uint256 public totalFeesCollected;

    event Joined(address indexed user, uint256 feePaid, uint256 index);
    event JoiningFeeUpdated(uint256 oldFee, uint256 newFee);
    event FeesWithdrawn(address indexed to, uint256 amount);

    constructor(address initialOwner) Ownable(initialOwner) {
        if (initialOwner == address(0)) revert ZeroAddress();
        joiningFee = DEFAULT_JOINING_FEE;
    }

    /// @notice Register for the workshop by paying the current joining fee.
    function join() external payable {
        if (isRegistered[msg.sender]) revert AlreadyRegistered();
        if (msg.value != joiningFee) {
            revert IncorrectJoiningFee(joiningFee, msg.value);
        }

        isRegistered[msg.sender] = true;
        amountPaid[msg.sender] = msg.value;
        registrantByIndex[usersCount] = msg.sender;

        unchecked {
            usersCount++;
        }
        totalFeesCollected += msg.value;

        emit Joined(msg.sender, msg.value, usersCount - 1);
    }

    /// @notice Admin can update the joining fee for future registrations.
    function setJoiningFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = joiningFee;
        joiningFee = newFee;
        emit JoiningFeeUpdated(oldFee, newFee);
    }

    /// @notice Withdraw collected registration fees to a recipient.
    function withdrawFees(address payable to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        if (amount > address(this).balance) revert TransferFailed();

        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert TransferFailed();

        emit FeesWithdrawn(to, amount);
    }

    /// @notice Withdraw the full contract balance to the owner.
    function withdrawAll() external onlyOwner {
        uint256 amount = address(this).balance;
        address payable to = payable(owner());

        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert TransferFailed();

        emit FeesWithdrawn(to, amount);
    }
}
