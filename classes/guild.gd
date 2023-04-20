# Represents a Discord Guild
class_name Guild extends DiscordDataclass


enum Default_Message_Notification_Level {
	ALL_MESSAGES,
	ONLY_MENTIONS
}

enum Explicit_Content_Filter {
	DISABLED,
	MEMBER_WITHOUT_ROLES,
	ALL_MEMBERS
}

enum MFA_Level {
	NONE,
	ELEVATED
}

enum Guild_NSFW_Level {
	DEFAULT,
	EXPLICIT,
	SAFE,
	AGE_RESTRICTED
}

enum Premium_Tier {
	NONE,
	TIER_1,
	TIER_2,
	TIER_3
}

enum System_Channel_Flags {
	SUPPRESS_JOIN_NOTIFICATIONS = 1 << 0,
	SUPPRESS_PREMIUM_SUBSCRIPTIONS = 1 << 1,
	SUPPRESS_GUILD_REMINDER_NOTIFICATIONS = 1 << 2,
	SUPPRESS_JOIN_NOTIFICATION_REPLIES = 1 << 3
}

#class Guild_Features:
#	var ANIMATED_BANNER: bool
#	var ANIMATED_ICON: bool
#	var AUTO_MODERATION: bool
#	var BANNER: bool
#	var COMMUNITY: bool
#	var DISCOVERABLE: bool
#	var FEATURABLE: bool
#	var INVITE_SPLASH: bool
#	var MEMBER_VERIFICATION_GATE_ENABLED: bool
#	var MONETIZATION_ENABLED: bool
#	var MORE_STICKERS: bool
#	var NEWS: bool
#	var PARTNERED: bool
#	var PREVIEW_ENABLED: bool
#	var PRIVATE_THREADS: bool
#	var ROLE_ICONS: bool
#	var TICKETED_EVENTS_ENABLED: bool
#	var VANITY_URL: bool
#	var VERIFIED: bool
#	var VIP_REGIONS: bool
#	var WELCOME_SCREEN_ENABLED: bool


## Guild id
var id: Snowflake
## Guild name (2-100 characters, excluding trailing and leading whitespace)
var name: String
## Icon hash `nullable`
var icon: String = ""
## Icon hash, returned when in the template object `optional` `nullable`
var icon_hash: String = ""
## Splash hash `nullable`
var splash: String = ""
## Discovery splash hash; only present for guilds with the `DISCOVERABLE` feature `nullable`
var discovery_splash: String = ""
## True if the user is the owner of the guild `optional`
var owner: bool = false
## Id of owner
var owner_id: String
## Total permissions for the user in the guild (excludes overwrites) `optional`
var permissions: Permissions = null
## [i](Deprecated: Use [member Channel.rtc_region] instead)[/i] Voice region id for the guild `optional` `nullable`
var region: String = ""
## Id of afk channel `nullable`
var afk_channel_id: Snowflake
## Afk timeout in seconds
var afk_timeout: int
## True if the server widget is enabled `optional`
var widget_enabled: bool = false
## The channel id that the widget will generate an invite to, or null if set to no invite `optional` `nullable`
var widget_channel_id: String = ""
## [GuildVerificationLevel] Verification level required for the guild
var verification_level: int
## [DefaultMessageNotificationLevel] Default message notifications level
var default_message_notifications: int
## Explicit content filter level
var explicit_content_filter: Explicit_Content_Filter
## [Array] of [Role] Roles in the guild
var roles: Array[Role]
## [Array] of [Emoji] Custom guild emojis
var emojis: Array
## Enabled guild features
var features: Array[String]
## Required MFA level for the guild
var mfa_level: MFA_Level
## Application id of the guild creator if it is bot-created `nullable`
var application_id: Snowflake
## The id of the channel where guild notices such as welcome messages and boost events are posted `nullable`
var system_channel_id: Snowflake
## System channel flags
var system_channel_flags: System_Channel_Flags
## The id of the channel where Community guilds can display rules and/or guidelines `nullable`
var rules_channel_id: Snowflake
## The maximum number of presences for the guild (null is always returned, apart from the largest of guilds) `optional` `nullable`
var max_presences: int
## The maximum number of members for the guild `optional`
var max_members: int
## The vanity url code for the guild `nullable`
var vanity_url_code: String = ""
## The description of a guild `nullable`
var description: String = ""
## Banner hash `nullable`
var banner: String = ""
## Server Boost level
var premium_tier: int
## The number of boosts this guild currently has `optional`
var premium_subscription_count: int
## The preferred locale of a Community guild; used in server discovery and notices from Discord, and sent in interactions; defaults to "en-US"
var preferred_locale: String
## The id of the channel where admins and moderators of Community guilds receive notices from Discord `nullable`
var public_updates_channel_id: Snowflake
## The maximum amount of users in a video channel `optional`
var max_video_channel_users: int
## Approximate number of members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true `optional`
var approximate_member_count: int
## Approximate number of non-offline members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true `optional`
var approximate_presence_count: int
## [WelcomeScreen] The welcome screen of a Community guild, shown to new members, returned in an Invite's guild object `optional`
var welcome_screen: Welcome_Screen
## (Undocumented)
var nsfw = null
## Guild NSFW Level
var nsfw_level: Guild_NSFW_Level
## Array of [Sticker] Custom guild stickers `optional`
var stickers: Array
## Whether the guild has the boost progress bar enabled
var premium_progress_bar_enabled: bool

# The following fields are only set in `GUILD_CREATE` event
## When this guild was joined at
var joined_at: String
## True if this is considered a large guild
var large: bool
## True if this guild is unavailable due to an outage
var unavailable: bool
## Total number of members in this guild
var member_count: int
## Array of partial [VoiceState] States of members currently in voice channels; lacks the `guild_id` key
var voice_states: Array
## Array of [GuildMember] Users in the guild
var members: Array
## Array of [Channel] Channels in the guild
var channels: Array[Channel]
## Array of [Channel] All active threads in the guild that current user has permission to view
var threads: Array
## Array of partial [PresenceUpdateEvent] Presences of the members in the guild, will only include non-offline members if the size is greater than large threshold
var presences: Array
## Array of [StageInstance] Stage instances in the guild
var stage_instances: Array
## Array of [GuildScheduledEvent] The scheduled events in the guild
var guild_scheduled_events: Array

## (Undocumented) `optional`
var hub_type = null
## (Undocumented) `optional`
var flags = null


class Guild_Widget_Settings_Object extends DiscordDataclass:
	var enabled: bool
	var channel_id: Snowflake

class Guild_Widget_Object extends DiscordDataclass:
	var id: Snowflake
	var name: String
	var instant_invite: String
	var channels: Array
	var members: Array[User]
	var presence_count: int

class Guild_Preview_Object extends DiscordDataclass:
	var id
	var name
	var icon
	var splash
	var discovery_splash
	var emojis
	var features
	var approximate_member_count
	var approximate_presence_count
	var description
	var stickers

class Guild_Member_Object extends DiscordDataclass:
	var user: User
	var nick: String
	var avatar: String
	var roles: Array[Snowflake]
	## ISO Timestamp Object
	var joined_at
	## ISO Timestamp Object
	var premium_since
	var deaf: bool
	var mute: bool
	var pending: bool
	var permissions: String
	## ISO Timestamp Object
	var communication_disable_until

	func _init(properties) -> void:
		if properties is Dictionary:
			if properties.has("user") and properties.user:
				properties.user = User.new(properties.user)
			if properties.has("roles") and properties.roles:
				var _roles: Array[Snowflake] = []
				for role in properties.roles:
					_roles.append(Snowflake.new(role))
				properties.roles = _roles
			if properties.has("channels") and properties.channels:
				for index in properties.channels.size():
					properties.channels[index] = Channel.new(properties.channels[index])
		super(properties)

class Integration_Object extends DiscordDataclass:
	enum Integration_Expire_Behaviour {
		Remove_Role,
		Kick
	}

	var id: Snowflake
	var name: String
	## Twitch, YouTube or Discord
	var type: String
	var enabled: bool
	var syncing: bool
	var role_id: Snowflake
	var enabled_emoticons: bool
	var expire_behaviour: Integration_Expire_Behaviour
	var expire_grace_period: int
	var user: User
	var account: Integration_Account_Object
	## Timestamp Object
	var synced_at
	var subscriber_count: int
	var revoked: bool
	var application: Integration_Application_Object

class Integration_Account_Object extends DiscordDataclass:
	var id: Snowflake
	var name: String

class Integration_Application_Object extends DiscordDataclass:
	var id: Snowflake
	var name: String
	var icon: String
	var description: String
	var bot: User

class Ban_Object extends DiscordDataclass:
	var reason: String
	var user: User

	func _init(properties) -> void:
		if properties is Dictionary:
			if properties.has("user") and properties.user:
				properties.user = User.new(properties.user)
		super(properties)

class Welcome_Screen extends DiscordDataclass:
	var description: String
	var welcome_channels: Array[Welcome_Screen_Channel]

	func _init(properties):
		if properties is Dictionary:
			if properties.has("welcome_channels") and properties.welcome_channels:
				var array: Array[Welcome_Screen_Channel] = []
				for welcome_screen_channel in properties.welcome_channels:
					array.append(Welcome_Screen_Channel.new(welcome_screen_channel))
				properties.welcome_channels = array
		super(properties)

class Welcome_Screen_Channel extends DiscordDataclass:
	var channel_id: Snowflake
	var description: String
	var emoji_id: Snowflake
	var emoji_name: String


func _init(properties) -> void:
	if properties.has("roles") and properties.roles:
		var role_array: Array[Role] = []
		for role_dict in properties.roles:
			role_array.append(Role.new(role_dict))
		properties.roles = role_array
	super(properties)


static func create_guild(options: = {}) -> Guild:
	var guild: Dictionary = await DiscordBot._send_request("/guilds", options)
	return Guild.new(guild)


static func get_guild(_id: Snowflake, with_counts: bool = true) -> Guild:
	var guild: Dictionary = await DiscordBot._send_get("/guilds/{guild.id}?with_counts={counts}".format(
		{
			"guild.id" = _id.id,
			counts = with_counts
		}
	))
	return Guild.new(guild)


static func get_guild_preview(_id: Snowflake) -> Object:
	return Guild.Guild_Preview_Object.new(await DiscordBot._send_get("/guilds/{guild.id}/preview".format({"guild.id" = _id.id})))


func modify_guild(options: Dictionary, _id: Snowflake = id) -> Guild:
	return Guild.new(await DiscordBot._send_request("/guilds/{guild.id}".format({"guild.id" = _id.id}), options, HTTPClient.METHOD_PATCH))


func delete_guild(_id: Snowflake = id) -> void:
	DiscordBot._send_get("/guilds/{guild.id}".format({"guild.id" = _id.id}), HTTPClient.METHOD_DELETE)


func get_guild_channels(_id: Snowflake = id) -> Array[Channel]:
	var array = await DiscordBot._send_get("/guilds/{guild.id}/channels".format({"guild.id" = _id.id}))
	print_debug(array)
	var channel_array: Array[Channel] = []
	for channel_dict in array:
		channel_array.append(Channel.new(channel_dict))
	return channel_array


func create_guild_channel(options: Dictionary = {name = "New Channel"}, _id: Snowflake = id) -> Channel:
	return Channel.new(await DiscordBot._send_request("/guilds/{guild.id}/channels".format({"guild.id" = _id.id}), options))


func modify_guild_channel_positions(options: Dictionary, _id: Snowflake = id) -> void:
	DiscordBot._send_request("/guilds/{guild.id}/channels".format({"guild.id" = _id.id}), options)


func list_active_threads(_id: Snowflake = id) -> Dictionary:
	var data: Dictionary = await DiscordBot._send_get("/guilds/{guild.id}/threads/active".format({"guild.id" = _id.id}))

	for index in data.members.size():
		data.members[index] = Channel.Thread_Member_Object.new(data.members[index])

	for index in data.threads.size():
		data.threads[index] = Channel.new(data.threads[index])

	return data


func get_guild_member(user_id: Snowflake, _id: Snowflake = id) -> Guild_Member_Object:
	return Guild.Guild_Member_Object.new(await DiscordBot._send_get("/guilds/{guild.id}/members/{user.id}".format({"guild.id" = _id.id, "user.id" = user_id.id})))


func list_guild_members(_id: Snowflake = id, options: Dictionary = {limit = 1000}) -> Array[Guild_Member_Object]:
	var member_array: Array[Dictionary] = await DiscordBot._send_get(
		"/guilds/{guild.id}/members?limit={limit}".format({
			"guild.id" = _id.id,
			"limit" = options.limit,
			"after" = options.after if options.has("after") and options.after else 0
		})
	)
	var _members: Array[Guild_Member_Object] = []
	for member_dict in member_array:
		_members.append(Guild_Member_Object.new(member_dict))
	return _members


func search_guild_member(query: String, limit: = 1000) -> Array[Guild.Guild_Member_Object]:
	var array: Array = await DiscordBot._send_get("/guilds/{guild.id}/members/search?query={query}&limit={limit}".format({"guild.id" = id.id, "query" = query, "limit" = limit}))
	for index in array.size():
		array[index] = Guild_Member_Object.new(array[index])
	return array

#func add_guild_member():
#	pass

func modify_guild_member(user_id: Snowflake, options: Dictionary = {}) -> Guild.Guild_Member_Object:
	return Guild_Member_Object.new(await DiscordBot._send_request("/guilds/{guild.id}/members/{user.id}".format({"guild.id" = id.id, "user.id" = user_id.id}), options, HTTPClient.METHOD_PATCH))


func modify_current_member(nick: String) -> Guild_Member_Object:
	return Guild_Member_Object.new(await DiscordBot._send_request("/guilds/{guild.id}/members/@me".format({"guild.id" = id.id}), {"nick" = nick}, HTTPClient.METHOD_PATCH))

## [i]Depracated[/i] Use [method modify_current_member] instead.
func modify_current_member_nick(nick: String) -> Guild_Member_Object:
	return await modify_current_member(nick)


func add_guild_member_role(user_id: Snowflake, role_id: Snowflake):
	DiscordBot._send_get("/guilds/{guild.id}/members/{user.id}/roles/{role.id}".format({"guild.id" = id.id, "user.id" = user_id.id, "role.id" = role_id.id}), HTTPClient.METHOD_PUT)

func remove_guild_member_role(user_id: Snowflake, role_id: Snowflake):
	DiscordBot._send_get("/guilds/{guild.id}/members/{user.id}/roles/{role.id}".format({"guild.id" = id.id, "user.id" = user_id.id, "role.id" = role_id.id}), HTTPClient.METHOD_DELETE)


func remove_guild_member(user_id: Snowflake):
	DiscordBot._send_get("/guilds/{guild.id}/members/{user.id}".format({"guild.id" = id.id, "user.id" = user_id.id}), HTTPClient.METHOD_DELETE)
