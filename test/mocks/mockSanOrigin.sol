//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz

pragma solidity 0.8.18;

import "test/Mocks/_SANOrigin.sol";

contract MockSanOrigin is SANOrigin {
    uint256[] levelPrices = [0, 0, 0, 0];

    constructor()
        SANOrigin("SO Mock", "SOM", 1, address(1), "https://base-uri.com/", "https://contract-uri.com/", levelPrices)
    {
        for (uint256 i; i < 10001; i++) {
            _safeMint(msg.sender, i + 1);
        }
    }

    function makeBound() public {
        for (uint256 i; i < 10000; i++) {
            // Soulbound Level 1
            if (i > 20 && i < 38) {
                tokenLevel[i] = SoulboundLevel.One;
            }

            // Soulbound level 3
            if (i > 38 && i < 3000) {
                tokenLevel[i] = SoulboundLevel.Three;
            }
        }
    }

    function makeAllBound() public {
        for (uint256 i; i < 10001; i++) {
            // Soulbound Level 1
            if (i < 2501) {
                tokenLevel[i] = SoulboundLevel.One;
            }
            // Soulbound Level 2
            if (i > 2500 && i < 5001) {
                tokenLevel[i] = SoulboundLevel.Two;
            }

            // Soulbound level 3
            if (i > 5000 && i < 7501) {
                tokenLevel[i] = SoulboundLevel.Three;
            }

            // Soulbound level 4
            if (i > 7500 && i < 10001) {
                tokenLevel[i] = SoulboundLevel.Three;
            }
        }
    }

    function TransferUnbound(address to, uint256 start, uint256 end) public {
        for (uint256 i = start; i < end; i++) {
            _safeTransferFrom(msg.sender, to, i);
        }
    }

    function TransferBound(address to, uint256 start, uint256 end) public {
        for (uint256 i = start; i < end; i++) {
            _safeTransferFrom(msg.sender, to, i);
        }
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId);
    }
}
