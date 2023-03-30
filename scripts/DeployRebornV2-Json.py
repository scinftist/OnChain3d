from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, PlatonicRebornV2
import json
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    demo = PlatonicRebornV2.deploy({"from": account})
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
        with open("./" + str(i) + ".txt", "w") as n:
            #     q = f.read()
            # t = demo.tokenURI(i)
            t = demo.renderTokenById(i)
            sleep(3)
            n.write(t)

    id = 3
    o = [4 * 2 ** 64, 4 * 2 ** 64, -8 * (2 ** 64)]
    op = 100
    rm = True
    asd = 1
    dvn = False
    fow = True
    wc = 15158332
    cl = [
        16761600,
        15158332,
        3447003,
        3066993,
        10181046,
        15844367,
        2600544,
        2719929,
        9323693,
        15965202,
        12597547,
        1752220,
        3426654,
        8359053,
        1482885,
        13849600,
        12436423,
        2899536,
        15787660,
        16101441,
    ]
    print(cl)
    a = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
"""
    b = """
    </body>
</html>"""
    # demo.setSetting(id, o, op, rm, asd, dvn, fow, wc, cl, {"from": account})
    # sleep(2)

    # print(demo.tokenURI(3))
    # sleep(2)
    # demo.setSetting(id, o, op, rm, asd, dvn, fow, wc, cl, {"from": account})
    for i in range(20):
        x = (4 * 2 ** 64) - (i * (2 ** 62))
        o = [x, 2 * 2 ** 64, -i * (2 ** 63)]
        t = demo.renderTokenById(3)
        sleep(3)
        with open("./svgs/" + "0" + ".html", "w") as n:
            #     q = f.read()

            # sleep(1)
            n.write(a + t + b)
            n.close()
        demo.setSetting(id, o, op, rm, asd, dvn, fow, wc, cl, {"from": account})

    # print(demo.tok(0))
    sleep(5)


def main():
    deploy_and_create(True)
