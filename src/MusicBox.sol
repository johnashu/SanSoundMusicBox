//SPDX-License-Identifier: UNLICENSED

/// @title San Sound Musix Box NFT
/// @author Maffaz

// LOCKUP AND CHANGE BASEURI

pragma solidity ^0.8.18;

import {Base721, IERC721, ERC721, Strings} from "src/token/ERC721/Base721.sol";
import {IMusicBox} from "src/interfaces/MusicBox/IMusicBox.sol";
import {
    ERC2981ContractWideRoyalties,
    ERC2981Base,
    ERC165,
    IERC165
} from "src/token/ERC2981/ERC2981ContractWideRoyalties.sol";

import {ERC721TokenReceiver} from "src/token/ERC721/ERC721.sol";

contract MusicBox is Base721, IMusicBox, ERC2981ContractWideRoyalties {
    /// The maximum ERC-2981 royalties percentage (two decimals).
    uint256 public constant MAX_ROYALTIES_PCT = 930; // 9.3%

    address public immutable SANCTUARY_ADDRESS;
    address public charactersAddress;

    mapping(uint256 tokenId => uint256 lockupTime) public lockupTime;
    mapping(uint256 tokenId => MusicBoxLevel) public tokenLevel;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        string memory _contractURI,
        address _SANCTUARY_ADDRESS
    ) Base721(_name, _symbol, _baseURI, _contractURI) {
        SANCTUARY_ADDRESS = _SANCTUARY_ADDRESS;
    }

    function setCharactersAddress(address _address) public onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        charactersAddress = _address;
    }

    /// @notice Locks up a MusicBox token for a specific time period
    /// @dev musicBoxLevel will be set to 'Locked' and this level will prevent any transfers.
    /// @param _lockupTime Lockup time to Soulbind for.
    /// @param tokenId Token Id to Lock.
    /// @param tokenOwner Owner of the token to check.
    function setLockupTime(uint256 _lockupTime, uint256 tokenId, address tokenOwner) external {
        if (msg.sender != charactersAddress) revert WrongCallingAddress();
        if (_lockupTime == 0) revert LockupTimeZero();
        if (ownerOf(tokenId) != tokenOwner) revert NotOwner();

        lockupTime[tokenId] = _lockupTime;
        tokenLevel[tokenId] = MusicBoxLevel.Locked;
        emit TokenLockedUp(tokenOwner, tokenId, _lockupTime);
    }

    /// @notice Mints a new token received from the Sanctuary Contract.  Sanctuary will perform checks.
    /// @dev The Sanctuary Contract deploys and sets its address in this contract.  Only that address can mint to it.
    /// @param _to Address to send the minted Token to.
    /// @param musicBoxLevel MusicBox level Common, Rare, Epic as sent by the Sanctuary.
    function mintFromSantuary(address _to, MusicBoxLevel musicBoxLevel) external {
        if (msg.sender != SANCTUARY_ADDRESS) revert OnlySanctuaryAllowedToMint();
        uint256 newId = _getTokenIdAndIncrement();
        tokenLevel[newId] = musicBoxLevel;
        _safeMint(_to, newId);
    }

    /**
     * @notice (only owner) Sets ERC-2981 royalties recipient and percentage.
     * @param _recipient The address to which to send royalties.
     * @param _value The royalties percentage (two decimals, e.g. 1000 = 10%).
     */
    function setRoyalties(address _recipient, uint256 _value) public onlyOwner {
        if (_value > MAX_ROYALTIES_PCT) revert ExceedsMaxRoyaltiesPercentage();
        _setRoyalties(_recipient, _value);
    }

    /**
     * @notice Transfers multiple tokens from `_from` to `_to`.
     * @param _from The address from which to transfer tokens.
     * @param _to The address to which to transfer tokens.
     * @param _tokenIds An array of token IDs to transfer.
     */
    function batchTransferFrom(address _from, address _to, uint256[] calldata _tokenIds) public {
        if (_to == address(0)) revert ZeroAddress();
        uint256 _amount = _tokenIds.length;

        unchecked {
            for (uint256 i; i < _amount; i++) {
                _canTransfer(_tokenIds[i]);

                if (_from != _ownerOf[_tokenIds[i]]) revert NotOwner();

                if (
                    !(
                        msg.sender == _from || !isApprovedForAll[_from][msg.sender]
                            || msg.sender == getApproved[_tokenIds[i]]
                    )
                ) {
                    revert NotAuthorised();
                }

                _ownerOf[_tokenIds[i]] = _to;

                delete getApproved[_tokenIds[i]];
            }
        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // We can save some gas here by updating all in one go.
        unchecked {
            _balanceOf[_from] -= _amount;
            _balanceOf[_to] += _amount;
        }

        emit BatchTransfer(_from, _to, _tokenIds);
    }

    /**
     * @notice Safely transfers multiple tokens from `_from` to `_to`.
     * @param _from The address from which to transfer tokens.
     * @param _to The address to which to transfer tokens.
     * @param _tokenIds An array of token IDs to transfer.
     */
    function batchSafeTransferFrom(address _from, address _to, uint256[] calldata _tokenIds, bytes calldata _data)
        public
    {
        if (_to == address(0)) revert ZeroAddress();
        uint256 _amount = _tokenIds.length;

        unchecked {
            for (uint256 i; i < _amount; i++) {
                _canTransfer(_tokenIds[i]);

                if (_from != _ownerOf[_tokenIds[i]]) revert NotOwner();

                if (
                    !(
                        msg.sender == _from || !isApprovedForAll[_from][msg.sender]
                            || msg.sender == getApproved[_tokenIds[i]]
                    )
                ) {
                    revert NotAuthorised();
                }

                _ownerOf[_tokenIds[i]] = _to;

                delete getApproved[_tokenIds[i]];

                if (
                    !(
                        _to.code.length == 0
                            || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenIds[i], _data)
                                == ERC721TokenReceiver.onERC721Received.selector
                    )
                ) {
                    revert UnSafeRecipient();
                }
            }
        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // We can save some gas here by updating all in one go.
        unchecked {
            _balanceOf[_from] -= _amount;
            _balanceOf[_to] += _amount;
        }

        emit BatchTransfer(_from, _to, _tokenIds);
    }

    function _canTransfer(uint256 tokenId) internal view override {
        if (block.timestamp < lockupTime[tokenId]) revert TokenLocked();
    }

    // Overrides.
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (!_exists(_tokenId)) revert TokenDoesNotExist();
        return string(
            abi.encodePacked(
                baseURI, Strings.toString(uint256(tokenLevel[_tokenId])), "/", Strings.toString(_tokenId), ".json"
            )
        );
    }

    function supportsInterface(bytes4 _interfaceId) public view override(IERC165, ERC2981Base, ERC721) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }
}
