from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, PlatonicRebornV2
import json
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    demo = PlatonicRebornV2.deploy({"from": account})
    #############
    with open("./solid-json.json", "r") as ss:
        #     q = f.read()
        y = json.load(ss)

    for i in range(5):
        # demo.solidStruct_IMU(
        #     0,
        #     _name,
        #     _vertices,
        #     _adjacency_matrix,
        #     _face_list,
        #     _face_polygon,
        #     {"from": account},
        # )
        demo.solidStruct_IMU(
            y[str(i)]["tokenId"],
            y[str(i)]["name"],
            y[str(i)]["vertices"],
            y[str(i)]["adj"],
            y[str(i)]["face_list"],
            y[str(i)]["face_polygon"],
            {"from": account},
        )
        sleep(2)
    sleep(5)
    print(demo.tok(0))
    sleep(5)

    print(demo.tokenURI(0))


def main():
    deploy_and_create(True)
