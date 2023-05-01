from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, OnChain3d, PlatonicToken
import json
from time import sleep


def deploy_and_create(mint_req=True):
    test_counter = 0
    pass_counter = 0
    account = get_account()
    demo = OnChain3d.deploy({"from": account})
    #############
    with open("./solid-json.json", "r") as ss:
        #     q = f.read()
        y = json.load(ss)

    for k in range(5):
        i = k

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

        # print(t)

    token = PlatonicToken.deploy({"from": account})
    token.setMetadataRenderer(demo.address, {"from": account})
    sleep(1)
    demo.setTargetAddress(token.address, {"from": account})
    test_counter += 1
    try:
        demo.setTargetAddress(token.address, {"from": accounts[1]})
        print("owners test did go wrong")

    except:
        print("owners test passed")
        pass_counter += 1
    # token.setMetadataRenderer
    sleep(0.1)
    for i in range(5):
        token.mintToken({"from": accounts[i]})

    for i in range(5):
        # print("behold\n")
        token.tokenURI(i)

    # print(demo.tokenURI(13))
    test_counter += 1
    try:
        token.tokenURI(5)
        print("something wnet wrong ")
    except:
        print("it's planned and passed")
        pass_counter += 1

    id = 0
    o = [2 ** 64, 4 * 2 ** 64, 0]
    op = 99
    rm = False
    asd = 7
    dvn = False
    fow = False
    wc = 15158332
    cl = [16761600, 15158332, 3447003, 3066993] * 5
    cl2 = "F5B041F0E68C" * 10
    _comp = 7 + 256 * op + 2 ** 16 * asd + 2 ** 32 * wc + 2 ** 56 * 255
    print(demo.getGeneralSetting(0))
    sleep(2)
    test_counter += 1
    try:
        demo.setMinimalSetting(
            id, o, _comp, bytes.fromhex(cl2[0:24]), {"from": accounts[0]}
        )
        print("owner Of test passed")
        pass_counter += 1
    except:
        print("something wnet worng ")
    test_counter += 1
    try:
        demo.setMinimalSetting(
            id, o, _comp, bytes.fromhex(cl2[0:24]), {"from": accounts[1]}
        )
        print("something wnet worng ")
    except:
        print("it's passed! ")
        pass_counter += 1

    print("token 3")
    print(token.tokenURI(3))

    print(pass_counter, "/", test_counter)

    # for i in range(5):
    #     t = demo.tokenURI(i)
    #     sleep(2)
    #     print(t)


def main():
    deploy_and_create(True)
