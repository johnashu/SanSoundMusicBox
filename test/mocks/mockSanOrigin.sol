//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz

pragma solidity ^0.8.18;

import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";

contract MockSanOrigin is Base721 {
    mapping(uint256 => uint256) public tokenLevel;

    constructor() Base721("SO Mock", "SOM", "https://base-uri.com/", "https://contract-uri.com/") {
        for (uint256 i; i < 10000; i++) {
            _safeMint(msg.sender, i + 1);

            // Soulbound Level 1
            if (i > 20 && i < 38) {
                tokenLevel[i] = 1;
            }

            // Soulbound level 3
            if (i > 38 && i < 3000) {
                tokenLevel[i] = 3;
            }

            setApprovalForAll(msg.sender, true);
        }
    }

    /**
     * @notice Safely transfers multiple tokens from `_from` to `_to`.
     * @param _from The address from which to transfer tokens.
     * @param _to The address to which to transfer tokens.
     * @param _tokenIds An array of token IDs to transfer.
     */
    function batchSafeTransferFrom(address _from, address _to, uint256[] calldata _tokenIds, bytes calldata _data)
        external
    {
        if (_to == address(0)) revert ZeroAddress();
        uint256 _amount = _tokenIds.length;

        unchecked {
            for (uint256 i; i < _amount; i++) {
                uint256 id = _tokenIds[i];
                _canTransfer(id);

                if (_from != _ownerOf[id]) revert NotOwner();

                if (!(msg.sender == _from || !isApprovedForAll[_from][msg.sender] || msg.sender == getApproved[id])) {
                    revert NotAuthorised();
                }

                _ownerOf[id] = _to;

                delete getApproved[id];
            }
        }
        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // We can save some gas here by updating all in one go.
        unchecked {
            _balanceOf[_from] -= _amount;
            _balanceOf[_to] += _amount;
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
        approve(msg.sender, tokenId);
        safeTransferFrom(from, to, tokenId);
    }

    function mint() public {
        _safeMint((msg.sender), totalSupply + 1);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {}
}
