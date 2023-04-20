class_name ApplicationCommand extends DiscordDataclass

## Represents a Discord application command.

enum COMMAND_TYPES {
	CHAT_INPUT = 1,
	USER,
	MESSAGE
}

const _COMMAND_TYPES = {
	1: 'CHAT_INPUT',
	2: 'USER',
	3: 'MESSAGE'
}

enum OPTION_TYPES {
	SUB_COMMAND = 1,
	SUB_COMMAND_GROUP,
	STRING,
	INTEGER,
	BOOLEAN,
	USER,
	CHANNEL,
	ROLE,
	MENTIONABLE,
	NUMBER
}

const _OPTION_TYPES = {
	1: 'SUB_COMMAND',
	2: 'SUB_COMMAND_GROUP',
	3: 'STRING',
	4: 'INTEGER',
	5: 'BOOLEAN',
	6: 'COMMAND',
	7: 'CHANNEL',
	8: 'ROLE',
	9: 'MENTIONABLE',
	10: 'NUMBER',
}

const _CHANNEL_TYPES = {
	'GUILD_TEXT': 0,
	'DM': 1,
	'GUILD_VOICE': 2,
	'GROUP_DM': 3,
	'GUILD_CATEGORY': 4,
	'GUILD_NEWS': 5,
	'GUILD_STORE': 6,
	'GUILD_NEWS_THREAD': 10,
	'GUILD_PUBLIC_THREAD': 11,
	'GUILD_PRIVATE_THREAD': 12,
	'GUILD_STAGE_VOICE': 13
}

var id: Snowflake
var type: COMMAND_TYPES = COMMAND_TYPES.CHAT_INPUT
var application_id: Snowflake
var guild_id: Snowflake
var name: String
var description: String

var options: Array
var default_permission: bool = true
var version: Snowflake

func set_type(p_type: String):
	type = COMMAND_TYPES[p_type]
	return self

func get_type():
	return _OPTION_TYPES[type]


## Registers your Application Command.
## [code]id[/code] is the Snowflake ID of the guild, if [code]null[/code] then the command will register as a Global Command.
func register(_guild_id: Snowflake = null):
	var slug = '/applications/%s' % DiscordBot.application.id

	if _guild_id:
		# Registering a guild command
		slug += '/guilds/%s' % _guild_id.id

	slug += '/commands'
	var res = await DiscordBot._send_request(slug, to_dict())
#	print_debug(slug)
	return ApplicationCommand.new(res)


func edit():
	var slug = '/applications/%s' % DiscordBot.application.id

	if guild_id:
		# Registering a guild command
		slug += '/guilds/%s' % guild_id.id

	slug += '/commands/%s' % id.id
	var payload: = {
		name = name,
		description = description,
		options = options,
		default_permission = default_permission
	}
#	print_debug(slug, payload)
	var res = await DiscordBot._send_request(slug, payload, HTTPClient.METHOD_PATCH)
	return ApplicationCommand.new(res)


func delete(_guild_id: Snowflake = guild_id):
	var slug = '/applications/%s' % DiscordBot.application.id

	if _guild_id:
		# Deleting a guild command
		slug += '/guilds/%s' % _guild_id.id

	slug += '/commands/%s' % id.id
	var res = await DiscordBot._send_get(slug, HTTPClient.METHOD_DELETE)
	print_debug(slug + " ", str(res) + " ", id.id)
	return res


func add_options(array_option_data: Array[Dictionary]) -> ApplicationCommand:
	for option_data in array_option_data:
		# Generic method to add an option to the command
		assert(option_data.has('type'), 'ApplicationCommand option must have a type')
		assert(option_data.has('name') and Helpers.is_valid_str(option_data.name), 'ApplicationCommand option must have a name')
		assert(option_data.has('description') and Helpers.is_valid_str(option_data.description), 'ApplicationCommand option must have a description')
		options.append(option_data)
	return self

static func sub_command_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.SUB_COMMAND, _name, _description, _data)

static func sub_command_group_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.SUB_COMMAND_GROUP, _name, _description, _data)

static func string_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.STRING, _name, _description, _data)

static func integer_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.INTEGER, _name, _description, _data)

static func boolean_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.BOOLEAN, _name, _description, _data)

static func user_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.USER, _name, _description, _data)

static func channel_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.CHANNEL, _name, _description, _data)

static func role_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.ROLE, _name, _description, _data)

static func mentionable_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.MENTIONABLE, _name, _description, _data)

static func number_option(_name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	return _make_option(OPTION_TYPES.NUMBER, _name, _description, _data)

static func choice(_name: String, _value) -> Dictionary:
	return {
		'name': _name,
		'value': _value
	}

static func _make_option(_type: int, _name: String, _description: String, _data: Dictionary = {}) -> Dictionary:
	if _data.has('channel_types'):
		for i in range(len(_data.channel_types)):
			if _CHANNEL_TYPES.has(_data.channel_types[i]):
				_data.channel_types[i] = _CHANNEL_TYPES[_data.channel_types[i]]

	return {
		'type': _type,
		'name': _name,
		'description': _description,
		# Optional data
		'required': _data.required if _data.has('required') else null,
		'choices': _data.choices if _data.has('choices') else null,
		'options': _data.options if _data.has('options') else null,
		'channel_types': _data.channel_types if _data.has('channel_types') else null,
		'min_value': _data.min_value if _data.has('min_value') else null,
		'max_value': _data.max_value if _data.has('max_value') else null,
		'autocomplete': _data.autocomplete if _data.has('autocomplete') else false
	}

#func _init(data: Dictionary = {}):
##	print_debug(data)
#	id = Snowflake.new(data.id) if data.has('id') and data.id else null
#	type = data.type if data.has('type') else COMMAND_TYPES.CHAT_INPUT
#	application_id = Snowflake.new(data.application_id) if data.has('application_id') and data.application_id else null
#
#	guild_id = Snowflake.new(data.guild_id) if data.has('guild_id') and data.guild_id else null
#	print_debug(guild_id, " ", typeof(guild_id))
#	name = data.name if data.has('name') else ''
#	description = data.description if data.has('description') else ''
#	options = data.options if data.has('options') else []
#	default_permission = data.default_permission if data.has('default_permission') else true
#	version = Snowflake.new(data.version) if data.has('version') and data.version else null
