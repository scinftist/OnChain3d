//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Fixedpoint32x32 {
    /**
     * @dev convert packed vector 3 signed fixedpoint32x32 as uint256 to array of fixedpoint64x64 in int128[3]
     * Bits Layout:
     * - [0..63]   `z in fixedpoint32x32`
     * - [64..127] `y in fixedpoint32x32`
     * - [128..191]  `x in fixedpoint32x32`
     * - [192..255]  `0`
     * -
     */
    function unPackVector(
        uint256 _packedVector
    ) internal pure returns (int128[3] memory) {
        int128[3] memory _unpackedVector;

        unchecked {
            _unpackedVector[2] =
                int128(int64(uint64(_packedVector & uint256(2 ** 64 - 1)))) *
                2 ** 32;
            _packedVector = _packedVector >> 64;
            _unpackedVector[1] =
                int128(int64(uint64(_packedVector & uint256(2 ** 64 - 1)))) *
                2 ** 32;
            _packedVector = _packedVector >> 64;
            _unpackedVector[0] =
                int128(int64(uint64(_packedVector & uint256(2 ** 64 - 1)))) *
                2 ** 32;
        }

        return _unpackedVector;
    }

    function packVector(
        int128[3] memory _unPackedVector
    ) internal pure returns (uint256) {
        uint256 packedVector;
        unchecked {
            packedVector |= fixedpoint64x64to32x32(_unPackedVector[0]);
            packedVector = packedVector << 64;
            packedVector |= fixedpoint64x64to32x32(_unPackedVector[1]);
            packedVector = packedVector << 64;
            packedVector |= fixedpoint64x64to32x32(_unPackedVector[2]);
        }
        return packedVector;
    }

    function fixedpoint64x64to32x32(
        int128 _fixedpoint64x64Number
    ) internal pure returns (uint256) {
        uint256 _fixedpoint32x32Number;
        unchecked {
            _fixedpoint32x32Number =
                uint256(uint128(_fixedpoint64x64Number / 1)) >>
                32;
        }
        return _fixedpoint32x32Number;
    }
}
