entity = class:new()

--KEY
--t: codename
--name: display name (spawner, tooltip)

--enemy: is it an enemy? (not spawned near checkpoints) (TODO)

--item: can be placed into ? blocks [item()]
--spawnable: can be spawned with spawner
--offset: can be offset

--input: can be linked (TODO)
--output: can output to linked entities (TODO)

entitylist = {	
	{t="remove"},
	{t="mushroom", spawnable=true, block=true},
	{t="oneup", spawnable=true, block=true},
	{t="star", spawnable=true, block=true},
	{t="manycoins", block=true},
	{t="goomba", spawnable=true, offset=9, block=true, supersize=true},
	{t="koopa", spawnable=true, offset=10, block=true, supersize=true},
	{t="spawn"},
	{t="goombahalf", supersize=true},
	{t="koopahalf", supersize=true},
	{t="flag"},
	{t="koopared", spawnable=true, offset=13, block=true, supersize=true},
	{t="kooparedhalf", supersize=true},
	{t="vine", block=true},
	{t="hammerbro", spawnable=true, block=true},
	{t="cheepred", spawnable=true, supersize=true},
	{t="cheepwhite", spawnable=true, supersize=true},
	{t="platformup"}, --my mouse is dying :(
	{t="platformright"},
	{t="box", name="cube", spawnable=true},
	{t="pipe"},
	{t="lakito", name="lakitu", spawnable=true, supersize=true},
	{t="mazestart"},
	{t="mazeend"},
	{t="mazegate"},
	{t="emancehor"},
	{t="emancever", name="emancipation grill"},
	{t="doorver", name="test door"},
	{t="doorhor"},
	{t="wallindicator"},
	{t="pipespawn"},
	{t="platformfall", spawnable=true},
	{t="bulletbillstart"},
	{t="bulletbillend"},
	{t="drain"},
	{t="lightbridgeright", name="lightbridge"},
	{t="lightbridgeleft"},
	{t="lightbridgedown"},
	{t="lightbridgeup"},
	{t="button"},
	{t="platformspawnerdown"},
	{t="platformspawnerup"},
	{t="groundlightver"},
	{t="groundlighthor"},
	{t="groundlightupright"},
	{t="groundlightrightdown"},
	{t="groundlightdownleft"},
	{t="groundlightleftup"},
	{t="faithplateup", name="faithplate"},
	{t="faithplateright"},
	{t="faithplateleft"},
	{t="laserright", name="laser"},
	{t="laserdown"},
	{t="laserleft"},
	{t="laserup"},
	{t="laserdetectorright", name="laserdetector"},
	{t="laserdetectordown"},
	{t="laserdetectorleft"},
	{t="laserdetectorup"},
	{t="bulletbill", name="bullet bill launcher"},
	{t="bluegeldown", name="gel dispenser"},
	{t="bluegelright"},
	{t="bluegelleft"},
	{t="orangegeldown"},
	{t="orangegelright"},
	{t="orangegelleft"},
	{t="boxtube", name="cube dispenser"},
	{t="pushbuttonleft", name="pedestal button"},
	{t="pushbuttonright"},
	{t="plant", spawnable=true, supersize=true},
	{t="whitegeldown"},
	{t="whitegelright"},
	{t="whitegelleft"},
	{t="timer"},
	{t="beetle", spawnable=true, offset=76, block=true, supersize=true},
	{t="beetlehalf", supersize=true},
	{t="kooparedflying", spawnable=true, supersize=true},
	{t="koopaflying", spawnable=true, supersize=true},
	{t="castlefireccw", name="firebar"},
	{t="seesaw"},
	{t="warppipe"},
	{t="castlefirecw"},
	{t="lakitoend"},
	{t="notgate"},
	{t="geltop", name="gel"},
	{t="gelleft"},
	{t="gelbottom"},
	{t="gelright"},
	{t="firestart"},
	{t="bowser", spawnable=true, supersize=true},
	{t="axe"},
	{t="platformbonus"},
	{t="spring"},
	{t="squid", name="blooper", spawnable=true, supersize=true},
	{t="flyingfishstart"},
	{t="flyingfishend"},
	{t="upfire", name="lava bubble", spawnable=true, block=true, supersize=true},
	{t="spikey", name="spiny", spawnable=true, offset=99, block=true, supersize=true},
	{t="spikeyhalf", supersize=true},
	{t="checkpoint"},
	{t="poisonmush", spawnable=true, block=true},
	{t="downplant", spawnable=true, supersize=true},
	{t="paragoomba", spawnable=true, block=true, supersize=true},
	{t="bigbill", name="banzai bill launcher"},
	{t="kingbill", spawnable=true},
	{t="sidestepper", spawnable=true, block=true, supersize=true},
	{t="barrel", spawnable=true, supersize=true},
	{t="icicle", spawnable=true},
	{t="angrysun", name="angry sun", spawnable=true},
	{t="angrysunend", name="angry sun end"},
	{t="splunkin", spawnable=true, offset=112, block=true, supersize=true},
	{t="splunkinhalf", supersize=true},
	{t="threeup", spawnable=true},
	{t="biggoomba", name="big goomba", spawnable=true, supersize=true},
	{t="bigspikey", name="big spiny", spawnable=true, supersize=true},
	{t="bigkoopa", name="big koopa", spawnable=true, supersize=true},
	{t="shell", spawnable=true, block=true, supersize=true},
	{t="goombrat", spawnable=true, offset=119, block=true, supersize=true},
	{t="goombrathalf"},
	{t="firebro", spawnable=true, block=true},
	{t="plusclock", spawnable=true, block=true},
	{t="springgreen"},
	{t="redplant", spawnable=true, supersize=true},
	{t="reddownplant", spawnable=true, supersize=true},
	{t="thwomp", spawnable=true, offset=224, supersize=true},
	{t="fishbone", spawnable=true, supersize=true},
	{t="drybones", spawnable=true, offset=128, block=true, supersize=true},
	{t="dryboneshalf", supersize=true},
	{t="muncher", spawnable=true, supersize=true, block=true},
	{t="bigbeetle", name="big beetle",spawnable=true, supersize=true},
	{t="meteorstart"},
	{t="meteorend"},
	{t="drygoomba", spawnable=true, offset=134, supersize=true},
	{t="drygoombahalf", supersize=true},
	{t="dryplant", spawnable=true, supersize=true},
	{t="drydownplant", spawnable=true, supersize=true},
	{t="donut"},
	{t="boomerangbro", spawnable=true, block=true},
	{t="parabeetle", spawnable=true, supersize=true},
	{t="ninji", spawnable=true, block=true, supersize=true},
	{t="hammersuit", spawnable=true, block=true},
	{t="boo", spawnable=true, supersize=true},
	{t="moleground", name="mole ground", spawnable=true, block=true},
	{t="bigmole", name="big mole", spawnable=true, supersize=true},
	{t="bomb", spawnable=true, offset=146, block=true, supersize=true},
	{t="bombhalf", supersize=true},
	{t="fireplant", spawnable=true, supersize=true},
	{t="flipblock"},
	{t="downfireplant", spawnable=true, supersize=true},
	{t="torpedoted"},
	{t="frogsuit", spawnable=true, block=true},
	{t="parabeetleright", spawnable=true, supersize=true},
	{t="boomboom", spawnable=true, supersize=true},
	{t="levelball", spawnable=true, block=true},
	{t="leaf", spawnable=true, block=true},
	{t="koopablue", spawnable=true, offset=157, supersize=true},
	{t="koopabluehalf", supersize=true},
	{t="koopaflying2", name="koopaflying hor", spawnable=true, supersize=true},
	{t="windstart"},
	{t="windend"},
	{t="pipe2"},
	{t="pinksquid", name="pink blooper", spawnable=true, supersize=true},
	{t="door"}, --not portal
	{t="ice"},
	{t="box2", name="companion cube", spawnable=true},
	{t="energylauncherright", name="energy launcher"},
	{t="energylauncherleft"},
	{t="energylauncherup"},
	{t="energylauncherdown"},
	{t="energycatcherright", name="energy catcher"},
	{t="energycatcherleft"},
	{t="energycatcherup"},
	{t="energycatcherdown"},
	{t="turretleft"},
	{t="turretright"},
	{t="turret2left"},
	{t="turret2right"},
	{t="blocktogglebutton", name="! button"},
	{t="buttonblockon", name="on block"},
	{t="buttonblockoff", name="off block"},
	{t="purplegeldown"},
	{t="purplegelright"},
	{t="purplegelleft"},
	{t="sleepfish", spawnable=true, supersize=true},
	{t="squarewave"},
	{t="delayer"},
	{t="coin", spawnable=true},
	{t="amp", name="fuzzy", spawnable=true, supersize=true},
	{t="parabeetlegreen", spawnable=true, supersize=true},
	{t="parabeetlegreenright", spawnable=true, supersize=true},
	{t="longfire", name="burner off"},
	{t="cannonball"},
	{t="minimushroom", spawnable=true, block=true},
	{t="rocketturret"},
	{t="glados"},
	{t="pedestal"},
	{t="portal1"},
	{t="portal2"},
	{t="text"},
	{t="regiontrigger"},
	{t="tiletool"},
	{t="iceflower", spawnable=true, block=true},
	{t="shyguy", spawnable=true, offset=204, block=true, supersize=true},
	{t="shyguyhalf", supersize=true},
	{t="enemytool", name="spawner", supersize=true},
	{t="randomizer"},
	{t="yoshi", spawnable=true, block=true, supersize=false},
	{t="bigblocktogglebutton"},
	{t="beetleshell", spawnable=true, supersize=true},
	{t="musicchanger"},
	{t="pbutton", name="p switch", spawnable=true, block=true},
	{t="spiketop", spawnable=true, offset=213, supersize=true},
	{t="spiketophalf", supersize=true},
	{t="pokey", spawnable=true, supersize=true},
	{t="snowpokey", spawnable=true, supersize=true},
	{t="fighterfly", spawnable=true, block=true, supersize=true},
	{t="swimwing", spawnable=true, block=true},
	{t="dkhammer", spawnable=true, block=true},
	{t="vinestop"},
	{t="chainchomp", spawnable=true, supersize=false},
	{t="bighammerbro", name="big hammerbro",spawnable=true},
	{t="edgelessbox", name="edgeless cube", spawnable=true},
	{t="rockywrench", spawnable=true, supersize=false},
	{t="thwomphalf", supersize=true},
	{t="watergeldown"},
	{t="watergelright"},
	{t="watergelleft"},
	{t="rotodisc"},
	{t="funneldown"},
	{t="funnelup"},
	{t="funnelright", name="funnel"},
	{t="funnelleft"},
	{t="pipespawndown"},
	{t="thwimp", spawnable=true},
	{t="drybeetle", spawnable=true, offset=236, block=true, supersize=true},
	{t="drybeetlehalf", supersize=true},
	{t="tinygoomba", spawnable=true, block=true},
	{t="koopaling", spawnable=true, supersize=true},
	{t="bigmushroom", spawnable=true, name="mega mushroom", block=true},
	{t="bowser3", spawnable=true, supersize=true},
	{t="icebro", spawnable=true, block=true},
	{t="squidnanny", name="blooper nanny", spawnable=true, supersize=true},
	{t="goombashoe", spawnable=true, supersize=false},
	{t="wiggler", spawnable=true, supersize=true}, --wiggler wednesday
	{t="magikoopa", spawnable=true, block=true, supersize=true},
	{t="homingbullet"},
	{t="boocircle", spawnable=true, supersize=true},
	{t="pdoor"},
	{t="keydoor"},
	{t="key", spawnable=true, block=true},
	{t="wigglerangry", spawnable=true, supersize=true},
	{t="tanookisuit", spawnable=true, block=true},
	{t="feather", spawnable=true, block=true},
	{t="carrot", spawnable=true, block=true},
	{t="weirdmushroom", spawnable=true, block=true},
	{t="pipespawnhor"},
	{t="ceilblocker"},
	{t="donutlast"},
	{t="skewer"},
	{t="boocrawler", spawnable=true, supersize=true},
	{t="downspikey", name="downspiny", spawnable=true, supersize=true},
	{t="downbeetle", spawnable=true, supersize=true},
	{t="spikeyshell", name="spinyshell", spawnable=true, block=true, supersize=true},
	{t="bigcloud", name="big cloud", spawnable=true, block=true},
	{t="longfireoff", name="burner on"},
	{t="belt"},
	{t="buttonbox", name="box button"},
	{t="buttonedgeless", name="edgeless button"},
	{t="luckystar", spawnable=true, block=true},
	{t="animationtrigger"},
	{t="animatedtiletrigger"},
	{t="rsflipflop"},
	{t="orgate"},
	{t="andgate"},
	{t="actionblock"},
	{t="collectable"},
	{t="collectablelock"},
	{t="powblock", spawnable=true, block=true},
	{t="switchblock"},
	{t="iciclebig", spawnable=true},
	{t="verspring", name="spring ver", spawnable=true, block=true},
	{t="horspring", name="spring hor", spawnable=true, block=true},
	{t="thwompleft", spawnable=true, supersize=true},
	{t="thwompright", spawnable=true, supersize=true},
	{t="risingwater"},
	{t="superballflower", spawnable=true, block=true},
	{t="beltswitch"},
	{t="drybonesshell", spawnable=true, block=true, supersize=true},
	{t="redseesaw"},
	{t="snakeblock"},
	{t="animationoutput"},
	{t="pbuttonblockon"},
	{t="pbuttonblockoff"},
	{t="spike", spawnable=true, block=true, supersize=true},
	{t="spikeball", spawnable=true, block=true, supersize=true},
	{t="frozencoin", spawnable=true},
	{t="powerup", block=true},
	{t="cheepcheep", supersize=true},
	{t="fireflower", spawnable=true, block=true},
	{t="propellerbox"},
	{t="cannonbox"},
	{t="clearpipe"},
	{t="cannonballcannon", spawnable=true, block=true, supersize=true},
	{t="camerastop"},
	{t="plantcreeper", name="piranha creeper"},
	{t="track"},
	{t="blueshell", spawnable=true, block=true},
	{t="boomerangflower", spawnable=true, block=true}, --hehe, boomerr
	{t="platform"},
	{t="pneumatictube"},
	{t="bigclassicmushroom", name="classic big mushroom", spawnable=true, block=true},
	{t="checkpointflag"},
	{t="supersize", argument="b", argumentname="supersize"},
	{t="mole", name="mole", spawnable=true, block=true, supersize=true},
	{t="grinder"},
	{t="bowserjr", spawnable=true, supersize=true},
	{t="trackswitch"},
}

--only spawnable with spawner or by enemies
hiddenentitylist = {
	{t="spikeyfall", name="spiny egg"},
	{t="bulletbillsingle", name="bulletbill"},
	{t="bigbillsingle", name="banzaibill"},
	{t="cannonballsingle", name = "cannonball"},
	{t="hammer"},
	{t="bowserfire"},
	{t="flyingfish"},
	{t="meteor"},
	{t="brofireball"},
	{t="broiceball"},
	{t="broboomerang"},
	{t="koopaling2", name="koopaling 2"},
	{t="koopaling3", name="koopaling 3"},
	{t="koopaling4", name="koopaling 4"},
	{t="koopaling5", name="koopaling 5"},
	{t="koopaling6", name="koopaling 6"},
	{t="koopaling7", name="koopaling 7"},
	{t="turretleft", name="turret"},
	{t="turret2left", name="defective turret"},
	{t="snowball"},
	{t="moving spring", name="moving spring"},
	{t="moving greenspring", name="moving greenspring"},
	{t="gel1", name="gel blue"},
	{t="gel2", name="gel orange"},
	{t="gel3", name="gel white"},
	{t="gel4", name="gel purple"},
	{t="gelcleanse", name="gel cleanse"},
}

--sort spawnable entities into a neat table
function generatespawnableentitylist(extraentities)
	local temptable = {}
	for i, t in pairs(entitylist) do
		if t.spawnable then
			table.insert(temptable, {t.t, t.name or t.t})
		end
	end
	if extraentities then
		for i, t in pairs(extraentities) do
			table.insert(temptable, {t.t, t.name or t.t})
		end
	end

	table.sort(temptable, function(a, b) return a[2] < b[2] end)

	local spawnableentities = {}
	local spawnableentitiesnames = {}
	for i, t in pairs(temptable) do
		table.insert(spawnableentities, t[1])
		table.insert(spawnableentitiesnames, t[2])
	end

	return spawnableentities, spawnableentitiesnames
end

tooltipimages = {}
tooltipquad = {}
tooltipquad[1] = love.graphics.newQuad(0,0,64,64,128,64)
tooltipquad[2] = love.graphics.newQuad(64,0,64,64,128,64)

for i = 1, #entitylist do
	local path = "graphics/entitytooltips/" .. entitylist[i].t .. ".png"
	if love.filesystem.getInfo(path) then
		tooltipimages[i] = {}
		tooltipimages[i].path = path
	end
end

entitydescriptions = {
	"place anywhere - acts as an entity eraser", --"remove",
	"place on a wall - mushroom", --"mushroom",
	"place on a wall - 1-up", --"oneup",
	"place on a wall - star", --"star",
	"place on a non question mark block - gives several coins", --"manycoins",
	"place on empty tile - goomba", --"goomba",
	"place on empty tile - koopa", --"koopa",
	"place on empty tile - mario's starting point", --"spawn",
	"place on empty tile - goomba - more to the right", --"goombahalf",
	"place on empty tile - koopa - more to the right", --"koopahalf",
	"place on a wall - bottom of the flag } end of level", --"flag",
	"place on empty tile - red koopa - will turn around at an edge", --"koopared",
	"place on empty tile - red koopa - more to the right", --"kooparedhalf",
	"place on wall - vine - right click to choose destination", --"vine",
	"place on empty tile - hammer bro", --"hammerbro",
	"place on empty underwater tile - cheep cheep fish - red", --"cheepred",
	"place on empty underwater tile - cheep cheep fish - white", --"cheepwhite",
	"place on empty tile - oscillating platform - right click for width", --"platformup", --my mouse is dying :(
	"place on empty tile - oscillating platform - right click for width", --"platformright",
	"place on empty tile - weighted storage cube", --"box",
	"place on pipe tile - pipe - right click for destination sublevel", --"pipe",
	"place on empty tile - lakitu - you can also add a lakitu end tile", --"lakito",
	"place on empty tile - logical maze start", --"mazestart",
	"place on empty tile - logical maze end", --"mazeend",
	"place on empty tile - maze gate - right click for the gate number", --"mazegate",
	"place on empty tile - horizontal emancipate grill - stops portals and companion cubes", --"emancehor",
	"place on empty tile - emancipation grill - stops portals and companion cubes", --"emancever",
	"place on empty tile - test chamber door - use link tool", --"doorver",
	"place on empty tile - horizontal door - use link tool", --"doorhor",
	"place on a wall - use link tool to show on or off state", --"wallindicator",
	"place on a pipe tile - right click for origin sublevel", --"pipespawn",
	"place on empty tile - falling platforms - right click for width", --"platformfall",
	"place anywhere - beginning of bullet zone", --"bulletbillstart",
	"place anywhere - end of bullet zone", --"bulletbillend",
	"place at the very bottom in an underwater level - drain - attracts mario down", --"drain",
	"place on empty tile - light bridge", --"lightbridgeright",
	"place on empty tile - light bridge to left", --"lightbridgeleft",
	"place on empty tile - light bridge to down", --"lightbridgedown",
	"place on empty tile - light bridge to up", --"lightbridgeup",
	"place on empty tile - floor button - use link", --"button",
	"place on top - platform spawner - right click for width", --"platformspawnerdown",
	"place at the bottom - up platform spawner - right click for width", --"platformspawnerup",
	"place on wall - use link to show on/off state", --"groundlightver",
	"place on wall - use link to show on/off state", --"groundlighthor",
	"place on wall - use link to show on/off state", --"groundlightupright",
	"place on wall - use link to show on/off state", --"groundlightrightdown",
	"place on wall - use link to show on/off state", --"groundlightdownleft",
	"place on wall - use link to show on/off state", --"groundlightleftup",
	"place on ground wall - faith plate", --"faithplateup",
	"place on ground wall - faith plate to the right", --"faithplateright",
	"place on ground wall - faith plate to the left", --"faithplateleft",
	"place on empty tile - laser", --"laserright",
	"place on empty tile - laser to bottom", --"laserdown",
	"place on empty tile - laser to left", --"laserleft",
	"place on empty tile - laser to up", --"laserup",
	"place on right edge wall or empty tile - will send off signal if laser is detected - use link", --"laserdetectorright",
	"place on down edge wall or empty tile - will send off signal if laser is detected - use link", --"laserdetectordown",
	"place on left edge wall or empty tile - will send off signal if laser is detected - use link", --"laserdetectorleft",
	"place on up edge wall or empty tile - will send off signal if laser is detected - use link", --"laserdetectorup",
	"place on bulletbill launchers - will make the launcher actually launch bulletbills", --"bulletbill",
	"place on empty tile - will produce gel to down - right click to pick gel", --"bluegeldown",
	"place on empty tile - will produce blue gel to right - blue gel } jump", --"bluegelright",
	"place on empty tile - will produce blue gel to left - blue gel } jump", --"bluegelleft",
	"place on empty tile - will produce orange gel to down - orange gel } run", --"orangegeldown",
	"place on empty tile - will produce orange gel to right - orange gel } run", --"orangegelright",
	"place on empty tile - will produce orange gel to left - orange gel } run", --"orangegelleft",
	"place on empty tile - will drop a box and remove previous one - use link", --"boxtube",
	"place on empty tile - will send a single on signal when used - use link", --"pushbuttonleft",
	"place on empty tile - will send a single on signal when used - use link", --"pushbuttonright",
	"place on empty tile - piranha plant will go up and down", --"plant",
	"place on empty tile - will produce white gel to down - white gel } portalable", --"whitegeldown",
	"place on empty tile - will produce white gel to right - white gel } portalable", --"whitegelright",
	"place on empty tile - will produce white gel to left - white gel } portalable", --"whitegelleft",
	"place anywhere - will send on signal for a duration - right click to set duration", --"timer",
	"place on empty tile - beetle - runs fast and resists fireballs", --"beetle",
	"place on empty tile - beetle - more to the right", --"beetlehalf",
	"place on empty tile - red flying koopa, goes up and down", --"kooparedflying",
	"place on empty tile - green flying koopa, jumps around", --"koopaflying",
	"place on wall - firebar - right click for direction and length", --"castlefireccw",
	"place on empty tile - see-saw - right click for see-saw type", --"seesaw",
	"place on wall - warp pipe - right click for destination world", --"warppipe",
	"place on wall - clockwise rotating fire - right click for width", --"castlefirecw",
	"place anywhere - defines a right border for lakitu - use with lakitu", --"lakitoend",
	"place anywhere - turns an input around", --notgate
	"place on tile - creates gel on this block. 1: blue, 2: orange, 3: white, 4:purple",
	"place on tile - creates gel on this block. 1: blue, 2: orange, 3: white, 4:purple",
	"place on tile - creates gel on this block. 1: blue, 2: orange, 3: white, 4:purple",
	"place on tile - creates gel on this block. 1: blue, 2: orange, 3: white, 4:purple",
	"place anywhere - fire start - bowser firethings will regularly cross the screen", --"firestart",
	"place on empty tile preferably on the first block on a bridge with an axe - bowser", --"bowser",
	"place on empty tile preferably behind a bridge - axe } end of level", --"axe",
	"place on empty tile - platform in coin worlds", --"platformbonus",
	"place on empty tile - spring", --"spring",
	"place on empty tile preferably underwater - blooper", --"squid",
	"place anywhere - defines the start of a flying cheep cheep zone", --"flyingfishstart",
	"place anywhere - defines the end of a flying cheep cheep zone", --"flyingfishend",
	"place anywhere - a lava bubble will jump up and down on this line", --"upfire",
	"place on empty tile - spiny", --"spikey",
	"place on empty tile - spiny - more to the right", --"spikeyhalf",
	"place on empty tile - checkpoint - mario will spawn there if he dies after reaching it", --"checkpoint",
	"place on a wall - poison mushroom", --"poisonmush",
	"place on empty tile - upside down piranha plant", --"downplant",
	"place on empty tile - paragoomba", --"paragoomba",
	"place on bulletbill launchers - will make the launcher actually launch banzaibills", --"bigbill",
	"place on empty tile - launches one giant king bill - right click for speed", --"kingbill",
	"place on empty tile - side stepper", --"sidestepper",
	"place on empty tile - barrel", --"barrel",
	"place on empty tile - icicle - right click for gravity", --"icicle",
	"place on empty tile - angry sun", --"angrysun",
	"place anywhere - defines a right border for angry sun - use with an angry sun", --"angrysunend",
	"place on empty tile - splunkin", --"splunkin",
	"place on empty tile - splunkin - more to the right", --"splunkinhalf",
	"place on a wall - 3-up moon", --"threeup",
	"place on empty tile - giant goomba", --"biggoomba",
	"place on empty tile - giant spiny", --"bigspikey",
	"place on empty tile - giant koopa", --"bigkoopa",
	"place on empty tile - koopa shell", --"shell",
	"place on empty tile - goombrat", --"goombrat",
	"place on empty tile - goombrat - more to the right", --"goombrathalf",
	"place on empty tile - fire bro", --"firebro"
	"place on a wall - clock", --"plusclock"
	"place on empty tile - green spring", --"springgreen"
	"place on empty tile - red piranha plant will go up and down fast", --"redplant",
	"place on empty tile - upside down red piranha plant", --"reddownplant",
	"place on empty tile - thwomp", --"thwomp",
	"place on empty underwater tile - fishbones - resists fireballs", --"fishbone",
	"place on empty tile - drybones - resists fireballs", --"drybones",
	"place on empty tile - drybones - more to the right", --"dryboneshalf",
	"place on empty tile - muncher", --"muncher",
	"place on empty tile - giant beetle", --"bigbeetle",
	"place anywhere - defines the start of a meteor zone", --"meteorstart",
	"place anywhere - defines the end of a meteor zone", --"meteorend",
	"place on empty tile - bone goomba - resists fireballs", --"drygoomba",
	"place on empty tile - bone goomba - more to the right", --"drygoombahalf",
	"place on empty tile - dry piranha plant - resists fireballs", --"dryplant",
	"place on empty tile - upside down dry piranha plant", --"drydownplant",
	"place on empty tile - donut platform - falls when stepped on", --"donut",
	"place on empty tile - boomerang bro", --"boomerangbro",
	"place anywhere - parabeetle - left", --"parabeetle",
	"place on empty tile - ninji", --"ninji",
	"place on a wall - hammer suit", --"hammersuit",
	"place anywhere - boo", --"boo",
	"place on empty tile - monty mole in ground", --"moleground",
	"place on empty tile - mega mole", --"bigmole",
	"place on empty tile - bob-omb", --"bomb",
	"place on empty tile - bob-omb - more to the right", --"bombhalf",
	"place on empty tile - venus firetrap - shoots fire", --"fireplant",
	"place on empty tile - rotating block - rotates when hit", --"donut",
	"place on empty tile - upside down venus firetrap", --"downfireplant",
	"place on empty tile - hand launches torpedo teds", --"torpedoted",
	"place on a wall - frog suit", --"frogsuit",
	"place anywhere - parabeetle - right", --"parabeetleright",
	"place on empty tile - boomboom", --"boomboom",
	"place on empty tile - ? ball - end of level",
	"place on a wall - raccoon leaf", --"leaf",
	"place on empty tile - blue koopa - moves fast", --"koopablue",
	"place on empty tile - blue koopa - more to the right", --"koopabluehalf",
	"place on empty tile - flying koopa, goes right and left", --"koopaflying2",
	"place anywhere - beginning of wind", --"windstart",
	"place anywhere - end of wind", --"windend",
	"place on pipe tile - pipe - right click for destination sublevel - enter left or up", --"pipe2?",
	"place on empty tile - pink blooper - stompable", --"pinksquid",
	"place on empty tile - door - right click for destination sublevel - press up to enter", --"door",
	"place on a wall - ice - makes tile slippery", --"ice",
	"place on empty tile - companion cube", --"box2",
	"place on empty tile - high energy pellet launcher - right click for options", --"energylauncherright",
	"place on empty tile - high energy pellet launcher - left", --"energylauncherleft",
	"place on empty tile - high energy pellet launcher - up", --"energylauncherup",
	"place on empty tile - high energy pellet launcher - down", --"energylauncherdown",
	"place on empty tile - high energy pellet catcher - use link", --"energycatcherright",
	"place on empty tile - high energy pellet catcher - left - use link", --"energycatcherleft",
	"place on empty tile - high energy pellet catcher - up - use link", --"energycatcherup",
	"place on empty tile - high energy pellet catcher - down - use link", --"energycatcherdown",
	"place on empty tile - turret - left", --"turretleft",
	"place on empty tile - turret - right", --"turretright",
	"place on empty tile - defective turret - left", --"turret2left",
	"place on empty tile - defective turret - right", --"turret2right",
	"place on empty tile - ! button - push to toggle ! button blocks - right click for colors", --"blocktogglebutton",
	"place on empty tile - ! button block - on - right click for colors", --"buttonblockon",
	"place on empty tile - ! button block - off - right click for colors", --"buttonblockoff",
	"place on empty tile - will produce purple gel to down - purple gel } gravity", --"purplegeldown",
	"place on empty tile - will produce purple gel to right - purple gel } gravity", --"purplegelright",
	"place on empty tile - will produce purple gel to left - purple gel } gravity", --"purplegelleft",
	"place on empty underwater tile - rip van fish - wakes up when player is near", --"sleepfish",
	"place anywhere - turns output on then off - right click to choose delay", --"squarewave",
	"place anywhere - delays an input - right click to choose delay", --"delayer",
	"place anywhere - coin", --"coin",
	"place on a track - fuzzy", --"amp",
	"place anywhere - green parabeetle - left - goes fast", --"parabeetlegreen",
	"place anywhere - green parabeetle - right - goes fast", --"parabeetlegreenright",
	"place on empty tile - burner - off - right click for direction", --"longfire",
	"place on tile - cannon ball - right click to choose direction", --"cannonball",
	"place on a wall - mini mushroom", --"minimushroom",
	"place on empty tile - rocket turret - shoots rockets", --"rocketturret",
	"place on empty tile - glados", --"GLaDOS",
	"place on empty tile - portal gun pedestal - right click to choose portals", --"pedestal",
	"place on a wall - portal 1 - right click to choose side - use link tool", --"portal1",
	"place on a wall - portal 2 - right click to choose side - use link tool", --"portal2",
	"place anywhere - text - right click to type text", --"text",
	"place anywhere - region trigger - right click to select region", --"region trigger",
	"place anywhere - tile tool - rightclick to type function", --"tiletool",
	"place on a wall - ice flower", --"iceflower",
	"place on empty tile - shy guy", --"shyguy",
	"place on empty tile - shy guy - more to the right", --"shyguyhalf",
	"place anywhere - spawner - rightclick to type enemy to spawn", --"enemytool",
	"place anywhere - randomizer - turns on a random output - right click to choose method", --"randomizer",
	"place on a wall - yoshi egg", --"yoshi",
	"place on empty tile - big ! button - push to toggle ! button blocks - right click for colors",
	"place on empty tile - beetle shell", --"beetleshell",
	"place anywhere - music changer - changes music - right click to select music", --"musicchanger",
	"place anywhere - p switch", --"pbutton",
	"place on empty tile - spike top - walks along walls", --"spiketop",
	"place on empty tile - spike top half - walks along walls", --"spiketophalf",
	"place on empty tile - pokey - right click for height", --"pokey",
	"place on empty tile - snow pokey - stompable - right click for height", --"snowpokey",
	"place on empty tile - fighter fly", --"fighterfly",
	"place on a wall - wing - allows player to fly", --"swimwing",
	"place on a wall - dk hammer", --"dkhammer",
	"place anywhere - vine stop", --"vinestop",
	"place anywhere - chainchomp", --"chainchomp",
	"place on empty tile - sledge bro", --"bighammerbro",
	"place on empty tile - edgeless safety cube", --"edgelessbox",
	"place on empty tile - rocky wrench", --"rockywrench",
	"place on empty tile - thwomp - more to the right", --"thwomp",
	"place on empty tile - will produce cleansing gel to down - removes gel", --"watergeldown",
	"place on empty tile - will produce cleansing gel to right - removes gel", --"watergelright",
	"place on empty tile - will produce cleansing gel to left - removes gel", --"watergelleft",
	"place anywhere - roto-disc - rightclick to change number and direction", --"rotodisc",
	"place on empty tile - excursion funnel up - use link tool", --"funnelup",
	"place on empty tile - excursion funnel down - use link tool", --"funneldown",
	"place on empty tile - excursion funnel - right click for options", --"funnelright",
	"place on empty tile - excursion funnel left - use link tool", --"funnelleft",
	"place on a pipe tile - right click for origin sublevel - down", --"pipespawndown",
	"place on empty tile - thwimp", --"thwimp",
	"place on empty tile - bony beetle - resists fireballs and has spikes", --"drybeetle",
	"place on empty tile - bony beetle - more to theee right", --"drybeetlehalf",
	"place on empty tile - tiny goomba", --"tinygoomba",
	"place on empty tile - koopaling - right click to change koopaling", --"koopaling",
	"place on a wall - mega mushroom", --"bigmushroom",
	"place on empty tile - super mario bros 3 bowser", --"bowser3",
	"place on empty tile - ice bro", --"icebro",
	"place on anywhere - blooper nanny", --"squidnanny",
	"place on empty tile - goombashoe - rightclick to change sprite", --"goombashoe",
	"place on empty tile - wiggler", --"wiggler",
	"place on empty tile - magikoopa", --"magikoopa",
	"place on a wall - homing bullet", --"homingbullet",
	"place on empty tile - boo circle", --"boocircle",
	"place on empty tile - p button door - right click for destination sublevel - use p button", --"pdoor",
	"place on empty tile - key door - right click for destination sublevel - use key", --"keydoor",
	"place anywhere - key - use for key door", --"key",
	"place on empty tile - angry wiggler", --"wigglerangry",
	"place on a wall - tanooki suit", --"tanookisuit",
	"place on a wall - feather", --"feather",
	"place on a wall - carrot", --"carrot",
	"place on a wall - weird mushroom", --"weirdmushroom",
	"place on a pipe tile - right click for origin sublevel - left or right", --"pipespawnhor",
	"place anywhere - makes it impossible to jump over the top row of blocks", --"ceilblocker",
	"place on empty tile - donut platform - falls when stood on for a while", --"donutlast",
	"place anywhere - skewer - right click for directions", --"skewer",
	"place above tile - stretch", --"boocrawler",
	"place on empty tile - upside down spiny", --"downspikey",
	"place on empty tile - upside down beetle", --"downbeetle",
	"place anywhere - spiny shell", --"spikeyshell",
	"place anywhere - big cloud - ride", --"bigcloud",
	"place on empty tile - burner - on - right click for direction", --"longfireoff",
	"place on empty tile - conveyor belt - right click to choose direction and speed", --"belt",
	"place on empty tile - cube floor button - use link", --"buttonbox",
	"place on empty tile - edgeless cube floor button - use link", --"buttonedgeless",
	"place on a wall - lucky star - kills all enemies", --"luckystar",
	"place anywhere - will start an animation when getting an input signal", -- "animationtrigger",
	"place anywhere - will animate tiles with the trigger attribute", --"animatedtiletrigger",
	"place anywhere - can be toggled on and off", --"rsflipflop",
	"place anywhere - or gate", --"orgate",
	"place anywhere - and gate", --"andgate",
	"place on empty tile - will create a coinblock style toggle button - use link tool", -- "actionblock",
	"place anywhere - collectable - right click to choose type", --"collectable",
	"place anywhere - collectable lock - sets output when collectables are collected", --"collectablelock",
	"place on empty tile - pow block", --"powblock",
	"place on empty tile - switch block - push to toggle ! button blocks - right click for colors", -- "switchblock",
	"place on empty tile - big icicle", --"iciclebig"
	"place on empty tile - vertical spring", --"verspring",
	"place on empty tile - horizontal spring", --"horspring",
	"place on empty tile - left thwomp", --"thwompleft",
	"place on empty tile - right thwomp", --"thwompright",
	"place anywhere - water - right click to adjust", --"risingwater",
	"place on a wall - super ball flower", --"superballflower",
	"place on empty tile - ! conveyor belt - right click to choose direction and speed", --"beltswitch",
	"place anywhere - dry bones shell", --"drybonesshell",
	"place on empty tile - red seesaw - right click for width", --"redseesaw",
	"place on empty tile - snake block - right click for path", --"snakeblock",
	"place anywhere - will output signal when triggered by an animation", -- "animationoutput",
	"place on empty tile - p block - on", --"pbuttonblockon",
	"place on empty tile - p block - off", --"pbuttonblockoff",
	"place on empty tile - spike - right click for types", --"spike",
	"place on empty tile - spike ball - right click for types", --"spikeball",
	"place on empty tile - frozen coin", --"frozencoin",
	"place on block - will give either a mushroom or a flower", --"powerup",
	"place on empty tile - red or white cheep cheep", --"cheepcheep",
	"place anywhere - fire flower", --"fireflower",
	"place on empty tile - propeller box", --"propellerbox",
	"place on empty tile - cannon box", --"cannonbox",
	"place on empty tile - clear pipe - right click to set path", --"clearpipe",
	"place on empty tile - cannon ball cannon - right click for direction", --"cannonballcannon",
	"place anywhere - camera stop - link to disable", --"camerastop",
	"place on empty tile - piranha creeper - right click for path", --"plantcreeper"
	"place anywhere - track - right click for path", --"track",
	"place on a wall - blue shell", --"blueshell",
	"place on a wall - boomerang flower", --"boomerangflower",
	"place on empty tile - oscillating platform - right click for width", -- "platform",
	"place on empty tile - pneumatic diversity vent - right click to set path", --"pneumatictube",
	"place on a wall - classic big mushroom", --"bigclassicmushroom",
	"place on empty tile - checkpoint flag", --"checkpointflag",
	"place on enemy - will make enemy super-sized", --"supersize",
	"place on empty tile - monty mole", --"mole",
	"place anywhere - grinder", --"grinder",
	"place on empty tile - bowser jr.", --"bowserjr",
	"place anywhere - track switch - right click for path", --"trackswitch",
}

rightclickvalues = {}

--rightclickvalues["vine"] = {"target", 0, 1, 2, 3, 4, 5, 6}

rightclickvalues["mazegate"] = {"gateno", 1, 2, 3, 4, 5}

rightclickvalues["icicle"] = {"gravity", 10, 13, 15, 8, 5}

rightclickvalues["blocktogglebutton"] = {"color", 1, 2, 3, 4}
rightclickvalues["buttonblockon"] = {"color", 1, 2, 3, 4}
rightclickvalues["buttonblockoff"] = {"color", 1, 2, 3, 4}
rightclickvalues["bigblocktogglebutton"] = {"color", 1, 2, 3, 4}
rightclickvalues["switchblock"] = {"color", 1, 2, 3, 4}

rightclickvalues["pedestal"] = {"portals", "both", "1 only", "2 only", "gel"}

rightclickvalues["pokey"] = {"height", "default", 1, 2, 3, 4, 5, 6, 7, 8}
rightclickvalues["snowpokey"] = {"height", "default", 1, 2, 3, 4, 5, 6, 7, 8}

rightclickvalues["goombashoe"] = {"type", 1, 2}

rightclickvalues["yoshi"] = {"color", 1, 2, 3, 4}

rightclickvalues["spike"] = {"type", "spike", "snow"}
rightclickvalues["spikeball"] = {"type", "spike", "snow"}

rightclickvalues["grinder"] = {"type", "grinder", "bumper"}

rightclicktype = {}
rightclicktype["text"] = {
	name = "text",
	default = "text|white|false|false|false|false",
	objfunc = function()
		rightclickobjects[4].coloredtext = true
	end,
	format = {
		"text",
		{"input", 1, "text", 14, 50, 1, function(v) rightclickvalues2[1] = v end}, --"input", var, default, width, maxlen, height, function
		"color",
		{"dropdown", 2, 6, nil, deepcopy(textcolorsnames)},
		{"checkbox", 3, "outline", default = false},
		{"checkbox", 5, "centered", default = false},
		{"checkbox", 6, "big", default = false},
		{"checkbox", 4, "default off", default = false},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}} --"input", var, text, function
	}
}
rightclicktype["regiontrigger"] = {
	name = "region trigger",
	default = "1|1|0|0|player",
	regionfunc = function(w,h,x,y) --setting region vars
		rightclickvalues2[1] = w
		rightclickvalues2[2] = h
		rightclickvalues2[3] = x
		rightclickvalues2[4] = y
	end,
	varfunc = function(v, i)
		if i == 1 then
			if not rightclickvalues2[5] then
				rightclickvalues2[5] = "player"
			end
		end
		return v
	end,
	format = {
		"trigger on",
		{"dropdown", 5, 10, nil, {"player","enemy","cube","everything"}},
		{"button", 2, {"select region", startrcregion, {1, 2}}}
	},
}

rightclicktype["pipe"] = {
	name = "pipe",
	default = "0|1|down|big",
	objfunc = function()
		rightclickobjects[7].entries = sublevelstable
	end,
	format = {
		"direction",
		{"dirbuttonset", 3},
		"target sub",
		{"dropdown", 1, 4, nil, maxsublevelstable},
		"exit id:",
		{"dropdown", 2, 4, nil, {1,2,3,4,5,6,7,8,9,10}},
		"pipe size:",
		{"dropdown", 4, 5, nil, {"big","small","tiny","giant"}},
		{"button", 2, {"link exit", startrclink, {"exit", "exit"}}, {"x", resetrclink, {"exit"}, textcolor = {255, 0, 0}}},
	},
	customoutputs = {"pipe", "pipe2", "pipespawn", "pipespawndown", "pipespawnhor"}
}
rightclicktype["pipe2"] = deepcopy(rightclicktype["pipe"])

rightclicktype["pipespawn"] = {
	name = "pipespawn",
	default = "0|1|up|big",
	objfunc = function()
		rightclickobjects[7].entries = sublevelstable
	end,
	format = {
		"direction",
		{"dirbuttonset", 3},
		"entry sub",
		{"dropdown", 1, 4, nil, maxsublevelstable},
		"id:",
		{"dropdown", 2, 4, nil, {1,2,3,4,5,6,7,8,9,10}},
		"pipe size:",
		{"dropdown", 4, 5, nil, {"big","small","tiny","giant"}},
	},
}
rightclicktype["pipespawndown"] = deepcopy(rightclicktype["pipespawn"])
rightclicktype["pipespawnhor"] = deepcopy(rightclicktype["pipespawn"])

rightclicktype["warppipe"] = {
	name = "warp pipe",
	default = "1|1|down|big",
	varfunc = function(v, i)
		local n = tonumber(v)
		if i == 1 then
			if n and hudworldletter and n > 9 and n <= 9+#alphabet then return alphabet:sub(n-9, n-9) end
		elseif i == 2 then --find level. If there isn't one, return 1
			if n then return n end return 1
		end return v
	end,
	savefunc = function()
		local v = rightclickvalues2[1]
		if tonumber(v) then
			rightclickvalues2[1] = math.min(maxworlds, tonumber(v))
		else --if letter inputed turn into number.
			local f1 = alphabet:find(tostring(v))
			if f1 then
				v = 9+f1
				rightclickvalues2[1] = math.min(maxworlds, v)
			end
		end 
	end,
	format = {
		"direction",
		{"dirbuttonset", 3},
		"world",
		{"input", 1, "1", 3, 2, 1, 
		function(v) 
			if tonumber(v) then
				rightclickvalues2[1] = math.min(maxworlds, tonumber(v))
			else
				--if letter inputed turn into number.
				local f1 = alphabet:find(tostring(v))
				if f1 then
					v = 9+f1
					rightclickvalues2[1] = math.min(maxworlds, v)
				end
			end 
		end},
		"level",
		{"input", 2, "2", 3, 2, 1, 
		function(v) 
			if tonumber(v) then
				rightclickvalues2[2] = math.min(maxlevels, tonumber(v))
			end 
		end},
		"pipe size:",
		{"dropdown", 4, 5, nil, {"big","small","tiny","giant"}},
	}
}
rightclicktype["vine"] = {
	name = "vine",
	default = "0",
	objfunc = function()
		rightclickobjects[2].entries = sublevelstable
	end,
	format = {
		"target",
		{"dropdown", 1, 4, nil, maxsublevelstable},
	},
}

--rightclickvalues["platformfall"] = {"width", 1.5, 2, 3, 5}
rightclicktype["platformfall"] = {
	name = "plarform fall",
	default = "1.5",
	format = {
		"width:",
		{"slider", 1, range = {1, 10, step = 0.5}},
	}
}
rightclicktype["platformbonus"] = {
	name = "plarform bonus",
	default = "3",
	format = {
		"width:",
		{"slider", 1, range = {1, 10, step = 0.5}},
	}
}
rightclicktype["platformup"] = {
	name = "plarformup",
	default = "1.5|0|8.625|6.4|false",
	varfunc = function(v, i)
		if i == 1 then
			if not rightclickvalues2[2] then
				if map[rightclickmenucox][rightclickmenucoy][2] and entitylist[map[rightclickmenucox][rightclickmenucoy][2]].t == "platformup" then
					rightclickvalues2[2] = "0"
					rightclickvalues2[3] = "8.625"
					rightclickvalues2[4] = "6.4"
				else
					rightclickvalues2[2] = "n3.3125"
					rightclickvalues2[3] = "0"
					rightclickvalues2[4] = "4"
				end
			end
		end
		return v
	end,
	format = {
		"width:",
		{"slider", 1, range = {1, 10, step = 0.5}},
		"distance x:",
		{"slider", 2, range = {-15, 15, round = 1}},
		"distance y:",
		{"slider", 3, range = {-15, 15, round = 1}},
		"duration:",
		{"slider", 4, range = {1, 20, round = 2}},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}},
	}
}
rightclicktype["platformright"] = deepcopy(rightclicktype["platformup"])
rightclicktype["platformright"].default = "1.5|n3.3125|0|4"
rightclicktype["platform"] = deepcopy(rightclicktype["platformup"])
rightclicktype["platform"].default = "1.5|n3.3125|0|4"
rightclicktype["platform"].name = "platform"
rightclicktype["platformspawnerup"] = {
	name = "plarformspawnerup",
	default = "3|3.5|2.18|up",
	varfunc = function(v, i)
		if i == 1 then
			if not rightclickvalues2[2] then
				rightclickvalues2[2] = "3.5"
				rightclickvalues2[3] = "2.18"
			end
		end
		return v
	end,
	format = {
		"direction",
		{"verdirbuttonset", 4},
		"width:",
		{"slider", 1, range = {1, 10, step = 0.5}},
		"speed:",
		{"slider", 2, range = {0.5, 10, round = 2}},
		"delay:",
		{"slider", 3, range = {1, 10, round = 2}},
	}
}
rightclicktype["platformspawnerdown"] = deepcopy(rightclicktype["platformspawnerup"])
rightclicktype["platformspawnerdown"].default = "3|3.5|2.18|down"
rightclicktype["cannonball"] = {
	name = "cannon ball",
	default = "left|7",
	format = {
		"direction",
		{"anglebuttonset", 1},
		"speed",
		{"slider", 2, range = {3.5, 14, round = 2}},
	},
}
rightclicktype["cannonballcannon"] = {
	name = "cannon ball",
	default = "left|7|down",
	format = {
		"direction",
		{"anglebuttonset", 1},
		"base",
		{"dirbuttonset", 3},
		"speed",
		{"slider", 2, range = {3.5, 14, round = 2}},
	},
}
rightclicktype["delayer"] = {
	name = "delayer",
	default = "1|true",
	format = {
		{"checkbox", 2, "visible"},
		"delay",
		{"input", 1, "1", 4, 4, 1, function(v) rightclickvalues2[1] = v end},
		{"button", 2, {"link trigger", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["squarewave"] = {
	name = "square wave",
	default = "0.5|0.5|true|0",
	varfunc = function(v, i)
		if not rightclickvalues2[2] then
			rightclickvalues2[2] = rightclickvalues2[1]
			rightclickvalues2[3] = true
		end
		return v
	end,
	format = {
		{"checkbox", 3, "visible"},
		"on time:",
		{"slider", 1, range = {0.01, 10, round = 2}},
		"off time:",
		{"slider", 2, range = {0.01, 10, round = 2}},
		"wave offset:",
		{"slider", 4, range = {0, 1, round = 2}},
	}
}
rightclicktype["tiletool"] = {
	name = "tile tool",
	default = "change to 1|1|1|0|0",
	objfunc = function()
		rightclickobjects[2].displayentries = rightclicktype["tiletool"].d
		for i, func in pairs(rightclicktype["tiletool"].t) do
			--find if start of function is the same as one of the dropdown entries
			local len = #func
			if rightclickvalues2[1]:sub(1, len) == func then
				--make input bar invisible
				rightclickobjects[3].active = true
				rightclickobjects[3].dontdraw = false
				if func == "change to " then
				elseif func == "set back to " then
				elseif func == "check gel " then
				elseif func == "set gel " then
				else
					rightclickobjects[3].active = false
					rightclickobjects[3].dontdraw = true
				end
				--split and set function and argument
				rightclickobjects[2].var = i
				rightclickobjects[3].value = rightclickvalues2[1]:sub(len+1, -1)
				rightclickobjects[3]:updatePos()
				break
			end
		end
	end,
	regionfunc = function(w,h,x,y) --setting region vars
		rightclickvalues2[2] = w
		rightclickvalues2[3] = h
		rightclickvalues2[4] = x
		rightclickvalues2[5] = y
	end,
	savefunc = function()
		if rightclickobjects[2] and rightclickobjects[3] then
			--save function correctly
			rightclickvalues2[1] = rightclicktype["tiletool"].t[rightclickobjects[2].var or 1] .. rightclickobjects[3].value
		end
	end,
	format = {
		"function:",

		{"dropdown", 1, 13,
		function(v)
			rightclickobjects[2].var = v
			--set default argument
			local func = rightclicktype["tiletool"].t[v]
			rightclickobjects[3].dontdraw = false
			rightclickobjects[3].active = true
			if func == "change to " then
				rightclickobjects[3].value = "1"
			elseif func == "set back to " then
				rightclickobjects[3].value = "1"
			elseif func == "check gel " then
				rightclickobjects[3].value = "1 all"
			elseif func == "set gel " then
				rightclickobjects[3].value = "top 1"
			else
				rightclickobjects[3].active = false
				rightclickobjects[3].dontdraw = true
				rightclickobjects[3].value = ""
			end
			rightclickobjects[3]:updatePos()
			rightclicktype["tiletool"].savefunc()
		end, 
		{"change to ","set back to ","group","remove","break","hit","set gel ","check gel ","remove gel"}},

		{"smallinput", 1, "1", 14, 20, 1, function(v) rightclicktype["tiletool"].savefunc() end},
		{"button", 2, {"select tiles", 
			function(var, step) 
				--save function correctly
				rightclickvalues2[1] = rightclicktype["tiletool"].t[rightclickobjects[2].var or 1] .. rightclickobjects[3].value
				startrcregion(var, step)
			end, {2, 1}}},
		{"button", 3, {"link trigger", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	},
	t = {"change to ","set back to ","group","remove","break","hit","set gel ","check gel ","remove gel"},
	d = {"change to:","set back to:","group","remove","break","hit","set gel:", "check gel:", "remove gel"},
}
rightclicktype["enemytool"] = {
	name = "spawner",
	default = "goomba|0|0|false|none|false",
	ignoredefault = {false,false,false,"missing",false},
	varfunc = function(v, i)
		if i == 1 then
			local list, listnames = generatespawnableentitylist(hiddenentitylist)
			rightclicktype["enemytool"].entitylistlength = #list
			for j, w in pairs(customenemies) do
				if w and enemiesdata[w] and enemiesdata[w].hidden then
					--hidden!
				else
					table.insert(list, w)
					table.insert(listnames, "_ENEMY" .. w)
				end
			end
			if rightclickvalues2[4] == "missing" then
				--backwards compatibility, should it be a custom enemy?
				if tablecontains(customenemies, v) then
					rightclickvalues2[4] = "true"
				else
					rightclickvalues2[4] = "false"
				end
			end
			rightclicktype["enemytool"].t = list
			rightclicktype["enemytool"].tnames = listnames
			local f = 1
			local t = rightclicktype["enemytool"].t
			for i = 1, #t do
				if v == t[i] and
				((rightclickvalues2[4] == nil) or (rightclickvalues2[4] == "true" and i > rightclicktype["enemytool"].entitylistlength)
				or (rightclickvalues2[4] == "false" and i <= rightclicktype["enemytool"].entitylistlength)) then
					f = i
					break
				end
			end
			return f
		end
		return v
	end,
	objfunc = function()
		rightclickobjects[2].entries = rightclicktype["enemytool"].t
		rightclickobjects[2].displayentries = rightclicktype["enemytool"].tnames
		rightclickobjects[2]:updatePos()
	end,
	savefunc = function()
		if rightclicktype["enemytool"].t[rightclickvalues2[1]] then
			if rightclickvalues2[1] > rightclicktype["enemytool"].entitylistlength then
				--it's a custom enemy
				rightclickvalues2[4] = true
			else
				rightclickvalues2[4] = false
			end
			rightclickvalues2[1] = rightclicktype["enemytool"].t[rightclickvalues2[1]]
		end
	end,
	format = {
		"enemy",
		{"dropdown", 1, 14, nil, {"goomba"}},
		--{"input", 1, "goomba", 14, 20, 1, function(v) rightclickvalues2[1] = v end},
		"velocity x:",
		{"slider", 2, range = {-50, 50, round = 1}},
		"velocity y:",
		{"slider", 3, range = {-50, 50, round = 1}},
		"animation",
		{"dropdown", 5, 14, nil, {"none", "block", "cannon", "pipeup", "pipedown", "pipeleft", "piperight", "poof"}, ignorerctt=true},
		{"checkbox", 6, "only on screen"},
		{"button", 2, {"link trigger ", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}},
	},
	t = {"goomba"},
	entitylistlength = 1,
	tnames = {"goomba"},
}
rightclicktype["kingbill"] = {
	name = "king ball",
	default = "5|right",
	varfunc = function(v, i)
		if i == 1 then
			if not rightclickvalues2[2] then rightclickvalues2[2] = "right" end
		end
		return v
	end,
	format = {
		"speed",
		{"slider", 1, range = {3, 9, round = 1}},
		"direction",
		{"dirbuttonset", 2},
		{"button", 2, {"link trigger", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}},
	},
}
rightclicktype["musicchanger"] = {
	name = "music changer",
	default = "overworld|1|true",
	varfunc = function(v, i)
		if i == 1 then
			local f = 1
			local t = musictable
			v = readlevelfilesafe(v)
			for i = 1, #t do --print(v,t[i])
				if v == t[i] then
					f = i
					break
				end
			end
			return f
		end
		return v
	end,
	objfunc = function()
		rightclicktype["musicchanger"].t = musictable
		rightclickobjects[3].entries = editormusictable
		rightclickobjects[3]:updatePos()
	end,
	savefunc = function()
		if tonumber(rightclickvalues2[1]) then
			rightclickvalues2[1] = musictable[rightclickvalues2[1]]
		end
		rightclickvalues2[1] = makelevelfilesafe(rightclickvalues2[1])
	end,
	format = {
		{"checkbox", 3, "visible"},
		"change music to",
		{"dropdown", 1, 15, function(v) rightclickobjects[3].var = v; rightclickvalues2[1] = rightclicktype["musicchanger"].t[v] end, {"overworld", "underground", "castle", "underwater", "star", "custom", "none"}}, --"dropdown", var, width (in chars), func, {entries}
		"custom music id",
		{"input", 2, "1", 2, 2, 1, function(v) rightclickvalues2[2] = v end},
		{"button", 2, {"link trigger", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}},
	},
	t = {"overworld", "underground", "castle", "underwater", "star", "custom", "none"}
}

rightclicktype["seesaw"] = {
	name = "seesaw",
	default = "7|4|6|3",
	fixdefault = true,
	varfunc = function(v, i)
		if i == 1 then
			if not rightclickvalues2[2] then
				--convert old format (do this later)
				rightclickvalues2[2] = seesawtype[v][2]
				rightclickvalues2[3] = seesawtype[v][3]
				rightclickvalues2[4] = seesawtype[v][4]
				return seesawtype[v][1]
			end
		end
		return v
	end,
	format = {
		"distance:",
		{"slider", 1, range = {2, 10, round = 0}},
		"left height:",
		{"slider", 2, range = {1, 10, round = 0}},
		"right height:",
		{"slider", 3, range = {1, 10, round = 0}},
		"platf. width:",
		{"slider", 4, range = {1, 10, step = 0.5}},
	},
}

rightclicktype["bowser"] = {
	name = "bowser",
	default = "boss",
	format = {
		"type",
		{"dropdown", 1, 4, nil, {"boss", "enemy"}},
	},
}

rightclicktype["door"] = {
	name = "door",
	default = "0|1|true",
	objfunc = function()
		rightclickobjects[2].entries = sublevelstable
	end,
	format = {
		"target sub",
		{"dropdown", 1, 4, nil, maxsublevelstable},
		"exit id:",
		{"dropdown", 2, 4, nil, {1,2,3,4,5,6,7,8,9,10}},
		{"checkbox", 3, "visible"},
		{"button", 2, {"link exit", startrclink, {"exit", "exit"}}, {"x", resetrclink, {"exit"}, textcolor = {255, 0, 0}}},
	},
}

rightclicktype["pdoor"] = rightclicktype["door"]
rightclicktype["keydoor"] = rightclicktype["door"]

rightclicktype["castlefirecw"] = {
	name = "fire bar clockwise",
	default = "6|" .. castlefiredelay .. "|0|cw|false",
	varfunc = function(v, i)
		if i == 1 then
			if not rightclickvalues2[2] then
				rightclickvalues2[2] = castlefiredelay
			end
		end
		return v
	end,
	savefunc = function()
		rightclickvalues2[2] = (rightclickobjects[4].value*0.97)+0.03
	end,
	format = {
		"length:",
		{"slider", 1, range = {1, 18, round = 0}},
		"delay:",
		{"slider", 2, range = {0.03, 1, round = 2}},
		"angle:",
		{"slider", 3, range = {0, 360, round = 0}},
		{"checkbox", 5, "smooth"},
		"direction:",
		{"rotbuttonset", 4},
	},
}
rightclicktype["castlefireccw"] = deepcopy(rightclicktype["castlefirecw"])
rightclicktype["castlefireccw"].default = "6|" .. castlefiredelay .. "|0|ccw|false"

rightclicktype["rotodisc"] = {
	name = "roto-disc",
	default = "1|left",
	format = {
		"roto-discs",
		{"dropdown", 1, 2, nil, {1, 2}},
		"direction",
		{"rotdirbuttonset", 2},
	},
}
rightclicktype["funnel"] = {
	name = "excursion funnel",
	default = tostring(funnelspeed) .. "|false|right|false",
	format = {
		"direction",
		{"dirbuttonset",3},
		"speed",
		{"slider", 1, range = {0, 10, round = 4}},
		{"checkbox", 2, "reverse"},
		{"checkbox", 4, "default off"},
		{"button", 2, {"link power  ", startrclink, {"power", "power"}}, {"x", resetrclink, {"power"}, textcolor = {255, 0, 0}}},
		{"button", 2, {"link reverse", startrclink, {"reverse", "reverse"}}, {"x", resetrclink, {"reverse"}, textcolor = {255, 0, 0}}}
	},
}
rightclicktype["funnelup"] = deepcopy(rightclicktype["funnel"])
rightclicktype["funnelup"].default = tostring(funnelspeed) .. "|false|up|false"
rightclicktype["funneldown"] = deepcopy(rightclicktype["funnel"])
rightclicktype["funneldown"].default = tostring(funnelspeed) .. "|false|down|false"
rightclicktype["funnelleft"] = deepcopy(rightclicktype["funnel"])
rightclicktype["funnelleft"].default = tostring(funnelspeed) .. "|false|left|false"
rightclicktype["funnelright"] = deepcopy(rightclicktype["funnel"])
rightclicktype["funnelright"].default = tostring(funnelspeed) .. "|false|right|false"

rightclicktype["belt"] = {
	name = "belt",
	default = "3|3",
	varfunc = function(v, i)
		if i == 1 then
			f = v -- I would have just removed all this but idk if you want to keep it or not
			if v == "right slow" then f = 3
			elseif v == "right fast" then f = 6
			elseif v == "left slow" then f = -3
			elseif v == "left fast" then f = -6
			end
			return f
		elseif i == 2 then
			return tonumber(v) or 3
		end
		return v
	end,
	format = {
		"speed",
		{"slider", 1, range = {-6, 6, round = 1}},
		"length",
		--{"input", 2, "3", 3, 2, 1, function(v) rightclickvalues2[2] = v end},
		{"slider", 2, range = {2, 50, round = 0}},
		{"button", 2, {"link power  ", startrclink, {"power", "power"}}, {"x", resetrclink, {"power"}, textcolor = {255, 0, 0}}},
		{"button", 2, {"link reverse", startrclink, {"reverse", "reverse"}}, {"x", resetrclink, {"reverse"}, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["beltswitch"] = {
	name = "beltswitch",
	default = "3|3|1",
	format = {
		"speed",
		{"slider", 1, range = {-6, 6, round = 1}},
		"length",
		{"slider", 2, range = {2, 50, round = 0}},
		"color",
		{"dropdown", 3, 3, nil, {1,2,3,4}},
	},
}
rightclicktype["animationtrigger"] = {
	name = "animation trigger",
	default = "",
	format = {
		"animation id",
		{"input", 1, "", 14, 20, 1, function(v) rightclickvalues2[1] = v end},
		{"button", 2, {"link trigger", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}rightclicktype["animationoutput"] = {
	name = "animation output",
	default = "",
	format = {
		"animation id",
		{"input", 1, "", 14, 20, 1, function(v) rightclickvalues2[1] = v end},
	}
}

rightclicktype["collectable"] = {
	name = "collectable",
	default = "1",
	format = {
		"collectable type",
		{"dropdown", 1, 4, nil, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}},
		{"button", 2, {"link collect", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	},
}

rightclicktype["collectablelock"] = {
	name = "collectablelock",
	default = "1|1",
	format = {
		"collectable type",
		{"dropdown", 1, 4, nil, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}},
		"unlock amount",
		{"input", 2, "1", 3, 3, 1, function(v) rightclickvalues2[2] = v end},
	},
}

--linking buttons
rightclicktype["timer"] = {
	name = "timer",
	default = "1|true",
	format = {
		{"checkbox", 2, "visible"},
		"time",
		{"input", 1, "1", 5, 5, 1, function(v)
			if tonumber(v) then
				rightclickvalues2[1] = math.max(0,v)
			else
				rightclickvalues2[1] = 0
				rightclickobjects[3].value = "0"
				rightclickobjects[3].textoffset = 0
			end
		end},
		--{"slider", 1, range = {1, 20, round = 1}},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	},
}
rightclicktype["portal"] = {
	name = "portal", default = "left|1|false",
	format = {
		"side",
		{"dirbuttonset", 1},
		"id",
		{"dropdown", 2, 5, nil, {"1","2","3","4","5","6","7","8"}},
		{"checkbox", 3, "default on"},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	},
}

rightclicktype["portal1"] = rightclicktype["portal"]
rightclicktype["portal2"] = rightclicktype["portal"]

rightclicktype["faithplate"] = {
	name = "faithplate",
	default = "13.3|30|false|false",
	format = {
		"x velocity:",
		{"slider", 1, range = {-50, 50, round = 4}},
		"y velocity:",
		{"slider", 2, range = {1, 46, round = 4}},
		{"checkbox", 3, "snap"},
		{"checkbox", 4, "default off"},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["faithplateup"] = deepcopy(rightclicktype["faithplate"])
rightclicktype["faithplateup"].default = "0|40|false|false"
rightclicktype["faithplateright"] = deepcopy(rightclicktype["faithplate"])
rightclicktype["faithplateright"].default = "30|30|false|false"
rightclicktype["faithplateleft"] = deepcopy(rightclicktype["faithplate"])
rightclicktype["faithplateleft"].default = "n30|30|false|false"

rightclicktype["animatedtiletrigger"] = {
	name = "animatedtiletrigger",
	default = "false|1|1|0|0",
	regionfunc = function(w,h,x,y) --setting region vars
		rightclickvalues2[2] = w
		rightclickvalues2[3] = h
		rightclickvalues2[4] = x
		rightclickvalues2[5] = y
	end,
	format = {
		{"checkbox", 1, "visible"},
		{"button", 1, {"select tiles", startrcregion, {2, 1}}},
		{"button", 2, {"link trigger", startrclink, {"power"}}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["orgate"] = {
	name = "orgate",
	default = "true",
	format = {
		{"checkbox", 1, "visible"},
		{"button", 1, {"link power", startrclink, {"link 1", 1}}, {"x", resetrclink, {1}, textcolor = {255, 0, 0}}},
		{"button", 1, {"link power", startrclink, {"link 2", 2}}, {"x", resetrclink, {2}, textcolor = {255, 0, 0}}},
		{"button", 1, {"link power", startrclink, {"link 3", 3}}, {"x", resetrclink, {3}, textcolor = {255, 0, 0}}},
		{"button", 1, {"link power", startrclink, {"link 4", 4}}, {"x", resetrclink, {4}, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["andgate"] = {
	name = "andgate",
	default = "true",
	format = {
		{"checkbox", 1, "visible"},
		{"button", 1, {"link power", startrclink, {"link 1", 1}}, {"x", resetrclink, {1}, textcolor = {255, 0, 0}}},
		{"button", 1, {"link power", startrclink, {"link 2", 2}}, {"x", resetrclink, {2}, textcolor = {255, 0, 0}}},
		{"button", 1, {"link power", startrclink, {"link 3", 3}}, {"x", resetrclink, {3}, textcolor = {255, 0, 0}}},
		{"button", 1, {"link power", startrclink, {"link 4", 4}}, {"x", resetrclink, {4}, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["rsflipflop"] = {
	name = "rsflipflop",
	default = "true",
	format = {
		{"checkbox", 1, "visible"},
		{"button", 1, {"link set  ", startrclink, {"set", "set"}}, {"x", resetrclink, {"set"}, textcolor = {255, 0, 0}}},
		{"button", 2, {"link reset", startrclink, {"reset", "reset"}}, {"x", resetrclink, {"reset"}, textcolor = {255, 0, 0}}}
	}
}

rightclicktype["geltop"] = {
	name = "gel",
	default = "1|true|false|false|false",
	objfunc = function()
		rightclickobjects[2].displayentries = rightclicktype["geltop"].tdisplay
	end,
	format = {
		"gel type",
		{"dropdown", 1, 6, nil, {"1", "2", "3", "4", "5"}},
		{"checkbox", 2, "top"},
		{"checkbox", 3, "left"},
		{"checkbox", 4, "bottom"},
		{"checkbox", 5, "right"},
	},
	tdisplay = {"blue","orange","white","purple","cleanse"},
}
--rightclicktype["geltop"] = {"gelid", 1, 2, 3, 4}
rightclicktype["gelleft"] = deepcopy(rightclicktype["geltop"])
rightclicktype["gelleft"].default = "1|false|true|false|false"
rightclicktype["gelbottom"] = deepcopy(rightclicktype["geltop"])
rightclicktype["gelbottom"].default = "1|false|false|true|false"
rightclicktype["gelright"] = deepcopy(rightclicktype["geltop"])
rightclicktype["gelright"].default = "1|false|false|false|true"

rightclicktype["boxtube"] = {
	name = "boxtube",
	default = "false|true|cube",
	varfunc = function(v, i)
		if i == 3 then
			local f = 1
			local t = rightclicktype["boxtube"].maketable()
			for i = 1, #t do
				if v == t[i] then
					f = i
					break
				end
			end
			return f
		end
		return v
	end,
	maketable = function()
		local list = {"cube","companion cube","edgeless cube"}
		local listnames = shallowcopy(list)
		for j, w in pairs(customenemies) do
			if w and enemiesdata[w] and enemiesdata[w].hidden then
				--hidden!
			else
				table.insert(list, w)
				table.insert(listnames, "_ENEMY" .. w)
			end
		end
		return list, listnames
	end,
	objfunc = function()
		rightclicktype["boxtube"].t, rightclicktype["boxtube"].tnames = rightclicktype["boxtube"].maketable()
		rightclickobjects[8].entries = rightclicktype["boxtube"].t
		rightclickobjects[8].displayentries = rightclicktype["boxtube"].tnames
		rightclickobjects[8]:updatePos()
	end,
	savefunc = function()
		if tonumber(rightclickvalues2[3]) then
			local t = rightclicktype["boxtube"].maketable()
			rightclickvalues2[3] = t[rightclickvalues2[3]]
		end
	end,
	format = {
		"on load:",
		{"checkbox", 1, "drop box"},
		"",
		{"checkbox", 2, "respawn obj"},
		"if destroyed",
		"",
		"object:",
		{"dropdown", 3, 13, function(v) rightclickobjects[8].var = v; rightclickvalues2[3] = rightclicktype["boxtube"].t[v] end, {}}, --"dropdown", var, width (in chars), func, {entries}
		{"button", 2, {"link trigger", startrclink},{"x", resetrclink, textcolor = {255, 0, 0}}}
	},
	t = {}
}
rightclicktype["button"] = {
	name = "button",
	default = "down",
	format = {
		"direction",
		{"dirbuttonset", 1},
	},
}
rightclicktype["buttonbox"] = deepcopy(rightclicktype["button"])
rightclicktype["buttonedgeless"] = deepcopy(rightclicktype["button"])

rightclicktype["pushbuttonleft"] = {
	name = "button",
	default = "left|down",
	format = {
		"direction",
		{"hordirbuttonset", 1},
		"base",
		{"dirbuttonset", 2}
	},
}
rightclicktype["pushbuttonright"] = deepcopy(rightclicktype["pushbuttonleft"])
rightclicktype["pushbuttonright"].default = "right|down"

rightclicktype["doorver"] = {
	name = "doorver",
	default = "true|ver|false",
	format = {
		"direction",
		{"orientationbuttonset",2},
		{"checkbox", 3, "start open"},
		{"checkbox", 1, "force close"},
		{"button", 2, {"link open ", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}},
	}
}
rightclicktype["doorhor"] = deepcopy(rightclicktype["doorver"])
rightclicktype["doorhor"].default = "true|hor|false"
rightclicktype["emancever"] = {
	name = "emancever",
	default = "ver|false",
	format = {
		"direction",
		{"orientationbuttonset",1},
		{"checkbox", 2, "default off"},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["emancehor"] = deepcopy(rightclicktype["emancever"])
rightclicktype["emancehor"].default = "hor|false"
rightclicktype["laserfield"] = {
	name = "laserfield",
	default = "ver|false",
	format = {
		"direction",
		{"orientationbuttonset",1},
		{"checkbox", 2, "default off"},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["laser"] = {
	name = "laser",
	default = "right|false",
	format = {
		"direction",
		{"dirbuttonset",1},
		{"checkbox", 2, "default off"},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["laserright"] = deepcopy(rightclicktype["laser"])
rightclicktype["laserdown"] = deepcopy(rightclicktype["laser"])
rightclicktype["laserdown"].default = "down|false"
rightclicktype["laserleft"] = deepcopy(rightclicktype["laser"])
rightclicktype["laserleft"].default = "left|false"
rightclicktype["laserup"] = deepcopy(rightclicktype["laser"])
rightclicktype["laserup"].default = "up|false"
rightclicktype["laserdetectorright"] = {
	name = "laser detector",
	default = "right|true|false",
	format = {
		"direction",
		{"dirbuttonset",1},
		"detects:",
		{"checkbox", 2, "laser"},
		{"checkbox", 3, "lightbridge"},
	}
}
rightclicktype["laserdetectordown"] = deepcopy(rightclicktype["laserdetectorright"])
rightclicktype["laserdetectordown"].default = "down|true|false"
rightclicktype["laserdetectorleft"] = deepcopy(rightclicktype["laserdetectorright"])
rightclicktype["laserdetectorleft"].default = "left|true|false"
rightclicktype["laserdetectorup"] = deepcopy(rightclicktype["laserdetectorright"])
rightclicktype["laserdetectorup"].default = "up|true|false"
rightclicktype["lightbridge"] = {
	name = "lightbridge",
	default = "right|false",
	format = {
		"direction",
		{"dirbuttonset",1},
		{"checkbox", 2, "default off"},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["lightbridgeright"] = deepcopy(rightclicktype["lightbridge"])
rightclicktype["lightbridgeleft"] = deepcopy(rightclicktype["lightbridge"])
rightclicktype["lightbridgeleft"].default = "down|false"
rightclicktype["lightbridgedown"] = deepcopy(rightclicktype["lightbridge"])
rightclicktype["lightbridgedown"].default = "left|false"
rightclicktype["lightbridgeup"] = deepcopy(rightclicktype["lightbridge"])
rightclicktype["lightbridgeup"].default = "up|false"
rightclicktype["notgate"] = {
	name = "notgate",
	default = "true",
	format = {
		{"checkbox", 1, "visible"},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}
rightclicktype["wallindicator"] = {name = "wallindicator", default = nil, varfunc = function(v) end,
	format = {{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}}}
rightclicktype["groundlight"] = {name = "groundlight", default = nil, varfunc = function(v) end,
	format = {{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}}}
rightclicktype["groundlightver"] = rightclicktype["groundlight"]
rightclicktype["groundlighthor"] = rightclicktype["groundlight"]
rightclicktype["groundlightupright"] = rightclicktype["groundlight"]
rightclicktype["groundlightrightdown"] = rightclicktype["groundlight"]
rightclicktype["groundlightdownleft"] = rightclicktype["groundlight"]
rightclicktype["groundlightleftup"] = rightclicktype["groundlight"]
rightclicktype["link"] = {name = "link", default = nil, varfunc = function(v) end,
	format = {{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}}}
rightclicktype["randomizer"] = {
	name = "randomizer",
	default = "1|true",
	format = {
		{"checkbox", 2, "visible"},
		"method",
		{"dropdown", 1, 11, nil, {1, 2, 3}, {"one output", "any output", "many outputs"}},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	},
}
rightclicktype["rocketturret"] = {name = "rocketturret", default = nil, varfunc = function(v) end,
	format = {{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}}}
rightclicktype["checkpoint"] = {name = "checkpoint", default = nil, varfunc = function(v) end,
	format = {{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}}}
rightclicktype["geldispenser"] = {
	name = "geldispenser",
	default = "down|1|false",
	objfunc = function()
		rightclickobjects[7].displayentries = rightclicktype["geldispenser"].tdisplay
	end,
	format = {
		"direction",
		{"dirbuttonset", 1},
		"type",
		{"dropdown", 2, 6, nil, {"1", "2", "3", "4", "5"}},
		{"checkbox", 3, "default off"},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	},
	tdisplay = {"blue","orange","white","purple","cleanse"},
}
rightclicktype["bluegeldown"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["bluegelright"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["bluegelleft"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["bluegeldown"].default = "down|1|false"
rightclicktype["bluegelright"].default = "right|1|false"
rightclicktype["bluegelleft"].default = "left|1|false"
rightclicktype["orangegeldown"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["orangegelright"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["orangegelleft"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["orangegeldown"].default = "down|2|false"
rightclicktype["orangegelright"].default = "right|2|false"
rightclicktype["orangegelleft"].default = "left|2|false"
rightclicktype["whitegeldown"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["whitegelright"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["whitegelleft"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["whitegeldown"].default = "down|3|false"
rightclicktype["whitegelright"].default = "right|3|false"
rightclicktype["whitegelleft"].default = "left|3|false"
rightclicktype["purplegeldown"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["purplegelright"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["purplegelleft"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["purplegeldown"].default = "down|4|false"
rightclicktype["purplegelright"].default = "right|4|false"
rightclicktype["purplegelleft"].default = "left|4|false"
rightclicktype["watergeldown"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["watergelright"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["watergelleft"] = deepcopy(rightclicktype["geldispenser"])
rightclicktype["watergeldown"].default = "down|5|false"
rightclicktype["watergelright"].default = "right|5|false"
rightclicktype["watergelleft"].default = "left|5|false"

rightclicktype["iciclebig"] = {
	name = "big icicle",
	default = "9|true",
	format = {
		"speed:",
		{"slider", 1, range = {9, 15, round = 1}},
		{"checkbox", 2, "falls"},
	}
}

rightclicktype["risingwater"] = {
	--region, type, fill, fill speed, on top, link power, link reverse
	name = "risingwater",
	default = "1|1|0|0|water|1|3|false|.5|false",
	regionfunc = function(w,h,x,y) --setting region vars
		rightclickvalues2[1] = w
		rightclickvalues2[2] = h
		rightclickvalues2[3] = x
		rightclickvalues2[4] = y
	end,
	format = {
		{"button", 1, {"  set area  ", function(var, step) startrcregion(var, step) end, {1, 2}}},
		"type:",
		{"dropdown", 5, 11, nil, {"clear water", "water", "poison", "poison water", "lava", "quicksand"}},
		"fill:",
		{"slider", 6, range = {0, 1, round = 5}},
		"fill speed:",
		{"slider", 7, range = {0, 10, round = 3}},
		{"checkbox", 8, "oscillate"},
		"wait time:",
		{"slider", 9, range = {0, 10, round = 2}},
		{"checkbox", 10, "on top"},
		{"button", 2, {"link power  ", startrclink, {"power", "power"}}, {"x", resetrclink, {"power"}, textcolor = {255, 0, 0}}},
		{"button", 2, {"link reverse", startrclink, {"reverse", "reverse"}}, {"x", resetrclink, {"reverse"}, textcolor = {255, 0, 0}}}
	},
}

rightclicktype["redseesaw"] = {
	name = "red seesaw",
	default = "5",
	format = {
		"width:",
		{"slider", 1, range = {3, 15, round = 0}},
	}
}

rightclicktype["snakeblock"] = {
	name = "snakeblock",
	default = "|3|2|false|false",
	pathfunc = function(s)
		rightclickvalues2[1] = s
	end,
	format = {
		{"button", 1, {"  set path  ", function(var) startrcpath(var) end, {1}}, {"x", function() rightclickvalues2[1] = "" end, {}, textcolor = {255, 0, 0}}},
		"length",
		{"slider", 2, range = {3, 20, round = 0}},
		"speed",
		{"slider", 3, range = {0, 6, round = 2}},
		{"checkbox", 4, "loop"},
		{"checkbox", 5, "respawn"},
		{"button", 6, {"link power  ", startrclink, {"power", "power"}}, {"x", resetrclink, {"power"}, textcolor = {255, 0, 0}}},
	}
}

rightclicktype["boomboom"] = {
	name = "boomboom",
	default = "boss|false",
	format = {
		"type",
		{"dropdown", 1, 5, nil, {"enemy", "key", "boss"}},
		{"checkbox", 2, "flying"},
	},
}

rightclicktype["koopaling"] = {
	name = "koopaling",
	default = "1|boss",
	objfunc = function()
		rightclickobjects[2].displayentries = {"larry", "morton", "wendy", "iggy", "roy", "lemmy", "ludwig"}
	end,
	format = {
		"koopaling:",
		{"dropdown", 1, 6, nil, {"1","2","3","4","5","6","7"}},
		"type",
		{"dropdown", 2, 5, nil, {"enemy", "key", "boss"}},
	},
}

rightclicktype["bowser3"] = {
	name = "bowser3",
	default = "boss",
	format = {
		"type",
		{"dropdown", 1, 5, nil, {"enemy", "key", "boss"}},
	},
}
rightclicktype["bowserjr"] = {
	name = "bowserjr",
	default = "boss",
	format = {
		"type",
		{"dropdown", 1, 5, nil, {"enemy", "key", "boss"}},
	},
}

rightclicktype["glados"] = {
	name = "glados",
	default = "150",
	format = {
		"neurotoxin time",
		{"slider", 1, range = {100, 500, round = 1}},
	},
}

rightclicktype["skewer"] = {
	name = "skewer",
	default = "down",
	format = {
		"direction",
		{"dirbuttonset", 1},
		{"button", 2, {"link trigger", startrclink, {"trigger", "trigger"}}, {"x", resetrclink, {"trigger"}, textcolor = {255, 0, 0}}},
	},
}

rightclicktype["thwomp"] = {
	name = "thwomp",
	default = "false",
	format = {
		{"checkbox", 1, "return to spawn"},
	},
}
rightclicktype["thwomphalf"] = deepcopy(rightclicktype["thwomp"])
rightclicktype["thwompleft"] = deepcopy(rightclicktype["thwomp"])
rightclicktype["thwompright"] = deepcopy(rightclicktype["thwomp"])

rightclicktype["upfire"] = {
	name = "upfire",
	default = "true",
	format = {
		{"checkbox", 1, "return to spawn"},
	},
}

rightclicktype["bigcloud"] = {
	name = "bigcloud",
	default = "false",
	format = {
		{"checkbox", 1, "infinite"},
	},
}

rightclicktype["longfire"] = {
	name = "longfire",
	default = "left|false",
	format = {
		"direction",
		{"dirbuttonset", 1},
		{"checkbox", 2, "default on"},
	},
}
rightclicktype["longfireoff"] = deepcopy(rightclicktype["longfire"])
rightclicktype["longfireoff"].default = "left|true"

rightclicktype["energylauncherright"] = {
	name = "energylauncher",
	default = "right|false|false|false",
	format = {
		"direction",
		{"dirbuttonset", 1},
		{"checkbox", 2, "offset"},
		{"checkbox", 4, "green"},
		{"checkbox", 3, "default off"},
		{"button", 2, {"link power", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}},
	},
}
rightclicktype["energylauncherleft"] = deepcopy(rightclicktype["energylauncherright"])
rightclicktype["energylauncherleft"].default = "left|false"
rightclicktype["energylauncherup"] = deepcopy(rightclicktype["energylauncherright"])
rightclicktype["energylauncherup"].default = "up|false"
rightclicktype["energylauncherdown"] = deepcopy(rightclicktype["energylauncherright"])
rightclicktype["energylauncherdown"].default = "down|false"
rightclicktype["energycatcherright"] = {
	name = "energycatcher",
	default = "right|false",
	format = {
		"direction",
		{"dirbuttonset", 1},
		{"checkbox", 2, "offset"},
	},
}
rightclicktype["energycatcherleft"] = deepcopy(rightclicktype["energycatcherright"])
rightclicktype["energycatcherleft"].default = "left|false"
rightclicktype["energycatcherup"] = deepcopy(rightclicktype["energycatcherright"])
rightclicktype["energycatcherup"].default = "up|false"
rightclicktype["energycatcherdown"] = deepcopy(rightclicktype["energycatcherright"])
rightclicktype["energycatcherdown"].default = "down|false"

rightclicktype["turretleft"] = {
	name = "turret",
	default = "left|turret|true",
	format = {
		"direction",
		{"hordirbuttonset", 1},
		"type",
		{"dropdown", 2, 8, nil, {"turret", "defective"}},
		{"checkbox", 3, "knockback"},
	},
}
rightclicktype["turretright"] = deepcopy(rightclicktype["turretleft"])
rightclicktype["turretright"].default = "right|turret"
rightclicktype["turret2left"] = deepcopy(rightclicktype["turretleft"])
rightclicktype["turretright"].default = "left|defective"
rightclicktype["turret2right"] = deepcopy(rightclicktype["turretleft"])
rightclicktype["turretright"].default = "right|defective"

rightclicktype["camerastop"] = {
	name = "camerastop",
	default = "1|1|0|0|false|false",
	regionfunc = function(w,h,x,y) --setting region vars
		rightclickvalues2[1] = w
		rightclickvalues2[2] = h
		rightclickvalues2[3] = x
		rightclickvalues2[4] = y
	end,
	format = {
		{"button", 1, {"select range", function(var, step) startrcregion(var, step) end, {1, 2}}},
		{"checkbox", 5, "force push"},
		{"checkbox", 6, "ignore if"},
		"off-screen",
		{"button", 2, {"link off", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}}
	}
}

rightclicktype["clearpipe"] = {
	name = "clear pipe",
	default = "|false",
	pathfunc = function(s)
		rightclickvalues2[1] = s
	end,
	format = {
		{"button", 1, {"  set path  ", function(var) startrcpath(var) end, {{1, default={0,0}, pipe=true}}},
		{"x", function() rightclickvalues2[1] = "" end, {}, textcolor = {255, 0, 0}}},
		{"checkbox", 2, "intersection"},
	}
}
rightclicktype["pneumatictube"] = {
	name = "pneumatic tube",
	default = "|false|true",
	pathfunc = function(s)
		rightclickvalues2[1] = s
	end,
	format = {
		{"button", 1, {"  set path  ", function(var) startrcpath(var) end, {{1, default={0,0}, pipe=true}}},
		{"x", function() rightclickvalues2[1] = "" end, {}, textcolor = {255, 0, 0}}},
		{"checkbox", 2, "intersection"},
		{"checkbox", 3, "suck"},
	}
}

rightclicktype["plantcreeper"] = {
	name = "pirannha creeper",
	default = "|false",
	pathfunc = function(s)
		rightclickvalues2[1] = s
	end,
	format = {
		{"button", 1, {"  set path  ", function(var) startrcpath(var) end, {{1, default={0,0}, pipe=true}}},
		{"x", function() rightclickvalues2[1] = "" end, {}, textcolor = {255, 0, 0}}},
		{"checkbox", 2, "sleeping"},
	}
}

rightclicktype["track"] = {
	name = "track",
	default = "0:0:c:c:d|true",
	trackfunc = function(s)
		rightclickvalues2[1] = s
	end,
	format = {
		{"button", 1, {"lay tracks", function(var) allowdrag = false; startrctrack(var, m) end, {{1}}},
		{"x", function() rightclickvalues2[1] = "0:0:c:c:d" end, {}, textcolor = {255, 0, 0}}},
		{"checkbox", 2, "visible"},
		{"button", 2, {"link stop ", startrclink}, {"x", resetrclink, textcolor = {255, 0, 0}}},
	}
}

rightclicktype["trackswitch"] = {
	name = "track switch",
	default = "0:0:c:c:d|0:0:c:c:d|true|1",
	trackfunc = function(s, var)
		rightclickvalues2[var] = s
	end,
	format = {
		{"button", 1, {"lay tracks #1", function(var) allowdrag = false; startrctrack(var) end, {{1}}},
		{"x", function() rightclickvalues2[1] = "0:0:c:c:d" end, {}, textcolor = {255, 0, 0}}},
		{"button", 2, {"lay tracks #2", function(var) allowdrag = false; startrctrack(var) end, {{2}}},
		{"x", function() rightclickvalues2[2] = "0:0:c:c:d" end, {}, textcolor = {255, 0, 0}}},
		{"checkbox", 3, "visible"},
		"color",
		{"dropdown", 4, 3, nil, {1,2,3,4}},
		{"button", 3, {"link switch ", startrclink, {"switch", "switch"}}, {"x", resetrclink, textcolor = {255, 0, 0}}},
		{"button", 3, {"link stop ", startrclink, {"stop", "power"}}, {"x", resetrclink, textcolor = {255, 0, 0}}},
	}
}

rightclicktype["spawn"] = {
	name = "spawn",
	default = "false",
	format = {
		{"checkbox", 1, "spawn on tile"},
	}
}

rightclicktype["windstart"] = {
	name = "windstart",
	default = tostring(windspeed),
	format = {
		"wind speed",
		{"slider", 1, range = {-4, 4, round = 2}},
	}
}

rightclicktype["donut"] = {
	name = "donut",
	default = "true",
	format = {
		{"checkbox", 1, "respawn"},
	},
}
rightclicktype["donutlast"] = deepcopy(rightclicktype["donut"])

rightclicktype["flag"] = {
	name = "flag",
	default = "true|false",
	format = {
		{"checkbox", 1, "border"},
		{"checkbox", 2, "castleflag"},
	},
}
rightclicktype["checkpointflag"] = {
	name = "checkpoint flag",
	default = "down|2",
	varfunc = function(v, i)
		if i == 2 and v then return v:gsub("n", "-") end
		return v
	end,
	objfunc = function()
		rightclickobjects[7].displayentries = powerupslist
		rightclickobjects[7].displayentries[1] = "nothing"
	end,
	savefunc = function()
		if rightclickvalues2[2] then
			rightclickvalues2[2] = rightclickvalues2[2]:gsub("-", "n")
		end
	end,
	format = {
		"base",
		{"dirbuttonset", 1},
		"powerup",
		{"dropdown", 2, 8, nil, powerupslistidsrc},
	},
}

rightclicktype["plant"] = {
	name = "plant",
	default = "up",
	format = {"direction", {"dirbuttonset", 1} },
}
rightclicktype["redplant"] = rightclicktype["plant"]
rightclicktype["dryplant"] = rightclicktype["plant"]
rightclicktype["fireplant"] = rightclicktype["plant"]
rightclicktype["downplant"] = shallowcopy(rightclicktype["plant"])
rightclicktype["downplant"].default = "down"
rightclicktype["reddownplant"] = rightclicktype["downplant"]
rightclicktype["drydownplant"] = rightclicktype["downplant"]
rightclicktype["downfireplant"] = rightclicktype["downplant"]

rightclicktype["mole"] = {
	name = "mole",
	default = "false",
	format = {
		{"checkbox", 1, "in ground"},
	},
}

rightclicktype["amp"] = {
	name = "fuzzy",
	default = "0|fuzzy",
	format = {
		"type:",
		{"dropdown", 2, 5, nil, {"fuzzy", "amp"}},
		"path:",
		{"dropdown", 1, 2, nil, {"0", "1", "2", "3", "4"}},
	},
}
rightclicktype["pbutton"] = {
	name = "pswitch",
	default = "down",
	format = {
		"base",
		{"verdirbuttonset", 1},
	},
}
rightclicktype["boocircle"] = {
	name = "boocircle",
	default = "cw|3|8|1.5|0.333",
	format = {
		"direction",
		{"rotbuttonset", 1},
		"radius",
		{"slider", 2, range = {2, 8, round = 1}},
		"boos",
		{"slider", 3, range = {2, 20, round = 0}},
		"gap",
		{"slider", 4, range = {0, 10, round = 1}},
		"speed",
		{"slider", 5, range = {0.1, 1, round = 3}},
	},
}

rightclicktype["muncher"] = {
	name = "frozen",
	default = "false",
	format = {
		{"checkbox", 1, "frozen"},
	}
}

rightclicktype["plusclock"] = {
	name = "plus clock",
	default = "100",
	format = {
		"time:",
		{"slider", 1, range = {10, 300, step = 10}},
	}
}

function entity:init(img, x, y, width, height)
	self.image = img
	self.quad = love.graphics.newQuad((x-1)*17, (y-1)*17, 16, 16, width, height)	
end

function entity:sett(i)
	for j = 1, #entitylist do
		if i == j then
			self.t = entitylist[j].t
		end
	end
end
