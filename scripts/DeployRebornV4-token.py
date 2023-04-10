from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, PlatonicRebornV3, PlatonicToken
import json
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    demo = PlatonicRebornV3.deploy({"from": account})
    #############
    with open("./solid-json.json", "r") as ss:
        #     q = f.read()
        y = json.load(ss)

    for k in range(5):
        i = k
        # demo.solidStruct_IMU(
        #     0,
        #     _name,
        #     _vertices,
        #     _adjacency_matrix,
        #     _face_list,
        #     _face_polygon,
        #     {"from": account},
        # )
        print(y[str(i)]["name"])
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

        t = demo.renderTokenById(i)
        print(t)

    token = PlatonicToken.deploy(demo.address, {"from": account})
    sleep(0.1)
    for i in range(5):
        token.mintToken({"from": account})

    for i in range(5):
        print("behold\n")
        print(token.tokenURI(i))

    print(demo.tokenURI(13))
    # for i in range(5):
    #     t = demo.tokenURI(i)
    #     sleep(2)
    #     print(t)


def main():
    deploy_and_create(True)
