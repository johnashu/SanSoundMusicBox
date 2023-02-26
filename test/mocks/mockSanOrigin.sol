//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz

pragma solidity ^0.8.18;

import "test/Mocks/_SANOrigin.sol";

contract MockSanOrigin is SANOrigin {
    constructor() SANOrigin("SO Mock", "SOM", 1, address(1), "https://base-uri.com/", "https://contract-uri.com/") {
        for (uint256 i; i < 10000; i++) {
            levelPrice[SoulboundLevel.One] = 0;
            levelPrice[SoulboundLevel.Two] = 0;
            levelPrice[SoulboundLevel.Three] = 0;
            levelPrice[SoulboundLevel.Four] = 0;

            _safeMint(msg.sender, i + 1);

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
        // approve(to, tokenId);
        safeTransferFrom(from, to, tokenId);
    }

    // function mint() public {
    //     _safeMint((msg.sender), totalSupply + 1);
    // }
}
