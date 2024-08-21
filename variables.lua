--SETABLE VARS--	
--almost all vars are in "blocks", "blocks per second" or just "seconds". Should be obvious enough what's what.
--also maxyspeed, bounceheight, koopajumpforce need to be updated in game.lua as well.
portalgundelay = 0.2
gellifetime = 2
bulletbilllifetime = 20
bigbilllifetime = 20
kingbilllifetime = 50
playertypelist = {"portal", "minecraft", "gelcannon", "cappy", "classic"}

joystickdeadzone = 0.2
joystickaimdeadzone = 0.5

--*most of the player physics variables are overridden by custom character properties*
walkacceleration = 8 --acceleration of walking on ground
runacceleration = 16 --acceleration of running on ground
walkaccelerationair = 8 --acceleration of walking in the air
runaccelerationair = 16 --acceleration of running in the air
minspeed = 0.7 --When friction is in effect and speed falls below this, speed is set to 0
frogminspeed = 6.3
frogfriction = 100
maxwalkspeed = 6.4 --fastest speedx when walking
maxrunspeed = 9.0 --fastest speedx when running
friction = 14 --amount of speed that is substracted when not pushing buttons, as well as speed added to acceleration when changing directions
superfriction = 100 --see above, but when speed is greater than maxrunspeed
frictionair = 0 --see above, but in air
airslidefactor = 0.8 --multiply of acceleration in air when changing direction
icefriction = 3 --friction when on ice entity
icewalkacceleration = 4 --acceleration of walking on ground on ice entitiy
icerunacceleration = 8 --^^^
icefreezetime = 1 --seconds stunned when hit by ice bro balls
groundfreezetime = 1 --seconds stunned when sledge bro ground pounded
goombashoehop = 8 --height of hops when mario has goomba shoe
fencespeed = 4 --speed when climbing fence
fencejumptime = 0.05 --how long mario jumps when holding up and jumping while climbing

--STARCOLORS
starcolors = {}
starcolors[1] = {{  0,   0,   0}, {200,  76,  12}, {252, 188, 176}}
starcolors[2] = {{  0, 168,   0}, {252, 152,  56}, {252, 252, 252}}
starcolors[3] = {{252, 216, 168}, {216,  40,   0}, {252, 152,  56}}
starcolors[4] = {{216,  40,   0}, {252, 152,  56}, {252, 252, 252}}

flowercolor = {{252, 216, 168}, {216, 40, 0}, {252, 152, 56}}
hammersuitcolor = {{0, 0, 0}, {255, 255, 255}, {252, 152, 56}}
frogsuitcolor = {{0, 168, 0}, {0, 0, 0}, {252, 152, 56}}
leafcolor = {{224, 32, 0}, {136, 112, 0}, {252, 152, 56}}
iceflowercolor = {{225,255,255}, {60, 188, 252}, {252, 152, 56}}
tanookisuitcolor =  {{200, 76, 12}, {0, 0, 0}, {252, 152, 56}}
statuecolor =  {{116, 116, 116}, {0, 0, 0}, {188, 188, 188}}
superballcolor = {{100, 100, 50}, {160, 160, 110}, {230, 230, 180}}
blueshellcolor = {{40, 0, 186}, {255, 255, 255}, {252, 152, 56}}
boomerangcolor = {{32, 56, 236}, {255, 255, 255}, {252, 152, 56}}

mariocombo = {100, 200, 400, 500, 800, 1000, 2000, 4000, 5000, 8000} --combo scores for bouncing on enemies
koopacombo = {500, 800, 1000, 2000, 4000, 5000, 8000} --combo scores for series of koopa kills
--star scores are identical so I'm just gonn be lazy
firepoints = {	goomba = 100,
				koopa = 200,
				plant = 200,
				bowser = 5000,
				squid = 200,
				cheep = 200,
				flyingfish = 200,
				hammerbro = 1000,
				lakito = 200,
				bulletbill = 200,
				downplant = 200,
				bigbill = 400,
				kingbill = 1000,
				sidestepper = 100,
				barrel = 100,
				icicle = 100,
				angrysun = 500,
				splunkin = 100,
				redplant = 200,
				reddownplant = 200,
				fishbone = 200,
				drybones = 200,
				meteor = 100,
				ninji = 100,
				parabeetle = 200,
				boo = 400,
				mole = 100,
				bigmole = 1000,
				bomb = 100,
				fireplant = 200,
				plantfire = 100,
				downfireplant = 200,
				torpedoted = 200,
				torpedolauncher = 400,
				boomboom = 2000,
				cannonball = 200,
				amp = 1000,
				fuzzy = 200,
				pokey = 100,
				thwomp = 200,
				chainchomp = 200,
				rockywrench = 200,
				magikoopa = 1000,
				spike = 200}

yacceleration = 80 --gravity
yaccelerationjumping = 30 --gravity while jumping (Only for mario)
tinymariogravity = 32 --mini mario gravity --24
tinymariogravityjumping = 24 --mini mario gravity
skinnymariogravity = 24
maxyspeed = 100 --SMB: 14
mari0maxyspeed = maxyspeed
smbmaxyspeed = 15--14
--minportalspeedy = 3 --Things exiting floor portals can't be slower than this (REPLACED WITH OBJECT'S HEIGHT (SEE PHYSICS.LUA FUNC "PORTALCOORDS" UP->UP))
jumpforce = 16--SMB: 16, Smaller(For portal?): 12.1
jumpforceadd = 1.9 --how much jumpforce is added at top speed (linear)
portalphysicsjumpforce = 10
portalphysicsjumpforceadd = 0.4
portalphysicsbluegelminforce = 26
raccoonjumpforce = 20
raccoonjumpforceadd = 2.0
raccoonflyjumpforce = 10
raccoonflytime = 5
raccoonspintime = 0.2
raccoonspinanimationspeed = 15
capejumpforce = 22
headforce = 2 --how fast mario will be sent back down when hitting a block with his head
--bounceforce = 12 --when jumping on an enemy, speedy will be set to this to make mario bounce (negative)
bounceheight = 14/16 --when jumping on enemy, the height that mario will fly up
bounceheightmaker = 20/16 --mario maker height
bounceheighthigh = 34/16 --bounce higher when holding key in mario maker physics
smbbounceheight = bounceheight
smb2jbounceheight = 2 --2-4.5?
passivespeed = 4 --speed that mario is moved against the pointing direction when inside blocks (by crouch sliding under low blocks and standing up for example)
hugemarioblockbounceforce = 6
groundpoundtime = 0.3
groundpoundforce = 10

--Variables that are different for underwater
uwwalkacceleration = 8

uwrunacceleration = 16
uwwalkaccelerationair = 8
uwmaxairwalkspeed = 5 
uwmaxairshellwalkspeed = 6.4
uwmaxwalkspeed = 3.6
uwmaxrunspeed = 5
uwfriction = 14
uwsuperfriction = 100
uwfrictionair = 0
uwairslidefactor = 0.8
uwjumpforce = 5.9
uwjumpforceadd = 0
uwyacceleration = 9
uwyaccelerationjumping = 12

waterdamping = 0.2
waterjumpforce = 13

uwmaxheight = 2.5
uwpushdownspeed = 3

bubblesmaxy = 2.5
bubblesspeed = 2.3
bubblesmargin = 0.5
bubblestime = {1.2, 1.6}

gelmaxrunspeed = 50
gelmaxwalkspeed = 25
gelrunacceleration = 25
gelwalkacceleration = 12.5
bluegelminforce = 0

horbouncemul = 1.5
horbouncespeedy = 20
horbouncemaxspeedx = 15
horbounceminspeedx = 2

cloudacceleration = 16
cloudspeed = 8.0 --speed for mario's cloud
cloudtime = 12 --time mario can ride cloud

drybonesshelltime = 3

--levelstuff
mappacklevels = {}

--kill tables (note: just entity names, types don't matter)
local t = true
fireballkill = {
	goomba = t, koopa = t, hammerbro = t, plant = t, cheep = t, bowser = t, squid = t, flyingfish = t, lakito = t, sidestepper = t, icicle = t, splunkin = t, ninji = t, mole = t, pokey = t, barrel = t, rockywrench = t, koopaling = t, spike = t, magikoopa = t, plantcreeper = t, fuzzy = t,
	}
iceballfreeze = {
	goomba = t, koopa = t, hammerbro = t, plant = t, cheep = t, bowser = t, squid = t, flyingfish = t, lakito = t, sidestepper = t, icicle = t, splunkin = t, ninji = t, mole = t, firebro = t, bomb = t, koopaling = t, drybones = t, spike = t, magikoopa = t, bowser = t, hammer = t, spikeball = t, bulletbill = t, bigbill = t, sidestepper = t, barrel = t, enemy = t, fuzzy = t, amp = t
	}
mariohammerkill = {
	goomba = t, koopa = t, hammerbro = t, plant = t, cheep = t, bowser = t, squid = t, flyingfish = t, lakito = t, sidestepper = t, icicle = t, splunkin = t, ninji = t, drygoomba = t, drybones = t, fishbone = t, boo = t, mole = t, bomb = t, bulletbill = t, torpedoted = t, parabeetle = t, pokey = t, barrel = t, chainchomp = t, thwomp = t, thwimp = t, rockywrench = t, koopaling = t, spike = t, spikeball = t, magikoopa = t, plantcreeper = t, fuzzy = t
	}
mariotailkill = {
	goomba = t, koopa = t, hammerbro = t, plant = t, cheep = t, bowser = t, squid = t, flyingfish = t, lakito = t, sidestepper = t, icicle = t, splunkin = t, ninji = t, mole = t, drybones = t, fishbone = t, drygoomba = t, boo = t, bomb = t, pokey = t, barrel = t, rockywrench = t, koopaling = t, spike = t, magikoopa = t, plantcreeper = t, fuzzy = t
	}

yoshitoungekill = {"mushroom", "goomba", "koopa", "hammerbro", "hammer", "plant", "cheep", "bowser", "squid", "flyingfish", "lakito", "sidestepper", "icicle", "splunkin", "ninji", "mole", "pokey", "barrel", "rockywrench", "enemy", "spike", "magikoopa", "fuzzy"}
dkhammerkill = {"goomba", "koopa", "hammerbro", "plant", "cheep", "bowser", "squid", "flyingfish", "lakito", "sidestepper", "icicle", "splunkin", "ninji", "mole", "pokey", "barrel", "chainchomp", "rockywrench", "enemy", "spike", "spikeball", "magikoopa"}

tileentities = {"tile", "buttonblock", "flipblock", "platform", "donut", "frozencoin", "tilemoving", "belt"}
tileentitieswind = {"tile", "buttonblock", "flipblock", "platform", "donut", "frozencoin", "tilemoving", "belt", "smallspring", "box", "spring", "screenboundary", "cubedispenser", "ceilblocker", "snakeblock", "powblock", "ice", "door", "lightbridgebody", "rocketturret", "blocktogglebutton", "cannonballcannon"}
freezetime = 6.5 --8
iceblockspeed = 10
iceblockkickminspeed = 2 --speed player needs to kick
iceblockairtime = 4

dkhammeranimspeed = 0.15

--yoshi
yoshieggjumpforce = 30
yoshieggbreaktime = .5
yoshijumpforce = 14
yoshijumpforceadd = 1.9
yoshipanicspeed = 6
yoshitoungespeed = 15
yoshitoungemaxwidth = 2.5
yoshitoungeheight = 12/16
yoshiswallowtime = 0.3

--yoshiwalkoffsets = {1, 2, 0}

--items
mushroomspeed = 3.6
mushroomtime = 0.7 --time until it fully emerged out the block
mushroomjumpforce = 13
poisonmushspeed = 3.6
poisonmushtime = 0.7 --time until it fully emerged out the block
poisonmushjumpforce = 13
starjumpforce = 13
staranimationdelay = 0.04
mariostarblinkrate = 0.08 --/disco
mariostarblinkrateslow = 0.16 --/disco
mariostarduration = 12
mariostarrunout = 1 --subtracts, doesn't add.

leafjumpforce = 7 --when it comes out of the block

goombaspeed = 2
goombaacceleration = 8
goombaanimationspeed = 0.2
goombadeathtime = 0.5 --the "stomped" animation of goombas will last this long
goombajumpforce = 9 --paragoomba

fighterflyjumpforce = 12
fighterflyjumpdelay = 0.5 --how long it stays on the floor

goombashoejumpforce = 32 --goomba in shoe, not mario in shoe
goombashoejumpdelay = 1 --how long it stays on the floor

wigglerspeed = 2
wigglerspeedangry = 4

thwompattackspeed = 15
thwompwait = .3
thwompreturnspeed = 3

muncheracceleration = 8
muncheranimationspeed = 0.1
muncherdeathtime = 0

barrelspeed = 3.5
barrelacceleration = 4
barrelanimationspeed = 0.1
barreldeathtime = 0

splunkinspeed = 2
splunkinmadspeed = 4
splinkinacceleration = 8
splunkinanimationspeed = 0.2
splunkindeathtime = 0.5
splunkinhealth = 2

ninjijumpforce = 23

sidestepperspeed = 2
sidestepperacceleration = 8
sidestepperanimationspeed = 0.2
sidestepperdeathtime = 0

koopaspeed = 2
koopasmallspeed = 12 --speed of turtle shells
koopaanimationspeed = 0.2
koopajumpforce = 10
smbkoopajumpforce = koopajumpforce
smb2jkoopajumpforce = 10
koopaflyinggravity = 30
smbkoopaflyinggravity = koopaflyinggravity
smb2jkoopaflyinggravity = 19.5
koopabluespeed = 3 --blue koopa speed
koopawakeup = 8.2--5.2
koopawakeupanimationspeed = 0.2
koopawakeupanimlen = 2
koopahitjumpforce = 13 --when hit from below

drybonesspeed = 2
drybonesanimationspeed = 0.2
drybonesjumpforce = 10
drybonesflyinggravity = 30

moleanimationspeed = 0.15
molespeed = 3.5
molechaserange = 2
molebounceforce = molespeed*2
moleacceleration = 14

bowseranimationspeed = 0.5
bowserspeedbackwards = 1.875
bowserspeedforwards = 0.875
bowserjumpforce = 7
bowsergravity = 10.9
bowserjumpdelay = 1
bowserfallspeed = 8.25 --for animation

boomboomjumpforce = 15
boomboomhighjumpforce = 35
boomboomhp = 3

boospeed = 2
booturnspeed = 4

koopalinganimationdelay = 0.2 --walking
koopalinganimationdelay2 = 0.08 --shell spin
koopalinganimationdelay3 = 0.08 --shell spin death
koopalingspeed = 4
koopalingshootdelay = {0.5, 1, 2, 2, 2, 3}
koopalingshootspread = 0.16-- time apart from each shot
koopalingshoottime = 0.8 --how long it takes to shoot
koopalingjumpspeed = 5
koopalingjumpdelay = {0.5, 0.5, 0.8, 1, 2, 3, 1}
koopalinghopjumpforce = {15, 15, 5, 15, 15, 15, 15, 8, 8} --jumping over blocks
koopalingjumpforce = {21.5, 21.5, 25, 21.5, 21.5, 21.5, 21.5, 20, 20} --big jump
koopalingshelljumpforce = {21.5, 21.5, 21.5, 21.5, 21.5, 21.5, 15, 21.5, 21.5} --jumping in shell
koopalingjumpgravity = 45
koopalingjumpgravity2 = 45 --bowser
koopalingdeathtime = 1.6
koopalingstomptime = 0.8
koopalingshelltime = 4 --bowserjr
koopalingshellspeed = 8
koopalingjrjumpdelay = {0, 0, 0.5, 0.5, 0.8, 1, 1, 1, 1}
koopalingshelldistance = 16 --how far mario needs to be to turn to shell

bowserhammertable = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.5, 1, 2, 1}
bowserhammerdrawtime = 0.5

bowserhealth = 5

cheepwhitespeed = 1
cheepredspeed = 1.8
cheepyspeed = 0.3
cheepheight = 1
cheepanimationspeed = 0.35

cheepanimationfastspeed = 0.08
cheepchasespeed = 3.2
cheepturnspeed = 1

platformverdistance = 8.625
platformhordistance = 3.3125
platformvertime = 6.4
platformhortime = 4
platformbonusspeed = 3.75

platformspawndelay = 2.18 --time between platform spawns

platformjustspeed = 3.5

seesawspeed = 4
seesawgravity = 30
seesawfriction = 4

koopaflyingdistance = 7.5
koopaflyingtime = 7

drybonesflyingdistance = 7.5
drybonesflyingtime = 7

bigkoopaflyingdistance = 7.5
bigkoopaflyingtime = 7

lakitothrowtime = 4
lakitorespawn = 16
lakitospace = 4
lakitodistancetime = 1.5
lakitohidetime = 0.5
lakitopassivex = 18-4/16 --from the flag (or axe (or right end of map))
lakitopassivespeed = 3

-- loiters between 4 blocks behind and 4 blocks ahead of you (total 9 blocks he goes above)
-- spawns only 3 of the hedgehog things and then hides until they're offscreen/dead
-- in 4-1 he disappears when you touch the first step (not stand on, touch from side while on the ground)
-- can be killed by single fireflower
-- the spiky dudes turn towards you after they fall down

angrysunthrowtime = 4
angrysunrespawn = 16
angrysunspace = 4
angrysundistancetime = 1.5
angrysunhidetime = 1.0
angrysunpassivex = 18-4/16 --from the flag (or axe (or right end of map))
angrysunpassivespeed = 5
angrysunfalltime = 0.1

fireballspeed = 15
fireballbrospeed = 10 -- 2/3
fireballjumpforce = 10
maxfireballs = 2
fireanimationtime = 0.11
iceballspeed = 7
iceballbrospeed = 5 -- 2/3 ish
iceballjumpforce = 10
superballspeed = 12
boomerangspeed = 10
boomerangbrospeed = 7 -- 2/3 ish

shotspeedx = 4 --X speed (constant) of fire/shell killed enemies
shotjumpforce = 8 --initial speedy (negative) when shot
shotgravity = 60 --how fast enemies that have been killed by fire or shell accellerate downwards

deathanimationjumpforce = 17
deathanimationjumptime = 0.3
deathgravity = 40
deathtotaltime = 4

portalanimationcount = 6 --frame count of portal animation
portalanimation = 1
portalanimationtimer = 0
portalanimationdelay = 0.08 --frame delay of portal animation
portalrotationalignmentspeed = 15 --how fast things return to a rotation of 0 rad(-ical)

scrollrate = 5
superscrollrate = 40
maxscrollrate = maxrunspeed*2
scrollingstartv = 12 --when the scrolling begins to set in (Both of these take the player who is the farthest on the left)
scrollingcompletev = 10 --when the scrolling will be as fast as mario can run
scrollingleftstartv = 6 --See above, but for scrolling left, and it takes the player on the right-estest.
scrollingleftcompletev = 4
seektime = 0.6 --time it takes to hold the up or down key to look
seekspeed = 13
seekrange = 5

blockbouncetime = 0.2
blockbounceheight = 0.4
coinblocktime = 0.3
coinblockdelay = 0.5/30

portaldotstimer = 0 --this is changed in game.lua for some reason

idleanimationspeed = 8
runanimationspeed = 10
piperunanimationspeed = 7
swimanimationspeed = 10
fenceanimationspeed = 6

propellertime = 0.7
propellerforce = 130
propellerspeed = 12
propellerfloatspeed = 6
cannonboxdelay = 1

spriteset = 1
background = 1
speed = 1
speedtarget = 1
speedmodifier = 10

scrollingscoretime = 0.8
scrollingscoreheight = 2.5

portalparticlespeed = 1
portalparticletimer = 0
portalparticletime = 0.05
portalparticleduration = 0.5

portaldotstime = 0.8
portaldotsdistance = 1.2
portaldotsinner = 10
portaldotsouter = 70

portalprojectilespeed = 100
portalprojectilesinemul = 100
portalprojectiledelay = 2
portalprojectilesinesize = 0.3
portalprojectileparticledelay = 0.002

emanceparticlespeed = 3
emanceparticlespeedmod = 0.3
emanceimgwidth = 64
emancelinecolor = {100, 100, 255, 10}

--excursion funnel
funnelbuildupspeed = 50--1
funnelspeed = 2.8--2
excursionbaseanimationtime = 0.1--0.15
funnelforce = 5
funnelmovespeed = 4--3

emancipateanimationtime = 0.6
emancipatefadeouttime = 0.2

emancipationfizzletime = 0.4
emancipationfizzledelay = 0.05

boxfriction = 20
boxfrictionair = 8

faithplatetime = 0.3

spacerunroom = 1.2/16 --How far you can fall but still be allowed onto the top of a block (For running over 1 tile wide gaps)

doorspeed = 2
groundlightdelay = 1

geldispensespeed = 0.05
geldispensethreshold = 100 --uses different speeds depending on how many gel blobs are on screen
gelmaxspeed = 30
gelmaxcount = 30
gelmaxcountglobal = 120

cubedispensertime = 1

pushbuttontime = 1

bulletbillspeed = 8.0
bulletbilltimemax = 4.5
bulletbilltimemin = 1.0
bulletbillrange = 3

bulletbillchasespeed = 3.6
bulletbillchasetime = 10
bulletbillturnspeed = 1.8
bulletbillchasetimemax = 5.5
bulletbillchasetimemin = 2.0

bigbillspeed = 8.0
bigbilltimemax = 4.5
bigbilltimemin = 1.0
bigbillrange = 3

kingbillspeed = 5.0
kingbillshotgravity = 60

cannonballspeed = 7

hammerbropreparetime = 0.5
hammerbrotime = {0.6, 1.6}
hammerbrospeed = 1.5
hammerbroschasespeed = 2
hammerbroanimationspeed = 0.15
hammerbrojumptime = 3
hammerbrojumpforce = 19
hammerbrojumpforcedown = 6

hammerspeed = 4
hammerstarty = 8
hammergravity = 25
hammeranimationspeed = 0.05

squidfallspeed = 0.9
squidxspeed = 3
squidupspeed = 3
squidacceleration = 10
squiddowndistance = 1

firespeed = 4.69
fireverspeed = 2
fireanimationdelay = 0.05

upfirestarty = 8 --not used
upfireforce = 19
upfiregravity = 20

flyingfishgravity = 20
flyingfishforce = 23

userange = 1
usesquaresize = 1

blockdebrisanimationtime = 0.1
blockdebrisgravity = 60

castlefireangleadd = 11.25
castlefiredelay = 3.4/(360/castlefireangleadd) --the number in front of the bracket is how long a full turn takes
castlefirefastdelay = (3.4/(360/castlefireangleadd))*(3/4)
castlefireanimationdelay = 0.07

chainchompspeed = 2
chainchompattackstart = 2.6--attack interval?
chainchompattackrange = 8
chainchompattackwait = chainchompattackstart-.4 --actually when it STARTS waiting
chainchompattackspeed = 22 --speed it charges at the player
chainchompattacktime = 1 --how long it stays "attacking"
chainchompfreedist = 6 --how far it has to be to break free
chainchompfreecount = 49 --how many times it has to attack to break free
chainchompfreespeed = 4--how fast it goes when free

rockywrenchintime = 2.5 --how long it is inside
rockywrenchwrenchtime = .5 --how long it has wrench
rockywrenchnowrenchtime = .5 --how long it waits without wrench
rockywrenchmovetime = .6 --how long it takes to move
rockywrenchtotaltime = rockywrenchintime+rockywrenchmovetime+rockywrenchwrenchtime+rockywrenchnowrenchtime+rockywrenchmovetime

--turrets
turretupdatetime = 0.1
turrettime = 0.4 --time it takes to activate
turretroom = 0.8
turretdarkenfactor = 0.3
turretshottime = 0.02
turretarmrotationspeed = 5

turretcriticleangle = math.pi/4
frenzytime = 1.5

turretshotduration = 0.1
turrethitdelay = 0.05

refillhitstime = 0.8
maxhitpoints = 12

--plants
plantintime = 1.8
plantouttime = 2
plantanimationdelay = 0.15
plantmovedist = 23/16
plantmovespeed = 2.3

redplantintime = 1.2
redplantouttime = 1.5
redplantanimationdelay = 0.15
redplantmovedist = 23/16
redplantmovespeed = 4

fireplantouttime = 5
plantfirespeed = 4

downfireplantintime = 5

--skewer
skewerstartlength = 48/16
skewerminlength = 16/16
skewermaxlength = 60
skewerspeed = 240/16
skewerretractspeed = 80/16
skewertime = 3

vinespeed = 2.13
vinemovespeed = 3.21
vinemovedownspeed = vinemovespeed*2
vineframedelay = 0.15
vineframedelaydown = vineframedelay/2

vineanimationstart = 4
vineanimationgrowheight = 6
vineanimationmariostart = vineanimationgrowheight/vinespeed
vineanimationstop = 1.75
vineanimationdropdelay = 0.5

--animationstuff
pipeanimationtime = 0.6
pipeanimationdelay = 1
pipeanimationdistancedown = 32/16
pipeanimationdistanceright = 16/16
pipeanimationrunspeed = 3
pipeupdelay = 1

pipespawndelay = 3

growtime = 0.9
shrinktime = 0.9
growframedelay = 0.08
shrinkframedelay = 0.08
invicibleblinktime = 0.02
invincibletime = 3.2

blinktime = 0.5

levelscreentime = 2.4 --2.4
gameovertime = 7
blacktimesub = 0.1
sublevelscreentime = 0.2

--flag animation
flagclimbframedelay = 0.07
scoredelay = 2
flagdescendtime = 0.9
flagydistance = 7+10/16
flaganimationdelay = 0.6
scoresubtractspeed = 1/60
castleflagstarty = 1.5
castleflagspeed = 3
castlemintime = 7
fireworkdelay = 0.55
fireworksoundtime = 0.2
endtime = 2

--spring
springtime = 0.2
springhighforce = 41
springforce = 24
smallspringhighforce = 34
springhorforce = 14
springytable = {0, 0.5, 1}

--green spring
springgreenhighforce = 190
mari0springgreenhighforce = springgreenhighforce
smbspringgreenhighforce = 110
springgreenforce = 24
springgreenytable = {0, 0.5, 1}

--flag scores and positions
flagscores = {100, 400, 800, 2000, 5000}
flagvalues = {9.8125, 7.3125, 5.8125, 2.9375}

--castle win animation
castleanimationchaindisappear = 0.38 --delay from axe disappearing to chain disappearing; once this starts, bowser starts tapping feet with a delay of 0.0666666
castleanimationbowserframedelay = 0.0666
castleanimationbridgedisappeardelay = 0.06 --delay between each bridge block disappearing, also delay between chain and first block
--bowser starts falling and stops moving immediately after the last block disappears
castleanimationmariomove = 1.07 --time when mario starts moving after bowser starts falling and is also unfrozen. music also starts playing at this point
castleanimationcameraaccelerate = 1.83 -- time when camera starts moving faster than mario, relative to start of his move
castleanimationmariostop = 2.3 -- when mario stops next to toad, relative to start of his move
castleanimationtextfirstline = 3.2 -- when camera stops and first line of text appears, relative to the start of his move
castleanimationtextsecondline = 5.3 --second line appears
castleanimationnextlevel = 9.47 -- splash screen for next level appears
-- first bowser is white goomba - see http://www.mariowiki.com/False_Bowser
-- first bowser takes 5 fireflower hits and dies as goomba
-- when fireflower killing boss, axe doesn't make bridge disappear

endanimationtextfirstline = 3.2 -- when camera stops and first line of text appears, relative to the start of his move
endanimationtextsecondline = 7.4 --second line appears
endanimationtextthirdline = 8.4 --third line appears
endanimationtextfourthline = 9.4 --fourth line appears
endanimationtextfifthline = 10.4 --fifth line appears
endanimationend = 12 -- user can press any button

drainspeed = 20
drainmax = 10

--minecraft stuff
minecraftrange = 3
minecraftbreaktime = 0.6

rainboomdelay = 0.03
rainboomframes = 49
rainboomspeed = 45
rainboomearthquake = 50

backgroundstripes = 24

konami = {"up", "up", "down", "down", "left", "right", "left", "right", "b", "a"}
androidkonami = {"w", "w", "s", "s", "a", "d", "a", "d", "lshift", " "}
konamii = 1

earthquakespeed = 40
bullettime = false
portalknockback = false
bigmario = false
goombaattack = false
sonicrainboom = false
playercollisions = false
scalefactor = 5
gelcannondelay = 0.05
gelcannonspeed = 30
infinitetime = false
infinitelives = false

pausemenuoptions = {"resume", "save game", "volume", "quit to", "quit to"}
pausemenuoptions2 = {"", "", "", "menu", "desktop"}

guirepeatdelay = 0.07
mappackhorscrollrange = 220

maximumbulletbills = 5
maximumbigbills = 5
maximumkingbills = 1
coinblocktime = 4

pbuttontime = 9.2

lowgravitymult = 0.2 --low gravity multiplier
lowgravityjumpingmult = 0.8
lowgravitymaxyspeed = 8
lovgravityxmult = 0.8 --speed multiplier

snakeblockspeed = 2
snakeblockfalltime = 1
snakeblockfallspeed = 8

clearpipespeed = 12
clearpipereleasespeed = 1--8
clearpipeenterspeed = 9 --speed needed to enter from above

plantcreeperspeed = 5.8
plantcreeperstompspeed = 8
plantcreeperstompdist = 4
plantcreeperouttime = 0.4
plantcreeperintime = 0.4
plantcreeperstomptime = 2
plantcreepersleepingstomptime = 3
plantcreeperhittime = 0.4

trackspeed = 3
trackfastspeed = 6
trackgravity = 40
trackmaxyspeed = 14

windspeed = 1 --1px every 4 fames
windspeedslow = 1 --1px every 2 frames

autoscrollingdefaultspeed = 3
autoscrollingmaxspeed = 8

dropshadow = false
dropshadowcolor = {0, 0, 0, 80}
--[[dropshadownooverlap = true --no overlapping dropshadows
dropshadowoverlapshader = love.graphics.newShader[[
	vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
		vec4 texcolor = Texel(tex, texture_coords);
		if (texcolor[3] == 0.0) {
			discard;
		};
        return texcolor * color;
    }
]]

anyiteminblock = false --allows any entity to be in block (doesn't work, use block=true instead)

levelballfinishback = {
	{  0, 168,   0},
	{  0, 148,   0},
	{200,  76,  12},
	{252, 152,  56},
	{  0, 168,   0},
	{  0, 148,   0},
	{200,  76,  12},
	{252, 152,  56},}
--less eye hurt (not nes accurate but it's worth it to reduce the possiblity of a seizure)
for i = 1, #levelballfinishback do
	for i2 = 1, #levelballfinishback[i] do
		levelballfinishback[i][i2] = levelballfinishback[i][i2]*0.80
	end
end

--[[levelballfinishback = { --nes accurate
	{  0, 168,   0},
	{252, 116, 180},
	{  0, 168,   0},
	{  1,  57,   0},
	{  0, 168,   0},
	{  1,  57,   0},
	{  0, 168,   0}}]] --background colors for level ball

helmetbounceforce = 14

maxmeteors = 6
meteorspeeds = {3.5, 4, 4.5, 5}
meteordelays = {0, 0.1, 0.15, 0.2, 0.25, 0.3, 0.6, 1.8, 2.1, 2}

powerupslistids = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "-1"}
powerupslistidsrc = shallowcopy(powerupslistids)
for i, v in pairs(powerupslistidsrc) do
	v = v:gsub("-", "n")
end
powerupslist = {"small", "big", "fire", "hammer", "frog", "raccoon", "ice", "mega", "tanooki",
	"cape", "bunny", "skinny", "superball", "blueshell", "boomerang", "huge", "tiny"}

onlysaveiflevelmodified = true

--colors for text entity and hud
textcolorsnames = {"black","blue","brown","gray","green","lime","maroon","orange","pink","purple","red","sky","white","yellow"}
textcolors = {
	white =  {255,255,255},
	black =  {  0,  0,  0},
	gray =   {120,120,120},
	red =    {216, 40,  0},
	maroon = {168,  0, 16},
	blue =   { 32, 52,236},
	sky =    { 60,188,252},
	yellow = {240,188, 60},
	green =  {  0,168,  0},
	lime =   {128,208, 16},
	orange = {252,152, 56},
	pink =   {252,116,180},
	purple = {116,  0,116},
	brown =  {200, 76, 12},
}

--background colors in calendar image for every month
calendarcolors = {
	{248, 133,  43},
	{252, 116, 180},
	{128, 208,  16},
	{  0, 168,   0},
	{168, 240, 188},
	{ 92, 148, 252},
	{ 32,  56, 236},
	{228,   0,  88},
	{200,  76,  12},
	{216,  40,   0},
	{ 60, 188, 252},
	{156, 252, 240}
}

--snooping as usual i see
--increasing the level limit is probably the only thing that will work correctly
--changing sublevels or worlds will cause trouble with letters and guis
--Update: I've increased the world and level limit. Watch only like one person use them.

--levels
alphabet = "abcdefghijklmnopqrstuvwxyz "
maxworlds = 999--9+26 --nine worlds + alphabet (not including -1 world)
maxlevels = 99--9+26
maxsublevels = 13 --any more than this doesn't even fit, but yea change it if you want
defaultworlds = 8
defaultlevels = 4
defaultsublevels = 5

onlinedlc = true

maxsublevelstable = {}
for k = 0, maxsublevels do
	table.insert(maxsublevelstable, k)
end

maxtilespritebatchsprites = 1000

emptytile = {1,gels={}}

-- portal colors
-- note: this should not be read directly due to mutation
-- use getDefaultPortalColor(index) or getDefaultPortalColors() instead to get a copy of the color
__defaultPortalColor = {{60, 188, 252}, {232, 130, 30}}

function getDefaultPortalColor(index)
	color = __defaultPortalColor[index]
	return {unpack(color)}
end

function getDefaultPortalColors()
	return {getDefaultPortalColor(1), getDefaultPortalColor(2)}
end
