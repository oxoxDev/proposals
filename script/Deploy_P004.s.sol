// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.12;

// ███████╗███████╗██████╗  ██████╗
// ╚══███╔╝██╔════╝██╔══██╗██╔═══██╗
//   ███╔╝ █████╗  ██████╔╝██║   ██║
//  ███╔╝  ██╔══╝  ██╔══██╗██║   ██║
// ███████╗███████╗██║  ██║╚██████╔╝
// ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝

// Website: https://zerolend.xyz
// Discord: https://discord.gg/zerolend
// Twitter: https://twitter.com/zerolendxyz
// Telegram: https://t.me/zerolendxyz

// visit https://github.com/zerolend/proposals for information about tests and deployment scripts
import { Script } from "lib/forge-std/src/Script.sol";
import { P004_UpgradePythOracles } from "src/p004/P004_UpgradePythOracles.sol";

contract Deploy_P004 is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new P004_UpgradePythOracles();

        vm.stopBroadcast();
    }
}
