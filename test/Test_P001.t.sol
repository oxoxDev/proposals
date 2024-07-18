// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {P001_LineaIsoModeAssests, IPoolConfigurator, IACLManager} from "../src/p001/P001_LineaIsoModeAssests.sol";
import {IPool, DataTypes} from "../lib/core-contracts/contracts/interfaces/IPool.sol";
import {IWrappedTokenGatewayV3} from "../lib/periphery-contracts/contracts/misc/interfaces/IWrappedTokenGatewayV3.sol";

contract Test_P001 is Test {
    P001_LineaIsoModeAssests payload;
    uint256 lineaFork;

    address mai;
    address wstETH;
    address grai;
    address ezETH;
    address weth;
    address wbtc;
    address wrsETH;
    address weETH;
    address usde;
    address dai;
    address provider;

    IPoolConfigurator config;
    IACLManager acl;
    IPool pool;

    IWrappedTokenGatewayV3 gateway = IWrappedTokenGatewayV3(0x5d50bE703836C330Fc2d147a631CDd7bb8D7171c);

    // safe that has access to the acl manager (eventually this should go into a timelock)
    address admin = address(0x14aAD4668de2115e30A5FeeE42CFa436899CCD8A);

    address weETHborrower = address(0x5eFb1c0ba60Ee295056c6EE112491584C31d2A33);

    // internal mask variables
    uint256 internal constant COLLATERAL_MASK = 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    uint256 internal constant DEBT_CEILING_MASK = 0xF0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant DEBT_CEILING_START_BIT_POSITION = 212;

    function setUp() external {
        lineaFork = vm.createFork(vm.envString("LINEA_RPC_URL"));
        vm.selectFork(lineaFork);
        vm.rollFork(6_953_695);

        payload = new P001_LineaIsoModeAssests();

        mai = payload.mai();
        wstETH = payload.wstETH();
        grai = payload.grai();
        ezETH = payload.ezETH();
        weth = payload.weth();
        wbtc = payload.wbtc();
        wrsETH = payload.wrsETH();
        weETH = payload.weETH();
        usde = payload.usde();
        dai = payload.dai();
        provider = payload.provider();

        acl = payload.acl();
        pool = payload.pool();
        config = payload.config();

        // create fork network
        vm.prank(admin);
        acl.addPoolAdmin(address(payload));

        vm.prank(admin);
        acl.addPoolAdmin(address(this));
    }

    function test__P001__execute() external {
        payload.execute();
    }

    function test__P001__canRepayDisabledIsolatedDebt_WEETH() external {
        payload.execute();

        // try to repay isolated debt
        vm.prank(weETHborrower);
        gateway.repayETH{value: 1 ether}(address(pool), 1 ether, 2, weETHborrower);
    }

    function test__P001__canRepayDisabledIsolatedDebtBeyondLimitsChangesDebt_WEETH() external {
        config.setDebtCeiling(weETH, 1);
        config.setBorrowableInIsolation(weth, false);

        uint256 debtBefore = _getIsolationModeTotalDebt(weETH);
        assertEq(debtBefore, 142661738);

        // try to repay isolated debt
        vm.prank(weETHborrower);
        gateway.repayETH{value: 2 ether}(address(pool), 2 ether, 2, weETHborrower);

        uint256 debtAfter = _getIsolationModeTotalDebt(weETH);
        assertEq(debtAfter, 142661538);
    }

    function test__P001__canRepayDisabledIsolatedDebtBeyondLimits_WEETH() external {
        config.setDebtCeiling(weETH, 1);
        config.setBorrowableInIsolation(weth, false);

        uint256 debtBefore = _getIsolationModeTotalDebt(weETH);
        assertEq(debtBefore, 142661738);

        payload.execute();

        uint256 debtBefore2 = _getIsolationModeTotalDebt(weETH);
        assertEq(debtBefore2, 0);

        // try to repay isolated debt
        vm.prank(weETHborrower);
        gateway.repayETH{value: 2 ether}(address(pool), 2 ether, 2, weETHborrower);

        uint256 debtAfter = _getIsolationModeTotalDebt(weETH);
        assertEq(debtAfter, 0);
    }

    function test__P001__canBorrowAnotherIsolatedDebtAsset() external {
        payload.execute();
    }

    function test__P001__cannotBorrowDisabledIsolatedAsset_WEETH() external {
        payload.execute();

        vm.prank(weETHborrower);
        vm.expectRevert(bytes("36"));
        gateway.borrowETH(address(pool), 1 ether, 2, 0);
    }

    function test__P001__canExitIsolationMode() external {
        (address assetBefore, uint256 ceilingBefore) = _getIsolationModeAsset(weETHborrower);
        assertEq(assetBefore, weETH);
        assertEq(ceilingBefore, 500000000);

        payload.execute();

        (, uint256 ceilingAfter) = _getIsolationModeAsset(weETHborrower);
        assertEq(ceilingAfter, 0);
    }

    function test__P001__noOverflowsOrUnderflows() external {
        payload.execute();
    }

    function _getIsolationModeAsset(address who) internal view returns (address assetAddress, uint256 ceiling) {
        DataTypes.UserConfigurationMap memory self = pool.getUserConfiguration(who);
        uint256 id = _getFirstAssetIdByMask(self, COLLATERAL_MASK);
        assetAddress = pool.getReservesList()[id];
        ceiling = _getDebtCeiling(assetAddress);
    }

    function _getFirstAssetIdByMask(DataTypes.UserConfigurationMap memory self, uint256 mask)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            uint256 bitmapData = self.data & mask;
            uint256 firstAssetPosition = bitmapData & ~(bitmapData - 1);
            uint256 id;
            while ((firstAssetPosition >>= 2) != 0) {
                id += 1;
            }
            return id;
        }
    }

    function _getDebtCeiling(address assetAddress) internal view returns (uint256) {
        DataTypes.ReserveData memory d = pool.getReserveData(assetAddress);
        return (d.configuration.data & ~DEBT_CEILING_MASK) >> DEBT_CEILING_START_BIT_POSITION;
    }

    function _getIsolationModeTotalDebt(address assetAddress) internal view returns (uint256) {
        DataTypes.ReserveData memory d = pool.getReserveData(assetAddress);
        return d.isolationModeTotalDebt;
    }
}
