//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {SafeERC20, IStuckERC20, IStuckERC721} from "src/token/rescue/SafeERC20.sol";
import {Ownable} from "src/utils/Ownable.sol";

error ArrayLengthMismatch();

contract TokenRescuer is Ownable {
    using SafeERC20 for IStuckERC20;

    function rescueBatchERC20(address _token, address[] calldata _receivers, uint256[] calldata _amounts)
        external
        onlyOwner
    {
        if (_receivers.length != _amounts.length) revert ArrayLengthMismatch();
        unchecked {
            for (uint256 i; i < _receivers.length; i += 1) {
                _rescueERC20(_token, _receivers[i], _amounts[i]);
            }
        }
    }

    function rescueBatchERC721(address _token, address[] calldata _receivers, uint256[][] calldata _tokenIds)
        external
        onlyOwner
    {
        if (_receivers.length != _tokenIds.length) revert ArrayLengthMismatch();
        unchecked {
            for (uint256 i; i < _receivers.length; i += 1) {
                uint256[] memory tokenIds = _tokenIds[i];
                for (uint256 j; j < tokenIds.length; j += 1) {
                    _rescueERC721(_token, _receivers[i], tokenIds[j]);
                }
            }
        }
    }

    function rescueERC20(address _token, address _receiver, uint256 _amount) external onlyOwner {
        _rescueERC20(_token, _receiver, _amount);
    }

    function rescueERC721(address _token, address _receiver, uint256 _tokenId) external onlyOwner {
        _rescueERC721(_token, _receiver, _tokenId);
    }

    function _rescueERC20(address _token, address _receiver, uint256 _amount) private {
        IStuckERC20(_token).safeTransfer(_receiver, _amount);
    }

    function _rescueERC721(address _token, address _receiver, uint256 _tokenId) private {
        IStuckERC721(_token).safeTransferFrom(address(this), _receiver, _tokenId);
    }
}
