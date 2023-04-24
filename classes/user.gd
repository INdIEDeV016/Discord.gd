class_name User extends DiscordDataclass

##Represents a Discord User.

enum User_Flags {
	STAFF = 1 << 0,
	PARTNER = 1 << 1,
	HYPESQUAD = 1 << 2,
	BUG_HUNTER_LEVEL_1 = 1 << 3,
	HYPESQUAD_ONLINE_HOUSE_1 = 1 << 6,
	HYPESQUAD_ONLINE_HOUSE_2 = 1 << 7,
	HYPESQUAD_ONLINE_HOUSE_3 = 1 << 8,
	PREMIUM_EARLY_SUPPORTER = 1 << 9,
	TEAM_PSEUDO_USER = 1 << 10,
	BUG_HUNTER_LEVEL_2 = 1 << 14,
	VERIFIED_BOT = 1 << 16,
	VERIFIED_DEVELOPER = 1 << 17,
	CERTIFIED_MODERATOR = 1 << 18,
	BOT_HTTP_INTERACTIONS = 1 << 19
}

enum Premium_Types {
	NONE,
	NITRO_CLASSIC,
	NITRO
}

const AVATAR_URL_FORMATS = ['webp', 'png', 'jpg', 'jpeg', 'gif']
const AVATAR_URL_SIZES = [16, 32, 64, 128, 256, 512, 1024, 2048, 4096]

var id: Snowflake
var username: String
var discriminator: String
var avatar: String

# Optional
var bot: bool
var system: bool
var mfa_enabled: bool
var locale: String
var verified: bool
var email: String
var flags: User_Flags
var premium_type: Premium_Types
var public_flags: User_Flags


class Connection extends DiscordDataclass:

	enum Visibility_Types {
		None,
		Everyone
	}

	var id: String
	var name: String
	var type: int
	var revoked: bool
	var integrations: Array[Guild.Integration_Object]
	var verified: bool
	var friend_sync: bool
	var show_activity: bool
	var visibility: Visibility_Types

## [codeblock]
##    options {
##        format: [String], one of webp, png, jpg, jpeg, gif (default png),
##        size: [int], one of 16, 32, 64, 128, 256, 512, 1024, 2048, 4096 (default 256),
##        dynamic: [bool], if true the format will automatically change to gif for animated avatars (default false)
##    }
## [/codeblock]


func _init(user):
	if user is User:
		return

	super(user)
#	# Compulsory
#	assert(user.has('id'), 'User must have an id')
#	assert(user.has('username'), 'User must have a username')
#	assert(user.has('discriminator'), 'User must have a discriminator')
#
#
#	id = Snowflake.new(user.id)
#	username = user.username
#	discriminator = user.discriminator
#	if user.avatar:
#		avatar = user.avatar
#
#	# Optional
#
#	if user.has('bot') and user.bot != null:
#		assert(typeof(user.bot) == TYPE_BOOL, 'bot attribute of User must be bool')
#		bot = user.bot
#	else:
#		bot = false
#
#	if user.has('system') and user.system != null:
#		assert(typeof(user.system) == TYPE_BOOL, 'system attribute of User must be bool')
#		system = user.system
#	else:
#		system = false
#
#	if user.has('mfa_enabled') and user.mfa_enabled != null:
#		assert(typeof(user.mfa_enabled) == TYPE_BOOL, 'mfa_enabled attribute of User must be bool')
#		mfa_enabled = user.mfa_enabled
#	else:
#		mfa_enabled = false
#
#	if user.has('verified') and user.verified != null:
#		assert(typeof(user.verified) == TYPE_BOOL, 'verified attribute of User must be bool')
#		verified = user.verified
#	else:
#		verified = false
#
#	if user.has('locale') and user.locale != null:
#		assert(typeof(user.locale) == TYPE_STRING, 'locale attribute of User must be String')
#		locale = user.locale
#
#	if user.has('email') and user.email != null:
#		assert(typeof(user.email) == TYPE_STRING, 'email attribute of User must be String')
#		email = user.email
#
#	if user.has('flags') and user.flags != null:
#		assert(DiscordHelpers.is_num(user.flags), 'flags attribute of User must be int')
#		flags = user.flags
#
#	if user.has('premium_type') and user.premium_type != null:
#		assert(DiscordHelpers.is_num(user.premium), 'premium_type attribute of User must be int')
#		premium_type = user.premium_type
#
#	if user.has('public_flags') and user.public_flags != null:
#		assert(DiscordHelpers.is_num(user.public_flags), 'public_flags attribute of User must be int')
#		public_flags = user.public_flags


static func get_current_user() -> User:
	return User.new(await DiscordBot._send_get("/users/@me"))


static func get_user(_id: Snowflake) -> User:
	return User.new(await DiscordBot._send_get("/users/{user.id}".format({"user.id" = _id.id})))


static func modify_current_user(options: Dictionary) -> User:
	return User.new(await DiscordBot._send_request("/users/@me", options))


func get_current_user_guilds() -> Array[Guild]:
	var array = await DiscordBot._send_get("/users/@me/guilds")
	var guild_array: Array[Guild] = []
	for item in array:
		guild_array.append(Guild.new(item))
	return guild_array


static func get_current_user_guild_member(_id: Snowflake) -> Guild.Guild_Member_Object:
	return Guild.Guild_Member_Object.new(await DiscordBot._send_get("/users/@me/guilds/{guild.id}/member".format({"guild.id" = _id.id})))


func leave_guild(_id: Snowflake):
	DiscordBot._send_get("/users/@me/guilds/{guild.id}".format({"guild.id" = _id.id}), HTTPClient.METHOD_DELETE)


static func create_dm(recipient_id: Snowflake):
	return Channel.new(await DiscordBot._send_request("/users/@me/channels", {"recipient_id" = recipient_id}))


static func create_group_dm(options: Dictionary):
	return Channel.new(await DiscordBot._send_request("/users/@me/channels", options))


func _get_display_avatar_url(options: Dictionary = {}, _id: Snowflake = id, _avatar: String = avatar) -> String:

	if options.has('format'):
		assert(options.format in AVATAR_URL_FORMATS, 'Invalid avatar_url provided to get_display_avatar')
	else:
		options.format = 'png'

	if options.has('size'):
		assert(int(options.size) in AVATAR_URL_SIZES, 'Invalid size provided to get_display_avatar')
	else:
		options.size = 256

	if options.has('dynamic'):
		assert(typeof(options.dynamic) == TYPE_BOOL, 'dynamic attribute must be of type bool in get_display_avatar')
		if DiscordHelpers.is_valid_str(_avatar) and _avatar.begins_with('a_'):
			options.format = 'gif'
	else:
		options.dynamic = false

	if _avatar.is_empty() or _avatar == null:
		return _get_default_avatar_url()
#	print_debug(options)
	return DiscordBot._cdn_base + '/avatars/%s/%s.%s?size=%s' % [_id.id, _avatar, options.format, options.size]


func _get_default_avatar_url() -> String:
	return DiscordBot._cdn_base + '/embed/avatars/%s.png' % [discriminator.to_int() % 5]


func get_display_avatar(options: Dictionary = {size = 32}) -> ImageTexture:
	var _avatar: = avatar
	if not options.has("format") or not options.format:
		options.format = "png"

	var d: = DirAccess.open(DiscordBot.cache_path.image)
	if not d:
		var d_err: = d.make_dir_recursive(DiscordBot.cache_path.image)
		if d_err != OK:
			push_error("Could not create the directory! ", error_string(d_err))

#	if _avatar.is_empty():
#		_avatar = avatar
	if d.file_exists(DiscordBot.cache_path.image + "%s_%s.%s" % [_avatar, options.size, options.format]):
		if _avatar.is_empty():
			_avatar = discriminator

		return DiscordHelpers.to_image_texture(Image.load_from_file(DiscordBot.cache_path.image + "%s_%s.%s" % [_avatar, options.size, options.format]))

#	print_debug(user_id, " ", avatar, " ", get_display_avatar_url(options, user_id, _avatar))
	var image: Image = DiscordHelpers.new().call(StringName("to_%s_image" % options.format), await DiscordBot._send_get_cdn(_get_display_avatar_url(options, id, avatar)))

	if _avatar.is_empty():
		_avatar = discriminator

	var image_err: int
	if _avatar != discriminator:
		image_err = image.call(StringName("save_%s" % options.format), DiscordBot.cache_path.image + "%s_%s.%s" % [_avatar, options.size, options.format])
	else:
		image_err = image.call(StringName("save_%s" % options.format), DiscordBot.cache_path.image + "%s.%s" % [_avatar, options.format])

	if image_err != OK: push_error("An error occured while storing the image cache: ERR_%s" % error_string(image_err).to_upper())
	return DiscordHelpers.to_image_texture(image)


func get_default_avatar() -> PackedByteArray:
	var png_bytes = await DiscordBot._send_get_cdn(_get_default_avatar_url())
	return png_bytes

#func _to_string(pretty: bool = false):
#	var data = {
#		'id': id.id,
#		'username': username,
#		'discriminator': discriminator,
#		'avatar': avatar,
#		'bot': bot,
#		'system': system,
#		'mfa_enabled': mfa_enabled,
#		'locale': locale,
#		'verified': verified,
#		'email': email,
#		'flags': flags,
#		'premium_type': premium_type,
#		'public_flags': public_flags
#	}
#
#	return "[User: ID = %s, Username = %s]" % [data.id, data.username]
