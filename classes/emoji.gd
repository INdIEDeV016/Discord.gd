class_name Emoji extends DiscordDataclass


## Obviously 😑, this is a class for handling Discord Emojis. 😄

## Emoji id.
var id: Snowflake
## Emoji name.
## Keeps the Unicode Character here, the actual Emoji. 😃
var name: String
## Roles allowed to use this emoji.
var roles: Array[Snowflake]
## User that created this emoji.
var user: User
## Whether this emoji must be wrapped in colons.
var require_colons: bool
## Whether this emoji is managed.
var managed: bool
## Whether this emoji is animated.
var animated: bool
## Whether this emoji can be used, may be false due to loss of Server Boosts
var available: bool


func _init(properties: Dictionary):
	for property in properties:
		match property:
			"roles":
#				properties[property] =
				pass
			"user":
				property[properties] = User.new(properties[property])

	super(properties)


## Gets all the emojis from a guild.
static func list_guild_emojis(guild_id: Snowflake):
	var emojis: Array[Emoji] = []
	for emoji in await DiscordBot._send_get("/guilds/{guild.id}/emojis".format({"guild.id" = guild_id.id})):
		emojis.append(Emoji.new(emoji))

	return emojis

## Gets emoji from a guild of the specified [param emoji_id].
func get_guild_emoji(guild_id: Snowflake, emoji_id: Snowflake):
	return Emoji.new(await DiscordBot._send_get("/guilds/{guild.id}/emojis/{emoji.id}".format({"guild.id" = guild_id.id, "emoji.id" = emoji_id.id})))

## Creates an emoji in a guild.
func create_guild_emoji(guild_id: Snowflake, options: Dictionary):
	return Emoji.new(await DiscordBot._send_request("/guilds/{guild.id}/emojis".format(
				{
					"guild.id" = guild_id.id
				}
			),
			options
		)
	)
