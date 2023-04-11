from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, PlatonicRebornV4, PlatonicToken
import json
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    demo = PlatonicRebornV4.deploy({"from": account})
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

    # token = PlatonicToken.deploy(demo.address, {"from": account})
    # sleep(0.1)
    # for i in range(5):
    #     token.mintToken({"from": account})

    # for i in range(5):
    #     print("behold\n")
    #     print(token.tokenURI(i))

    # print(demo.tokenURI(13))
    # for i in range(5):
    #     t = demo.tokenURI(i)
    #     sleep(2)
    #     print(t)
    id = 0
    o = [2 ** 64, 8 * 2 ** 64, 0]
    op = 99
    rm = False
    asd = 7
    dvn = False
    fow = False
    wc = 15158332
    cl = [16761600, 15158332, 3447003, 3066993]
    id = 0
    o = [2 ** 64, 2 ** 64, 0]
    op = 99
    rm = False
    asd = 7
    dvn = False
    fow = False
    wc = 15158332
    cl = [16761600, 15158332, 3447003, 3066993] * 5
    cl2 = "F5B041F0E68C" * 10
    _comp = 7 + 256 * op + 2 ** 16 * asd + 2 ** 32 * wc
    print(demo.getGeneralSetting(0))
    sleep(2)
    demo.setMinimalSetting(id, o, _comp, bytes.fromhex(cl2[0:24]), {"from": account})

    # demo.novoSetSetting(
    #     id, o, op, rm, asd, dvn, fow, wc, bytes.fromhex(cl2), {"from": account}
    # )
    print(demo.getGeneralSetting(0))
    sleep(2)
    demo.setMinimalSetting(4, o, _comp, bytes.fromhex(cl2[0:120]), {"from": account})

    sleep(2)
    print("444444444444")
    print(demo.getGeneralSetting(4))
    sleep(2)
    print("KKKK")
    print(demo.previewTokenById(1, o, _comp, bytes.fromhex(cl2[0:36])))
    sleep(2)

    demo.setMinimalSetting(id, o, _comp, bytes.fromhex(cl2[0:24]), {"from": account})

    # demo.novoSetSetting(
    #     id, o, op, rm, asd, dvn, fow, wc, bytes.fromhex(cl2), {"from": account}
    # )
    sleep(2)
    demo.setMinimalSetting(4, o, _comp, bytes.fromhex(cl2[0:120]), {"from": account})
    sleep(2)
    for i in range(5):
        print("behold\n")
        print(demo.renderTokenById(i))
        sleep(2)


def main():
    deploy_and_create(True)
