//SPDX-License-Identifier: MIT

import {Fixedpoint32x32} from "./Utils3D/Fixedpoint32x32.sol";

pragma solidity ^0.8.0;

abstract contract TokenSettings {
    struct GeneralSetting {
        int128[3] observer;
        uint24 back_color;
        uint24 wire_color;
        uint16 angular_speed_deg;
        uint8 opacity;
        bool rotating_mode;
        bool dist_v_normalize;
        bool face_or_wire;
        uint24[] color_list;
    }

    struct MinimalSetting {
        uint256 observer; //packeSettingAndObserver;
        bytes colorlist;
    }

    uint256 private constant packedDefaultObserver =
        0x00ff6699001f4505000000040000000000000004000000000000000100000000;
    // uint256 private constant defaultCompressed = 71888926379296005;
    bytes private constant defaultColorlist =
        hex"ffc300e74c3c3498db2ecc719b59b6f1c40f27ae602980b98e44adf39c12c0392b1abc9c34495e7f8c8d16a085d35400bdc3c72c3e50f0e68cf5b041";

    // tokenId -> MinimalSetting
    mapping(uint256 => MinimalSetting) private minimalSettings;

    // a  function to unpack the packed data of minimal setting to general setting
    function minimalToGeneral(
        MinimalSetting memory _minimal
    ) internal pure returns (GeneralSetting memory) {
        uint256 _comp = _minimal.observer >> 192;
        int128[3] memory _observer = Fixedpoint32x32.unPackVector(
            _minimal.observer
        );
        return
            GeneralSetting({
                observer: _observer,
                opacity: opacityConverter(_comp),
                rotating_mode: rotating_modeConverter(_comp),
                angular_speed_deg: angular_speed_degConverter(_comp),
                dist_v_normalize: dist_v_normalizeConverter(_comp),
                face_or_wire: face_or_wiretConverter(_comp),
                back_color: back_colorConverter(_comp),
                wire_color: wire_colorConverter(_comp),
                color_list: color_listConverter(_minimal.colorlist)
            });
    }

    // set setting
    function setMinimal(
        uint256 id,
        int128[3] calldata _observer,
        uint256 _compressed,
        bytes calldata _colorlist
    ) internal {
        uint256 _packObserver;
        unchecked {
            _packObserver =
                (_compressed << 192) |
                Fixedpoint32x32.packVector(_observer);
        }

        minimalSettings[id] = MinimalSetting(_packObserver, _colorlist);
    }

    // retrive setting
    function getGeneralSetting(
        uint256 id
    ) public view returns (bool, GeneralSetting memory) {
        bool isDefault;
        MinimalSetting memory _minimalSetting = minimalSettings[id];
        int128[3] memory _observer = Fixedpoint32x32.unPackVector(
            _minimalSetting.observer
        );
        if (_observer[0] == 0 && _observer[1] == 0) {
            isDefault = true;
            // return (isDefault, defaultSetting);
            return (
                isDefault,
                minimalToGeneral(
                    MinimalSetting(packedDefaultObserver, defaultColorlist)
                )
            );
        } else {
            isDefault = false;
            return (isDefault, minimalToGeneral(_minimalSetting));
        }
    }

    function getMinimalSetting(
        uint256 id
    ) public view returns (bool, MinimalSetting memory) {
        bool isDefault;
        MinimalSetting memory _minimalSetting = minimalSettings[id];
        int128[3] memory _observer = Fixedpoint32x32.unPackVector(
            _minimalSetting.observer
        );
        if (_observer[0] == 0 && _observer[1] == 0) {
            isDefault = true;
            return (isDefault, _minimalSetting);
        } else {
            isDefault = false;
            return (isDefault, _minimalSetting);
        }
    }

    function opacityConverter(uint256 compressd) internal pure returns (uint8) {
        unchecked {
            return uint8((compressd >> 8) & 0xff);
        }
    }

    function rotating_modeConverter(
        uint256 compressd
    ) internal pure returns (bool) {
        unchecked {
            return (compressd & 1) == 1;
        }
    }

    function angular_speed_degConverter(
        uint256 compressd
    ) internal pure returns (uint16) {
        unchecked {
            return uint16((compressd >> 16) & 0xffff);
        }
    }

    function dist_v_normalizeConverter(
        uint256 compressd
    ) internal pure returns (bool) {
        unchecked {
            return (compressd & 2) == 2;
        }
    }

    function face_or_wiretConverter(
        uint256 compressd
    ) internal pure returns (bool) {
        unchecked {
            return (compressd & 4) == 4;
        }
    }

    function wire_colorConverter(
        uint256 compressd
    ) internal pure returns (uint24) {
        unchecked {
            return uint24((compressd >> 32) & 0xffffff);
        }
    }

    function back_colorConverter(
        uint256 compressd
    ) internal pure returns (uint24) {
        unchecked {
            return uint24((compressd >> 56) & 0xffffff);
        }
    }

    function color_listConverter(
        bytes memory colorlist
    ) internal pure returns (uint24[] memory) {
        uint256 len = colorlist.length;
        uint24[] memory _colors = new uint24[](len / 3);
        for (uint256 i; i < len / 3; i++) {
            unchecked {
                _colors[i] = uint24(
                    bytesToUint(
                        abi.encodePacked(
                            colorlist[i * 3],
                            colorlist[i * 3 + 1],
                            colorlist[i * 3 + 2]
                        )
                    )
                );
            }
        }
        return _colors;
    }

    function bytesToUint(bytes memory b) internal pure returns (uint256) {
        uint256 number;
        for (uint256 i = 0; i < b.length; i++) {
            number =
                number +
                uint256(uint8(b[i])) *
                (2 ** (8 * (b.length - (i + 1))));
        }
        return number;
    }
}
