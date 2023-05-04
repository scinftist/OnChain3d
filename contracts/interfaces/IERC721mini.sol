// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC721mini {
    function ownerOf(uint256 _tokenId) external view returns (address);
}
