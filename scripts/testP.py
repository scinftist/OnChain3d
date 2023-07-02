from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import (
    accounts,
    config,
    network,
    OnChain3dMetadataRenderer,
    OnChain3D,
)
import json
from time import sleep


def deploy_and_create(mint_req=True):
    test_counter = 0
    pass_counter = 0
    account = get_account()
    demo = OnChain3dMetadataRenderer.deploy({"from": account})

    token = OnChain3D.deploy({"from": account})
    print("time remaining = " + str(token.remainingTime()))
    #############
    # with open("./solid-json.json", "r") as ss:
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
        sleep(0.5)

        # print(t)

    # token = OnChain3dTokenPlaceHolder.deploy({"from": account})
    token.setMetadataRenderer(demo.address, {"from": account})
    sleep(0.5)
    demo.setTargetAddress(token.address, {"from": account})
    test_counter += 1
    token.mintToken(1, {"from": accounts[0], "value": 1e16})
    print(demo.getGeneralSetting(0))
    id = 0
    o = [4 * 2 ** 64, 4 * 2 ** 64, -1 * 2 ** 64]
    op = 23

    asd = 0

    # wc = 15158332
    wc = 10 * 2 ** 8 + 11 * 2 ** 4 + 12
    bc = 9 * 2 ** 8 + 8 * 2 ** 4 + 7

    cl2 = "F5B041F0E68C" * 10
    _comp = 2 + 256 * op + 2 ** 16 * asd + 2 ** 32 * wc + 2 ** 44 * bc

    demo.setMinimalSetting(
        id, o, _comp, bytes.fromhex(cl2[0:24]), {"from": accounts[0]}
    )
    pass_counter += 1
    print("it passed previeew ")
    # print(pre)
    sleep(0.5)
    # pre = demo.previewTokenById(id, o, _comp, bytes.fromhex(cl2[0:24]))
    # pass_counter += 1
    # print("it passed previeew ")
    # print(pre)
    print(demo.getGeneralSetting(0))
    sleep(0.5)
    pre = demo.previewTokenById(id, o, _comp, bytes.fromhex(cl2[0:24]))
    sleep(0.5)
    print(cl2[0:24])
    print(_comp)
    print(o)

    print("time remaining = ")
    print("done")


def main():
    deploy_and_create(True)
