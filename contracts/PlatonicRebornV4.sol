//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Base64} from "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Base64.sol";

import "./ABDKMath64x64.sol";
import "./Trigonometry.sol";

contract PlatonicRebornV3 {
    uint256 Pi = 3141592653589793238;
    //remove before deploy
    uint256 s = 0;
    //observer distance to projection plane
    int128 public dist = ABDKMath64x64.fromInt(1);
    //// svg header
    string private svgHead =
        '<svg width="%100" height="%100" viewBox="0 0 1000 1000" fill="white" xmlns="http://www.w3.org/2000/svg">';
    string private svgTail = "</svg>";
    // parts for rendering polygon svg

    string private p1 = '<polygon points="';
    string private p2 = '" fill="#';

    string private p3 = '" opacity="0.';
    string private p4 = '" />';

    ////
    // parts for rendering wireframe svg
    string private l1 = '<line x1="';
    string private l2 = '" y1="';
    string private l3 = '" x2="';
    string private l4 = '" y2="';
    string private l5 = '" stroke="#';
    string private l6 = '" stroke-width="2"/>';

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

    // struct to carry data along the the {svgWireframe} to  cumpute wireframe setting- too many stack too deep
    struct wire_struct {
        uint64[] pix;
        bool[] adj;
        uint24 wire_color;
        uint256 lenVertices;
        string headstring;
    }
    // struct to carry data along the the {svgPolygon}  to  cumpute polygon setting- too many stack too deep
    struct poly_struct {
        uint64[] pix;
        uint256[] sorted_index;
        uint8[] face_list;
        uint24[] color_list;
        uint8 opacity;
        uint8 polygon;
        // string headstring;
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
        bool[] adjacency_matrix;
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
        uint24 wire_color;
        uint24[] color_list;
    }
    // defualt value for token that has not set their generalSettings[tokenId] yet.
    GeneralSetting private defaultSetting;
    // five solid
    mapping(uint256 => solid) num2solid;
    // tokenId -> GeneralSetting
    mapping(uint256 => GeneralSetting) generalSettings;
    // number of faces of each solid
    uint256[5] private number_of_faces = [4, 6, 8, 12, 20];

    // uploading data of the 5 platonic solid
    function solidStruct_IMU(
        uint8 _tokenId,
        string calldata _name,
        int128[3][] calldata _vertices,
        bool[] calldata _adjacency_matrix,
        uint8[] calldata _face_list,
        uint8 _face_polygon
    ) external {
        num2solid[_tokenId].name = _name;
        num2solid[_tokenId].vertices = _vertices;
        num2solid[_tokenId].adjacency_matrix = _adjacency_matrix;
        num2solid[_tokenId].face_list = _face_list;
        num2solid[_tokenId].face_polygon = _face_polygon;
    }

    // initialize the default value, set in the constructor
    function inital_array() private {
        defaultSetting.observer = [
            ABDKMath64x64.fromInt(4),
            ABDKMath64x64.fromInt(4),
            ABDKMath64x64.fromInt(-8)
        ];

        ////
        defaultSetting.wire_color = 16737945;
        defaultSetting.face_or_wire = true;
        defaultSetting.opacity = 9;
        defaultSetting.rotating_mode = false;
        defaultSetting.angular_speed_deg = 0;
        defaultSetting.dist_v_normalize = false;
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

    constructor() {
        inital_array();
    }

    // set setting
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
        require(
            _color_list.length <= number_of_faces[id % 5],
            "wrong number of colors"
        );
        require(_opacity < 100, "opacity should be less than 100");
        int128[3] memory tempObserver = [_observer[0], _observer[1], int128(0)];
        int128 tempNorm = norm(tempObserver);
        require(tempNorm > 55340232221128654848, "too close");

        generalSettings[id] = GeneralSetting({
            observer: _observer,
            opacity: _opacity,
            rotating_mode: _rotating_mode,
            angular_speed_deg: _angular_speed_deg,
            dist_v_normalize: _dist_v_normalize,
            face_or_wire: _face_or_wire,
            wire_color: _wire_color,
            color_list: _color_list
        });
    }

    // retrive setting
    function getSetting(
        uint256 id
    ) public view returns (GeneralSetting memory) {
        return generalSettings[id];
    }

    // return the cross product of to vector
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

    // return the dot product of to vector
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
        uint256 angle_deg
    ) internal view returns (int128[3] memory) {
        int128[3] memory d = [
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(0),
            ABDKMath64x64.fromInt(0)
        ];

        uint256 tetha_rad = ((block.timestamp / 900) * (angle_deg % 360) * Pi) /
            180;
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
    ) internal view returns (int128[3] memory) {
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
    ) public view returns (string memory) {
        string memory a = "";
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
            a = string(abi.encodePacked(a, p2, toHexString(color, 3), p3));

            a = string(abi.encodePacked(a, opacityStr, p4));
        }

        return a;
    }

    // rendering token with wireframe (wire) setting
    function svgWireframe(
        wire_struct memory wrs0
    ) public view returns (string memory) {
        uint256 vLen = wrs0.lenVertices;
        string memory a = "";

        for (uint256 i = 1; i < vLen; i++) {
            for (uint256 j; j < i; j++) {
                if (wrs0.adj[i * vLen + j] == true) {
                    a = string(
                        abi.encodePacked(
                            a,
                            l1,
                            uint2str(wrs0.pix[i * 2 + 0]),
                            l2
                        )
                    );
                    a = string(
                        abi.encodePacked(a, uint2str(wrs0.pix[i * 2 + 1]), l3)
                    );

                    a = string(
                        abi.encodePacked(
                            a,
                            uint2str(wrs0.pix[j * 2 + 0]),
                            l4,
                            uint2str(wrs0.pix[j * 2 + 1]),
                            l5
                        )
                    );
                    a = string(
                        abi.encodePacked(a, toHexString(wrs0.wire_color, 3), l6)
                    );
                }
            }
        }

        // a = string(abi.encodePacked(a, svgTail));
        return a;
    }

    // preparing setting of token for {previewTokenById}
    function preSetting(
        uint256 id,
        int128[3] calldata _observer,
        uint8 _opacity,
        bool _rotating_mode,
        uint8 _angular_speed_deg,
        bool _dist_v_normalize,
        bool _face_or_wire,
        uint24 _wire_color,
        uint24[] calldata _color_list
    ) internal view returns (GeneralSetting memory) {
        require(
            _color_list.length <= number_of_faces[id % 5],
            "wrong number of colors"
        );
        require(_opacity < 100, "opacity should be less than 100");
        int128[3] memory tempObserver = [_observer[0], _observer[1], int128(0)];
        int128 tempNorm = norm(tempObserver);
        require(tempNorm > 55340232221128654848, "too close");
        GeneralSetting memory _generalSetting;
        _generalSetting = GeneralSetting({
            observer: _observer,
            opacity: _opacity,
            rotating_mode: _rotating_mode,
            angular_speed_deg: _angular_speed_deg,
            dist_v_normalize: _dist_v_normalize,
            face_or_wire: _face_or_wire,
            wire_color: _wire_color,
            color_list: _color_list
        });
        return _generalSetting;
    }

    //for preview the tokenSVG with new setting, see EIP-4883
    function previewTokenById(
        uint256 tid,
        int128[3] calldata _observerP,
        uint8 _opacityP,
        bool _rotating_modeP,
        uint8 _angular_speed_degP,
        bool _dist_v_normalizeP,
        bool _face_or_wireP,
        uint24 _wire_colorP,
        uint24[] calldata _color_listP
    ) public view returns (string memory) {
        solid memory _solid = num2solid[tid % 5];

        GeneralSetting memory _generalSetting = preSetting(
            tid,
            _observerP,
            _opacityP,
            _rotating_modeP,
            _angular_speed_degP,
            _dist_v_normalizeP,
            _face_or_wireP,
            _wire_colorP,
            _color_listP
        );

        pix_struct memory pxs;

        deepstruct memory _deepstruct;

        int128[3] memory _observer = _generalSetting.observer;
        _deepstruct._center = center(_solid.vertices);

        _observer = relative_observer(
            _observer,
            _deepstruct._center,
            _generalSetting.angular_speed_deg
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

        if (_generalSetting.face_or_wire) {
            poly_struct memory pls;
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

            // rendering svg in polygon setting
            return svgPolygon(pls);
        } else {
            wire_struct memory wrs;
            wrs.pix = _deepstruct.pix0;
            wrs.adj = _solid.adjacency_matrix;
            wrs.wire_color = _generalSetting.wire_color;

            wrs.lenVertices = _solid.vertices.length;

            // wrs.headstring = "";
            return svgWireframe(wrs);
        }
    }

    //safe cast?
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        string memory _svg = string(
            abi.encodePacked(svgHead, (renderTokenById(tokenId)), svgTail)
        );
        string memory _metadataTop = string(
            abi.encodePacked(
                '{"description": "interactive 3D objects fully on-chain, rendered by Etherum.", "name": "',
                num2solid[tokenId % 5].name,
                " ",
                uint2str(tokenId / 5)
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
                                ' " , "image": "data:image/svg+xml;base64,',
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

        GeneralSetting memory _generalSetting = generalSettings[tid];
        // if setting is not set load defualt setting
        if (
            _generalSetting.observer[0] == 0 && _generalSetting.observer[1] == 0
        ) {
            _generalSetting = defaultSetting;
        }
        //structs to carry data - to avoid stack too deep
        pix_struct memory pxs;
        deepstruct memory _deepstruct;

        int128[3] memory _observer = _generalSetting.observer;
        _deepstruct._center = center(_solid.vertices);
        // relative observer with respect to center of the solid object
        _observer = relative_observer(
            _observer,
            _deepstruct._center,
            _generalSetting.angular_speed_deg
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

        if (_generalSetting.face_or_wire) {
            poly_struct memory pls;
            // depth sorting the polygon (faces)
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

            // rendering svg in polygon setting
            return svgPolygon(pls);
        } else {
            wire_struct memory wrs;
            wrs.pix = _deepstruct.pix0;
            wrs.adj = _solid.adjacency_matrix;
            wrs.wire_color = _generalSetting.wire_color;

            wrs.lenVertices = _solid.vertices.length;

            // rendering svg in wireframe setting
            return svgWireframe(wrs);
        }
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

    ///

    ////
    ///
    function sss() public {
        s += 1;
    }
}
