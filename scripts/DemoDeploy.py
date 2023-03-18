from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, Euclid
from time import sleep

# import pygame
import io

# sample_token_uri = "https://ipfs.io/ipfs/Qmd9MCGtdVz2miNumBHDbvj8bigSgTwnr4SbyH6DNnpWdt?filename=0-PUG.json"


def deploy_and_create(mint_req=True):
    account = get_account()
    # acc0 = "0xCA1231CE623B4B1DC9A57D71F6BD1372D239FB21"
    # acc1 = "0x93E2D388FDDA47DFBDB0CE97180D2EBD9E2E9AEE"
    # acc2 = "0xb61577009E6FD3a5F99B2A5110ec286277509311"
    demo = Euclid.deploy({"from": account})
    _tokenId = 0
    _name = "tetrahydron"
    _observer = [73786976294838206464, 0, 0]
    _vertices = [
        [-36893488147419103232, 0, 0],
        [18446744073709551616, 31950697969885028352, 0],
        [18446744073709551616, -31950697969885028352, 0],
        [0, 0, 52175271301331132416],
    ]
    _adjacency_matrix = [
        [False, True, True, True],
        [True, False, True, True],
        [True, True, False, True],
        [True, True, True, False],
    ]
    _adjacency_matrix = [
        False,
        True,
        True,
        True,
        True,
        False,
        True,
        True,
        True,
        True,
        False,
        True,
        True,
        True,
        True,
        False,
    ]
    _face_list = [[0, 1, 2], [0, 2, 3], [0, 1, 3], [1, 2, 3]]
    _face_list = [0, 1, 2, 0, 2, 3, 0, 1, 3, 1, 2, 3]
    _face_polygon = 3
    _color_list = [[255, 102, 153], [255, 0, 0], [255, 153, 0], [255, 255, 0]]
    _wire_color = [255, 102, 153]
    _face_or_wire = False
    _opacity = "90"
    _rotating_mode = True
    _angular_speed_deg = 2
    _tokenId4 = 4
    _name4 = "icosahydron"
    _observer4 = [73786976294838206464, 0, 0]
    _vertices4 = [
        [0, 18446744073709551616, 29847458893034688512],
        [0, -18446744073709551616, 29847458893034688512],
        [0, 18446744073709551616, -29847458893034688512],
        [0, -18446744073709551616, -29847458893034688512],
        [-29847458893034688512, 0, 18446744073709551616],
        [18446744073709551616, -29847458893034688512, 0],
        [18446744073709551616, 29847458893034688512, 0],
        [29847458893034688512, 0, 18446744073709551616],
        [29847458893034688512, 0, -18446744073709551616],
        [-18446744073709551616, -29847458893034688512, 0],
        [-18446744073709551616, 29847458893034688512, 0],
        [-29847458893034688512, 0, -18446744073709551616],
    ]
    _adjacency_matrix4 = [
        [False, True, False, False, True, False, True, True, False, False, True, False],
        [True, False, False, False, True, True, False, True, False, True, False, False],
        [False, False, False, True, False, False, True, False, True, False, True, True],
        [False, False, True, False, False, True, False, False, True, True, False, True],
        [True, True, False, False, False, False, False, False, False, True, True, True],
        [False, True, False, True, False, False, False, True, True, True, False, False],
        [True, False, True, False, False, False, False, True, True, False, True, False],
        [True, True, False, False, False, True, True, False, True, False, False, False],
        [False, False, True, True, False, True, True, True, False, False, False, False],
        [False, True, False, True, True, True, False, False, False, False, False, True],
        [True, False, True, False, True, False, True, False, False, False, False, True],
        [False, False, True, True, True, False, False, False, False, True, True, False],
    ]
    _adjacency_matrix4 = [
        False,
        True,
        False,
        False,
        True,
        False,
        True,
        True,
        False,
        False,
        True,
        False,
        True,
        False,
        False,
        False,
        True,
        True,
        False,
        True,
        False,
        True,
        False,
        False,
        False,
        False,
        False,
        True,
        False,
        False,
        True,
        False,
        True,
        False,
        True,
        True,
        False,
        False,
        True,
        False,
        False,
        True,
        False,
        False,
        True,
        True,
        False,
        True,
        True,
        True,
        False,
        False,
        False,
        False,
        False,
        False,
        False,
        True,
        True,
        True,
        False,
        True,
        False,
        True,
        False,
        False,
        False,
        True,
        True,
        True,
        False,
        False,
        True,
        False,
        True,
        False,
        False,
        False,
        False,
        True,
        True,
        False,
        True,
        False,
        True,
        True,
        False,
        False,
        False,
        True,
        True,
        False,
        True,
        False,
        False,
        False,
        False,
        False,
        True,
        True,
        False,
        True,
        True,
        True,
        False,
        False,
        False,
        False,
        False,
        True,
        False,
        True,
        True,
        True,
        False,
        False,
        False,
        False,
        False,
        True,
        True,
        False,
        True,
        False,
        True,
        False,
        True,
        False,
        False,
        False,
        False,
        True,
        False,
        False,
        True,
        True,
        True,
        False,
        False,
        False,
        False,
        True,
        True,
        False,
    ]
    _face_list4 = [
        [0, 1, 4],
        [0, 1, 7],
        [0, 4, 10],
        [0, 6, 7],
        [0, 6, 10],
        [1, 4, 9],
        [1, 5, 7],
        [1, 5, 9],
        [2, 3, 8],
        [2, 3, 11],
        [2, 6, 8],
        [2, 6, 10],
        [2, 10, 11],
        [3, 5, 8],
        [3, 5, 9],
        [3, 9, 11],
        [4, 9, 11],
        [4, 10, 11],
        [5, 7, 8],
        [6, 7, 8],
    ]
    _face_list4 = [
        0,
        1,
        4,
        0,
        1,
        7,
        0,
        4,
        10,
        0,
        6,
        7,
        0,
        6,
        10,
        1,
        4,
        9,
        1,
        5,
        7,
        1,
        5,
        9,
        2,
        3,
        8,
        2,
        3,
        11,
        2,
        6,
        8,
        2,
        6,
        10,
        2,
        10,
        11,
        3,
        5,
        8,
        3,
        5,
        9,
        3,
        9,
        11,
        4,
        9,
        11,
        4,
        10,
        11,
        5,
        7,
        8,
        6,
        7,
        8,
    ]
    _face_polygon4 = 3
    _color_list4 = [
        [255, 102, 153],
        [255, 0, 0],
        [255, 153, 0],
        [255, 255, 0],
        [0, 153, 0],
        [0, 153, 204],
        [51, 0, 153],
        [153, 0, 153],
        [247, 255, 49],
        [247, 255, 49],
        [193, 20, 0],
        [91, 10, 0],
        [255, 102, 153],
        [255, 0, 0],
        [255, 153, 0],
        [255, 255, 0],
        [0, 153, 0],
        [0, 153, 204],
        [51, 0, 153],
        [153, 0, 153],
    ]
    _wire_color4 = [255, 102, 153]
    _face_or_wire4 = True
    _opacity4 = "90"
    _rotating_mode4 = True
    _angular_speed_deg4 = 2
    # demo.p
    print("sleep...")
    sleep(2)
    # demo.publish_on_etherscan()
    # print(demo.mmm())
    print("hell yeah")
    # demo.publish_on_etherscan()
    sleep(0.1)
    demo.sss({"from": account})
    sleep(0.1)
    demo.solidStruct_nov(
        _tokenId,
        _name,
        _observer,
        _vertices,
        {"from": account},
    )
    sleep(0.1)
    demo.solidStruct_aff(
        _tokenId,
        _adjacency_matrix,
        _face_list,
        _face_polygon,
        _color_list,
        {"from": account},
    )
    sleep(0.1)
    demo.solidStruct_wfora(
        _tokenId,
        _wire_color,
        _face_or_wire,
        _opacity,
        _rotating_mode,
        _angular_speed_deg,
        {"from": account},
    )

    sleep(0.1)
    demo.solidStruct_nov(
        _tokenId4,
        _name4,
        _observer4,
        _vertices4,
        {"from": account},
    )
    sleep(0.1)

    demo.solidStruct_aff(
        _tokenId4,
        _adjacency_matrix4,
        _face_list4,
        _face_polygon4,
        _color_list4,
        {"from": account},
    )
    sleep(0.1)
    demo.solidStruct_wfora(
        _tokenId4,
        _wire_color4,
        _face_or_wire4,
        _opacity4,
        _rotating_mode4,
        _angular_speed_deg4,
        {"from": account},
    )
    sleep(0.1)
    print(demo.tok(0))
    print("hell yeah new1")
    sleep(0.1)
    demo.sss({"from": account})
    sleep(0.1)
    print(demo.tok(4))
    # pygame_surface = pygame.image.load(io.BytesIO(a.encode()))
    print("hell yeah new2")
    print(demo.tok(0))
    print("hell yeah new3")
    sleep(0.1)
    demo.sss({"from": account})
    sleep(0.1)
    print(demo.tok(4))
    # pygame_surface = pygame.image.load(io.BytesIO(a.encode()))
    print("hell yeah new4")
    return demo


def main():
    deploy_and_create(True)
