// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.12;

import {Test} from "lib/forge-std/src/Test.sol";
import { P003_UpdateCliffForAirdrops, IVestedZeroNFT } from "src/p003/P003_UpdateCliffForAirdrops.sol";

contract Test_P003 is Test {
    address private constant VESTED_ZERO_NFT_PROXY_ADDRESS = 0x9FA72ea96591e486FF065E7C8A89282dEDfA6C12;
    address private constant IMPERSONATED_USER = 0xbB226555fBB98850273B10b0CF55aD2f99966d20;
    uint256[] public tokenIds;

    P003_UpdateCliffForAirdrops payload;
    IVestedZeroNFT vestedZeroNFT;

    function setUp() public {
        vm.createSelectFor(vm.envString("LINEA_RPC_URL), 7_766_645)

        vestedZeroNFT = IVestedZeroNFT(VESTED_ZERO_NFT_PROXY_ADDRESS);
        payload = new P003_UpdateCliffForAirdrops();

        vm.startPrank(IMPERSONATED_USER);
    }

    function test_P003_execute() external {
        uint256 lastTokenId = vestedZeroNFT.lastTokenId();
        IVestedZeroNFT.LockDetails lockDetails;

        for (uint256 i = 0; i < lastTokenId; i++) {
            payload.getAirdropTokenId(i);
        }        

        for (uint256 i = 0; i < tokenIds.length; i++) {
            lockDetails = vestedZeroNFT.tokenIdToLockDetails(tokenIds[i]);
            assertEq(lockDetails.cliffDuration, 86400 * 180);
        }

        payload.execute();

        for (uint256 i = 0; i < tokenIds.length; i++) {
            lockDetails = vestedZeroNFT.tokenIdToLockDetails(tokenIds[i]);
            assertEq(lockDetails.cliffDuration, 86400 * 90);
        }
    }
}