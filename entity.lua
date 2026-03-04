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
	{t="oneup", name="1-up", spawnable=true, block=true},
	{t="star", spawnable=true, block=true},
	{t="manycoins", name="multi-coin block", block=true},
	{t="goomba", spawnable=true, offset=9, block=true, supersize=true},
	{t="koopa", spawnable=true, offset=10, block=true, supersize=true},
	{t="spawn", name="player spawn"},
	{t="goombahalf", supersize=true},
	{t="koopahalf", supersize=true},
	{t="flag", name="flag pole"},
	{t="koopared", name="red koopa", spawnable=true, offset=13, block=true, supersize=true},
	{t="kooparedhalf", supersize=true},
	{t="vine", block=true},
	{t="hammerbro", name="hammer bro", spawnable=true, block=true},
	{t="cheepred", name="cheep cheep red", spawnable=true, supersize=true},
	{t="cheepwhite", name="cheep cheep white", spawnable=true, supersize=true},
	{t="platformup"}, --my mouse is dying :(
	{t="platformright"},
	{t="box", name="storage cube", spawnable=true},
	{t="pipe", name="pipe entrance"},
	{t="lakito", name="lakitu", spawnable=true, supersize=true},
	{t="mazestart", name="maze start"},
	{t="mazeend", name="maze end"},
	{t="mazegate", name="maze gate"},
	{t="emancehor"},
	{t="emancever", name="emancipation grill"},
	{t="doorver", name="test door"},
	{t="doorhor"},
	{t="wallindicator", name="wall indicator"},
	{t="pipespawn", name="pipe exit"},
	{t="platformfall", name="falling platform", spawnable=true},
	{t="bulletbillstart", name="bullet bill start"},
	{t="bulletbillend", name="bullet bill end"},
	{t="drain"},
	{t="lightbridgeright", name="lightbridge"},
	{t="lightbridgeleft"},
	{t="lightbridgedown"},
	{t="lightbridgeup"},
	{t="button"},
	{t="platformspawnerdown", name="platform spawner"},
	{t="platformspawnerup"},
	{t="groundlightver", name="antlines up"},
	{t="groundlighthor", name="antlines across"},
	{t="groundlightupright", name="antlines up right"},
	{t="groundlightrightdown", name="antlines down right"},
	{t="groundlightdownleft", name="antlines down left"},
	{t="groundlightleftup", name="antlines up left"},
	{t="faithplateup", name="faithplate"},
	{t="faithplateright"},
	{t="faithplateleft"},
	{t="laserright", name="laser"},
	{t="laserdown"},
	{t="laserleft"},
	{t="laserup"},
	{t="laserdetectorright", name="laser detector"},
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
	{t="plant", name="piranha plant", spawnable=true, supersize=true},
	{t="whitegeldown"},
	{t="whitegelright"},
	{t="whitegelleft"},
	{t="timer", name="wall timer"},
	{t="beetle", spawnable=true, offset=76, block=true, supersize=true},
	{t="beetlehalf", supersize=true},
	{t="kooparedflying", name="red flying koopa", spawnable=true, supersize=true},
	{t="koopaflying", name="flying koopa", spawnable=true, supersize=true},
	{t="castlefireccw", name="firebar"},
	{t="seesaw", name="seesaw platform"},
	{t="warppipe", name="world warp"},
	{t="castlefirecw"},
	{t="lakitoend", name="lakitu end"},
	{t="notgate", name="not gate"},
	{t="geltop", name="floor gel"},
	{t="gelleft"},
	{t="gelbottom"},
	{t="gelright"},
	{t="firestart"},
	{t="bowser", spawnable=true, supersize=true},
	{t="axe"},
	{t="platformbonus", name="bonus platform"},
	{t="spring"},
	{t="squid", name="blooper", spawnable=true, supersize=true},
	{t="flyingfishstart", name="flying fish start"},
	{t="flyingfishend", name="flying fish end"},
	{t="upfire", name="podoboo", spawnable=true, block=true, supersize=true},
	{t="spikey", name="spiny", spawnable=true, offset=99, block=true, supersize=true},
	{t="spikeyhalf", supersize=true},
	{t="checkpoint"},
	{t="poisonmush", name="poison mushroom", spawnable=true, block=true},
	{t="downplant", name="piranha plant", spawnable=true, supersize=true},
	{t="paragoomba", spawnable=true, block=true, supersize=true},
	{t="bigbill", name="banzai bill launcher"},
	{t="kingbill", name="king bill", spawnable=true},
	{t="sidestepper", spawnable=true, block=true, supersize=true},
	{t="barrel", spawnable=true, supersize=true},
	{t="icicle", spawnable=true},
	{t="angrysun", name="angry sun", spawnable=true},
	{t="angrysunend", name="angry sun end"},
	{t="splunkin", spawnable=true, offset=112, block=true, supersize=true},
	{t="splunkinhalf", supersize=true},
	{t="threeup", name="3-up moon", spawnable=true},
	{t="biggoomba", name="big goomba", spawnable=true, supersize=true},
	{t="bigspikey", name="big spiny", spawnable=true, supersize=true},
	{t="bigkoopa", name="big koopa", spawnable=true, supersize=true},
	{t="shell", spawnable=true, block=true, supersize=true},
	{t="goombrat", spawnable=true, offset=119, block=true, supersize=true},
	{t="goombrathalf"},
	{t="firebro", name="fire bro", spawnable=true, block=true},
	{t="plusclock", name="plus clock", spawnable=true, block=true},
	{t="springgreen", name="green spring"},
	{t="redplant", name="red piranha plant", spawnable=true, supersize=true},
	{t="reddownplant", name="red piranha plant", spawnable=true, supersize=true},
	{t="thwomp", spawnable=true, offset=224, supersize=true},
	{t="fishbone", name="fishbones", spawnable=true, supersize=true},
	{t="drybones", name="dry bones", spawnable=true, offset=128, block=true, supersize=true},
	{t="dryboneshalf", supersize=true},
	{t="muncher", spawnable=true, supersize=true, block=true},
	{t="bigbeetle", name="big beetle",spawnable=true, supersize=true},
	{t="meteorstart", name="meteor fall start"},
	{t="meteorend", name="meteor fall end"},
	{t="drygoomba", name="dry goomba", spawnable=true, offset=134, supersize=true},
	{t="drygoombahalf", supersize=true},
	{t="dryplant", name="dry piranha plant", spawnable=true, supersize=true},
	{t="drydownplant", name="dry piranha plant", spawnable=true, supersize=true},
	{t="donut", name="red donut block"},
	{t="boomerangbro", name="booomerang bro", spawnable=true, block=true},
	{t="parabeetle", spawnable=true, supersize=true},
	{t="ninji", spawnable=true, block=true, supersize=true},
	{t="hammersuit", name="hammer suit", spawnable=true, block=true},
	{t="boo", spawnable=true, supersize=true},
	{t="moleground", name="mole ground", spawnable=true, block=true},
	{t="bigmole", name="big mole", spawnable=true, supersize=true},
	{t="bomb", name="bob-omb", spawnable=true, offset=146, block=true, supersize=true},
	{t="bombhalf", supersize=true},
	{t="fireplant", name="fire piranha plant", spawnable=true, supersize=true},
	{t="flipblock", name="flip block"},
	{t="downfireplant", name="fire piranha plant", spawnable=true, supersize=true},
	{t="torpedoted", name="torpedo ted"},
	{t="frogsuit", name="forg suit", spawnable=true, block=true},
	{t="parabeetleright", name="parabeetle", spawnable=true, supersize=true},
	{t="boomboom", name="boom boom", spawnable=true, supersize=true},
	{t="levelball", name="? ball", spawnable=true, block=true},
	{t="leaf", name="raccoon leaf", spawnable=true, block=true},
	{t="koopablue", name="blue koopa", spawnable=true, offset=157, supersize=true},
	{t="koopabluehalf", supersize=true},
	{t="koopaflying2", name="flying koppa hor", spawnable=true, supersize=true},
	{t="windstart", name="wind start"},
	{t="windend", name="wind end"},
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
	{t="turretleft", name="turret"},
	{t="turretright"},
	{t="turret2left"},
	{t="turret2right"},
	{t="blocktogglebutton", name="! button"},
	{t="buttonblockon", name="on block"},
	{t="buttonblockoff", name="off block"},
	{t="purplegeldown"},
	{t="purplegelright"},
	{t="purplegelleft"},
	{t="sleepfish", name="rip van fish", spawnable=true, supersize=true},
	{t="squarewave", name="square wave"},
	{t="delayer"},
	{t="coin", spawnable=true},
	{t="amp", name="fuzzy / amp", spawnable=true, supersize=true},
	{t="parabeetlegreen", name="green parabeetle", spawnable=true, supersize=true},
	{t="parabeetlegreenright", name="green parabeetle", spawnable=true, supersize=true},
	{t="longfire", name="burner off"},
	{t="cannonball"},
	{t="minimushroom", name="mini mushroom", spawnable=true, block=true},
	{t="rocketturret", name="rocket turret"},
	{t="glados"},
	{t="pedestal", name="portal pedisatal"},
	{t="portal1", name="portal spawner"},
	{t="portal2", name="portal spawner"},
	{t="text"},
	{t="regiontrigger", name="region trigger"},
	{t="tiletool", name="tile tool"},
	{t="iceflower", name="ice flower", spawnable=true, block=true},
	{t="shyguy", name="shy guy", spawnable=true, offset=204, block=true, supersize=true},
	{t="shyguyhalf", supersize=true},
	{t="enemytool", name="enemy spawner", supersize=true},
	{t="randomizer"},
	{t="yoshi", spawnable=true, block=true, supersize=false},
	{t="bigblocktogglebutton", name="big ! button"},
	{t="beetleshell", name="beetle shell", spawnable=true, supersize=true},
	{t="musicchanger", name="music changer"},
	{t="pbutton", name="p switch", spawnable=true, block=true},
	{t="spiketop", name="spike top", spawnable=true, offset=213, supersize=true},
	{t="spiketophalf", supersize=true},
	{t="pokey", spawnable=true, supersize=true},
	{t="snowpokey", name="snow pokey", spawnable=true, supersize=true},
	{t="fighterfly", spawnable=true, block=true, supersize=true},
	{t="swimwing", name="swim wing", spawnable=true, block=true},
	{t="dkhammer", name="dk hammer", spawnable=true, block=true},
	{t="vinestop", name="vine stop"},
	{t="chainchomp", name="chain chomp", spawnable=true, supersize=false},
	{t="bighammerbro", name="big hammerbro",spawnable=true},
	{t="edgelessbox", name="edgeless cube", spawnable=true},
	{t="rockywrench", name="rocky wrench", spawnable=true, supersize=false},
	{t="thwomphalf", supersize=true},
	{t="watergeldown"},
	{t="watergelright"},
	{t="watergelleft"},
	{t="rotodisc", name="roto-disc"},
	{t="funneldown"},
	{t="funnelup"},
	{t="funnelright", name="funnel"},
	{t="funnelleft"},
	{t="pipespawndown"},
	{t="thwimp", spawnable=true},
	{t="drybeetle", name="dry beetle", spawnable=true, offset=236, block=true, supersize=true},
	{t="drybeetlehalf", supersize=true},
	{t="tinygoomba", name="tiny goomba", spawnable=true, block=true},
	{t="koopaling", spawnable=true, supersize=true},
	{t="bigmushroom", spawnable=true, name="mega mushroom", block=true},
	{t="bowser3", name="smb3 bowser", spawnable=true, supersize=true},
	{t="icebro", name="ice bro", spawnable=true, block=true},
	{t="squidnanny", name="blooper nanny", spawnable=true, supersize=true},
	{t="goombashoe", name="shoe goomba", spawnable=true, supersize=false},
	{t="wiggler", spawnable=true, supersize=true}, --wiggler wednesday
	{t="magikoopa", spawnable=true, block=true, supersize=true},
	{t="homingbullet", name="homing bullet bill"},
	{t="boocircle", name="boo circle", spawnable=true, supersize=true},
	{t="pdoor", name="p door"},
	{t="keydoor", name="key door"},
	{t="key", spawnable=true, block=true},
	{t="wigglerangry", name="angry wiggler", spawnable=true, supersize=true},
	{t="tanookisuit", name="tanooki suit", spawnable=true, block=true},
	{t="feather", name="cape feather", spawnable=true, block=true},
	{t="carrot", spawnable=true, block=true},
	{t="weirdmushroom", name="weird mushroom", spawnable=true, block=true},
	{t="pipespawnhor"},
	{t="ceilblocker", name="ceiling blocker"},
	{t="donutlast", name="donut"},
	{t="skewer"},
	{t="boocrawler", name="boo crawler", spawnable=true, supersize=true},
	{t="downspikey", name="upside-down spiny", spawnable=true, supersize=true},
	{t="downbeetle", name="upside-down beetle", spawnable=true, supersize=true},
	{t="spikeyshell", name="spiny shell", spawnable=true, block=true, supersize=true},
	{t="bigcloud", name="big cloud", spawnable=true, block=true},
	{t="longfireoff", name="burner on"},
	{t="belt", name="conveyor belt"},
	{t="buttonbox", name="cube button"},
	{t="buttonedgeless", name="edgeless button"},
	{t="luckystar", spawnable=true, block=true},
	{t="animationtrigger", name="animation trigger"},
	{t="animatedtiletrigger", name="animated tile trigger"},
	{t="rsflipflop", name="rs flip-flop gate"},
	{t="orgate", name="or gate"},
	{t="andgate", name="and gate"},
	{t="actionblock", name="action block"},
	{t="collectable"},
	{t="collectablelock", name="collectable lock"},
	{t="powblock", name="pow block", spawnable=true, block=true},
	{t="switchblock", name="switch block"},
	{t="iciclebig", name="big icicle", spawnable=true},
	{t="verspring", name="spring ver", spawnable=true, block=true},
	{t="horspring", name="spring hor", spawnable=true, block=true},
	{t="thwompleft", name="thwomp left", spawnable=true, supersize=true},
	{t="thwompright", name="thwomp right", spawnable=true, supersize=true},
	{t="risingwater", name="rising water"},
	{t="superballflower", name="superball flower", spawnable=true, block=true},
	{t="beltswitch", name="switch conveyor belt"},
	{t="drybonesshell", name="dry bones shell", spawnable=true, block=true, supersize=true},
	{t="redseesaw", name="red seesaw"},
	{t="snakeblock", name="snake block"},
	{t="animationoutput", name="animation output"},
	{t="pbuttonblockon", name="p block on"},
	{t="pbuttonblockoff", name="p block off"},
	{t="spike", spawnable=true, block=true, supersize=true},
	{t="spikeball", name="spike ball", spawnable=true, block=true, supersize=true},
	{t="frozencoin", name="frozen coin", spawnable=true},
	{t="powerup", block=true},
	{t="cheepcheep", supersize=true},
	{t="fireflower", name="fire flower", spawnable=true, block=true},
	{t="propellerbox", name="propeller box"},
	{t="cannonbox"}, name="cannonball box",
	{t="clearpipe", name="clear pipe"},
	{t="cannonballcannon", name="cannonball cannon", spawnable=true, block=true, supersize=true},
	{t="camerastop", name="camera stop"},
	{t="plantcreeper", name="piranha creeper"},
	{t="track"},
	{t="blueshell", spawnable=true, block=true},
	{t="boomerangflower", name="boomerang flower", spawnable=true, block=true}, --hehe, boomerr
	{t="platform"},
	{t="pneumatictube", name="pneumatic tube"},
	{t="bigclassicmushroom", name="classic big mushroom", spawnable=true, block=true},
	{t="checkpointflag", name="checkpoint flag"},
	{t="supersize", argument="b", argumentname="supersize"},
	{t="mole", name="mole", spawnable=true, block=true, supersize=true},
	{t="grinder", name="grinder / bumper"},
	{t="bowserjr", name="bowser jr", spawnable=true, supersize=true},
	{t="trackswitch", name="switch track"},
}

--only spawnable with spawner or by enemies
hiddenentitylist = {
	{t="spikeyfall", name="spiny egg"},
	{t="bulletbillsingle", name="bullet bill"},
	{t="bigbillsingle", name="banzai bill"},
	{t="cannonballsingle", name="cannonball"},
	{t="hammer"},
	{t="bowserfire", name="bowser fire"},
	{t="flyingfish", name="flying fish"},
	{t="meteor"},
	{t="brofireball", name = "fireball"},
	{t="broiceball", name = "iceball"},
	{t="broboomerang", name = "boomerang"},
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
	"removes entities from the level", --"remove",
	"grows player to big, becomes a fire flower if player is big", --"mushroom",
	"gives player an extra life", --"oneup",
	"makes player invicible for a short amount of time", --"star",
	"gives coins, can be hit several times", --"manycoins",
	"walks back and forth, stomp to defeat", --"goomba",
	"walks back and forth, stomp to kick around and break blocks", --"koopa",
	"starting point", --"spawn",
	"walks back and forth, stomp to defeat", --"goombahalf",
	"walks back and forth, stomp to kick around and break blocks", --"koopahalf",
	"end of the level, plays animation", --"flag",
	"walks back and forth but not off cliffs, stomp to kick around and break blocks", --"koopared",
	"walks back and forth but not off cliffs, stomp to kick around and break blocks", --"kooparedhalf",
	"grows and can be climbed, travel between sublevels or stop it with vinestop", --"vine",
	"walks around, jumps up and down and throws hammers", --"hammerbro",
	"moves left while oscillating up and down", --"cheepred",
	"moves left while oscillating up and down, slower", --"cheepwhite",
	"moves between two points", --"platformup", --my mouse is dying :(
	"moves between two points", --"platformright",
	"can be picked up and dropped, activates buttons", --"box",
	"enter to travel between sublevels", --"pipe",
	"hovers above and throws down spinys", --"lakito",
	"start of a maze, loops until all gates reached", --"mazestart",
	"end of a maze, loops until all gates reached", --"mazeend",
	"gate for the maze, must be touched to end the maze", --"mazegate",
	"stops portals and destroys enemies and cubes", --"emancehor",
	"stops portals and destroys enemies and cubes", --"emancever",
	"blocks player and portals until openned", --"doorver",
	"blocks player and portals until openned", --"doorhor",
	"shows an on/off state when triggered", --"wallindicator",
	"exit from another pipe", --"pipespawn",
	"falls when stood on", --"platformfall",
	"stats shooting bullet bills from the right side", --"bulletbillstart",
	"stops shooting bullet bills from the right side", --"bulletbillend",
	"attracts mario down while underwater", --"drain",
	"platform to carry player, can be redirected with portals", --"lightbridgeright",
	"platform to carry player, can be redirected with portals", --"lightbridgeleft",
	"platform to carry player, can be redirected with portals", --"lightbridgedown",
	"platform to carry player, can be redirected with portals", --"lightbridgeup",
	"can be activated by the player or cubes", --"button",
	"spawns platforms from the top or bottom of the screen", --"platformspawnerdown",
	"spawns platforms from the top or bottom of the screen", --"platformspawnerup",
	"shows an on/off state when triggered", --"groundlightver",
	"shows an on/off state when triggered", --"groundlighthor",
	"shows an on/off state when triggered", --"groundlightupright",
	"shows an on/off state when triggered", --"groundlightrightdown",
	"shows an on/off state when triggered", --"groundlightdownleft",
	"shows an on/off state when triggered", --"groundlightleftup",
	"lanches players and objects", --"faithplateup",
	"lanches players and objects", --"faithplateright",
	"lanches players and objects", --"faithplateleft",
	"kills players, can be redirected through portals and activate laser recievers", --"laserright",
	"kills players, can be redirected through portals and activate laser recievers", --"laserdown",
	"kills players, can be redirected through portals and activate laser recievers", --"laserleft",
	"kills players, can be redirected through portals and activate laser recievers", --"laserup",
	"recieves lasers (or light bridges) and activates a signal", --"laserdetectorright",
	"recieves lasers (or light bridges) and activates a signal", --"laserdetectordown",
	"recieves lasers (or light bridges) and activates a signal", --"laserdetectorleft",
	"recieves lasers (or light bridges) and activates a signal", --"laserdetectorup",
	"will make a tile launch bullet bills", --"bulletbill",
	"drops gel blobs that cover tiles and light bridges", --"bluegeldown",
	"drops gel blobs that cover tiles and light bridges", --"bluegelright",
	"drops gel blobs that cover tiles and light bridges", --"bluegelleft",
	"drops gel blobs that cover tiles and light bridges", --"orangegeldown",
	"drops gel blobs that cover tiles and light bridges", --"orangegelright",
	"drops gel blobs that cover tiles and light bridges", --"orangegelleft",
	"drops cubes or enemies.", --"boxtube",
	"can be activated by players to trigger signals", --"pushbuttonleft",
	"can be activated by players to trigger signals", --"pushbuttonright",
	"goes in and out of pipes", --"plant",
	"drops gel blobs that cover tiles and light bridges", --"whitegeldown",
	"drops gel blobs that cover tiles and light bridges", --"whitegelright",
	"drops gel blobs that cover tiles and light bridges", --"whitegelleft",
	"sends a signal for an amount of time, shows ingame", --"timer",
	"walks back and forth, stomp to kick around and break blocks, immune to fireballs", --"beetle",
	"walks back and forth, stomp to kick around and break blocks, immune to fireballs", --"beetlehalf",
	"flies up and down, loses wings when stomped", --"kooparedflying",
	"moves left and right, jumps around, loses wings when stomped", --"koopaflying",
	"rotates around a block, hurts players", --"castlefireccw",
	"when one platform goes down the other goes up, breaks when overextended", --"seesaw",
	"enter to travel between levels/worlds", --"warppipe",
	"rotates around a block, hurts players", --"castlefirecw",
	"makes lakitu leave when passed", --"lakitoend",
	"inverts a signal", --notgate
	"adds gel to the block",
	"adds gel to the block",
	"adds gel to the block",
	"adds gel to the block",
	"starts shooting fire from across the screen, shoots from bowser if he exists", --"firestart",
	"a boss that guards the axe", --"bowser",
	"end of the level, breaks the bridge to drop bowser, saves toad or peach", --"axe",
	"moves right when stood on", --"platformbonus",
	"launches player upwards", --"spring",
	"moves down then up and right", --"squid",
	"starts shooting flying fish up from the bottom of the screen", --"flyingfishstart",
	"stops shooting flying fish up from the bottom of the screen", --"flyingfishend",
	"shoots up and falls down", --"upfire",
	"hurts player when jumped on", --"spikey",
	"hurts player when jumped on", --"spikeyhalf",
	"player will spawn back here after dying once they activate it", --"checkpoint",
	"hurts player when touched", --"poisonmush",
	"goes in and out of pipes, comes from pipe above", --"downplant",
	"jumps around, loses wings when stomped", --"paragoomba",
	"will make a tile launch banzaibills", --"bigbill",
	"launches king bills from the side of the screen", --"kingbill",
	"walks back and forth, cannot be stomped, killed with 2 fireballs", --"sidestepper",
	"moves back and forth, cannot be stomped, faster", --"barrel",
	"falls when player passes under", --"icicle",
	"flies across the screen", --"angrysun",
	"makes the angry sun leave when passed", --"angrysunend",
	"walks back and forth, can be stomped twice, faster when angry", --"splunkin",
	"walks back and forth, can be stomped twice, faster when angry", --"splunkinhalf",
	"gives player 3 lives when touched", --"threeup",
	"walks back and forth, bigger", --"biggoomba",
	"walks back and forth, cannot be stomped, bigger", --"bigspikey",
	"walks back and forth, stomp to kick around and break blocks and hard blocks, bigger", --"bigkoopa",
	"stomp to kick around and break blocks", --"shell",
	"walks back and forth and turns around on cliffs", --"goombrat",
	"walks back and forth and turns around on cliffs", --"goombrathalf",
	"walks around, jumps up and down and throws fireballs", --"firebro"
	"gives time when touched", --"plusclock"
	"launches player upwards very fast and far", --"springgreen"
	"goes in and out of pipes, faster", --"redplant",
	"goes in and out of pipes, faster, comes from pipe above", --"reddownplant",
	"falls when player passes under it", --"thwomp",
	"moves forwards, attacks player when near them, resists fireballs", --"fishbone",
	"resists fireballs, collapses when stomped", --"drybones",
	"resists fireballs, collapses when stomped", --"dryboneshalf",
	"hurts player", --"muncher",
	"walks back and forth, kick around and break blocks, immune to fireballs, bigger", --"bigbeetle",
	"starts dropping meteors from the sky", --"meteorstart",
	"stops dropping meteors from the sky", --"meteorend",
	"moves back and forth, immune to fireballs", --"drygoomba",
	"moves back and forth, immune to fireballs", --"drygoombahalf",
	"goes in and out of pipes, immune to fireballs", --"dryplant",
	"goes in and out of pipes, immune to fireballs, comes from pipe above", --"drydownplant",
	"shakes and falls when stood on", --"donut",
	"walks around, jumps up and down and throws boomerang", --"boomerangbro",
	"flies accros the screen and moves up when player is riding them", --"parabeetle",
	"jumps up and down", --"ninji",
	"gives the player the hammer suit, fires hammers", --"hammersuit",
	"moves towards the player when not looked at", --"boo",
	"jumps out the ground and chases the player", --"moleground",
	"walks back and forth, can be ridden", --"bigmole",
	"walks back and forth, explodes after being stomped for a short time", --"bomb",
	"walks back and forth, explodes after being stomped for a short time", --"bombhalf",
	"goes in and out of pipes, fires fireballs towards the player when extended", --"fireplant",
	"will become nonsolid when flipping", --"flipblock",
	"goes in and out of pipes, comes from pipe above, fires fireballs towards the player when extended", --"downfireplant",
	"hand comes down from ceiling and launches torpedo teds", --"torpedoted",
	"gives the player the frog suit, allows faster movement underwater", --"frogsuit",
	"flies accros the screen and moves up when player is riding them", --"parabeetleright",
	"a minor boss who chases you and flails its arms", --"boomboom",
	"ends the level when touched",
	"gives the player a raccoon tail, breaks blocks and kills enemies, allows flying", --"leaf",
	"walks back and forth, stomp to kick around and break blocks, faster", --"koopablue",
	"walks back and forth, stomp to kick around and break blocks, faster", --"koopabluehalf",
	"flies left and right, loses wings when stomped", --"koopaflying2",
	"starts wind that pushes the player around", --"windstart",
	"stops wind that pushes the player around", --"windend",
	"enter to travel between sublevels", --"pipe2?",
	"moves down then up and right, stompable", --"pinksquid",
	"enter to travel between sublevels", --"door",
	"makes tiles this is placed on slippery", --"ice",
	"can be picked up and dropped, activates buttons", --"box2",
	"launches energy pellets that hurt the player, can be caught by catchers", --"energylauncherright",
	"launches energy pellets that hurt the player, can be caught by catchers", --"energylauncherleft",
	"launches energy pellets that hurt the player, can be caught by catchers", --"energylauncherup",
	"launches energy pellets that hurt the player, can be caught by catchers", --"energylauncherdown",
	"catches energy pellets and sends a signal", --"energycatcherright",
	"catches energy pellets and sends a signal", --"energycatcherleft",
	"catches energy pellets and sends a signal", --"energycatcherup",
	"catches energy pellets and sends a signal", --"energycatcherdown",
	"fires bullets at the player, can be destroyed", --"turretleft",
	"fires bullets at the player, can be destroyed", --"turretright",
	"fires bullets at the player, can be destroyed", --"turret2left",
	"fires bullets at the player, can be destroyed", --"turret2right",
	"toggles button blocks when pressed, can be repushed after a short time.", --"blocktogglebutton",
	"turns nonsolid when toggled on", --"buttonblockon",
	"turns solid when toggled on", --"buttonblockoff",
	"drops gel blobs that cover tiles and light bridges", --"purplegeldown",
	"drops gel blobs that cover tiles and light bridges", --"purplegelright",
	"drops gel blobs that cover tiles and light bridges", --"purplegelleft",
	"sleeps, wakes when player is near and chases them", --"sleepfish",
	"turns on and off continuously on a loop", --"squarewave",
	"delays a signal by a number of seconds", --"delayer",
	"gives a coin when collected", --"coin",
	"moves along a path, cannot be stomped, amps are immune", --"amp",
	"flies accros the screen and moves up when player is riding them, faster", --"parabeetlegreen",
	"flies accros the screen and moves up when player is riding them, faster", --"parabeetlegreenright",
	"turns on and off on a cycle", --"longfire",
	"shoots cannonballs from a tile", --"cannonball",
	"makes the player mini, can jump high and fit in small gaps", --"minimushroom",
	"shoots rockets towards the player, hurts glados", --"rocketturret",
	"drops cores when shot, after 4 are destroyed the level ends", --"GLaDOS",
	"gives a portal gun when touched", --"pedestal",
	"spawns a portal when triggered", --"portal1",
	"spawns a portal when triggered", --"portal2",
	"display text in the level", --"text",
	"triggers when something is inside the range", --"region trigger",
	"modify tiles when triggered", --"tiletool",
	"gives the player the ability to launch iceballs that freeze enemies", --"iceflower",
	"walks back and forth, can be picked up and thrown", --"shyguy",
	"walks back and forth, can be picked up and thrown", --"shyguyhalf",
	"spawns enemies when triggered", --"enemytool",
	"sends a random output when triggered", --"randomizer",
	"spawns yoshi when broken, eats enemies", --"yoshi",
	"permanently toggles button blocks when pressed",
	"stomp to kick around and break blocks, makes the player immune to fireballs / bounce enemies", --"beetleshell",
	"changes music when activated", --"musicchanger",
	"swaps brick and coins, freezes belts and activates p doors and p blocks", --"pbutton",
	"walks on floors, walls and ceilings", --"spiketop",
	"walks on floors, walls and ceilings", --"spiketophalf",
	"walks left and right, made of multiple segments", --"pokey",
	"walks left and right, made of multiple segments, can be stomped", --"snowpokey",
	"bounces to move, can be stomped", --"fighterfly",
	"allows the player to swim in midair", --"swimwing",
	"gives the player a hammer that kills enemies", --"dkhammer",
	"stops vines and disables warp", --"vinestop",
	"attaches to a block and lunges at the player", --"chainchomp",
	"walks around, jumps up and down and throws hammers, causes shockwave when landing", --"bighammerbro",
	"can be picked up, dropped and rolled around, activates buttons", --"edgelessbox",
	"lifts up out of ground and throws wrenches towards the player", --"rockywrench",
	"falls when player passes under it", --"thwomp",
	"drops gel blobs that clean tiles and light bridges", --"watergeldown",
	"drops gel blobs that clean tiles and light bridges", --"watergelright",
	"drops gel blobs that clean tiles and light bridges", --"watergelleft",
	"rotates around a block, hurts players, can be passed under", --"rotodisc",
	"carries players and objects, can go through portals", --"funnelup",
	"carries players and objects, can go through portals", --"funneldown",
	"carries players and objects, can go through portals", --"funnelright",
	"carries players and objects, can go through portals", --"funnelleft",
	"exit from another pipe", --"pipespawndown",
	"jumps around", --"thwimp",
	"walks back and forth, retracts into shell, grows spikes, collapses when stomped", --"drybeetle",
	"walks back and forth, retracts into shell, grows spikes, collapses when stomped", --"drybeetlehalf",
	"walks back and forth, can be stomped and only hurts mini mario", --"tinygoomba",
	"bosses who chase you and stop to shoot projectiles", --"koopaling",
	"makes the player mega, can break blocks and kill enemies", --"bigmushroom",
	"a final boss who shoots fireballs, and slams down into the floor under you", --"bowser3",
	"walks around, jumps up and down and throws ice balls", --"icebro",
	"blooper with baby children that follow them", --"squidnanny",
	"jumps, gives shoe when stomped, allows stomping/safe walking on spikes/munchers", --"goombashoe",
	"walks left and right, made of multiple segments, gets angry when stomped", --"wiggler",
	"teleports around, casting spells at the player", --"magikoopa",
	"will make a tile launch homing bullet bills - flies towards the player", --"homingbullet",
	"spawns a circle of boos with a hole for safe passing", --"boocircle",
	"enter to travel between sublevels, must have a p switch active", --"pdoor",
	"enter to travel between sublevels, must have a key", --"keydoor",
	"gives the player a key to use with key doors", --"key",
	"walks left and right, made of multiple segments, already angry", --"wigglerangry",
	"gives the player a tanooki suit, raccoon but you can become a invincible statue", --"tanookisuit",
	"gives the player a cape, breaks blocks and kills enemies, allows flying", --"feather",
	"gives the player bunny ears, allows slow falling", --"carrot",
	"makes the player long and skinny, allows higher jumping", --"weirdmushroom",
	"exit from another pipe", --"pipespawnhor",
	"adds a massive ceiling above the screen that stops people going over", --"ceilblocker",
	"shakes and falls when stood on for too long", --"donutlast",
	"extends out to smash block and enemies in front of it", --"skewer",
	"walks back and forth, going in and out of the ground", --"boocrawler",
	"walks back and forth on the ceiling, falls down when player gets close", --"downspikey",
	"walks back and forth on the ceiling, falls down when player gets close", --"downbeetle",
	"walk into to kick around and break blocks, makes player immune to fireballs and break", --"spikeyshell",
	"can be ridden to fly around freely", --"bigcloud",
	"turns on and off oon a cycle", --"longfireoff",
	"moves players and objects", --"belt",
	"can be activated by cubes", --"buttonbox",
	"can be activated by only edgeless cubes", --"buttonedgeless",
	"kills all enemies on screen", --"luckystar",
	"activates an animation when triggered", -- "animationtrigger",
	"activates animated tiles when triggered", --"animatedtiletrigger",
	"can be turned on and off", --"rsflipflop",
	"will activate if any signal is on", --"orgate",
	"will only activate if all signals are on", --"andgate",
	"can be hit to toggle on and off", -- "actionblock",
	"when collected gets added to the players hud, can trigger collectable locks", --"collectable",
	"player must have a certain number of collectables for this to activate", --"collectablelock",
	"kills all enemies on screen when hit", --"powblock",
	"toggles button blocks when hit", -- "switchblock",
	"falls when player passes under or stands on top, can be static", --"iciclebig"
	"launches player up when stood on", --"verspring",
	"launches player backwards when walked into", --"horspring",
	"flies towards player when player passes infront of it", --"thwompleft",
	"flies towards player when player passes infront of it", --"thwompright",
	"a region of liquid, can be made to rise and fall", --"risingwater",
	"gives the player the ability to launch superballs", --"superballflower",
	"moves players and objects, toggles direction when button switches", --"beltswitch",
	"can be used to ride on rising lava, makes player invincible and allows groundpound", --"drybonesshell",
	"swivels back and forth", --"redseesaw",
	"moves in a path and breaks when ended", --"snakeblock",
	"send signal when activated by an animation", -- "animationoutput",
	"turns nonsolid when p switch is toggled on", --"pbuttonblockon",
	"turns solid when p switch is toggled on", --"pbuttonblockoff",
	"launches spike balls towards the player", --"spike",
	"rolls along the floor and breaks blocks", --"spikeball",
	"can be melted by any source of fire", --"frozencoin",
	"grows player to big, becomes a fire flower if player is big", --"powerup",
	"moves left while oscillating up and down, can be red or gray", --"cheepcheep",
	"gives the player the ability to launch fireballs", --"fireflower",
	"allows the player to fly into the air and slow fall", --"propellerbox",
	"allows the player to shoot cannon balls", --"cannonbox",
	"players and objects can travel through them", --"clearpipe",
	"shoots cannonballs", --"cannonballcannon",
	"stops the camera in a certain range", --"camerastop",
	"follows a path, can be stomped to send back", --"plantcreeper"
	"can carry objects around", --"track",
	"gives the player a blue shell, run to go into shell and break blocks / kill enemies", --"blueshell",
	"gives the player the ability throw boomerangs, come back to player", --"boomerangflower",
	"moves between two points", -- "platform",
	"players and objects can travel through them, can also suck and blow objects", --"pneumatictube",
	"makes the player bigger, can also break blocks", --"bigclassicmushroom",
	"player will spawn back here after dying once they activate it", --"checkpointflag",
	"can be placed on an enemy, makes the enemy bigger and may modify behavior", --"supersize",
	"jumps out the ground and chases the player", --"mole",
	"can kill or bounce the player", --"grinder",
	"a minor boss that shoots fireballs and jumps", --"bowserjr",
	"can carry objects around and changes direction when button switches", --"trackswitch",
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
	--region, type, fill, fill speed, link power, link reverse
	name = "risingwater",
	default = "1|1|0|0|water|1|3|false|.5",
	regionfunc = function(w,h,x,y) --setting region vars
		rightclickvalues2[1] = w
		rightclickvalues2[2] = h
		rightclickvalues2[3] = x
		rightclickvalues2[4] = y
	end,
	format = {
		{"button", 1, {"  set area  ", function(var, step) startrcregion(var, step) end, {1, 2}}},
		"type:",
		{"dropdown", 5, 11, nil, {"clear water", "water", "poison", "poison water", "lava", "quicksand", "quicksandtop"}},
		"fill:",
		{"slider", 6, range = {0, 1, round = 5}},
		"fill speed:",
		{"slider", 7, range = {0, 10, round = 3}},
		{"checkbox", 8, "oscillate"},
		"wait time:",
		{"slider", 9, range = {0, 10, round = 2}},
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
