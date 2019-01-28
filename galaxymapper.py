import os
from PIL import Image, ImageDraw

# line 1: Seed
# line 2: faction index:name
# line 3: gates
# line 4 - 1003: Sectors


def getGalaxyData():
    versionFile = open(os.getenv('APPDATA')+"\\Avorion\\galaxymap.txt", "r")
    seed = 0
    count = 1
    factionList = {}
    gateList = []
    sectorList = {}
    for l in versionFile:
        if count is 1:
            seed = l
        if count is 2:
            a = 1
        if count is 3:
            gates = l.split(",")
            del gates[0]

            for g in gates:
                spt = g.split(";")
                list = []
                for c in spt:
                    gt = c.split(":")
                    list.append([int(gt[0]), int(gt[1])])
                gateList.append(list)
        if count > 3 and count < 1004:
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
        count += 1

    return seed, factionList, gateList, sectorList

def createImages(factionList, gateList, sectorList):
    size = 4
    img = Image.new('RGBA', (1000*size, 1000*size), (0,0,0,255))
    img.save('background.png')
    imgRift = Image.new('RGBA', (1000*size, 1000*size), (0,0,0,0)) #all seethrough
    imgHome = Image.new('RGBA', (1000*size, 1000*size), (0,0,0,0)) #all seethrough
    imgGreen = Image.new('RGBA', (1000*size, 1000*size), (0,0,0,0)) #all seethrough
    imgOrange = Image.new('RGBA', (1000*size, 1000*size), (0,0,0,0)) #all seethrough

    drawRift = ImageDraw.Draw(imgRift)
    drawHome = ImageDraw.Draw(imgHome)
    drawGreen = ImageDraw.Draw(imgGreen)
    drawOrange = ImageDraw.Draw(imgOrange)


    for y,v in sectorList.items():
        for x,w in v.items():
            xC = (x+500)*size
            yC = (y*-1 + 500)*size
            xC = xC - size/2
            yC = yC - size/2
            if w[0] == 1:
                drawRift.rectangle([xC,yC,xC+size-1,yC+size-1], fill=(32,32,32,255))
            if w[0] == 2:
                drawHome.rectangle([xC,yC,xC+size-1,yC+size-1], fill=(0,0,255,255))
            if w[0] == 4:
                drawGreen.rectangle([xC,yC,xC+size-1,yC+size-1], fill=(0,255,0,255))
            if w[0] == 5:
                drawOrange.rectangle([xC,yC,xC+size-1,yC+size-1], fill=(128,128,0,255))

    imgRift.save('rifts.png')
    imgHome.save('homes.png')
    imgGreen.save('regular.png')
    imgOrange.save('offgrids.png')

    imgGate = Image.new('RGBA', (1000*size, 1000*size), (0,0,0,0)) #all seethrough
    drawGate = ImageDraw.Draw(imgGate)

    for sGate in gateList:

        startX, startY = sGate[0][0], sGate[0][1]
        startX = (startX+500)*size
        startY = (startY*-1 + 500)*size
        for x in range(1, len(sGate)):
            stopX, stopY = sGate[x][0], sGate[x][1]
            stopX = (stopX+500)*size
            stopY = (stopY*-1 + 500)*size
            if startX >= 0 and startY >= 0 and stopX >= 0 and stopY >= 0:
                drawGate.line([startX-1, startY-1, stopX-1, stopY-1], (255,255,255,255), max(1, int(size/4)))

    imgGate.save('gates.png')



seed, factionList, gateList, sectorList = getGalaxyData()
createImages(factionList, gateList, sectorList)
#
input("Press enter to exit")
