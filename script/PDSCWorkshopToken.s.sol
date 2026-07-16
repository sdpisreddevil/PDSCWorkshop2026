// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {PDSCWorkshopToken} from "../src/PDSCWorkshopToken.sol";

/// @notice Deploy ERC-20 for an existing PDSCWorkshop2026 registration contract.
/// Requires WORKSHOP_ADDRESS in the environment.
///   forge script script/PDSCWorkshopToken.s.sol:PDSCWorkshopTokenScript \
///     --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
contract PDSCWorkshopTokenScript is Script {
    function run() public returns (PDSCWorkshopToken token) {
        address workshop = vm.envAddress("WORKSHOP_ADDRESS");
        uint256 claimAmount = vm.envOr("CLAIM_AMOUNT", uint256(100 ether));

        uint256 deployerKey = vm.envOr("PRIVATE_KEY", uint256(0));
        address deployer;

        if (deployerKey != 0) {
            deployer = vm.addr(deployerKey);
            vm.startBroadcast(deployerKey);
        } else {
            vm.startBroadcast();
            deployer = msg.sender;
        }

        token = new PDSCWorkshopToken(workshop, deployer, deployer, claimAmount);

        console.log("PDSCWorkshopToken deployed at:", address(token));
        console.log("Workshop:", workshop);
        console.log("Owner / premint recipient:", deployer);
        console.log("Claim amount:", claimAmount);
        console.log("Chain id:", block.chainid);

        vm.stopBroadcast();
    }
}
