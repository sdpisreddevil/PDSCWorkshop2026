// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {PDSCWorkshopBadge} from "../src/PDSCWorkshopBadge.sol";

/// @notice Deploy ERC-721 badge for an existing PDSCWorkshop2026 registration contract.
/// Requires WORKSHOP_ADDRESS in the environment.
///   forge script script/PDSCWorkshopBadge.s.sol:PDSCWorkshopBadgeScript \
///     --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
contract PDSCWorkshopBadgeScript is Script {
    function run() public returns (PDSCWorkshopBadge badge) {
        address workshop = vm.envAddress("WORKSHOP_ADDRESS");

        uint256 deployerKey = vm.envOr("PRIVATE_KEY", uint256(0));
        address deployer;

        if (deployerKey != 0) {
            deployer = vm.addr(deployerKey);
            vm.startBroadcast(deployerKey);
        } else {
            vm.startBroadcast();
            deployer = msg.sender;
        }

        badge = new PDSCWorkshopBadge(workshop, deployer);

        console.log("PDSCWorkshopBadge deployed at:", address(badge));
        console.log("Workshop:", workshop);
        console.log("Owner:", deployer);
        console.log("Chain id:", block.chainid);

        vm.stopBroadcast();
    }
}
