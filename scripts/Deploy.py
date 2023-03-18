from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, Platonic
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    demo = Platonic.deploy({"from": account})
    print(demo.tok(1))


def main():
    deploy_and_create(True)
