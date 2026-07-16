// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {PDSCWorkshop2026} from "../src/PDSCWorkshop2026.sol";
import {PDSCWorkshopToken} from "../src/PDSCWorkshopToken.sol";
import {PDSCWorkshopBadge} from "../src/PDSCWorkshopBadge.sol";

/// @notice Deploy the full PDSC Workshop 2026 suite: registration + ERC-20 + ERC-721.
///   forge script script/DeployAll.s.sol:DeployAllScript \
///     --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
/// Or:
///   ./script/deploy.sh all <rpc-url-or-name>
contract DeployAllScript is Script {
    function run()
        public
        returns (PDSCWorkshop2026 workshop, PDSCWorkshopToken token, PDSCWorkshopBadge badge)
    {
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

        workshop = new PDSCWorkshop2026(deployer);
        token = new PDSCWorkshopToken(address(workshop), deployer, deployer, claimAmount);
        badge = new PDSCWorkshopBadge(address(workshop), deployer);

        console.log("=== PDSC Workshop 2026 deployed ===");
        console.log("Registration:", address(workshop));
        console.log("ERC-20 Token:", address(token));
        console.log("ERC-721 Badge:", address(badge));
        console.log("Owner:", deployer);
        console.log("Joining fee (wei):", workshop.joiningFee());
        console.log("Claim amount:", claimAmount);
        console.log("Chain id:", block.chainid);

        vm.stopBroadcast();
    }
}
