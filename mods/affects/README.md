Affects

This adds an API to easily affect players in various ways, both positive and negative.

Depends: whoison ( https://github.com/bremaweb/whoison )
License: WTFPL

Functions

affects.registerAffect( {affect definition} )
affects.affectPlayer(name,affectid)
affects.removeAffect(name,affectid)

Affect Definition

affect = {
			affectid = <unique string id for this affect>,
			name = <string name for this affect>,
			stages = { {stage definition}, {stage definition}, .. },
			onremove = function(name,player,affectid) -- optional function that is ran when the affect is removed
}


Stage Definition
This is where the magic happens. You can define as many stages for an affect as you want. This can be used to gradually decrease the affect or make the affect change over time. The sky is the limit

{
	time = <number of seconds this stage lasts>,
	
	physics = { ... }, 
	optional this is a table as used by set_physics_override  ( https://github.com/minetest/minetest/blob/master/doc/lua_api.txt#L1787 ) to change the physics for a player during this stage
	
	emote = { chance = <Number 1-100>, action = <string> }
	optional chance is the chance out of 100 that action will be displayed in chat as if the affected player had used /me <action>
	
	place = { chance = <number 1-100>, node = <string node that will be placed> },
	optional, chance is the chance out of 100 the player with place the node defined at their current position, node would be a string like "default:dirt"
	
	damage = { chance = <number 1-100>, amount = <number> }
	optional, chance the player will be dealt the amount defined in damage, this could be a negative number and actually result in healing instead of damage
	
	custom { func = function(name, player, affectid), chance = <number 1-100>, runonce = <true/false> }
	optional, a function that you can write to do whatever you want. runonce tells whether this function should only be ran once or not
	
}
	
	
When a player is affected they start at the first stage. The function to apply the affects runs every 30 seconds. Each time it runs it uses what you defined a chance to determine if it should execute that item of the stage. The custom function has a runonce variable, if true the custom function will only run one time for the whole time that stage is in affect. After the player has been online longer than the time in your stage definition they are moved to the next stage, and the affect is applied. After they pass the last stage of the affect the onremove function is called, and the physics are reset, and the affect is removed.
	
It is up to you to write the code to initially apply an affect to a player. That can be done by using an item, digging a node, or executing a chat command. 
	
This depends on the whoison mod for the whoison.getTimeOnline(name) function to know how long a player has been online, to advance the stages after the right amount of time.


