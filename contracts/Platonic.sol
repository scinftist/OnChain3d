//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/token/ERC721/ERC721.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/token/ERC721/ERC721.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/access/Ownable.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/security/ReentrancyGuard.sol";
// import ABDKMath64x64 ;// from "./ABDK.sol";
// import Trigonometry ;//from "./Trigonometry.sol";
// import {Base64} from "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Base64.sol";

import "./ABDKMath64x64.sol";
import "./Trigonometry.sol";

contract Platonic {
    uint256 Pi = 3141592653589793238;
    uint256 s = 0;
    // int128[3][8] public CO;
    // bool[8][8] public C;
    // uint256[4][6] public CF;
    int128 public dist = ABDKMath64x64.fromInt(1);
    ////
    string headp = '<svg height="400" width="400">';
    string headp0 = '<svg height="';
    string headp1 = '" width="';
    string headp2 = '">';
    string p1 = '<polygon points="';
    string p2 = '" style="fill:rgb(';

    string p3 = ");stroke:purple;opacity:.";
    string p4 = ';stroke-width:1" />';
    string tailp = "</svg>";
    ////
    string headl = '<svg height="400" width="400">';
    string l1 = "<line x1=";
    string l2 = " y1=";
    string l3 = " x2=";
    string l4 = " y2=";
    string l5 = ' style="stroke:rgb(';
    string l6 = ');stroke-width:2"/>';
    string taill = "</svg>";

    /// / aspect ratio + distance aware vs normalize
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
        uint16 hhead;
        uint16 whead;
    }
    // int128[3] memory _plane_normal;
    //     int128[3] memory _plane_vs_observer;
    //     // int128[3][] memory _vertices = num2solid[tid].vertices;
    //     // uint16 _angle = num2solid[tid].angular_speed_deg;
    //     solid memory _solid = num2solid[tid];
    //     int128[3] memory _center;
    //     int128[3] memory _observer = num2solid[tid].observer;
    //     // uint8[][] memory _face_list = num2solid[tid].face_list;
    //     // bool _face_or_wire = num2solid[tid].face_or_wire;
    //     // uint8[3][] memory _color_list = num2solid[tid].color_list;
    //     uint256[] memory _face_index;
    //     int128[] memory _projected_points_in_3d;
    //     int128[3] memory _z_prime;
    //     int128[3] memory _x_prime;
    //     int128[] memory _projected_points_in_2d;
    //     uint64[] memory pix0;

    // if [][] not posible do[] ([]*[]);;;;;;;;;;;;;
    struct wire_struct {
        uint64[] pix;
        bool[][] adj;
        uint8[3] wire_color;
        uint8 aspect_ratio_mode;
        // uint16[2] custome_w_h;
        string headstring;
    }
    struct poly_struct {
        uint64[] pix;
        uint256[] sorted_index;
        uint8[][] face_list;
        uint8[3][] color_list;
        string opacity;
        uint8 aspect_ratio_mode;
        // uint16[2] custome_w_h;
        string headstring;
    }
    struct pix_struct {
        int128[] points_2d;
        int128[3] _observer;
        bool _dist_v_normalize;
        uint8 _aspect_ratio_mode;
        uint16 _custome_h;
        uint16 _custome_w;
    }
    // int128[] memory points_2d,
    //     int128[3] memory _observer,
    //     bool _dist_v_normalize,
    //     uint8 _aspect_ratio_mode,
    //     uint16[2] memory _custome_w_h

    struct solid {
        string name;
        int128[3] observer;
        int128[3][] vertices;
        bool[][] adjacency_matrix;
        uint8[][] face_list;
        uint8 face_polygon;
        uint8[3][] color_list;
        uint8[3] wire_color;
        bool face_or_wire;
        string opacity;
        bool rotating_mode;
        uint16 angular_speed_deg;
        bool dist_v_normalize;
        uint8 aspect_ratio_mode; //0 square ,1 9:16 , 2 custome
        uint16 custome_h;
        uint16 custome_w;
    }
    //uint8?//number of faces ?
    mapping(uint8 => solid) num2solid;

    //num2solid[n].name = 'tetrahydra
    ///covert to 64x64 before deploy

    function inital_array() public {
        num2solid[1].name = "Cube";
        num2solid[1].observer = [
            ABDKMath64x64.fromInt(1),
            ABDKMath64x64.fromInt(2),
            ABDKMath64x64.fromInt(0)
        ];
        num2solid[1].vertices.push(
            [
                ABDKMath64x64.fromInt(0),
                ABDKMath64x64.fromInt(0),
                ABDKMath64x64.fromInt(1)
            ]
        );
        num2solid[1].vertices.push(
            [
                ABDKMath64x64.fromInt(0),
                ABDKMath64x64.fromInt(1),
                ABDKMath64x64.fromInt(1)
            ]
        );
        num2solid[1].vertices.push(
            [
                ABDKMath64x64.fromInt(0),
                ABDKMath64x64.fromInt(0),
                ABDKMath64x64.fromInt(0)
            ]
        );
        num2solid[1].vertices.push(
            [
                ABDKMath64x64.fromInt(0),
                ABDKMath64x64.fromInt(1),
                ABDKMath64x64.fromInt(0)
            ]
        );
        num2solid[1].vertices.push(
            [
                ABDKMath64x64.fromInt(1),
                ABDKMath64x64.fromInt(0),
                ABDKMath64x64.fromInt(1)
            ]
        );
        num2solid[1].vertices.push(
            [
                ABDKMath64x64.fromInt(1),
                ABDKMath64x64.fromInt(1),
                ABDKMath64x64.fromInt(1)
            ]
        );
        num2solid[1].vertices.push(
            [
                ABDKMath64x64.fromInt(1),
                ABDKMath64x64.fromInt(0),
                ABDKMath64x64.fromInt(0)
            ]
        );
        num2solid[1].vertices.push(
            [
                ABDKMath64x64.fromInt(1),
                ABDKMath64x64.fromInt(1),
                ABDKMath64x64.fromInt(0)
            ]
        );
        // num2solid[0].vertices[0] = [int128(0), 0, 0];
        num2solid[1].adjacency_matrix.push(
            [bool(false), true, true, false, true, false, false, false]
        );
        num2solid[1].adjacency_matrix.push(
            [bool(true), false, false, true, false, true, false, false]
        );
        num2solid[1].adjacency_matrix.push(
            [bool(true), false, false, true, false, false, true, false]
        );
        num2solid[1].adjacency_matrix.push(
            [bool(false), true, true, false, false, false, false, true]
        );
        num2solid[1].adjacency_matrix.push(
            [bool(true), false, false, false, false, true, true, false]
        );
        num2solid[1].adjacency_matrix.push(
            [bool(false), true, false, false, true, false, false, true]
        );
        num2solid[1].adjacency_matrix.push(
            [bool(false), false, true, false, true, false, false, true]
        );
        num2solid[1].adjacency_matrix.push(
            [bool(false), false, false, true, false, true, true, false]
        );

        num2solid[1].face_list.push([0, 1, 3, 2]);
        num2solid[1].face_list.push([2, 3, 7, 6]);
        num2solid[1].face_list.push([0, 4, 6, 2]);
        num2solid[1].face_list.push([0, 1, 5, 4]);
        num2solid[1].face_list.push([1, 5, 7, 3]);
        num2solid[1].face_list.push([4, 5, 7, 6]);

        num2solid[1].face_polygon = 4;

        num2solid[1].color_list.push([255, 102, 153]);
        num2solid[1].color_list.push([255, 0, 0]);
        num2solid[1].color_list.push([255, 153, 0]);
        num2solid[1].color_list.push([255, 255, 0]);
        num2solid[1].color_list.push([0, 153, 0]);
        num2solid[1].color_list.push([0, 153, 204]);
        // num2solid[0].color_list.push([51, 0, 153]);
        // num2solid[0].color_list.push([153, 0, 153]);
        ////
        num2solid[1].wire_color = [255, 102, 153];
        num2solid[1].face_or_wire = true;
        num2solid[1].opacity = "50";
        num2solid[1].rotating_mode = true;
        num2solid[1].angular_speed_deg = 0;
        num2solid[1].dist_v_normalize = true;
        num2solid[1].aspect_ratio_mode = 0;
        num2solid[1].custome_h = 1000;
        num2solid[1].custome_w = 1000;

        // num2solid[2].name = "octahydra";

        // num2solid[2].observer = [
        //     ABDKMath64x64.fromInt(3),
        //     ABDKMath64x64.fromInt(0),
        //     ABDKMath64x64.fromInt(1)
        // ];
        // num2solid[2].vertices.push([int128(0), 0, -18446744073709551616]);
        // num2solid[2].vertices.push([int128(0), -18446744073709551616, 0]);
        // num2solid[2].vertices.push([int128(18446744073709551616), 0, 0]);
        // num2solid[2].vertices.push([int128(0), 18446744073709551616, 0]);
        // num2solid[2].vertices.push([int128(18446744073709551616), 0, 0]);
        // num2solid[2].vertices.push([int128(0), 0, 18446744073709551616]);
        // //
        // num2solid[2].adjacency_matrix.push(
        //     [bool(false), true, true, true, true, false]
        // );
        // num2solid[2].adjacency_matrix.push(
        //     [bool(true), false, true, false, true, true]
        // );
        // num2solid[2].adjacency_matrix.push(
        //     [bool(true), true, false, true, false, true]
        // );
        // num2solid[2].adjacency_matrix.push(
        //     [bool(true), false, true, false, true, true]
        // );
        // num2solid[2].adjacency_matrix.push(
        //     [bool(true), true, false, true, false, true]
        // );
        // num2solid[2].adjacency_matrix.push(
        //     [bool(false), true, true, true, true, false]
        // );
        // //
        // num2solid[2].face_list.push([0, 1, 2]);
        // num2solid[2].face_list.push([0, 2, 3]);
        // num2solid[2].face_list.push([0, 3, 4]);
        // num2solid[2].face_list.push([0, 4, 1]);
        // num2solid[2].face_list.push([5, 1, 2]);
        // num2solid[2].face_list.push([5, 2, 3]);
        // num2solid[2].face_list.push([5, 3, 4]);
        // num2solid[2].face_list.push([5, 4, 1]);
        // //
        // num2solid[2].face_polygon = 3;
        // //
        // num2solid[2].color_list.push([255, 102, 153]);
        // num2solid[2].color_list.push([255, 0, 0]);
        // num2solid[2].color_list.push([255, 153, 0]);
        // num2solid[2].color_list.push([255, 255, 0]);
        // num2solid[2].color_list.push([0, 153, 0]);
        // num2solid[2].color_list.push([0, 153, 204]);
        // num2solid[2].color_list.push([51, 0, 153]);
        // num2solid[2].color_list.push([153, 0, 153]);
        // //
        // num2solid[2].wire_color = [255, 102, 153];
        // //
        // num2solid[2].face_or_wire = true;
        // num2solid[2].opacity = "50";
        // num2solid[2].rotating_mode = true;
        // num2solid[2].angular_speed_deg = 17;
    }

    constructor() {
        inital_array();
    }

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

    function norm(int128[3] memory a) internal pure returns (int128) {
        return ABDKMath64x64.sqrt(dot(a, a));
    }

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

    // maybe it's unnecesarry
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

        uint256 tetha_rad = (block.number * (angle_deg % 360) * Pi) / 180;
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

    function new_projected_points_in_3d(
        int128[3] memory relative_observer0,
        int128[3] memory plane_normal0,
        int128[3][] memory vertices0
    ) internal pure returns (int128[] memory) {
        int128[] memory dd = new int128[](vertices0.length * 3);
        // int128[][] memory dd = new int128[3][](CO.length);
        int128[3] memory a;
        int128 t;
        for (uint256 i = 0; i < vertices0.length; i++) {
            a = line_vector(relative_observer0, vertices0[i]);
            // a = line_vector(vertices0[i], relative_observer0);
            t = dot(a, plane_normal0);
            dd[i * 3 + 0] = ABDKMath64x64.add(
                ABDKMath64x64.div(a[0], t),
                relative_observer0[0]
            );
            dd[i * 3 + 1] = ABDKMath64x64.add(
                ABDKMath64x64.div(a[1], t),
                relative_observer0[1]
            );
            dd[i * 3 + 2] = ABDKMath64x64.add(
                ABDKMath64x64.div(a[2], t),
                relative_observer0[2]
            );
        }

        return dd;
    }

    function new_projected_points_in_2d(
        int128[] memory points_3d,
        int128[3] memory z_prime0,
        int128[3] memory x_prime0,
        int128[3] memory observer_vs_plane0
    ) internal pure returns (int128[] memory) {
        int128[] memory d = new int128[](points_3d.length);
        for (uint256 i; i < (points_3d.length / 3); i++) {
            d[i * 2 + 0] = dot(
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
            d[i * 2 + 1] = dot(
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

        return d;
    }

    function new_scaled_newpoints(
        pix_struct memory _pxs
    ) internal pure returns (uint64[] memory) {
        int128 mx0;
        uint16 _w;
        uint16 _h;
        uint16 _t;
        int128 mx1;
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
        }
        // 100 = fs min(w,h)/2
        (_h, _w) = h_w_detection(
            _pxs._aspect_ratio_mode,
            _pxs._custome_h,
            _pxs._custome_w
        );
        if (_w < _h) {
            _t = _w / 2;
        } else {
            _t = _h / 2;
        }

        if (_pxs._dist_v_normalize) {
            scale_factor = ABDKMath64x64.div(
                ABDKMath64x64.fromUInt(_t),
                norm(_pxs._observer)
            );
        } else {
            scale_factor = ABDKMath64x64.fromUInt(_t);
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

    function new_svg_wf(
        wire_struct memory wrs0
    ) public view returns (string memory) {
        // bool[][] memory adj = num2solid[0].adjacency_matrix;

        string memory a = "";
        a = wrs0.headstring;
        for (uint256 i = 1; i < wrs0.adj.length; i++) {
            for (uint256 j; j < i; j++) {
                if (wrs0.adj[i][j] == true) {
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
                        abi.encodePacked(
                            a,
                            uint2str(wrs0.wire_color[0]),
                            ",",
                            uint2str(wrs0.wire_color[1]),
                            ",",
                            uint2str(wrs0.wire_color[2]),
                            l6
                        )
                    );
                }
            }
        }

        a = string(abi.encodePacked(a, taill));
        return a;
    }

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

    function x_prime(
        int128[3] memory plane_normal0,
        int128[3] memory z_prime0
    ) internal pure returns (int128[3] memory) {
        return cross(z_prime0, plane_normal0);
    }

    function face_index(
        int128[3] memory relative_observer0,
        int128[3][] memory vertices0,
        uint8[][] memory face_list0
    ) internal pure returns (uint256[] memory) {
        int128[] memory df = new int128[](face_list0.length);
        int128 mx;
        uint256 mxi;
        uint256[] memory sorted_index = new uint256[](face_list0.length);
        for (uint256 i; i < face_list0.length; i++) {
            for (uint256 j; j < face_list0[0].length; j++)
                df[i] = ABDKMath64x64.add(
                    df[i],
                    norm(
                        line_vector(
                            vertices0[face_list0[i][j]],
                            relative_observer0
                        )
                    )
                );
        }
        for (uint256 i; i < face_list0.length; i++) {
            for (uint256 j; j < face_list0.length; j++) {
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

    function new_svg_poly(
        poly_struct memory pls0
    ) public view returns (string memory) {
        string memory a = "";
        uint8[][] memory face_list0 = pls0.face_list;
        uint8[3] memory color;
        uint8[3][] memory color_list0 = pls0.color_list;
        uint64[] memory pix0 = pls0.pix;
        // string memory opacitystr0 = opacitystr(pls0.opacity);
        uint256[] memory sorted_index0 = pls0.sorted_index;
        uint256 t = 0;
        uint256 t2 = 0;
        uint64 x0 = 0;
        uint64 x1 = 0;
        a = pls0.headstring;
        for (uint256 i = 0; i < face_list0.length; i++) {
            a = string(abi.encodePacked(a, p1));
            color = color_list0[sorted_index0[i]];
            t = sorted_index0[i];
            for (uint256 j; j < face_list0[0].length; j++) {
                t2 = face_list0[t][j] * 2;
                x0 = pix0[t2];
                // x0 = 0;
                x1 = pix0[t2 + 1];
                // x1 = 0;
                a = string(abi.encodePacked(a, uint2str(x0), ","));
                a = string(abi.encodePacked(a, uint2str(x1), " "));

                // a = string(
                //     abi.encodePacked(
                //         a,
                //         uint2str(pix0[j * 2 + 0]),
                //         l4,
                //         uint2str(pix0[j * 2 + 1]),
                //         l5
                //     )
                // );
            }
            a = string(abi.encodePacked(a, p2, uint2str(color[0]), ","));
            a = string(
                abi.encodePacked(
                    a,
                    uint2str(color[1]),
                    ",",
                    uint2str(color[2]),
                    p3
                )
            );
            a = string(abi.encodePacked(a, pls0.opacity, p4));
        }
        a = string(abi.encodePacked(a, tailp));
        return a;
    }

    // function opacitystr(uint8 opacity) public view returns (string memory) {
    //     if (opacity > 99) {
    //         return "1.0";
    //     } else {
    //         return string(abi.encodePacked("0.", uint2str(opacity)));
    //     }
    // }

    function tok_preview(
        uint8 tid,
        bytes calldata _bytes
    ) public view returns (string memory) {
        //returns (string memory)
        // int128[3] memory _plane_normal;
        // int128[3] memory _plane_vs_observer;
        // // int128[3][] memory _vertices = num2solid[tid].vertices;
        // // uint16 _angle = num2solid[tid].angular_speed_deg;
        solid memory _solid; // = num2solid[tid];
        // int128[3] memory _center;
        // int128[3] memory _observer = num2solid[tid].observer;
        // // uint8[][] memory _face_list = num2solid[tid].face_list;
        // // bool _face_or_wire = num2solid[tid].face_or_wire;
        // // uint8[3][] memory _color_list = num2solid[tid].color_list;
        // uint256[] memory _face_index;
        // int128[] memory _projected_points_in_3d;
        // int128[3] memory _z_prime;
        // int128[3] memory _x_prime;
        // int128[] memory _projected_points_in_2d;
        // uint64[] memory pix0;
        wire_struct memory wrs;
        poly_struct memory pls;
        pix_struct memory pxs;
        // preview case + header
        deepstruct memory _deepstruct;

        _solid = update_struct(_bytes, tid);
        // return (_solid.observer[0]);
        //end of preview maniulation
        int128[3] memory _observer = _solid.observer;
        _deepstruct._center = center(_solid.vertices);
        _observer = relative_observer(
            _observer,
            _deepstruct._center,
            _solid.angular_speed_deg
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

        _deepstruct._projected_points_in_3d = new_projected_points_in_3d(
            _observer,
            _deepstruct._plane_normal,
            _solid.vertices
        );
        _deepstruct._projected_points_in_2d = new_projected_points_in_2d(
            _deepstruct._projected_points_in_3d,
            _deepstruct._z_prime,
            _deepstruct._x_prime,
            _deepstruct._plane_vs_observer
        );
        pxs.points_2d = _deepstruct._projected_points_in_2d;
        pxs._observer = _solid.observer;
        pxs._dist_v_normalize = _solid.dist_v_normalize;
        pxs._aspect_ratio_mode = _solid.aspect_ratio_mode;
        pxs._custome_h = _solid.custome_h;
        pxs._custome_w = _solid.custome_w;

        _deepstruct.pix0 = new_scaled_newpoints(pxs);
        (_deepstruct.whead, _deepstruct.hhead) = h_w_detection(
            _solid.aspect_ratio_mode,
            _solid.custome_h,
            _solid.custome_w
        );
        if (_solid.face_or_wire) {
            _deepstruct._face_index = face_index(
                _observer,
                _solid.vertices,
                _solid.face_list
            );

            pls.pix = _deepstruct.pix0;
            pls.face_list = _solid.face_list;
            pls.color_list = _solid.color_list;
            pls.sorted_index = _deepstruct._face_index;
            pls.opacity = _solid.opacity;
            pls.headstring = head_func(_deepstruct.hhead, _deepstruct.whead);
            return new_svg_poly(pls);
            // return "zart";
        } else {
            wrs.pix = _deepstruct.pix0;
            wrs.adj = _solid.adjacency_matrix;
            wrs.wire_color = _solid.wire_color;
            wrs.headstring = head_func(_deepstruct.hhead, _deepstruct.whead);
            return new_svg_wf(wrs);
        }
        // return new_svg_wf(pix0);
    }

    function tok(uint8 tid) public view returns (string memory) {
        solid memory _solid = num2solid[tid];
        // int128[3] memory _center;
        // int128[3] memory _observer = num2solid[tid].observer;
        // // uint8[][] memory _face_list = num2solid[tid].face_list;
        // // bool _face_or_wire = num2solid[tid].face_or_wire;
        // // uint8[3][] memory _color_list = num2solid[tid].color_list;
        // uint256[] memory _face_index;
        // int128[] memory _projected_points_in_3d;
        // int128[3] memory _z_prime;
        // int128[3] memory _x_prime;
        // int128[] memory _projected_points_in_2d;
        // uint64[] memory pix0;
        wire_struct memory wrs;
        poly_struct memory pls;
        pix_struct memory pxs;
        // preview case + header
        deepstruct memory _deepstruct;

        // _solid = update_struct(_bytes, tid);
        // return (_solid.observer[0]);
        //end of preview maniulation
        int128[3] memory _observer = _solid.observer;
        _deepstruct._center = center(_solid.vertices);

        _observer = relative_observer(
            _observer,
            _deepstruct._center,
            _solid.angular_speed_deg
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

        _deepstruct._projected_points_in_3d = new_projected_points_in_3d(
            _observer,
            _deepstruct._plane_normal,
            _solid.vertices
        );

        _deepstruct._projected_points_in_2d = new_projected_points_in_2d(
            _deepstruct._projected_points_in_3d,
            _deepstruct._z_prime,
            _deepstruct._x_prime,
            _deepstruct._plane_vs_observer
        );
        pxs.points_2d = _deepstruct._projected_points_in_2d;
        pxs._observer = _solid.observer;
        pxs._dist_v_normalize = _solid.dist_v_normalize;
        pxs._aspect_ratio_mode = _solid.aspect_ratio_mode;
        pxs._custome_h = _solid.custome_h;
        pxs._custome_w = _solid.custome_w;

        _deepstruct.pix0 = new_scaled_newpoints(pxs);
        // return "zart";
        (_deepstruct.whead, _deepstruct.hhead) = h_w_detection(
            _solid.aspect_ratio_mode,
            _solid.custome_h,
            _solid.custome_w
        );
        if (_solid.face_or_wire) {
            _deepstruct._face_index = face_index(
                _observer,
                _solid.vertices,
                _solid.face_list
            );

            pls.pix = _deepstruct.pix0;
            pls.face_list = _solid.face_list;
            pls.color_list = _solid.color_list;
            pls.sorted_index = _deepstruct._face_index;
            pls.opacity = _solid.opacity;
            pls.headstring = head_func(_deepstruct.hhead, _deepstruct.whead);
            return new_svg_poly(pls);
            // return "zart";
        } else {
            wrs.pix = _deepstruct.pix0;
            wrs.adj = _solid.adjacency_matrix;
            wrs.wire_color = _solid.wire_color;
            wrs.headstring = head_func(_deepstruct.hhead, _deepstruct.whead);
            return new_svg_wf(wrs);
        }
        // return new_svg_wf(pix0);
    }

    function h_w_detection(
        uint8 _aspectratio,
        uint16 _custome_h,
        uint16 _custome_w
    ) internal pure returns (uint16, uint16) {
        if (_aspectratio == 0) {
            return (1000, 1000);
        }
        if (_aspectratio == 1) {
            return (1920, 1080);
        }
        if (_aspectratio == 2) {
            return (_custome_h, _custome_w);
        }
    }

    function head_func(
        uint16 _h,
        uint16 _w
    ) internal pure returns (string memory) {
        // '<svg height="400" width="400">'
        return
            string(
                abi.encodePacked(
                    '<svg height="',
                    uint2str(_h),
                    '" width="',
                    uint2str(_w),
                    '">'
                )
            );
        // return "s";
    }

    function update_struct(
        bytes calldata _bytes,
        uint8 tid
    ) internal view returns (solid memory) {
        solid memory _solid = num2solid[tid];
        // bool a = true;
        uint8 tempbyte = 0;
        uint256 ai = 0;
        uint8 headflag = 0;
        uint8 headcontrol = 0;
        while (ai < _bytes.length) {
            tempbyte = uint8(_bytes[ai]);
            headflag = tempbyte & 15;
            headcontrol = (tempbyte >> 4) & 15;
            if (headflag == 0) {
                ai += 1;
                bytes memory nbytes;
                uint256 obs;
                uint256 mask = 2 ** 127 - 1;
                nbytes = bytes(_bytes[ai:ai + 16]);
                // _solid.observer[headcontrol] = int128(_bytes[ai:ai + 16]);
                ai += 16;
                obs = bytesToUint(nbytes);
                if ((obs & (2 ** 127)) == 1) {
                    _solid.observer[headcontrol] = int128(
                        int256(uint256(obs & mask) - (2 ** 128))
                    );
                    // ai += 16;
                } else {
                    _solid.observer[headcontrol] = int128(int256(obs));
                    // ai += 16;
                }
            }

            if (headflag == 1) {
                ai += 1;
                _solid.face_or_wire = ((headcontrol & 1) == 1);
            }
            if (headflag == 2) {
                ai += 1;
                _solid.rotating_mode = (headcontrol == 1);
            }
            if (headflag == 3) {
                ai += 1;
                require(uint8(_bytes[ai]) < 100, "opacity must be under 100");
                _solid.opacity = uint2str(uint8(_bytes[ai]));
                ai += 1;
            }
            if (headflag == 4) {
                ai += 1;
                // uint256 mask = 2**15 - 1;
                // bytes memory nbytes = bytes(_bytes[ai:ai + 2]);
                uint256 ang = (bytesToUint(bytes(_bytes[ai:ai + 2])));
                require(ang < 361, "out of bound()");
                _solid.opacity = uint2str(ang);
                ai += 2;
                // require();
            }
            if (headflag == 5) {
                ai += 1;
                _solid.wire_color = [
                    uint8(_bytes[ai]),
                    uint8(_bytes[ai + 1]),
                    uint8(_bytes[ai + 2])
                ]; //, uint8(0), uint8(0)];
                // assert(_solid.wire_color[0] == 1);
                ai += 3;
                // for (uint256 i = 0; i < 3; i++) {
                // _solid.wire_color = uint8(_bytes[ai]);
                //     ai += 1;
                // }
            }
            if (headflag == 6) {
                ai += 1;
                _solid.color_list[uint8(_bytes[ai])] = [
                    uint8(_bytes[ai + 1]),
                    uint8(_bytes[ai + 2]),
                    uint8(_bytes[ai + 3])
                ];
                ai += 4;
            }
            if (headflag == 7) {
                ai++;
                uint256 number_of_faces = _solid.face_list.length;
                for (uint256 i = 0; i < number_of_faces; i++) {
                    _solid.color_list[i] = [
                        uint8(_bytes[ai]),
                        uint8(_bytes[ai + 1]),
                        uint8(_bytes[ai + 2])
                    ];
                    ai += 3;
                }
            }
            if (headflag == 8) {
                ai += 1;
                _solid.dist_v_normalize = ((headcontrol & 1) == 1);
            }
            if (headflag == 9) {
                ai += 1;
                if (headcontrol == 0) {
                    _solid.aspect_ratio_mode = 0;
                }
                if (headcontrol == 1) {
                    _solid.aspect_ratio_mode = 1;
                }
                if (headcontrol == 2) {
                    _solid.aspect_ratio_mode = 2;
                    _solid.custome_h = uint16(bytesToUint(_bytes[ai:ai + 2]));
                    ai += 2;
                    _solid.custome_h = uint16(bytesToUint(_bytes[ai:ai + 2]));
                    ai += 2;
                }
            }
            //9

            // a = false;
        }
        return _solid;
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

    ///

    ////
    ///
    function sss() public {
        s += 1;
    }
}
