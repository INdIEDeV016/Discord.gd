# Represents a Discord channel
class_name Channel extends DiscordDataclass


enum Channel_Types{
	GUILD_TEXT,
	DM,
	GUILD_VOICE,
	GROUP_DM,
	GUILD_CATEGORY,
	GUILD_NEWS,
	GUILD_NEWS_THREAD = 10,
	GUILD_PUBLIC_THREAD,
	GUILD_PRIVATE_THREAD,
	GUILD_STAGE_VOICE,
	GUILD_DIRECTORY,
	GUILD_FORUM
}

enum Video_Quality_Modes {
	AUTO = 1,
	FULL
}

enum Channel_Flags {
	PINNED = 1 << 1
}

## The id of this channel
var id: Snowflake
##  The type of channel
var type: Channel_Types
## The id of the guild (may be missing for some channel objects received over gateway guild dispatches) `optional`
var guild_id: Snowflake
## Sorting position of the channel `optional`
var position: int
## [Array] of [Overwrite] Explicit permission overwrites for members and roles `optional`
var permission_overwrites: Array
## The name of the channel (1-100 characters) `optional` `nullable`
var name: String
## The channel topic (0-1024 characters) `optional` `nullable`
var topic: String
## Whether the channel is nsfw `optional`
var nsfw: bool
## The id of the last message sent in this channel (or thread channels) `optional` `nullable`
var last_message_id: Snowflake = Snowflake.new()
## The bitrate (in bits) of the voice channel `optional`
var bitrate: int
## The user limit of the voice channel `optional`
var user_limit: int
## Amount of seconds a user has to wait before sending another message (0-21600); bots, as well as users with the permission manage_messages or manage_channel, are unaffected `optional`
var rate_limit_per_user: int
## [Array] of [User] The recipients of the DM `optional`
var recipients: Array[User]
## Icon hash of the group DM `optional` `nullable`
var icon: String
## Id of the creator of the group DM or thread `optional`
var owner_id: Snowflake
## Application id of the group DM creator if it is bot-created `optional`
var application_id: Snowflake
## For guild channels: id of the parent category for a channel (each parent category can contain up to 50 channels), for threads: id of the text channel this thread was created `optional` `nullable`
var parent_id: Snowflake
## [Timestamp] When the last pinned message was pinned `optional` `nullable`
var last_pin_timestamp = null
## Voice region id for the voice channel, automatic when set to null `optional` `nullable`
var rtc_region: String
## The camera video quality mode of the voice channel, 1 when not present `optional`
var video_quality_mode: Video_Quality_Modes
	## An approximate count of messages in a thread, stops counting at 50 `optional`
var message_count: int
## An approximate count of users in a thread, stops counting at 50 `optional`
var member_count: int
## Thread-specific fields not needed by other channels `optional`
var thread_metadata: Thread_Metadata_Object
var member = null # [ThreadMember] Thread member object for the current user, if they have joined the thread, only included on certain API endpoints `optional`
## Default duration that the clients (not the API) will use for newly created threads, in minutes, to automatically archive the thread after recent activity, can be set to: 60, 1440, 4320, 10080 `optional`
var default_auto_archive_duration: int
## Computed permissions for the invoking user in the channel, including overwrites, only included when part of the resolved data received on a slash command interaction `optional`
var permissions: Permissions
var flags = null # [int] Channel flags combined as a bitfield `optional`

## (Undocumented) `optional`
var total_message_sent: int
## [Array] of [String] (Undocumented) `optional`
var member_ids_preview: Array[String]
var available_tags = null # (Undocumented) `optional`
var template = null # (Undocumented) `optional`
var default_reaction_emoji = null # (Undocumented) `optional`
## Included when a thread is created in `THREAD_CREATE`
var newly_created: bool


class Message extends DiscordDataclass:


	enum Types {
		DEFAULT,
		RECIPIENT_ADD,
		RECIPIENT_REMOVE,
		CALL,
		CHANNEL_NAME_CHANGE,
		CHANNEL_ICON_CHANGE,
		CHANNEL_PINNED_MESSAGE,
		USER_JOIN,
		GUILD_BOOST,
		GUILD_BOOST_TIER_1,
		GUILD_BOOST_TIER_2,
		GUILD_BOOST_TIER_3,
		CHANNEL_FOLLOW_ADD,
		GUILD_DISCOVERY_DISQUALIFIED = 14,
		GUILD_DISCOVERY_REQUALIFIED,
		GUILD_DISCOVERY_GRACE_PERIOD_INITIAL_WARNING,
		GUILD_DISCOVERY_GRACE_PERIOD_FINAL_WARNING,
		THREAD_CREATED,
		REPLY,
		CHAT_INPUT_COMMAND,
		THREAD_STARTER_MESSAGE,
		GUILD_INVITE_REMINDER,
		CONTEXT_MENU_COMMAND,
		AUTO_MODERATION_ACTION,
	}


	## Id of the message
	var id: Snowflake
	## Id of the channel the message was sent in
	var channel_id: Snowflake
	## The author of this message (not guaranteed to be a valid user)
	var author: User
	## Contents of the message
	var content: String
	## When this message was sent
	var timestamp: String
	## When this message was edited (or null if never) `nullable`
	var edited_timestamp: String
	## Whether this was a TTS message
	var tts: bool
	## Whether this message mentions everyone
	var mention_everyone: bool
	## [Array] of [User] Users specifically mentioned in the message
	var mentions: Array[User]
	## [Array] of [String] Roles Ids of roles specifically mentioned in this message
	var mention_roles: Array[String]
	## [Array] of [ChannelMention] Channels specifically mentioned in this message `optional`
	var mention_channels: Array
	## [Array] of [Attachment] Any attached files
	var attachments: Array[Attachment_Object]
	## [Array] of [Embed] Any embedded content
	var embeds: Array[Embed]
	## [Array] of [Reaction] Reactions to the message `optional`
	var reactions: Array[Reaction_Object]
	## [int] | [String] Used for validating a message was sent `optional`
	var nonce = null
	## Whether this message is pinned
	var pinned: bool
	## If the message is generated by a webhook, this is the webhook's id `optional`
	var webhook_id: String
	## [MessageTypes] type of message
	var type: int
	## [MessageActivity] Sent with Rich Presence-related chat embeds `optional`
	var activity = null
	## Partial [Application] Sent with Rich Presence-related chat embeds `optional`
	var application = null
	## If the message is an [Interaction] or application-owned webhook, this is the id of the application `optional`
	var application_id: Snowflake
	## Data showing the source of a crosspost, channel follow add, pin, or reply message `optional`
	var message_reference: Message_Reference_Object
	## [MessageFlags] Message flags combined as a bitfield `optional`
	var flags = null
	## The message associated with the message_reference `optional` `nullable`
	var referenced_message: Message
	## [MessageInteraction] Sent if the message is a response to an [Interaction] `optional`
	var interaction = null
	## The thread that was started from this message, includes [ThreadMember] `optional`
	var thread: Channel
	## [Array] of [MessageActionRow] Sent if the message contains components like buttons, action rows, or other interactive components `optional`
	var components = null
	## [Array] of [MessageStickerItem] Sent if the message contains stickers `optional`
	var sticker_items = null
	## [Array] of Sticker (deprecated) The stickers sent with the message `optional`
	var stickers = null


	class Message_Reference_Object extends DiscordDataclass:
		var message_id: Snowflake
		var channel_id: Snowflake
		var guild_id: Snowflake
		var fail_if_not_exists: bool

	class Embed extends DiscordDataclass:
		enum Types {
			rich,
			image,
			video,
			gif,
			article,
			link
		}

		var title: String
		var type: String = 'rich'
		var description: String
		var url: String
		## Timestamp Object
		var timestamp
		var color: int
		var footer: Embed_Footer_Object
		var image: Embed_Image_Object
		var thumbnail: Embed_Thumbnail_Object
		var video: Embed_Video_Object
		var provider: Embed_Provider_Object
		var author: Embed_Author_Object
		var fields: Array[Embed_Field_Object]

		class Embed_Thumbnail_Object extends DiscordDataclass:
			var url: String:
				set(new):
					if Helpers.is_valid_url(new): url = new
			var proxy_url: String:
				set(new):
					if Helpers.is_valid_url(new): proxy_url = new
			var height: int
			var width: int

		class Embed_Video_Object extends DiscordDataclass:
			var url: String:
				set(new):
					if Helpers.is_valid_url(new): url = new
			var proxy_url: String:
				set(new):
					if Helpers.is_valid_url(new): proxy_url = new
			var height: int
			var width: int

		class Embed_Image_Object extends DiscordDataclass:
			var url: String:
				set(new):
					if Helpers.is_valid_url(new): url = new
			var proxy_url: String:
				set(new):
					if Helpers.is_valid_url(new): proxy_url = new
			var height: int
			var width: int

		class Embed_Provider_Object extends DiscordDataclass:
			var name: String
			var url:
				set(new):
					if Helpers.is_valid_url(new): url = new

		class Embed_Author_Object extends DiscordDataclass:
			var name: String
			var url: String:
				set(new):
					if Helpers.is_valid_url(new): url = new
			var icon_url: String:
				set(new):
					if Helpers.is_valid_url(new): icon_url = new
			var proxy_url: String:
				set(new):
					if Helpers.is_valid_url(new): proxy_url = new

		class Embed_Field_Object extends DiscordDataclass:
			var name: String
			var value: String
			var inline: bool

		class Embed_Footer_Object extends DiscordDataclass:
			var text: String
			var url: String:
				set(new):
					if Helpers.is_valid_url(new): url = new
			var proxy_icon_url: String:
				set(new):
					if Helpers.is_valid_url(new): proxy_icon_url = new


	func _init(properties: Dictionary):
		for property in properties:
			if properties[property] == null:
				continue

			match property:
				"author":
					properties[property] = User.new(properties[property])
				"referenced_message":
					properties[property] = Message.new(properties[property])
				"message_reference":
					properties[property] = Message_Reference_Object.new(properties[property])
				"attachments":
#					print_debug(properties.attachments)
					for index in properties.attachments.size():
						properties.attachments[index] = Channel.Attachment_Object.new(properties.attachments[index])
#					print_debug(properties.attachments)
#					breakpoint
				"embeds":
					for index in properties.embeds.size():
						properties.embeds[index] = Channel.Message.Embed.new(properties.embeds[index])
				"mentions":
					for index in properties.mentions.size():
						properties.mentions[index] = User.new(properties.mentions[index])

		super(properties)

class Followed_Channel_Object extends DiscordDataclass:
	var channel_id: Snowflake
	var webhook_id: Snowflake

class Reaction_Object extends DiscordDataclass:
	var count: int
	var me: bool
	## Emoji Object
	var emoji

class Overite_Object extends DiscordDataclass:
	enum Type {
		ROLE = 0,
		MEMBER
	}

	var id: Snowflake
	var type: Overite_Object.Type
	var allow: String
	var deny: String

class Thread_Metadata_Object extends DiscordDataclass:
	var archived: bool
	var auto_archive_duration: int
	## Timestamp Object
	var archive_timestamp
	var locked: bool
	var invitable: bool
	## Timestamp Object
	var create_timestamp

class Thread_Member_Object extends DiscordDataclass:
	var id: Snowflake
	var user_id: Snowflake
	## Timestamp Object
	var join_timestamps
	var flags: int

class Attachment_Object extends DiscordDataclass:
	var id: Snowflake
	var filename: String
	var description: String
	var content_type: String
	var size: int
	var url: String:
		set(new):
			if Helpers.is_valid_url(new): url = new
	var proxy_url: String:
		set(new):
			if Helpers.is_valid_url(new): proxy_url = new
	var height: int
	var width: int
	var ephemeral: bool

	func _init(properties: Dictionary) -> void:
		super(properties)

class Allowed_Mentions_Object:
	var types: = {
		"Role" = "role",
		"User" = "user",
		"Everyone" = "everyone"
	}

	var parse: Array[String]
	var roles: Array[Snowflake]
	var users: Array[Snowflake]
	var replied_user: bool

func _init(properties: Dictionary = {}) -> void:
	for property in properties:
		if properties[property] == null:
				continue

		match property:
			"thread_metadata":
				properties[property] = Thread_Metadata_Object.new(properties[property])
	super(properties)

static func get_channel(_id: Snowflake):
	var channel: Dictionary = await DiscordBot._send_get("/channels/{channel.id}".format({"channel.id" = _id.id}))
	return Channel.new(channel)


static func modify_channel(channel: Channel, options: Dictionary):
	DiscordBot._send_request("/channels/{channel.id}".format({"channel.id" = channel.id.id,}), options, HTTPClient.METHOD_PATCH)


func delete_channel(channel: Channel = self):
	DiscordBot._send_get("/channels/{channel.id}".format({"channel.id" = channel.id.id}), HTTPClient.METHOD_DELETE)

func get_channel_messages(
	option: = {
#		around = Snowflake.new(),
		before = last_message_id if last_message_id.id else Snowflake.new(),
#		after = Snowflake.new(),
		},
		limit: int = 100,
	_id: Snowflake = id,
	):
	if option.has("before") and option.before.id == last_message_id.id and last_message_id.id == null:
		return []

	var data = await DiscordBot._send_get("/channels/{channel.id}/messages?{option}={option.value}&limit={limit}".format(
		{
			"channel.id" = _id.id,
			"limit" = limit,
			"option" = option.keys()[0],
			"option.value" = option.values()[0].id
		}
	))
	# Using `data` variable for debugging and checking errors
	var messages_array: Array[Dictionary] = data
	var array: Array[Message] = []
	for message in messages_array:
		array.append(Message.new(message))

	array.push_front(await get_channel_message(Snowflake.new(option.values()[0].id)))
#	print_debug(array[0].content, " <||> ", array[1].content)
	return array


## Get a channel by ID. Returns a channel object. If the channel is a thread, a thread member object is included in the returned result.
func get_channel_message(message_id: Snowflake = last_message_id) -> Channel.Message:
	var message: Dictionary = {}
	if message_id.id != null:
		message = await DiscordBot._send_get("/channels/{channel.id}/messages/{message.id}".format({"channel.id" = id.id, "message.id" = message_id.id}))
	#	Helpers.print_dict(message)
	return Channel.Message.new(message)

##Post a message to a guild text or DM channel. Returns a message object. Fires a Message Create Gateway event. See message formatting for more information on how to properly format messages.
##To create a message as a reply to another message, apps can include a [member Channel.Message.message_reference] with a [member Channel.Message.id]. The [member Channel.Message.Message_Reference_Object.channel_id] and [member Channel.Message.Message_Reference_Object.guild_id] in the [Channel.Message.Message_Reference_Object] are optional, but will be validated if provided.
##[br][br]
##[b][u]Note:[/u][/b] Discord may strip certain characters from message content, like invalid unicode characters or characters which cause unexpected message formatting. If you are passing user-generated strings into message content, consider sanitizing the data to prevent unexpected behavior and utilizing allowed_mentions to prevent unexpected mentions.
##[br][br]
##Files must be attached using a [code]multipart/form-data[/code] body as described in [b][url=https://discord.com/developers/docs/reference#uploading-files]Uploading Files[/url][/b].
##[br][br]
##[b]Limitations[/b]
##[br][br]
##[ul]
##[br]When operating on a guild channel, the current user must have the [code]SEND_MESSAGES[/code] permission.
##[br]When sending a message with tts (text-to-speech) set to true, the current user must have the [code]SEND_TTS_MESSAGES[/code] permission.
##[br]When creating a message as a reply to another message, the current user must have the [code]READ_MESSAGE_HISTORY[/code] permission.
##[br]The referenced message must exist and cannot be a system message.
##[br]     The maximum request size when sending a message is 8MiB.
##[br]For the embed object, you can set every field except type (it will be rich regardless of if you try to set it), provider, video, and any height, width, or proxy_url values for images.
##[br][/ul]
##[br][br]
##[b]JSON/Form Params[/b]
##[br][br]
##[u][b]Note:[/b] When creating a message, apps must provide a value for at least one of content, embeds, sticker_ids, or files[n].[/u]
##[br][br]
##[table]
##[codeblock]
##+-------------------------+-----------------------------------------+--------------------------------------------------------------------------------------------------------+
##|           FIELD         |                   TYPE                  |                      DESCRIPTION                                                                       |
##+-------------------------+-----------------------------------------+--------------------------------------------------------------------------------------------------------+
##|  content?*              |    string                               |    Message contents (up to 2000 characters)                                                            |
##|  tts?                   |    boolean                              |    true if this is a TTS message                                                                       |
##|  embeds?*               |    array of embed objects               |    Embedded rich content (up to 6000 characters)                                                       |
##|  allowed_mentions?      |    allowed mention object               |    Allowed mentions for the message                                                                    |
##|  message_reference?     |    message reference                    |    Include to make your message a reply                                                                |
##|  components?            |    array of message component objects   |    Components to include with the message                                                              |
##|  sticker_ids?*          |    array of snowflakes                  |    IDs of up to 3 stickers in the server to send in the message                                        |
##|  files[n]?*             |    file contents                        |    Contents of the file being sent. See Uploading Files                                                |
##|  payload_json?          |    string                               |    JSON-encoded body of non-file params, only for multipart/form-data requests. See Uploading Files    |
##|  attachments?           |    array of partial attachment objects  |    Attachment objects with filename and description. See Uploading Files                               |
##|  flags?                 |    integer                              |    Message flags combined as a bitfield (only SUPPRESS_EMBEDS can be set)                              |
##+-------------------------+-----------------------------------------+--------------------------------------------------------------------------------------------------------+
##* At least one of content, embeds, sticker_ids, or files[n] is required.
##[/codeblock]
##[/table]
##[br][br]
##[b]Example Request Body (application/json)[/b]
##[codeblock]
##{
##  "content": "Hello, World!",
##  "tts": false,
##  "embeds": [
##     {
##     "title": "Hello, Embed!",
##     "description": "This is an embedded message."
##     }
##  ]
##}
##[/codeblock]
##[br][br]
##Examples for file uploads are available in [b][url=https://discord.com/developers/docs/reference#uploading-files]Uploading Files[/url][/b].
func create_message(options: Dictionary = {content = ""}) -> Channel.Message:
	return await DiscordBot.send(id.id, options.get("content"), options)


func crosspost_message(message: Channel.Message) -> Channel.Message:
	return Message.new(await DiscordBot._send_get("/channels/{channel.id}/messages/{message.id}/crosspost".format(
		{
			"channel.id" = id.id,
			"message.id" = message.id,
		}
	)))


func create_reaction(message: Channel.Message, emoji: Emoji):
	return Message.new(await DiscordBot._send_get("/channels/{channel.id}/messages/{message.id}/reactions/{emoji}/@me".format(
		{
			"channel.id" = id.id,
			"message.id" = message.id,
			"emoji" = emoji.to_dict(),
		}
	)))


static func edit_message(message: Channel.Message, options: Dictionary = {content = ""}) -> Channel.Message:
	return await DiscordBot.edit(message, options.content, options)


static func delete_message(message: Channel.Message):
	DiscordBot.delete(message)


func delete_messages(amount: int = 100, option: Dictionary = {before = last_message_id}):
	var main: Callable = func main_function(_amount: int):
		var messages_array = await DiscordBot._send_get("/channels/{channel.id}/messages?{option}={option.value}&limit={limit}".format(
			{
				"channel.id" = id.id,
				"option" = option.keys()[0],
				"option.value" = option.values()[0].id,
				"limit" = clampi(_amount, 2, 100),
			}
		))

		var snowflake_array: Array[String] = []
		snowflake_array.append(option.values()[0].id)
		if messages_array is Array: for message in messages_array:
			if message is Dictionary: if message.has("id"):
				snowflake_array.append(message.id)

		if snowflake_array.size() > 100:
			snowflake_array.resize(100)

		DiscordBot._send_request("/channels/{channel.id}/messages/bulk-delete".format({"channel.id" = id.id}), {messages = snowflake_array})

	if amount > 100:
		for index in int(amount / 100.0):
			await main.call(100)

		if int(amount % 100) != 0:
			await main.call(int(amount % 100))
	else:
		await main.call(int(amount))
