// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

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

import {IPoolConfigurator} from "@zerolendxyz/core-v3/contracts/interfaces/IPoolConfigurator.sol";
import {IACLManager} from "@zerolendxyz/core-v3/contracts/interfaces/IACLManager.sol";

contract P001_LineaIsoModeAssests {
    uint256 public number;

    address public mai;
    address public wstETH;
    address public grai;
    address public weth;

    IPoolConfigurator public config;
    IACLManager public acl;

    function execute() public {
        config.setBorrowableInIsolation(mai, true);
        config.setBorrowableInIsolation(wstETH, true);
        config.setBorrowableInIsolation(grai, true);
        config.setBorrowableInIsolation(weth, true);

        acl.removePoolAdmin(address(this));
    }
}
