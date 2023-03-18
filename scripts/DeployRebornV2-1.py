from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, PlatonicRebornV2
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    demo = PlatonicRebornV2.deploy({"from": account})
    #############
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
    # _face_list = [[0, 1, 2], [0, 2, 3], [0, 1, 3], [1, 2, 3]]
    _face_list = [0, 1, 2, 0, 2, 3, 0, 1, 3, 1, 2, 3]
    _face_polygon = 3
    # _color_list = [[255, 102, 153], [255, 0, 0], [255, 153, 0], [255, 255, 0]]
    # _wire_color = [255, 102, 153]
    # _face_or_wire = False

    ############
    # demo.solidStruct_IMU({"from": account})
    demo.solidStruct_IMU(
        0,
        _name,
        _vertices,
        _adjacency_matrix,
        _face_list,
        _face_polygon,
        {"from": account},
    )
    sleep(5)
    print(demo.tok(0))
    sleep(5)

    print(demo.tokenURI(0))


def main():
    deploy_and_create(True)
