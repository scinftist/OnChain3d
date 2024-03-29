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
    # print("time remaining = " + str(token.remainingTime()))
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
    sleep(0.2)
    demo.setTargetAddress(token.address, {"from": account})
    test_counter += 1
    try:
        demo.setTargetAddress(token.address, {"from": accounts[1]})
        print("owners test did go wrong")

    except:
        print("owners test passed")
        pass_counter += 1

    sleep(0.1)
    for i in range(5):
        token.mintToken(1, {"from": accounts[i], "value": 2e15})

    for i in range(5):

        token.tokenURI(i)

    test_counter += 1
    try:
        token.tokenURI(5)
        print("something wnet wrong ")
    except:
        print("it's planned and passed")
        pass_counter += 1

    id = 0
    o = [2 ** 64, 4 * 2 ** 64, -3 * 2 ** 64]
    op = 37

    asd = 7

    wc = 15158332

    cl2 = "F5B041F0E68C" * 10
    _comp = 7 + 256 * op + 2 ** 16 * asd + 2 ** 32 * wc + 2 ** 56 * 255
    print(demo.getGeneralSetting(0))
    sleep(0.2)
    test_counter += 1
    try:
        demo.setMinimalSetting(
            id, o, _comp, bytes.fromhex(cl2[0:24]), {"from": accounts[0]}
        )
        print("owner Of test passed")
        pass_counter += 1
    except:
        print("something wnet worng A")
    test_counter += 1
    try:
        demo.setMinimalSetting(
            id, o, _comp, bytes.fromhex(cl2[0:24]), {"from": accounts[1]}
        )
        print("something wnet worng ")
    except:
        print("it's passed! ")
        pass_counter += 1
    test_counter += 1
    try:
        pre = demo.previewTokenById(id, o, _comp, bytes.fromhex(cl2[0:24]))
        pass_counter += 1
        print("it passed previeew ")
        print(pre)
    except Exception as e:
        print(e)
        print("it fucked ")
    # pre = demo.previewTokenById(id, o, _comp, bytes.fromhex(cl2[0:24]))

    # sleep(2)
    # print(pre)
    print("token 3")
    for i in range(5):
        print("token" + str(i))
        print(token.tokenURI(i))
        sleep(0.2)

    print(pass_counter, "/", test_counter)

    sleep(0.2)
    print("this is the _render address  " + str(token.metadataRendererAddress()))
    # metadataRendererAddress
    # metadataRendererAdddress
    print("balance")
    print(account.balance())
    token.withdraw({"from": account})
    print("balance")
    print(account.balance())
    print("done")


def main():
    deploy_and_create(True)
