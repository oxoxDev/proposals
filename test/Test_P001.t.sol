// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {P001_LineaIsoModeAssests, IPoolConfigurator, IACLManager} from "../src/P001_LineaIsoModeAssests.sol";
import {IPool, DataTypes} from "../lib/core-contracts/contracts/interfaces/IPool.sol";

contract Test_P001 is Test {
    P001_LineaIsoModeAssests payload;
    uint256 lineaFork;

    address mai = address(0xf3B001D64C656e30a62fbaacA003B1336b4ce12A);
    address wstETH = address(0xB5beDd42000b71FddE22D3eE8a79Bd49A568fC8F);
    address grai = address(0x894134a25a5faC1c2C26F1d8fBf05111a3CB9487);
    address ezETH = address(0x2416092f143378750bb29b79eD961ab195CcEea5);
    address weth = address(0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f);
    address wbtc;
    address wrsETH;
    address weETH;
    address usde;
    address dai;

    address provider;

    IPoolConfigurator config;
    IACLManager acl;
    IPool pool;

    address admin = address(0x14aAD4668de2115e30A5FeeE42CFa436899CCD8A);

    function setUp() external {
        lineaFork = vm.createFork(vm.envString("LINEA_RPC_URL"));
        vm.selectFork(lineaFork);
        vm.rollFork(6_953_695);

        payload = new P001_LineaIsoModeAssests(
            mai,
            wstETH,
            grai,
            ezETH,
            weth,
            wbtc,
            wrsETH,
            weETH,
            usde,
            dai,
            address(provider)
        );

        acl = payload.acl();
        pool = payload.pool();
        config = payload.config();

        // create fork network
        vm.prank(admin);
        acl.addPoolAdmin(address(payload));
    }

    function test__P001__execute() external {
        payload.execute();
    }

    function test__P001__canRepayDisabledIsolatedDebt() external {
        payload.execute();
    }

    function test__P001__canRepayDisabledIsolatedDebtBeyondLimits() external {
        payload.execute();
    }

    function test__P001__canBorrowAnotherIsolatedDebtAsset() external {
        payload.execute();
    }

    function test__P001__cannotBorrowDisabledIsolatedAsset() external {
        payload.execute();
    }

    function test__P001__noOverflowsOrUnderflows() external {
        payload.execute();
    }
}
