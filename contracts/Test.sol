//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Test {
    struct GeneralSetting {
        int128[3] observer;
        string opacity;
        bool rotating_mode;
        uint16 angular_speed_deg;
        bool dist_v_normalize;
        bool face_or_wire;
        uint24 wire_color;
        uint24[] color_list;
    }

    GeneralSetting private defaultSetting;
    mapping(uint256 => GeneralSetting) generalSettings;

    constructor() {
        inital_array();
    }

    function inital_array() private {
        // num2solid[1].name = "Cube";
        defaultSetting.observer = [int128(4) << 64, int128(4) << 64, int128(0)];

        ////
        defaultSetting.wire_color = 16737945;
        defaultSetting.face_or_wire = false;
        defaultSetting.opacity = "80";
        defaultSetting.rotating_mode = true;
        defaultSetting.angular_speed_deg = 0;
        defaultSetting.dist_v_normalize = true;
        defaultSetting.color_list = [
            16761600,
            15158332,
            3447003,
            3066993,
            10181046,
            15844367,
            2600544,
            2719929,
            9323693,
            15965202,
            12597547,
            1752220,
            3426654,
            8359053,
            1482885,
            13849600,
            12436423,
            2899536,
            15787660,
            16101441
        ];
    }

    function getSetting(
        uint256 id
    ) public view returns (GeneralSetting memory) {
        GeneralSetting memory _generalSetting = generalSettings[id];
        if (
            _generalSetting.observer[0] == 0 && _generalSetting.observer[1] == 0
        ) {
            _generalSetting = defaultSetting;
        }

        return _generalSetting;
    }

    function setSetting(
        uint256 id,
        int128[3] calldata _observer,
        uint8 _opacity,
        bool _rotating_mode,
        uint8 _angular_speed_deg,
        bool _dist_v_normalize,
        bool _face_or_wire,
        uint24 _wire_color,
        uint24[] calldata _color_list
    ) public {
        require(_color_list.length == 24);
        generalSettings[id] = GeneralSetting({
            observer: _observer,
            opacity: uint2str(_opacity),
            rotating_mode: _rotating_mode,
            angular_speed_deg: _angular_speed_deg,
            dist_v_normalize: _dist_v_normalize,
            face_or_wire: _face_or_wire,
            wire_color: _wire_color,
            color_list: _color_list
        });
    }

    function uint2str(
        uint256 _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
// GeneralSetting {
//         int128[3] observer;
//         string opacity;
//         bool rotating_mode;
//         uint16 angular_speed_deg;
//         bool dist_v_normalize;
//         bool face_or_wire;
//         uint24 wire_color;
//         uint24[] color_list;
//     }
