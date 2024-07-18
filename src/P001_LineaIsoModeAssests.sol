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

import {IPoolConfigurator} from "../lib/core-contracts/contracts/interfaces/IPoolConfigurator.sol";
import {IACLManager} from "../lib/core-contracts/contracts/interfaces/IACLManager.sol";

interface IRevokeRole {
    function renounceRole(bytes32 role, address account) external;
}

contract P001_LineaIsoModeAssests {
    address public mai;
    address public wstETH;
    address public grai;
    address public weth;
    address public ezETH;
    IPoolConfigurator public config;
    IACLManager public acl;

    constructor(
        address _mai,
        address _wstETH,
        address _grai,
        address _ezETH,
        address _weth,
        address _config,
        address _acl
    ) {
        mai = _mai;
        wstETH = _wstETH;
        grai = _grai;
        weth = _weth;
        ezETH = _ezETH;
        config = IPoolConfigurator(_config);
        acl = IACLManager(_acl);
    }

    function execute() public {
        config.setBorrowableInIsolation(mai, false);
        config.setBorrowableInIsolation(wstETH, false);
        config.setBorrowableInIsolation(grai, false);
        config.setBorrowableInIsolation(ezETH, false);
        config.setBorrowableInIsolation(weth, false);

        IRevokeRole(address(acl)).renounceRole(
            acl.POOL_ADMIN_ROLE(),
            address(this)
        );
    }
}
