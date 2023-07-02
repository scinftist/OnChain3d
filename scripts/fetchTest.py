from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import (
    Contract,
    accounts,
    config,
    network,
    OnChain3dMetadataRenderer,
    OnChain3D,
)
import json
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    with open("./abi.json", "r") as bb:
        # PlatonicSolids.json
        #     q = f.read()
        abi = json.load(bb)

    demo = Contract.from_abi(
        "OnChain3dMetadataRenderer", "0x9e43180a5E4D82B0961Da1ec54366bf67214B87c", abi
    )
    id = 6
    o = [4 * 2 ** 64, 4 * 2 ** 64, -1 * 2 ** 64]
    opacity = 23

    angularSpeed = 0

    # wc = 15158332
    wireColor = 10 * 2 ** 8 + 11 * 2 ** 4 + 12
    backColor = 9 * 2 ** 8 + 8 * 2 ** 4 + 7

    cl2 = "F5B041F0E68C" * 10
    _comp = (
        2
        + 256 * opacity
        + 2 ** 16 * angularSpeed
        + 2 ** 32 * wireColor
        + 2 ** 48 * backColor
    )
    pre = demo.previewTokenById(id, o, _comp, bytes.fromhex(cl2[0:36]))
    sleep(0.5)
    print(pre)
    # print(cl2[0:24])
    # print(_comp)
    # print(o)
    get general

    print("time remaining = ")
    print("done")


def main():
    deploy_and_create(True)
