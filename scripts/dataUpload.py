from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import (
    Contract,
    accounts,
    config,
    network,
)
import json
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    with open("./abi.json", "r") as bb:
        # PlatonicSolids.json
        #     q = f.read()
        abi = json.load(bb)
    # demo = Contract.from_explorer("0x6d04C3F8e618a2404803Ca72f5dF93f4F50CaD45")
    demo = Contract.from_abi(
        "OnChain3dMetadataRenderer", "0xEAb057eB4259F482751970c3B1A5482c807D6ab2", abi
    )
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
        sleep(20)

        # print(t)

    sleep(2)
    print("done")


def main():
    deploy_and_create(True)
