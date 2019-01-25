import os
from PIL import Image, ImageDraw


def getGalaxyData():
    versionFile = open(os.getenv('APPDATA')+"\\Avorion\\galaxymap.txt", "r")
    seed = 0
    a = True
    sectorList = {}
    for l in versionFile:
        if a is True:
            a = False
            seed = l
        else:
            [y,sectorString] = l.split("|", maxsplit=1)
            sectors = sectorString.split(",")
            del sectors[0]
            sectors[len(sectors)-1] = sectors[len(sectors)-1].replace("\n", "")
            sector = {}
            for s in sectors:
                a = s.split(";")
                a[0] = int(a[0])
                a[1] = int(a[1])
                a[2] = int(a[2])
                sector[a[0]] = a[1:3]

            y = int(y)
            sectorList[y] = sector

    return sectorList, seed

def createImage(data):
    size = 2
    img = Image.new('RGB', (1000*size, 1000*size))
    draw = ImageDraw.Draw(img)
    for y,v in data.items():
        for x,w in v.items():
            xC = (x+500)*size
            yC = (y*-1 + 500)*size
            if w[0] == 1:
                draw.rectangle([xC,yC,xC+size-1,yC+size-1], fill=(128,128,128))
            if w[0] == 2:
                draw.rectangle([xC,yC,xC+size-1,yC+size-1], fill=(0,0,255))
            if w[0] == 4:
                draw.rectangle([xC,yC,xC+size-1,yC+size-1], fill=(0,255,0))
            if w[0] == 5:
                draw.rectangle([xC,yC,xC+size-1,yC+size-1], fill=(128,128,0))


    img.save('image.png')


data, _ = getGalaxyData()
createImage(data)
#
input("Press enter to exit")
