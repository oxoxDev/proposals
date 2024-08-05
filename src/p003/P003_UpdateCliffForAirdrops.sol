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

import { IVestedZeroNFT } from "lib/governance/contracts/interfaces/IVestedZeroNFT.sol";
import { VestedZeroNFT } from "lib/governance/contracts/vesting/VestedZeroNFT.sol";

contract P003_UpdateCliffForAirdrops {
    uint256 public constant LINEAR_DURATION = 86400 * 91;
    uint256 public constant CLIFF_DURATION = 86400 * 90;
    address public constant VESTED_ZERO_NFT_PROXY_ADDRESS = 0x9FA72ea96591e486FF065E7C8A89282dEDfA6C12;
    uint256[] public tokenIds;
    VestedZeroNFT public vestedZeroNFT;

    constructor() {
        vestedZeroNFT = IVestedZeroNFT(VESTED_ZERO_NFT_PROXY_ADDRESS);
    }

    function execute() public {

        uint256 lastTokenId = vestedZeroNFT.lastTokenId();

        for (uint256 i = 0; i < lastTokenId; i++) {
            getAirdropTokenId(i);
        }

        uint256[] memory linearDuration = new uint256[](tokenIds.length);
        uint256[] memory cliffDuration = new uint256[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            linearDuration[i] = LINEAR_DURATION;
            cliffDuration[i] = CLIFF_DURATION;
        }

        vestedZeroNFT.updateCliffDuration(tokenIds, linearDuration, cliffDuration);
    }

    function getAirdropTokenId(uint256 i) internal {
        (uint256 category,, uint256 cliffDuration) = vestedZeroNFT.tokenIdToLockDetails(i);
        if (category == IVestedZeroNFT.Category.AIRDROP) {
            if (cliffDuration > 86400 * 90) {
                tokenIds.push(i);
            }
        }
    }
}
