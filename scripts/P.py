from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import (
    accounts,
    config,
    network,
    Play,
)
import json
from time import sleep


def deploy_and_create(mint_req=True):
    test_counter = 0
    pass_counter = 0
    account = get_account()
    demo = Play.deploy({"from": account})

    with open("./scripts/PlatonicSolids.json", "r") as ss:
        # PlatonicSolids.json
        #     q = f.read()
        y = json.load(ss)

    for k in range(5):
        i = k

        print(y[str(i)]["name"])
        demo.solidStruct_IMU(
            y[str(i)]["tokenId"],
            y[str(i)]["name"],
            y[str(i)]["vertices"],
            y[str(i)]["face_list"],
            y[str(i)]["face_polygon"],
            {"from": account},
        )
        sleep(2)

        # print(t)
    id = 4
    o = [2 ** 64, 4 * 2 ** 64, 0]
    op = 99

    asd = 7

    wc = 15158332

    cl2 = "F5B041F0E68C" * 10
    _comp = 7 + 256 * op + 2 ** 16 * asd + 2 ** 32 * wc + 2 ** 56 * 255
    # print(demo.getGeneralSetting(0))
    # sleep(2)
    # test_counter += 1

    demo.setMinimalSetting(
        id, o, _comp, bytes.fromhex(cl2[0:120]), {"from": accounts[0]}
    )
    sleep(2)
    id = 4
    o = [2 ** 65, 4 * 2 ** 64, 0]
    op = 60

    asd = 13

    wc = 15158332

    cl2 = "F5B041F0E68C" * 10
    cl2 = "5FB0140F6EC8" * 10
    demo.setMinimalSetting(
        id, o, _comp, bytes.fromhex(cl2[0:120]), {"from": accounts[0]}
    )
    for i in range(5):
        print("getting " + str(i))
        print(demo.unPackVector(i))
    for i in range(5):
        print("getting Unpacked Solid " + str(i))
        print(demo.getUnPackedSolid(i))

    print("done")


def main():
    deploy_and_create(True)
