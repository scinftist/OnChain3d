from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, Test
import json
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    demo = Test.deploy({"from": account})
    # print(demo.getSetting(0))
    id = 0
    o = [2 ** 64, 2 ** 64, 0]
    op = 99
    rm = False
    asd = 7
    dvn = False
    fow = False
    wc = 15158332
    cl = [16761600, 15158332, 3447003, 3066993] * 5
    cl2 = "F5B041F0E68C" * 5

    demo.setSetting(id, o, op, rm, asd, dvn, fow, wc, cl, {"from": account})
    sleep(2)
    demo.newSetSetting(id, o, op, 7, asd, wc, cl, {"from": account})
    sleep(2)
    demo.novoSetSetting(
        id, o, op, rm, asd, dvn, fow, wc, bytes.fromhex(cl2), {"from": account}
    )
    sleep(2)
    demo.setSetting(id, o, op, rm, asd, dvn, fow, wc, cl, {"from": account})
    sleep(2)
    demo.newSetSetting(id, o, op, 7, asd, wc, cl, {"from": account})
    sleep(2)
    demo.novoSetSetting(
        id, o, op, rm, asd, dvn, fow, wc, bytes.fromhex(cl2), {"from": account}
    )
    # print(demo.getSetting(0))bytearray.fromhex(hex_string)
    # demo.setSetting(id, o, op, rm, asd, dvn, fow, wc, cl * 6, {"from": account})
    sleep(2)
    # print(demo.getSetting(0))


def main():
    deploy_and_create(True)
