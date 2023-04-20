class_name Role extends DiscordDataclass


var id: Snowflake
var name: String
var color: int
var hoist: bool
var icon: String
var unicode_emoji: String
var positions: int
var permissions: String
var managed: bool
var mentionable: bool
var tags: Role_Tags

class Role_Tags extends DiscordDataclass:
	var bot_id: Snowflake
	var integration_id: Snowflake
	var premium_subscriber
