//SPDX-License-Identifier: MIT

import {Fixedpoint32x32} from "./Utils3D/Fixedpoint32x32.sol";

pragma solidity ^0.8.0;

abstract contract SolidData {
    struct Solid {
        string name;
        int128[3][] vertices;
        uint8[] face_list;
        uint8 face_polygon;
    }
    struct PackedSolid {
        uint256[] vertices;
        bytes face_list;
        string name;
        uint8 face_polygon;
    }
    uint256[5] internal number_of_faces = [4, 6, 8, 12, 20];

    // five Solid
    mapping(uint256 => PackedSolid) num2PackedSolid;

    // uploading data of the 5 platonic Solid
    function solidStruct(
        uint8 _tokenId,
        string calldata _name,
        uint256[] calldata _vertices,
        bytes calldata _face_list,
        uint8 _face_polygon
    ) internal {
        num2PackedSolid[_tokenId].name = _name;
        num2PackedSolid[_tokenId].vertices = _vertices;
        num2PackedSolid[_tokenId].face_list = _face_list;
        num2PackedSolid[_tokenId].face_polygon = _face_polygon;
    }

    function getUnPackedSolid(
        uint256 _solidNumber
    ) public view returns (Solid memory) {
        PackedSolid memory _PS = num2PackedSolid[_solidNumber];
        uint256 _len = _PS.vertices.length;
        uint256 _faceLen = number_of_faces[_solidNumber] * _PS.face_polygon;
        uint8[] memory _fl = new uint8[](_faceLen);
        int128[3][] memory _vertices = new int128[3][](_len);
        for (uint56 i = 0; i < _len; i++) {
            uint256 tempUnit = _PS.vertices[i];

            _vertices[i] = Fixedpoint32x32.unPackVector(tempUnit);
        }
        for (uint256 j = 0; j < _faceLen; j++) {
            _fl[j] = uint8(_PS.face_list[j]);
        }
        return Solid(_PS.name, _vertices, _fl, _PS.face_polygon);
    }
}
