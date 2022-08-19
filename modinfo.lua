-- This information tells other players more about the mod
name = "Glimmer and Family DST"
description = "Glimmer joins the world of Don't Starve Together! \n Perks:\n-[NEW!] Will Spawn Babies when Glommer is around \n-Drops healing item, \"Glimmer Sap\", periodically \n-Craftable Shrine \n-Sanity Aura \n-Sanity Aura \n\nWeaknesses: \n-Slower"
author = "Jaime Nufio aka Code Monkey"
version = "2.4" -- This is the version of the template. Change it to your own number.

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = ""


-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = true
all_clients_require_mod = true -- Character mods need this set to true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = {
"character","follower","Code Monkey","glommer","mob","pet",
}

configuration_options =
{
    {
        name = "rtype",
        label = "Recipe Type",
        options =
        {
            {description = "Newbie", data =		 0.75},
            {description = "Normal", data =			1},
            {description = "Difficult", data =		2},
            {description = "Extra Spicy", data =	3},			
        },
        default = 1,
    },
	{
        name = "gcap",
        label = "Amount of Babies",
        options =
        {
            {description = "A Few", data =		 	 3},
            {description = "Some", data =			 5},
            {description = "Extra", data =			 7},
            {description = "Double Extra", data =	15},	
            {description = "Hella", data =			30},				
        },
        default = 5,
    },
	{
        name = "speed",
        label = "Birth Rates",
        options =
        {
            {description = "Really Fast", data = 		  1/16},
            {description = "Quick", data =				  1/8},
            {description = "Normal", data =			   	  	1/2},
            {description = "Slow", data =				  	1},	
            {description = "Dead Turtle", data =	    	2},				
        },
        default = 1,
    },
	    {
        name = "rdrop",
        label = "Drop Rate",
        options =
        {
            {description = "Very Rare", data =		 5},
            {description = "Kinda Rare", data =		 3},
            {description = "Rare", data =		     2},
            {description = "Common", data =			 1},	
            {description = "Frequent", data =		1/3},				
        },
        default = 1/3,
    },
}