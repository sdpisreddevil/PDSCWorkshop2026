// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {PDSCWorkshopItems} from "../src/PDSCWorkshopItems.sol";

/// @notice Deploy ERC-1155 items for an existing PDSCWorkshop2026 registration contract.
/// Requires WORKSHOP_ADDRESS in the environment.
///   forge script script/PDSCWorkshopItems.s.sol:PDSCWorkshopItemsScript \
///     --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
contract PDSCWorkshopItemsScript is Script {
    function run() public returns (PDSCWorkshopItems items) {
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

        items = new PDSCWorkshopItems(workshop, deployer);

        console.log("PDSCWorkshopItems deployed at:", address(items));
        console.log("Workshop:", workshop);
        console.log("Owner:", deployer);
        console.log("ATTENDEE_PASS id:", items.ATTENDEE_PASS());
        console.log("SWAG_VOUCHER id:", items.SWAG_VOUCHER());
        console.log("CERTIFICATE id:", items.CERTIFICATE());
        console.log("Chain id:", block.chainid);

        vm.stopBroadcast();
    }
}
