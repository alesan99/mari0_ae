animationguiline = class:new()

animationlist = {}
local toenter = {}

--TRIGGERS:

table.insert(toenter, {name = "mapload",
	t = {
		t="trigger",
		nicename="on map load",
		entries={
			
		}
	}
})

table.insert(toenter, {name = "animationtrigger",
	t = {
		t="trigger",
		nicename="animation trigger",
		entries={
			{
				t="text",
				value="with id",
			},
			
			{
				t="input",
				default="myanim",
			},
		}
	}
})

table.insert(toenter, {name = "timepassed",
	t = {
		t="trigger",
		nicename="after seconds:",
		entries={
			{
				t="numinput",
				default="1"
			},
		}
	}
})

table.insert(toenter, {name = "playerxgreater",
	t = {
		t="trigger",
		nicename="player's x position >",
		entries={
			{
				t="numinput"
			},
		}
	}
})

table.insert(toenter, {name = "playerxless",
	t = {
		t="trigger",
		nicename="player's x position <",
		entries={
			{
				t="numinput"
			},
		}
	}
})

table.insert(toenter, {name = "playerygreater",
	t = {
		t="trigger",
		nicename="player's y position >",
		entries={
			{
				t="numinput"
			},
		}
	}
})

table.insert(toenter, {name = "playeryless",
	t = {
		t="trigger",
		nicename="player's y position <",
		entries={
			{
				t="numinput"
			},
		}
	}
})

table.insert(toenter, {name = "mariotimeless",
	t = {
		t="trigger",
		nicename="time below:",
		entries={
			{
				t="numinput"
			},
		}
	}
})

table.insert(toenter, {name = "buttonpressed",
	t= {
		t="trigger",
		nicename="button pressed:",
		entries={
			{
				t="buttonselection",
			},
			
			{
				t="text",
				value="by"
			},
			
			{
				t="playerselectionany",
			},
		}
	}
})

table.insert(toenter, {name = "buttonreleased",
	t= {
		t="trigger",
		nicename="button released:",
		entries={
			{
				t="buttonselection",
			},
			
			{
				t="text",
				value="by"
			},
			
			{
				t="playerselectionany",
			},
		}
	}
})

table.insert(toenter, {name = "pswitchtrigger",
	t= {
		t="trigger",
		nicename="pBswitch triggered:",
		entries={
			{
				t="text",
				value="when switch is"
			},
			
			{
				t="powerselection",
			},
		}
	}
})

table.insert(toenter, {name = "switchblocktrigger",
	t= {
		t="trigger",
		nicename="switch block triggered:",
		entries={
			{
				t="text",
				value="with color"
			},
			
			{
				t="switchblockselection",
			},
		}
	}
})


table.insert(toenter, {name = "playerlandsonground",
	t= {
		t="trigger",
		nicename="player lands on ground:",
		entries={
			{
				t="text",
				value="player"
			},
			
			{
				t="playerselectionany",
			},
		}
	}
})


table.insert(toenter, {name = "playerhurt",
	t= {
		t="trigger",
		nicename="player is hurt:",
		entries={
			{
				t="text",
				value="player:"
			},
			
			{
				t="playerselectionany",
			},
		}
	}
})

table.insert(toenter, {name = "whennumber",
	t= {
		t="trigger",
		nicename="when number:",
		entries={
			{
				t="text",
				value="name",
			},

			{
				t="input",
			},

			{
				t="comparisonselection",
			},
			
			{
				t="numinput",
			},
		}
	}
})

--CONDITIONS:

table.insert(toenter, {name = "noprevsublevel", 
	t = {
		t="condition",
		nicename="map started here",
		entries={
			
		}
	}
})

table.insert(toenter, {name = "worldequals", 
	t = {
		t="condition",
		nicename="world is number",
		entries={
			{
				t="numinput",
				default="1"
			},
		}
	}
})

table.insert(toenter, {name = "levelequals", 
	t = {
		t="condition",
		nicename="level is number",
		entries={
			{
				t="numinput",
				default="1"
			},
		}
	}
})

table.insert(toenter, {name = "sublevelequals",
	t= {
		t="condition",
		nicename="sublevel is number",
		entries={
			{
				t="sublevelselection",
			}
		}
	}
})

table.insert(toenter, {name = "requirecoins",
	t= {
		t="condition",
		nicename="require coins",
		entries={
			{
				t="numinput",
			}
		}
	}
})

table.insert(toenter, {name = "requirepoints",
	t= {
		t="condition",
		nicename="require points",
		entries={
			{
				t="numinput",
			}
		}
	}
})

table.insert(toenter, {name = "requirecollectables",
	t= {
		t="condition",
		nicename="require collectables",
		entries={
			{
				t="numinput",
			},
			
			{
				t="text",
				value="type",
			},
			
			{
				t="collectableselection",
			}
		}
	}
})

table.insert(toenter, {name = "ifcoins",
	t= {
		t="condition",
		nicename="if coins",
		entries={
			{
				t="comparisonselection",
			},
			{
				t="numinput",
			}
		}
	}
})

table.insert(toenter, {name = "ifpoints",
	t= {
		t="condition",
		nicename="if points",
		entries={
			{
				t="comparisonselection",
			},
			{
				t="numinput",
			}
		}
	}
})

table.insert(toenter, {name = "ifcollectables",
	t= {
		t="condition",
		nicename="if collectables",
		entries={
			{
				t="comparisonselection",
			},
			{
				t="numinput",
			},
			{
				t="text",
				value="type",
			},
			{
				t="collectableselection",
			}
		}
	}
})

table.insert(toenter, {name = "requirekeys",
t= {
	t="condition",
	nicename="require keys",
	entries={
		{
			t="numinput",
		},
		
		{
			t="text",
			value="from"
		},
		
		{
			t="playerselectionany",
		},
	}
}
})

table.insert(toenter, {name = "playerissize", 
	t = {
		t="condition",
		nicename="player is size",
		entries={
			{
				t="powerupselection",
			},
			{
				t="playerselectionany",
			},
		}
	}
})


table.insert(toenter, {name = "buttonhelddown",
	t= {
		t="condition",
		nicename="button held down:",
		entries={
			{
				t="buttonselection",
			},
			
			{
				t="text",
				value="by"
			},
			
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "ifnumber",
	t= {
		t="condition",
		nicename="if number:",
		entries={
			{
				t="text",
				value="name",
			},

			{
				t="input",
			},

			{
				t="comparisonselection",
			},
			
			{
				t="numinput",
			},
		}
	}
})

table.insert(toenter, {name = "requireplayers",
	t= {
		t="condition",
		nicename="require players:",
		entries={
			{
				t="levelselection",
			},
		}
	}
})

--ACTIONS:

table.insert(toenter, {name = "disablecontrols", 
	t = {
		t="action",
		nicename="disable controls",
		entries={
			{
				t="text",
				value="of"
			},
			
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "enablecontrols", 
	t = {
		t="action",
		nicename="enable controls",
		entries={
			{
				t="text",
				value="of"
			},
			
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "sleep", 
	t = {
		t="action",
		nicename="sleep/wait",
		entries={
			{
				t="numinput",
				default="1",
			},
			
			{
				t="text",
				value="seconds",
			},
		}
	}
})

table.insert(toenter, {name = "setcamerax", 
	t = {
		t="action",
		nicename="set camera to x:",
		entries={
			{
				t="numinput",
			},
		}
	}
})

table.insert(toenter, {name = "setcameray", 
	t = {
		t="action",
		nicename="set camera to y:",
		entries={		
			{
				t="numinput",
			},
		}
	}
})

table.insert(toenter, {name = "pancameratox", 
	t = {
		t="action",
		nicename="pan camera to x:",
		entries={
			{
				t="numinput",
			},
			
			{
				t="text",
				value="over",
			},
			
			{
				t="numinput",
			},
			
			{
				t="text",
				value="seconds",
			}
		}
	}
})

table.insert(toenter, {name = "pancameratoy", 
	t = {
		t="action",
		nicename="pan camera to y:",
		entries={
			{
				t="numinput",
			},
			
			{
				t="text",
				value="over",
			},
			
			{
				t="numinput",
			},
			
			{
				t="text",
				value="seconds",
			}
		}
	}
})

table.insert(toenter, {name = "pancamera", 
	t = {
		t="action",
		nicename="pan camera:",
		entries={
			{
				t="text",
				value="hor:",
			},

			{
				t="numinput",
			},

			{
				t="text",
				value="ver:",
			},

			{
				t="numinput",
			},

			
			{
				t="text",
				value="over",
			},
			
			{
				t="numinput",
			},
			
			{
				t="text",
				value="seconds",
			}
		}
	}
})

table.insert(toenter, {name = "disablescroll", 
	t = {
		t="action",
		nicename="disable scrolling",
		entries={
		
		}
	}
})

table.insert(toenter, {name = "disableverscroll", 
	t = {
		t="action",
		nicename="disable y scrolling",
		entries={
		
		}
	}
})

table.insert(toenter, {name = "disablehorscroll", 
	t = {
		t="action",
		nicename="disable x scrolling",
		entries={
		
		}
	}
})

table.insert(toenter, {name = "enablescroll", 
	t = {
		t="action",
		nicename="enable scrolling",
		entries={
		
		}
	}
})

table.insert(toenter, {name = "enableverscroll", 
	t = {
		t="action",
		nicename="enable y scrolling",
		entries={
		
		}
	}
})

table.insert(toenter, {name = "enablehorscroll", 
	t = {
		t="action",
		nicename="enable x scrolling",
		entries={
		
		}
	}
})

table.insert(toenter, {name = "setx", 
	t = {
		t="action",
		nicename="move player to x:",
		entries={
			{
				t="playerselection"
			},
			
			{
				t="text",
				value="to x=",
			},
			
			{
				t="numinput"
			}
		}
	}
})

table.insert(toenter, {name = "sety", 
	t = {
		t="action",
		nicename="move player to y:",
		entries={
			{
				t="playerselection"
			},
			
			{
				t="text",
				value="to y=",
			},
			
			{
				t="numinput"
			}
		}
	}
})

table.insert(toenter, {name = "playerwalk", 
	t = {
		t="action",
		nicename="animate to walk:",
		entries={
			{
				t="playerselection",
			},
			
			{
				t="text",
				value="towards"
			},
			
			{
				t="directionselection",
			},
			
			{
				t="text",
				value="speed",
			},
			
			{
				t="walkspeedselection",
			},
		}
	}
})

table.insert(toenter, {name = "playeranimationstop", 
	t = {
		t="action",
		nicename="stop playeranimations:",
		entries={
			{
				t="playerselection",
			}
		}
	}
})

table.insert(toenter, {name = "disableanimation", 
	t = {
		t="action",
		nicename="disable this animation",
		entries={
			
		}
	}
})

table.insert(toenter, {name = "enableanimation", 
	t = {
		t="action",
		nicename="enable this anim",
		entries={
			
		}
	}
})

table.insert(toenter, {name = "playerjump", 
	t = {
		t="action",
		nicename="make jump:",
		entries={
			{
				t="playerselection",
			}
		}
	}
})

table.insert(toenter, {name = "playerstopjump", 
	t = {
		t="action",
		nicename="stop jumping:",
		entries={
			{
				t="playerselection",
			}
		}
	}
})

table.insert(toenter, {name = "dialogbox", 
	t = {
		t="action",
		nicename="create dialog",
		entries={
			{
				t="text",
				value="with text"
			},
			
			{
				t="input",
				length=192
			},
			
			{
				t="text",
				value="and speaker"
			},
			
			{
				t="input"
			},

			{
				t="text",
				value="color"
			},
			
			{
				t="colorselection"
			},
		}
	}
})

table.insert(toenter, {name = "removedialogbox", 
	t = {
		t="action",
		nicename="destroy dialogs",
		entries={
			
		}
	}
})

table.insert(toenter, {name = "playmusic", 
	t = {
		t="action",
		nicename="play music",
		entries={
			{
				t="musicselection"
			}
		}
	}
})

table.insert(toenter, {name = "playsound", 
	t = {
		t="action",
		nicename="play sound",
		entries={
			{
				t="soundselection"
			}
		}
	}
})

table.insert(toenter, {name = "stopsound", 
	t = {
		t="action",
		nicename="stop sound",
		entries={
			{
				t="soundselection"
			}
		}
	}
})

table.insert(toenter, {name = "stopsounds", 
	t = {
		t="action",
		nicename="stop all sounds",
		entries={
			
		}
	}
})

table.insert(toenter, {name = "screenshake", 
	t = {
		t="action",
		nicename="shake the screen",
		entries={
			{
				t="text",
				value="with"
			},
			
			{
				t="numinput",
			},
			
			{
				t="text",
				value="force",
			}
		}
	}
})

table.insert(toenter, {name = "addcoins", 
	t = {
		t="action",
		nicename="add coins",
		entries={
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="coins"
			}
		}
	}
})

table.insert(toenter, {name = "addpoints", 
	t = {
		t="action",
		nicename="add points",
		entries={
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="points"
			}
		}
	}
})

table.insert(toenter, {name = "removepoints", 
	t = {
		t="action",
		nicename="remove points",
		entries={
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="points"
			}
		}
	}
})

table.insert(toenter, {name = "addtime", 
	t = {
		t="action",
		nicename="add time",
		entries={
			{
				t="numinput",
				default="100"
			},
			
			{
				t="text",
				value="seconds"
			}
		}
	}
})

table.insert(toenter, {name = "removetime", 
	t = {
		t="action",
		nicename="remove time",
		entries={
			{
				t="numinput",
				default="100"
			},
			
			{
				t="text",
				value="seconds"
			}
		}
	}
})

table.insert(toenter, {name = "settime", 
	t = {
		t="action",
		nicename="set time",
		entries={
			{
				t="numinput",
				default="100"
			},
			
			{
				t="text",
				value="seconds"
			}
		}
	}
})

table.insert(toenter, {name = "changebackgroundcolor", 
	t = {
		t="action",
		nicename="change background color",
		entries={
			{
				t="text",
				value="to r"
			},
			
			{
				t="numinput",
				default="255"
			},
			
			{
				t="text",
				value="g"
			},
			
			{
				t="numinput",
				default="255"
			},
			
			{
				t="text",
				value="b"
			},
			
			{
				t="numinput",
				default="255"
			},
		}
	}
})

table.insert(toenter, {name = "killplayer", 
	t = {
		t="action",
		nicename="hurt player:",
		entries={
			{
				t="playerselection",
			}
		}
	}
})

table.insert(toenter, {name = "instantkillplayer", 
	t = {
		t="action",
		nicename="kill player:",
		entries={
			{
				t="playerselection",
			}
		}
	}
})

table.insert(toenter, {name = "changetime", 
	t = {
		t="action",
		nicename="change time left",
		entries={
			{
				t="text",
				value="to"
			},
		
			{
				t="numinput",
				default="400"
			}
		}
	}
})

table.insert(toenter, {name = "loadlevel", 
	t = {
		t="action",
		nicename="load level:",
		entries={
			{
				t="text",
				value="world"
			},
		
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="level"
			},
		
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="sublevel"
			},
		
			{
				t="numinputshort",
				default="0"
			},
			
			{
				t="text",
				value="exit:"
			},
		
			{
				t="exitidselection"
			}
		}
	}
})

table.insert(toenter, {name = "loadlevelinstant", 
	t = {
		t="action",
		nicename="load level instantly:",
		entries={
			{
				t="text",
				value="world"
			},
		
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="level"
			},
		
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="sublevel"
			},
		
			{
				t="numinputshort",
				default="0"
			},
			
			{
				t="text",
				value="exit:"
			},
		
			{
				t="exitidselection"
			}
		}
	}
})


table.insert(toenter, {name = "nextlevel", 
	t = {
		t="action",
		nicename="next level",
		entries={
		}
	}
})

table.insert(toenter, {name = "disableplayeraim", 
	t = {
		t="action",
		nicename="disable aiming",
		entries={
			{
				t="text",
				value="of"
			},
			
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "enableplayeraim", 
	t = {
		t="action",
		nicename="enable aiming",
		entries={
			{
				t="text",
				value="of"
			},
			
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "closeportals", 
	t = {
		t="action",
		nicename="close portals",
		entries={
			{
				t="text",
				value="of"
			},
			
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "makeplayerlook", 
	t = {
		t="action",
		nicename="make player aim to deg",
		entries={
			{
				t="playerselection",
			},
			
			{
				t="text",
				value="to"
			},
			
			{
				t="numinput",
			},
			
			{
				t="text",
				value="degrees"
			},
		}
	}
})

table.insert(toenter, {name = "makeplayerfireportal", 
	t = {
		t="action",
		nicename="make fire portal:",
		entries={
			{
				t="text",
				value="player"
			},
			
			{
				t="playerselection",
			},
			
			{
				t="text",
				value="portal #"
			},
			
			{
				t="numinput",
				default="1"
			},
		}
	}
})

table.insert(toenter, {name = "disableportalgun", 
	t = {
		t="action",
		nicename="disable portal gun of",
		entries={
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "enableportalgun", 
	t = {
		t="action",
		nicename="enable portal gun of",
		entries={
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "changebackground", 
	t = {
		t="action",
		nicename="change background",
		entries={
			{
				t="backgroundselection"
			}
		}
	}
})

table.insert(toenter, {name = "autosave", 
	t = {
		t="action",
		nicename="save game progress",
		entries={
			{
				t="text",
				value=" and "
			},
			{
				t="notifyplayer"
			}
		}
	}
})

table.insert(toenter, {name = "changeforeground", 
	t = {
		t="action",
		nicename="change foreground",
		entries={
			{
				t="backgroundselection"
			}
		}
	}
})

table.insert(toenter, {name = "removecoins", 
	t = {
		t="action",
		nicename="remove coins",
		entries={
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="coins"
			}
		}
	}
})

table.insert(toenter, {name = "removecollectables", 
	t = {
		t="action",
		nicename="remove collectables",
		entries={
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="type",
			},
			
			{
				t="collectableselection",
			}
		}
	}
})

table.insert(toenter, {name = "addcollectables", 
	t = {
		t="action",
		nicename="add collectables",
		entries={
			{
				t="numinput",
				default="1"
			},
			
			{
				t="text",
				value="type",
			},
			
			{
				t="collectableselection",
			}
		}
	}
})

table.insert(toenter, {name = "addkeys",
t= {
	t="action",
	nicename="add keys",
	entries={
		{
			t="numinput",
		},
		
		{
			t="text",
			value="to"
		},
		
		{
			t="playerselection",
		},
	}
}
})

table.insert(toenter, {name = "removekeys",
t= {
	t="action",
	nicename="remove keys",
	entries={
		{
			t="numinput",
		},
		
		{
			t="text",
			value="from"
		},
		
		{
			t="playerselection",
		},
	}
}
})

table.insert(toenter, {name = "resetcollectables", 
	t = {
		t="action",
		nicename="reset collectables",
		entries={
			{
				t="text",
				value="type",
			},
			
			{
				t="collectableselection",
			}
		}
	}
})

table.insert(toenter, {name = "setautoscrolling", 
	t = {
		t="action",
		nicename="set autoscrolling:",
		entries={
			{
				t="text",
				value="to x speed",
			},
			{
				t="numinput",
				default="3",
			},
			{
				t="text",
				value="to y speed",
			},
			{
				t="numinput",
				default="2",
			}
		}
	}
})

table.insert(toenter, {name = "stopautoscrolling", 
	t = {
		t="action",
		nicename="stop autoscrolling",
		entries={		

		}
	}
})

table.insert(toenter, {name = "togglewind", 
	t = {
		t="action",
		nicename="set wind",
		entries={		
			{
				t="text",
				value="to speed",
			},
			{
				t="numinput",
				default="1",
			}
		}
	}
})

table.insert(toenter, {name = "togglelowgravity", 
	t = {
		t="action",
		nicename="toggle low gravity",
		entries={		

		}
	}
})

table.insert(toenter, {name = "togglelightsout", 
	t = {
		t="action",
		nicename="toggle lights out",
		entries={		

		}
	}
})

table.insert(toenter, {name = "centercamera", 
	t = {
		t="action",
		nicename="center camera",
		entries={		

		}
	}
})

table.insert(toenter, {name = "repeat", 
	t = {
		t="action",
		nicename="repeat",
		entries={		

		}
	}
})

table.insert(toenter, {name = "removeshoe", 
	t = {
		t="action",
		nicename="remove shoe:",
		entries={
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "removehelmet", 
	t = {
		t="action",
		nicename="remove helmet:",
		entries={
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "animationoutput", 
t = {
	t="action",
	nicename="animation output:",
	entries={
		{
			t="text",
			value="with id",
		},
		
		{
			t="input",
			default="myanim",
		},

		{
			t="text",
			value="send signal:",
		},

		{
			t="signalselection",
		},
	}
}
})

table.insert(toenter, {name = "triggeranimation", 
t = {
	t="action",
	nicename="animation trigger:",
	entries={
		{
			t="text",
			value="with id",
		},
		
		{
			t="input",
			default="myanim",
		}
	}
}
})

table.insert(toenter, {name = "transformenemy", 
t = {
	t="action",
	nicename="transform enemy:",
	entries={
		{
			t="text",
			value="with \"transformanimation\":",
		},
		
		{
			t="input",
			default="",
		},
	}
}
})

table.insert(toenter, {name = "killallenemies", 
	t = {
		t="action",
		nicename="kill all enemies",
		entries={		

		}
	}
})

table.insert(toenter, {name = "setplayersize", 
	t = {
		t="action",
		nicename="make player grow:",
		entries={
			{
				t="powerupselection",
			},
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "disablejumping", 
	t = {
		t="action",
		nicename="disable jumping",
		entries={
			{
				t="text",
				value="for"
			},
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "enablejumping", 
	t = {
		t="action",
		nicename="enable jumping",
		entries={
			{
				t="text",
				value="for"
			},
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "setnumber",
	t= {
	t="action",
		nicename="set number:",
		entries={
			{
				t="text",
				value="name",
			},

			{
				t="input",
			},

			{
				t="operationselection",
			},
			
			{
				t="numinput",
			},
		}
	}
})

table.insert(toenter, {name = "resetnumbers",
	t= {
	t="action",
		nicename="reset numbers",
		entries={
		}
	}
})

table.insert(toenter, {name = "launchplayer", 
	t = {
		t="action",
		nicename="launch player:",
		entries={
			{
				t="playerselection",
			},
			{
				t="text",
				value="x speed",
			},
			{
				t="numinput",
				default="0",
			},
			{
				t="text",
				value="y speed",
			},
			{
				t="numinput",
				default="0",
			}
		}
	}
})

table.insert(toenter, {name = "setplayerlight", 
	t = {
		t="action",
		nicename="set player light:",
		entries={
			{
				t="numinput",
				default="3.5",
			},
		}
	}
})

table.insert(toenter, {name = "waitforinput", 
	t = {
		t="action",
		nicename="wait for input:",
		entries={
			{
				t="buttonselection",
			},
			
			{
				t="text",
				value="by"
			},
			
			{
				t="playerselectionany",
			},
		}
	}
})


table.insert(toenter, {name = "waitfortrigger", 
	t = {
		t="action",
		nicename="wait for anim trigger:",
		entries={
			{
				t="text",
				value="with id",
			},
			{
				t="input",
				default="myanim",
			},
		}
	}
})

table.insert(toenter, {name = "changeportal", 
	t = {
		t="action",
		nicename="set available portals:",
		entries={
			{
				t="text",
				value="for"
			},
			{
				t="playerselection",
			},
			{
				t="text",
				value="to"
			},
			{
				t="portalselection",
			},
		}
	}
})

table.insert(toenter, {name = "makeinvincible", 
	t = {
		t="action",
		nicename="make invincible",
		entries={
			{
				t="numinput",
			},
			{
				t="text",
				value="for"
			},
			{
				t="playerselection",
			},
		}
	}
})

table.insert(toenter, {name = "changeswitchstate", 
	t = {
		t="action",
		nicename="change switch state:",
		entries={
			{
				t="text",
				value="with color"
			},
			{
				t="switchblockselection",
			},
			{
				t="text",
				value="global"
			},
			{
				t="powerselection",
			},
		}
	}
})

--SORT ALPHABETICALLY (I didn't even know you could greater/less compare strings.)
table.sort(toenter, function(a, b) return a.t.nicename < b.t.nicename end)

local typelist = {"trigger", "condition", "action"}

local animationstrings = {}

for i = 1, #typelist do
	animationstrings[typelist[i] ] = {}
end

for i, v in pairs(toenter) do
	animationlist[v.name] = v.t
	table.insert(animationstrings[v.t.t], v.t.nicename)
end

function animationguiline:init(tabl, t2)
	self.t = tabl
	self.type = t2
	
	local x = 0
	self.elements = {}
	self.elements[1] = {}
	local start = 1
	for i = 1, #animationstrings[self.type] do
		if animationlist[self.t[1]] and animationlist[self.t[1]].nicename == animationstrings[self.type][i] then
			start = i
		end
	end
	local firstwidth = 22--#animationstrings[self.type][start]
	
	self.deletebutton = guielement:new("button", 0, 0, "x", function() self:delete() end, nil, nil, nil, 8, 0.1)
	self.deletebutton.textcolor = {200, 0, 0}
	
	self.downbutton = guielement:new("button", 0, 0, "↓", function() self:movedown() end, nil, nil, nil, 8, 0.1)
	self.downbutton.textcolor = {255, 255, 255}
	
	self.upbutton = guielement:new("button", 0, 0, "↑", function() self:moveup() end, nil, nil, nil, 8, 0.1)
	self.upbutton.textcolor = {255, 255, 255}
	
	self.elements[1].gui = guielement:new("dropdown", 0, 0, firstwidth, function(val) self:changemainthing(val) end, start, unpack(animationstrings[self.type]))
	self.elements[1].width = 14+firstwidth*8
	
	if not self.t[1] then
		for i, v in pairs(animationlist) do
			if v.nicename == animationstrings[self.type][1] then
				self.t[1] = i
				break
			end
		end
	end
	
	local tid = 1
	if animationlist[self.t[1] ] then
		for i, v in ipairs(animationlist[self.t[1] ].entries) do
			local temp = {}
			
			if v.t == "text" then
				temp.t = "text"
				temp.value = v.value
				temp.width = #v.value*8
			else
				tid = tid + 1
				
				local dropdown = false
				local dropwidth
				local args, displayargs
				local coloredtext
				
				if v.t == "input" then
					local width = 15
					local maxwidth = v.length or 30
					temp.gui = guielement:new("input", 0, 0, width, nil, self.t[tid] or v.default or "", maxwidth, nil, nil, 0)
					temp.gui.bypassspecialcharacters = true
					temp.width = 4+width*8
					
				elseif v.t == "numinput" or v.t == "numinputshort" then
					local width = 5
					if v.t == "numinputshort" then
						width = 3
					end
					local maxwidth = 10
					temp.gui = guielement:new("input", 0, 0, width, nil, self.t[tid] or v.default or "0", maxwidth, nil, true, 0)
					temp.gui.bypassspecialcharacters = true
					temp.width = 4+width*8
					
				elseif v.t == "playerselection" then
					dropdown = true
					dropwidth = 8
					args = {"everyone", "player 1", "player 2", "player 3", "player 4"}

				elseif v.t == "playerselectionany" then
					dropdown = true
					dropwidth = 8
					args = {"everyone", "player 1", "player 2", "player 3", "player 4"}
					displayargs = {"anyone", "player 1", "player 2", "player 3", "player 4"}
					
				elseif v.t == "worldselection" then
					dropdown = true
					dropwidth = 1
					args = {"1", "2", "3", "4", "5", "6", "7", "8"}
					
				elseif v.t == "levelselection" then
					dropdown = true
					dropwidth = 1
					args = {"1", "2", "3", "4"}
					
				elseif v.t == "sublevelselection" then
					dropdown = true
					dropwidth = 4
					args = {"main"}
					for k = 1, mappacklevels[marioworld][mariolevel] do
						table.insert(args, tostring(k))
					end
					
				elseif v.t == "directionselection" then
					dropdown = true
					dropwidth = 5
					args = {"right", "left"}
					
				elseif v.t == "musicselection" then
					dropdown = true
					dropwidth = 15
					args = {unpack(musictable)}

				elseif v.t == "soundselection" then
					dropdown = true
					dropwidth = 15
					args = {unpack(soundliststring)}

				elseif v.t == "backgroundselection" then
					dropdown = true
					dropwidth = 10
					args = {unpack(custombackgrounds)}

				elseif v.t == "collectableselection" then
					dropdown = true
					dropwidth = 2
					args = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}

				elseif v.t == "buttonselection" then
					dropdown = true
					dropwidth = 7
					args = {"jump", "run", "left", "right", "up", "down", "use", "reload"}

				elseif v.t == "signalselection" then
					dropdown = true
					dropwidth = 7
					args = {"toggle", "on", "off"}

				elseif v.t == "powerselection" then
					dropdown = true
					dropwidth = 4
					args = {"on", "off"}

				elseif v.t == "switchblockselection" then
					dropdown = true
					dropwidth = 1
					args = {"1", "2", "3", "4"}

				elseif v.t == "exitidselection" then
					dropdown = true
					dropwidth = 2
					args = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}
				
				elseif v.t == "powerupselection" then
					dropdown = true
					dropwidth = 8
					args = powerupslistids
					displayargs = powerupslist
				
				elseif v.t == "colorselection" then
					dropdown = true
					dropwidth = 7
					args = {}
					for i, v in pairs(textcolors) do
						if i ~= "white" then
							table.insert(args, i)
						end
					end
					table.sort(args)
					table.insert(args,1,"white")
					coloredtext = true

				elseif v.t == "walkspeedselection" then
					dropdown = true
					dropwidth = 5
					args = {maxwalkspeed, maxrunspeed, 3}
					displayargs = {"walk", "run", "slow"}

				elseif v.t == "comparisonselection" then
					dropdown = true
					dropwidth = 2
					args = {"=", ">", "<"}
					displayargs = {"=", ">", "<"}
				elseif v.t == "operationselection" then
					dropdown = true
					dropwidth = 2
					args = {"=", "+", "-"}
					displayargs = {"=", "+", "-"}

				elseif v.t == "portalselection" then
					dropdown = true
					dropwidth = 6
					args = {"both","none","1 only","2 only","gel"}
					displayargs = {"both","none","1 only","2 only","gel"}
				
				elseif v.t == "notifyplayer" then
					dropdown = true
					dropwidth = 24
					args = {true, false}
					displayargs = {"notify the player", "don't notify the player"}
				end
				
				if dropdown then
					local j = #self.elements+1
					local starti = 1
					for j, k in pairs(args) do
						if self.t[tid] == k then
							starti = j
						end
					end
					
					temp.gui = guielement:new("dropdown", 0, 0, dropwidth, function(val) self:submenuchange(val, j) end, starti, unpack(args))
					temp.gui.displayentries = displayargs
					temp.width = dropwidth*8+14
					if coloredtext then
						temp.gui.coloredtext = true
					end
				end
			end
			
			table.insert(self.elements, temp)
		end
	end
end

function animationguiline:update(dt)
	for i = 1, #self.elements do
		if self.elements[i].gui then
			self.elements[i].gui:update(dt)
		end
	end
	self.downbutton:update(dt)
	self.upbutton:update(dt)
end

function animationguiline:draw(x, y)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", x*scale, y*scale, (width*16-x)*scale, 11*scale)
	love.graphics.setColor(255, 255, 255)
	
	local xadd = 0
	self.deletebutton.x = x+xadd
	self.deletebutton.y = y
	self.deletebutton:draw()
	xadd = xadd + 10
	
	self.downbutton.x = x+xadd
	self.downbutton.y = y
	self.downbutton:draw()
	xadd = xadd + 10
	
	self.upbutton.x = x+xadd
	self.upbutton.y = y
	self.upbutton:draw()
	xadd = xadd + 12
	
	for i = 1, #self.elements do
		if self.elements[i].t == "text" then
			love.graphics.setColor(255, 255, 255)
			properprintF(self.elements[i].value, (x+xadd-1)*scale, (y+2)*scale)
			xadd = xadd + self.elements[i].width
		else
			if not self.elements[i].gui.extended then
				self.elements[i].gui.x = x+xadd
				self.elements[i].gui.y = y
			end
			if self.elements[i].gui.scrollbar then
				self.elements[i].gui.scrollbar.x = (self.elements[i].gui.width*8+13)+x+xadd
			end
			xadd = xadd + self.elements[i].width
		end
	end
end

function animationguiline:click(x, y, button)
	if self.deletebutton:click(x, y, button) then
		return true
	end
	
	if self.downbutton:click(x, y, button) then
		return true
	end
	
	if self.upbutton:click(x, y, button) then
		return true
	end
	
	local rettrue
	
	local i = 1
	while i <= #self.elements do
		if self.elements[i].gui then
			if self.elements[i].gui:click(x, y, button) then
				rettrue = true
			end
		end
		i = i + 1
	end
	
	return rettrue
end

function animationguiline:unclick(x, y, button)
	self.downbutton:unclick(x, y, button)
	self.upbutton:unclick(x, y, button)

	local i = 1
	while i <= #self.elements do
		if self.elements[i].gui then
			if self.elements[i].gui.unclick then
				self.elements[i].gui:unclick(x, y, button)
			end
		end
		i = i + 1
	end
end

function animationguiline:delete()
	deleteanimationguiline(self.type, self)
end

function animationguiline:moveup()
	moveupanimationguiline(self.type, self)
end

function animationguiline:movedown()
	movedownanimationguiline(self.type, self)
end

function animationguiline:keypressed(key, textinput)
	for i = 1, #self.elements do
		if self.elements[i].gui then
			self.elements[i].gui:keypress(key, textinput)
		end
	end
end

function animationguiline:changemainthing(value)
	local name
	for i, v in pairs(animationlist) do
		if v.nicename == animationstrings[self.type][value] then
			name = i
		end
	end
	self:init({name}, self.type)
end

function animationguiline:submenuchange(value, id)
	self.elements[id].gui.var = value
end

function animationguiline:haspriority()
	for i, v in pairs(self.elements) do
		if v.gui then
			if v.gui.priority then
				return true
			end
		end
	end
	
	return false
end
