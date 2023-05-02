//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Base64} from "./utils/Base64.sol";
import "./access/Ownable.sol";

import "./lib/ABDKMath64x64.sol";
import "./lib/Trigonometry.sol";

import "./interfaces/IMetadataRenderer.sol";
import "./interfaces/IERC721mini.sol";

/**
 * @dev the following contract is a thought experiment of first 3d graphics rendering by Etherum,
 * for this experiment we nominateted platonic solids to render becuase they are a good benchmark
 * for validating rendering algorithm due to high degree of symetry, this implemntation is based on
 * painters algorithm and also have the capability to render in polygon mode and wireframe mode,
 * these objects are interactive and token owners can change the observer position of the rendering scene,
 * or change the polygon colors of their token, and someothere things.
 * for more info please visit https://OnChain3d.xyz
 */

contract OnChain3dMetadataRenderer2 is Ownable, IMetadataRenderer {
    IERC721mini public targetContract;
    string private _contractURI;

    uint256 constant Pi = 3141592653589793238;
    //observer distance to projection plane = 1
    int128 constant dist = 18446744073709551616;
    //// svg header
    string private constant svgHead =
        '<svg width="1000" height="1000" viewBox="0 0 1000 1000" fill="none" xmlns="http://www.w3.org/2000/svg">';
    string private constant svgTail = "</svg>";
    // parts for rendering polygon svg

    string private constant p1 = '<polygon points="';
    string private constant p2 = '" fill="';

    string private constant p3 = '" opacity="0.';
    string private constant p4 = '" />';

    /// struct to carry data along the the {renderTokenById} and {previewTokenById} - too many stack too deep
    struct deepstruct {
        int128[3] _plane_normal;
        int128[3] _plane_vs_observer;
        int128[3] _center;
        int128[3] _observer;
        uint256[] _face_index;
        int128[] _projected_points_in_3d;
        int128[3] _z_prime;
        int128[3] _x_prime;
        int128[] _projected_points_in_2d;
        uint64[] pix0;
    }

    // struct to carry data along the the {svgPolygon}  to  cumpute polygon setting- too many stack too deep
    struct poly_struct {
        uint64[] pix;
        uint256[] sorted_index;
        uint8[] face_list;
        uint24[] color_list;
        uint8 opacity;
        uint8 polygon;
        bool face_or_wire;
        uint24 wire_color;
        uint24 back_color;
    }
    // struct to carry data inside the {scaledPoints}
    struct pix_struct {
        int128[] points_2d;
        int128[3] _observer;
        bool _dist_v_normalize;
    }
    // struct for holding data of 5 solid that many tokens uses
    struct solid {
        string name;
        int128[3][] vertices;
        // bool[] adjacency_matrix;
        uint8[] face_list;
        uint8 face_polygon;
    }
    // struct for holding each token setting
    struct GeneralSetting {
        int128[3] observer;
        uint8 opacity;
        bool rotating_mode;
        uint16 angular_speed_deg;
        bool dist_v_normalize;
        bool face_or_wire;
        uint24 back_color;
        uint24 wire_color;
        uint24[] color_list;
    }
    struct MinimalSetting {
        int128[3] observer;
        uint256 compressed;
        bytes colorlist;
    }

    // defualt value for token that has not set their generalSettings[tokenId] yet.
    //defualt
    int128[3] private defaultObserver = [
        int128(73786976294838206464),
        73786976294838206464,
        18446744073709551616
    ];
    uint256 private constant defaultCompressed =
        2575379241833274503823015105670432005;
    bytes private constant defaultColorlist =
        hex"ffc300e74c3c3498db2ecc719b59b6f1c40f27ae602980b98e44adf39c12c0392b1abc9c34495e7f8c8d16a085d35400bdc3c72c3e50f0e68cf5b041";
    //
    // GeneralSetting private defaultSetting;
    // five solid
    mapping(uint256 => solid) num2solid;
    // tokenId -> GeneralSetting
    mapping(uint256 => MinimalSetting) minimalSettings;
    // number of faces of each solid
    uint256[5] private number_of_faces = [4, 6, 8, 12, 20];

    constructor() {}

    function setTargetAddress(IERC721mini _targetAddress) public onlyOwner {
        targetContract = _targetAddress;
    }

    function setContractURI(string memory _uri) public onlyOwner {
        _contractURI = _uri;
    }

    // uploading data of the 5 platonic solid
    function solidStruct_IMU(
        uint8 _tokenId,
        string calldata _name,
        int128[3][] calldata _vertices,
        uint8[] calldata _face_list,
        uint8 _face_polygon
    ) public onlyOwner {
        num2solid[_tokenId].name = _name;
        num2solid[_tokenId].vertices = _vertices;

        num2solid[_tokenId].face_list = _face_list;
        num2solid[_tokenId].face_polygon = _face_polygon;
    }

    function getSolid(uint256 _solidNumber) public view returns (solid memory) {
        return num2solid[_solidNumber];
    }

    // a  function to unpack the packed data of minimal setting to general setting
    function minimalToGeneral(
        MinimalSetting memory _minimal
    ) internal pure returns (GeneralSetting memory) {
        uint256 _comp = _minimal.compressed;
        return
            GeneralSetting({
                observer: _minimal.observer,
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
    function setMinimalSetting(
        uint256 id,
        int128[3] calldata _observer,
        uint256 _compressed,
        bytes calldata _colorlist
    ) public {
        // this function is only callable by token Owner
        require(
            targetContract.ownerOf(id) == msg.sender,
            "You must own the token"
        );
        require(
            _colorlist.length == number_of_faces[id % 5] * 3,
            "wrong number of colors"
        );
        require(
            opacityConverter(_compressed) < 100,
            "opacity should be less than 100"
        );
        int128[3] memory tempObserver = [_observer[0], _observer[1], int128(0)];
        int128 tempNorm = norm(tempObserver);
        require(tempNorm > 64563604257983430656, "too close");
        minimalSettings[id] = MinimalSetting(
            _observer,
            _compressed,
            _colorlist
        );
    }

    // retrive setting
    function getGeneralSetting(
        uint256 id
    ) public view returns (bool, GeneralSetting memory) {
        bool isDefault;
        MinimalSetting memory _minimalSetting = minimalSettings[id];
        if (
            _minimalSetting.observer[0] == 0 && _minimalSetting.observer[1] == 0
        ) {
            isDefault = true;
            // return (isDefault, defaultSetting);
            return (
                isDefault,
                minimalToGeneral(
                    MinimalSetting(
                        defaultObserver,
                        defaultCompressed,
                        defaultColorlist
                    )
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
        if (
            _minimalSetting.observer[0] == 0 && _minimalSetting.observer[1] == 0
        ) {
            isDefault = true;
            return (isDefault, _minimalSetting);
        } else {
            isDefault = false;
            return (isDefault, _minimalSetting);
        }
    }

    // return the cross product of two vector
    function cross(
        int128[3] memory a,
        int128[3] memory b
    ) internal pure returns (int128[3] memory) {
        int128[3] memory d;
        d[0] = ABDKMath64x64.sub(
            ABDKMath64x64.mul(a[1], b[2]),
            ABDKMath64x64.mul(a[2], b[1])
        );
        d[1] = ABDKMath64x64.sub(
            ABDKMath64x64.mul(a[2], b[0]),
            ABDKMath64x64.mul(a[0], b[2])
        );
        d[2] = ABDKMath64x64.sub(
            ABDKMath64x64.mul(a[0], b[1]),
            ABDKMath64x64.mul(a[1], b[0])
        );
        return d;
    }

    // return the dot product of two vector
    function dot(
        int128[3] memory a,
        int128[3] memory b
    ) internal pure returns (int128) {
        int128 d = 0;
        d += ABDKMath64x64.mul(a[0], b[0]);
        d += ABDKMath64x64.mul(a[1], b[1]);
        d += ABDKMath64x64.mul(a[2], b[2]);
        return d;
    }

    // compute the norm of a vector
    function norm(int128[3] memory a) internal pure returns (int128) {
        return ABDKMath64x64.sqrt(dot(a, a));
    }

    // returns the vector ab , vector form point a to b, and return it as a fixed point 64x6x integer[3]
    function line_vector(
        int128[3] memory a,
        int128[3] memory b
    ) internal pure returns (int128[3] memory) {
        int128[3] memory d;

        d[0] = ABDKMath64x64.sub(b[0], a[0]);
        d[1] = ABDKMath64x64.sub(b[1], a[1]);
        d[2] = ABDKMath64x64.sub(b[2], a[2]);
        return d;
    }

    // compute the center of the solid object
    function center(
        int128[3][] memory vertices0
    ) internal pure returns (int128[3] memory) {
        int128[3] memory d = [
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(0)
        ];
        uint256 len = vertices0.length;
        for (uint256 i = 0; i < len; i++) {
            d[0] = ABDKMath64x64.add(d[0], vertices0[i][0]);
            d[1] = ABDKMath64x64.add(d[1], vertices0[i][1]);
            d[2] = ABDKMath64x64.add(d[2], vertices0[i][2]);
        }
        d[0] = ABDKMath64x64.div(d[0], ABDKMath64x64.fromUInt(len));
        d[1] = ABDKMath64x64.div(d[1], ABDKMath64x64.fromUInt(len));
        d[2] = ABDKMath64x64.div(d[2], ABDKMath64x64.fromUInt(len));
        return d;
    }

    // compute the relative observer from the center of tthe solid object and compute the rotation along z axis if need per 15 min
    function relative_observer(
        int128[3] memory observer0,
        int128[3] memory center0,
        uint256 angle_deg,
        bool rotating_mode
    ) internal view returns (int128[3] memory) {
        int128[3] memory d = [
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(0)
        ];

        if (rotating_mode) {
            uint256 tetha_rad = ((block.timestamp / 900) *
                (angle_deg % 360) *
                Pi) / 180;
            int128 si = ABDKMath64x64.div(
                ABDKMath64x64.fromInt(Trigonometry.sin(tetha_rad)),
                ABDKMath64x64.fromInt(1e18)
            );
            int128 cosi = ABDKMath64x64.div(
                ABDKMath64x64.fromInt(Trigonometry.cos(tetha_rad)),
                ABDKMath64x64.fromInt(1e18)
            );
            d = [
                dot([cosi, -si, 0], observer0),
                dot([si, cosi, 0], observer0),
                observer0[2]
            ];
        } else {
            d = observer0;
        }

        d[0] = ABDKMath64x64.add(d[0], center0[0]);
        d[1] = ABDKMath64x64.add(d[1], center0[1]);
        d[2] = ABDKMath64x64.add(d[2], center0[2]);

        return d;
    }

    // compute normal vector of the projection plane
    function plane_normal_vector(
        int128[3] memory relative_observer0,
        int128[3] memory center0
    ) internal pure returns (int128[3] memory) {
        int128[3] memory d;
        d = line_vector(relative_observer0, center0);
        int128 n = norm(d);
        d[0] = ABDKMath64x64.div(d[0], n);
        d[1] = ABDKMath64x64.div(d[1], n);
        d[2] = ABDKMath64x64.div(d[2], n);
        return d;
    }

    // middle point of the projection plane
    function plane_vs_observer(
        int128[3] memory relative_observer0,
        int128[3] memory plane_normal0
    ) internal pure returns (int128[3] memory) {
        int128[3] memory d = [
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(0)
        ];
        d[0] = ABDKMath64x64.add(
            relative_observer0[0],
            ABDKMath64x64.mul(dist, plane_normal0[0])
        );
        d[1] = ABDKMath64x64.add(
            relative_observer0[1],
            ABDKMath64x64.mul(dist, plane_normal0[1])
        );
        d[2] = ABDKMath64x64.add(
            relative_observer0[2],
            ABDKMath64x64.mul(dist, plane_normal0[2])
        );
        return d;
    }

    // points intersection with observer plane in 3d
    function projectedPointsIn3d(
        int128[3] memory relative_observer0,
        int128[3] memory plane_normal0,
        int128[3][] memory vertices0
    ) internal pure returns (int128[] memory) {
        int128[] memory _pointsIn3d = new int128[](vertices0.length * 3);

        int128[3] memory a;
        int128 t;
        for (uint256 i = 0; i < vertices0.length; i++) {
            a = line_vector(relative_observer0, vertices0[i]);

            t = dot(a, plane_normal0);
            _pointsIn3d[i * 3 + 0] = ABDKMath64x64.add(
                ABDKMath64x64.div(a[0], t),
                relative_observer0[0]
            );
            _pointsIn3d[i * 3 + 1] = ABDKMath64x64.add(
                ABDKMath64x64.div(a[1], t),
                relative_observer0[1]
            );
            _pointsIn3d[i * 3 + 2] = ABDKMath64x64.add(
                ABDKMath64x64.div(a[2], t),
                relative_observer0[2]
            );
        }

        return _pointsIn3d;
    }

    // point in projection plane with respect of Z_prime, X_prime as new coordinate system with origin at observer_vs_plane point
    function projectedPointsIn2d(
        int128[] memory points_3d,
        int128[3] memory z_prime0,
        int128[3] memory x_prime0,
        int128[3] memory observer_vs_plane0
    ) internal pure returns (int128[] memory) {
        uint256 len = (points_3d.length / 3);
        int128[] memory points_in_2d = new int128[](len * 2);
        for (uint256 i; i < len; i++) {
            points_in_2d[i * 2 + 0] = dot(
                line_vector(
                    observer_vs_plane0,
                    [
                        points_3d[i * 3 + 0],
                        points_3d[i * 3 + 1],
                        points_3d[i * 3 + 2]
                    ]
                ),
                x_prime0
            );
            points_in_2d[i * 2 + 1] = dot(
                line_vector(
                    observer_vs_plane0,
                    [
                        points_3d[i * 3 + 0],
                        points_3d[i * 3 + 1],
                        points_3d[i * 3 + 2]
                    ]
                ),
                z_prime0
            );
        }

        return points_in_2d;
    }

    // points scaled for the rendering from fixedpoint 64x64 to uint64, and normalization of the plane if neccesary
    function scaledPoints(
        pix_struct memory _pxs
    ) internal pure returns (uint64[] memory) {
        int128 mx0; // maximum of X coordinate

        uint16 _t = 500;
        int128 mx1; //maximum of Y coordinate
        int128 scale_factor;
        int128[] memory points_2d = _pxs.points_2d;
        mx0 = points_2d[0];
        mx1 = points_2d[1];
        uint64[] memory pix = new uint64[](points_2d.length);
        // assert(pix.length == 16);
        // return pix;
        for (uint256 i; i < (points_2d.length / 2); i++) {
            if (mx0 < points_2d[i * 2 + 0]) {
                mx0 = points_2d[i * 2 + 0];
            }
            if (mx1 < points_2d[i * 2 + 1]) {
                mx1 = points_2d[i * 2 + 1];
            }
        }
        if (mx0 < mx1) {
            mx0 = mx1;
        } // mx0 : maximum of X and Y coordinate

        if (_pxs._dist_v_normalize) {
            scale_factor = ABDKMath64x64.div(
                ABDKMath64x64.fromUInt(_t),
                norm(_pxs._observer)
            );
        } else {
            // scale_factor = ABDKMath64x64.fromUInt(_t);
            scale_factor = ABDKMath64x64.div(
                ABDKMath64x64.fromUInt(_t),
                ABDKMath64x64.fromUInt(2)
            );
        }
        // max(mx0 ,mx1) mx
        for (uint256 i; i < (points_2d.length / 2); i++) {
            pix[i * 2 + 0] = ABDKMath64x64.toUInt(
                ABDKMath64x64.add(
                    ABDKMath64x64.div(
                        ABDKMath64x64.mul(points_2d[i * 2 + 0], scale_factor),
                        mx0
                    ),
                    ABDKMath64x64.fromUInt(_t)
                )
            );
            pix[i * 2 + 1] = ABDKMath64x64.toUInt(
                ABDKMath64x64.add(
                    ABDKMath64x64.div(
                        ABDKMath64x64.mul(points_2d[i * 2 + 1], scale_factor),
                        mx0
                    ),
                    ABDKMath64x64.fromUInt(_t)
                )
            );
        }
        return pix;
    }

    // poject vector (0,0,-1) to the plane
    function z_prime(
        int128[3] memory plane_normal0
    ) internal pure returns (int128[3] memory) {
        int128[3] memory z = [
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(-1)
        ];
        //svg has left handed coordinate system hence -z
        int128[3] memory z_p;
        int128 nz;
        int128 dz;
        dz = dot(z, plane_normal0);
        z_p[0] = ABDKMath64x64.sub(
            z[0],
            ABDKMath64x64.mul(dz, plane_normal0[0])
        );
        z_p[1] = ABDKMath64x64.sub(
            z[1],
            ABDKMath64x64.mul(dz, plane_normal0[1])
        );
        z_p[2] = ABDKMath64x64.sub(
            z[2],
            ABDKMath64x64.mul(dz, plane_normal0[2])
        );
        nz = norm(z_p);
        z_p[0] = ABDKMath64x64.div(z_p[0], nz);
        z_p[1] = ABDKMath64x64.div(z_p[1], nz);
        z_p[2] = ABDKMath64x64.div(z_p[2], nz);

        return z_p;
    }

    // cross Z-prime with plane normal to find a perpendicular vetor to z_prime, inside the plane
    function x_prime(
        int128[3] memory plane_normal0,
        int128[3] memory z_prime0
    ) internal pure returns (int128[3] memory) {
        return cross(z_prime0, plane_normal0);
    }

    // depth sorting face polygons to be rendered
    function face_index(
        int128[3] memory relative_observer0,
        int128[3][] memory vertices0,
        uint8[] memory face_list0,
        uint8 polygon0
    ) internal pure returns (uint256[] memory) {
        uint256 face_list_length0 = face_list0.length / polygon0;
        int128[] memory df = new int128[](face_list_length0);
        int128 mx;
        uint256 mxi;
        uint256[] memory sorted_index = new uint256[](face_list_length0);

        for (uint256 i; i < face_list_length0; i++) {
            for (uint256 j; j < polygon0; j++) {
                mx = norm(
                    line_vector(
                        vertices0[face_list0[i * polygon0 + j]],
                        relative_observer0
                    )
                );
                df[i] = ABDKMath64x64.add(df[i], mx);
            }
        }
        mx = 0; // delete mx value
        for (uint256 i; i < face_list_length0; i++) {
            for (uint256 j; j < face_list_length0; j++) {
                if (mx < df[j]) {
                    mx = df[j];
                    mxi = j;
                }
            }
            delete df[mxi];
            // df[mxi]
            sorted_index[i] = mxi;
            mx = 0;
        }
        return sorted_index;
    }

    // rendering token SVG with the polygon setting (face)
    function svgPolygon(
        poly_struct memory pls0
    ) internal pure returns (string memory) {
        // uint
        string memory a = string(
            abi.encodePacked(
                '<rect x="0" y="0" width="1000" height="1000" fill="#',
                toHexString(pls0.back_color, 3),
                '" /><g stroke="#',
                toHexString(pls0.wire_color, 3),
                '" stroke-width="1.42" stroke-opacity="0.69">'
            )
        );
        uint8[] memory face_list0 = pls0.face_list;
        uint8 _polygon = pls0.polygon;
        uint256 face_list_length0 = face_list0.length / _polygon;
        uint24 color;
        uint24[] memory color_list0 = pls0.color_list;
        uint64[] memory pix0 = pls0.pix;
        string memory opacityStr = string(
            abi.encodePacked(
                uint2str(pls0.opacity / 10),
                uint2str(pls0.opacity % 10)
            )
        );

        uint256[] memory sorted_index0 = pls0.sorted_index;
        uint256 t = 0;
        uint256 t2 = 0;
        uint64 x0 = 0;
        uint64 y0 = 0;

        for (uint256 i = 0; i < face_list_length0; i++) {
            a = string(abi.encodePacked(a, p1));

            color = color_list0[sorted_index0[i]];
            t = sorted_index0[i];

            for (uint256 j; j < _polygon; j++) {
                t2 = face_list0[t * _polygon + j] * 2;
                x0 = pix0[t2];
                // x0 = 0;
                y0 = pix0[t2 + 1];

                a = string(abi.encodePacked(a, uint2str(x0), ","));
                a = string(abi.encodePacked(a, uint2str(y0), " "));
            }
            if (pls0.face_or_wire) {
                a = string(
                    abi.encodePacked(a, p2, "#", toHexString(color, 3), p3)
                );
            } else {
                a = string(abi.encodePacked(a, p2, "none", p3));
            }
            a = string(abi.encodePacked(a, opacityStr, p4));
        }

        return string(abi.encodePacked(a, "</g>"));
    }

    // preparing setting of token for {previewTokenById}
    function preSetting(
        uint256 id,
        int128[3] calldata _observer,
        uint256 _compressed,
        bytes calldata _colorlist
    ) internal view returns (GeneralSetting memory) {
        require(
            _colorlist.length == number_of_faces[id % 5] * 3,
            "wrong number of colors"
        );
        require(
            opacityConverter(_compressed) < 100,
            "opacity should be less than 100"
        );
        int128[3] memory tempObserver = [_observer[0], _observer[1], int128(0)];
        int128 tempNorm = norm(tempObserver);
        require(tempNorm > 64563604257983430656, "too close");
        return
            minimalToGeneral(
                MinimalSetting(_observer, _compressed, _colorlist)
            );
    }

    //for preview the tokenSVG with new setting, see EIP-4883
    function previewTokenById(
        uint256 tid,
        int128[3] calldata _observerP,
        uint256 _compressedP,
        bytes calldata _colorlistP
    ) public view returns (string memory) {
        solid memory _solid = num2solid[tid % 5];

        GeneralSetting memory _generalSetting = preSetting(
            tid,
            _observerP,
            _compressedP,
            _colorlistP
        );

        pix_struct memory pxs;
        poly_struct memory pls;
        deepstruct memory _deepstruct;

        int128[3] memory _observer = _generalSetting.observer;
        _deepstruct._center = center(_solid.vertices);

        _observer = relative_observer(
            _observer,
            _deepstruct._center,
            _generalSetting.angular_speed_deg,
            _generalSetting.rotating_mode
        );
        _deepstruct._plane_normal = plane_normal_vector(
            _observer,
            _deepstruct._center
        );
        _deepstruct._plane_vs_observer = plane_vs_observer(
            _observer,
            _deepstruct._plane_normal
        );

        _deepstruct._z_prime = z_prime(_deepstruct._plane_normal);
        _deepstruct._x_prime = x_prime(
            _deepstruct._plane_normal,
            _deepstruct._z_prime
        );

        _deepstruct._projected_points_in_3d = projectedPointsIn3d(
            _observer,
            _deepstruct._plane_normal,
            _solid.vertices
        );

        _deepstruct._projected_points_in_2d = projectedPointsIn2d(
            _deepstruct._projected_points_in_3d,
            _deepstruct._z_prime,
            _deepstruct._x_prime,
            _deepstruct._plane_vs_observer
        );
        pxs.points_2d = _deepstruct._projected_points_in_2d;
        pxs._observer = _generalSetting.observer;
        pxs._dist_v_normalize = _generalSetting.dist_v_normalize;

        _deepstruct.pix0 = scaledPoints(pxs);

        _deepstruct._face_index = face_index(
            _observer,
            _solid.vertices,
            _solid.face_list,
            _solid.face_polygon
        );

        pls.pix = _deepstruct.pix0;
        pls.face_list = _solid.face_list;
        pls.color_list = _generalSetting.color_list;
        pls.sorted_index = _deepstruct._face_index;
        pls.opacity = _generalSetting.opacity;
        pls.polygon = _solid.face_polygon;
        pls.wire_color = _generalSetting.wire_color;
        pls.face_or_wire = _generalSetting.face_or_wire;
        pls.back_color = _generalSetting.back_color;

        return svgPolygon(pls);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        string memory _svg = string(
            abi.encodePacked(svgHead, (renderTokenById(tokenId)), svgTail)
        );
        string memory _metadataTop = string(
            abi.encodePacked(
                '{"description": "interactive 3D objects fully on-chain, rendered by Etherum.", "name": "',
                num2solid[tokenId % 5].name,
                " ",
                uint2str(tokenId / 5),
                '" ,"attributes": [{"display_type": "number", "trait_type": "tokenId", "value": ',
                uint2str(tokenId),
                '},{"trait_type": "polyhydron", "value": "',
                num2solid[tokenId % 5].name,
                '"}]'
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                _metadataTop,
                                '  , "image": "data:image/svg+xml;base64,',
                                Base64.encode(bytes(_svg)),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    // for more detail see EIP-4883, renderTokenById -- Too many stack too deep see
    function renderTokenById(uint256 tid) public view returns (string memory) {
        solid memory _solid = num2solid[tid % 5];

        // GeneralSetting memory _generalSetting = generalSettings[tid];
        GeneralSetting memory _generalSetting;
        bool b;
        (b, _generalSetting) = getGeneralSetting(tid);

        //structs to carry data - to avoid stack too deep
        pix_struct memory pxs;
        deepstruct memory _deepstruct;
        poly_struct memory pls;

        int128[3] memory _observer = _generalSetting.observer;
        _deepstruct._center = center(_solid.vertices);
        // relative observer with respect to center of the solid object
        _observer = relative_observer(
            _observer,
            _deepstruct._center,
            _generalSetting.angular_speed_deg,
            _generalSetting.rotating_mode
        );
        // projection plane normal vector
        _deepstruct._plane_normal = plane_normal_vector(
            _observer,
            _deepstruct._center
        );
        // new origin in the projection plane
        _deepstruct._plane_vs_observer = plane_vs_observer(
            _observer,
            _deepstruct._plane_normal
        );
        // z_prime , normalize projection of (0,0,-1) uint vector to projection plane
        _deepstruct._z_prime = z_prime(_deepstruct._plane_normal);
        // cross product of z_prime with plane normal to get the perpendicular vector inside the projection plane
        _deepstruct._x_prime = x_prime(
            _deepstruct._plane_normal,
            _deepstruct._z_prime
        );
        // projected point onto projection plane in 3d
        _deepstruct._projected_points_in_3d = projectedPointsIn3d(
            _observer,
            _deepstruct._plane_normal,
            _solid.vertices
        );
        //  projection points onto the plane in 2d
        _deepstruct._projected_points_in_2d = projectedPointsIn2d(
            _deepstruct._projected_points_in_3d,
            _deepstruct._z_prime,
            _deepstruct._x_prime,
            _deepstruct._plane_vs_observer
        );
        pxs.points_2d = _deepstruct._projected_points_in_2d;
        pxs._observer = _generalSetting.observer;
        pxs._dist_v_normalize = _generalSetting.dist_v_normalize;
        // scaling the points and removing decimal point
        _deepstruct.pix0 = scaledPoints(pxs);

        _deepstruct._face_index = face_index(
            _observer,
            _solid.vertices,
            _solid.face_list,
            _solid.face_polygon
        );

        pls.pix = _deepstruct.pix0;
        pls.face_list = _solid.face_list;
        pls.color_list = _generalSetting.color_list;
        pls.sorted_index = _deepstruct._face_index;
        pls.opacity = _generalSetting.opacity;
        pls.polygon = _solid.face_polygon;
        pls.wire_color = _generalSetting.wire_color;
        pls.face_or_wire = _generalSetting.face_or_wire;
        pls.back_color = _generalSetting.back_color;

        return svgPolygon(pls);
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
    ) public pure returns (uint24[] memory) {
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

    //needs check
    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes16 _SYMBOLS = "0123456789abcdef";
        bytes memory buffer = new bytes(2 * length);
        // buffer[0] = "0";
        // buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i - 2] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function initializeWithData(bytes memory) public pure {
        revert("not callable");
    }
}
