// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {PDSCWorkshop2026} from "../src/PDSCWorkshop2026.sol";

/// @notice Deploy to a specific RPC with forge's --rpc-url flag:
///   forge script script/PDSCWorkshop2026.s.sol:PDSCWorkshop2026Script \
///     --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
/// Or:
///   ./script/deploy-pdsc.sh <rpc-url-or-name>
contract PDSCWorkshop2026Script is Script {
    function run() public returns (PDSCWorkshop2026 workshop) {
        uint256 deployerKey = vm.envOr("PRIVATE_KEY", uint256(0));
        address deployer;

        if (deployerKey != 0) {
            deployer = vm.addr(deployerKey);
            vm.startBroadcast(deployerKey);
        } else {
            // Uses --private-key / --account supplied on the CLI.
            vm.startBroadcast();
            deployer = msg.sender;
        }

        workshop = new PDSCWorkshop2026(deployer);
        console.log("PDSCWorkshop2026 deployed at:", address(workshop));
        console.log("Owner:", workshop.owner());
        console.log("Joining fee (wei):", workshop.joiningFee());
        console.log("Chain id:", block.chainid);

        vm.stopBroadcast();
    }
}
