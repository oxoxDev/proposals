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

// visit https://github.com/zerolend/proposals for information about tests and deployment scripts

import {IPoolAddressesProvider} from "../lib/core-contracts/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPoolConfigurator} from "../lib/core-contracts/contracts/interfaces/IPoolConfigurator.sol";
import {IACLManager} from "../lib/core-contracts/contracts/interfaces/IACLManager.sol";
import {IPool} from "../lib/core-contracts/contracts/interfaces/IPool.sol";

interface IRevokeRole {
    function renounceRole(bytes32 role, address account) external;
}

contract P001_LineaIsoModeAssests {
    address public dai;
    address public ezETH;
    address public grai;
    address public mai;
    address public usde;
    address public wbtc;
    address public weETH;
    address public weth;
    address public wrsETH;
    address public wstETH;

    IPoolConfigurator public config;
    IACLManager public acl;
    IPool public pool;

    constructor(
        address _mai,
        address _wstETH,
        address _grai,
        address _ezETH,
        address _weth,
        address _wbtc,
        address _wrsETH,
        address _weETH,
        address _usde,
        address _dai,
        address _provider
    ) {
        mai = _mai;
        wstETH = _wstETH;
        grai = _grai;
        weth = _weth;
        ezETH = _ezETH;
        wbtc = _wbtc;
        wrsETH = _wrsETH;
        weETH = _weETH;
        usde = _usde;
        dai = _dai;

        config = IPoolConfigurator(
            IPoolAddressesProvider(_provider).getPoolConfigurator()
        );
        acl = IACLManager(IPoolAddressesProvider(_provider).getACLManager());
        pool = IPool(IPoolAddressesProvider(_provider).getPool());
    }

    function execute() public {
        // remove asssets from isolation mode borrow
        config.setBorrowableInIsolation(mai, false);
        config.setBorrowableInIsolation(wstETH, false);
        config.setBorrowableInIsolation(grai, false);
        config.setBorrowableInIsolation(ezETH, false);
        config.setBorrowableInIsolation(weth, false);

        // set RF
        config.setReserveFactor(dai, 5000);
        config.setReserveFactor(wrsETH, 5000);
        config.setReserveFactor(weETH, 5000);
        config.setReserveFactor(usde, 5000);
        config.setReserveFactor(wbtc, 5000);

        // disable flashloan for mai and grai
        config.setReserveFlashLoaning(mai, false);
        config.setReserveFlashLoaning(grai, false);

        // todo need to write tests for this; remove these assets from debt ceiling later
        // // remove from isolation mode
        // config.setDebtCeiling(ezETH, 0);
        // config.setDebtCeiling(weETH, 0);
        // config.setDebtCeiling(wrsETH, 0);

        IRevokeRole(address(acl)).renounceRole(
            acl.POOL_ADMIN_ROLE(),
            address(this)
        );
    }
}
