_G = GLOBAL
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH
local require = GLOBAL.require
require "behaviours/doaction"

local rec = GetModConfigData("rtype")

PrefabFiles = {
"glimmer","glimmerflower","glimmerfuel","statueglimmer","babbyglimmer","babbyglommer"
}

Assets = {

	Asset("ATLAS", "images/inventoryimages/statueglimmer.xml"),
    Asset("IMAGE", "images/inventoryimages/statueglimmer.tex"),
}


GLOBAL.STRINGS.NAMES.STATUEGLIMMER = "Glimmer Statue"
STRINGS.RECIPE_DESC.STATUEGLIMMER = "About time Glommer gets a buddy."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.STATUEGLIMMER = "Now where, oh where, is Glimmer?"
	
GLOBAL.STRINGS.NAMES.GLIMMERFLOWER = "Glimmer's Flower"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GLIMMERFLOWER = "Why is it blue?"
	
GLOBAL.STRINGS.NAMES.GLIMMERFUEL = "Glimmer's Sap"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GLIMMERFUEL = "I bet it tastes like really sweet!"
	
GLOBAL.STRINGS.NAMES.GLIMMER = "Glimmer"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GLIMMER = "She's ploofy, like cotton candy!"

GLOBAL.STRINGS.NAMES.BABBYGLIMMER = "Lil' Babby Glimmer"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.BABBYGLIMMER = "Look at the wee lil'babby!"

GLOBAL.STRINGS.NAMES.BABBYGLOMMER = "The Wee Lad Babby Glommer"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.BABBYGLOMMER = "Look, he thinks he's a grown up!"
	
--statueglimmer = GLOBAL.Recipe("statueglimmer",{Ingredient("rocks", 20),Ingredient("reviver", 1),Ingredient("nightmarefuel",4) }, RECIPETABS.MAGIC, TECH.NONE, "statueglimmer_placer" ) 

if rec == 0.75 then
	local statueglimmer = AddRecipe("statueglimmer",{Ingredient("rocks", 60),Ingredient("butterfly", 3),Ingredient("nightmarefuel",2) }, RECIPETABS.MAGIC, TECH.NONE, "statueglimmer_placer" ) 
	statueglimmer.atlas = "images/inventoryimages/statueglimmer.xml"
elseif rec == 1 then
	local statueglimmer = AddRecipe("statueglimmer",{Ingredient("rocks", 20),Ingredient("reviver", 1),Ingredient("nightmarefuel",4) }, RECIPETABS.MAGIC, TECH.NONE, "statueglimmer_placer" ) 
	statueglimmer.atlas = "images/inventoryimages/statueglimmer.xml"
elseif rec == 2 then
	local statueglimmer = AddRecipe("statueglimmer",{Ingredient("marble", 10),Ingredient("redgem", 3),Ingredient("nightmarefuel",6) }, RECIPETABS.MAGIC, TECH.NONE, "statueglimmer_placer" ) 
	statueglimmer.atlas = "images/inventoryimages/statueglimmer.xml"
elseif rec == 3 then	
	local statueglimmer = AddRecipe("statueglimmer",{Ingredient("marble", 15),Ingredient("purplegem", 1),Ingredient("nightmarefuel",12) }, RECIPETABS.MAGIC, TECH.NONE, "statueglimmer_placer" ) 
	statueglimmer.atlas = "images/inventoryimages/statueglimmer.xml"
end




