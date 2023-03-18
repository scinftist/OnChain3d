from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, PlatonicReborn
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    demo = PlatonicReborn.deploy({"from": account})
    print(demo.tok(1))

    print(demo.tokenURI(1))


def main():
    deploy_and_create(True)
