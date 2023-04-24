#@tool
extends Node

##Main script for discord.gd plugin
##
##Copyright 2021, Krishnendu Mondal
##For Copyright and License: See LICENSE.md

# Signals
signal event(event: Dictionary)
signal bot_ready()
signal channel_create(channel: Dictionary)
signal channel_update(channel: Dictionary)
signal channel_delete(channel: Dictionary)
#signal thread_create(thread: Dictionary)
#signal thread_update(thread: Dictionary)
#signal thread_delete(thread: Dictionary)
signal guild_create(guild: Dictionary)
signal guild_update(guild: Dictionary)
signal guild_delete(guild: Dictionary)
signal guild_ban_add(guild_id: Snowflake, user: User)
signal guild_ban_remove(guild_id: Snowflake, user: User)
signal guild_member_add(guild_id: Snowflake, member: Guild.Guild_Member_Object)
signal guild_member_remove(guild_id: Snowflake, user: User)
signal guild_member_chunk(guild_id: Snowflake, members: Array[Guild.Guild_Member_Object], chunk_index: int, chunt_count: int, extra_parameters: Dictionary)
signal guild_member_update(guild_id: Snowflake, member: Guild.Guild_Member_Object)
signal message_create(message: Channel.Message)
signal message_update(message: Channel.Message)
signal message_delete(message: Dictionary)
signal interaction_create(interaction: DiscordInteraction)
signal message_reaction_add(data: Dictionary)
signal message_reaction_remove(data: Dictionary)
signal message_reaction_remove_all(data: Dictionary)
signal message_reaction_remove_emoji(data: Dictionary)

const CHANNEL_TYPES = {
	'0': 'GUILD_TEXT',
	'1': 'DM',
	'2': 'GUILD_VOICE',
	'3': 'GROUP_DM',
	'4': 'GUILD_CATEGORY',
	'5': 'GUILD_NEWS',
	'6': 'GUILD_STORE',
	'10': 'GUILD_NEWS_THREAD',
	'11': 'GUILD_PUBLIC_THREAD',
	'12': 'GUILD_PRIVATE_THREAD',
	'13': 'GUILD_STAGE_VOICE'
}
const GUILD_ICON_SIZES = [16, 32, 64, 128, 256, 512, 1024, 2048, 4096]
const ACTIVITY_TYPES = {'GAME': 0, 'STREAMING': 1, 'LISTENING': 2, 'WATCHING': 3, 'COMPETING': 5}
const PRESENCE_STATUS_TYPES = ['ONLINE', 'DND', 'IDLE', 'INVISIBLE', 'OFFLINE']


# Public Variables
var TOKEN: String
var VERBOSE: bool = false
var INTENTS: int = 513


# Private Variables
var _gateway_base = 'wss://gateway.discord.gg/?v=10&encoding=json'
var _https_domain = 'https://discord.com'
var _api_slug = '/api/v10'
var _https_base = _https_domain + _api_slug
var _cdn_base = 'https://cdn.discordapp.com'
var _headers: Array
var _client: WebSocketPeer = WebSocketPeer.new()
var _sess_id: String
var _last_seq: float
var _invalid_session_is_resumable: bool
var _heartbeat_interval: int
var _heartbeat_ack_received = true
var _login_error
var _logged_in = false

# Caches
var user: User
var application: Dictionary
var guilds: = {}
var channels: = {}
var users: = {}
var cache_path: = {
	image = "user://cache/image_cache/"
}
# Count of the number of guilds initially loaded
var guilds_loaded = 0


# Public Functions
func login(token: String = TOKEN, intents: int = INTENTS) -> void:
	TOKEN = token
	INTENTS = intents
	assert(not TOKEN.is_empty() and TOKEN.length() > 10, 'ERROR: Unable to login. TOKEN attribute not set.')
	_headers = [
		'Authorization: Bot %s' % TOKEN,
		'User-Agent: discord.gd (https://github.com/3ddelano/discord.gd)'
	]
	_login_error = _client.connect_to_url(_gateway_base)
	# No internet?
	print("Logged In!" if _login_error == OK else "Failed to Login.")
	if _login_error == ERR_INVALID_PARAMETER:
		print('Trying to reconnect in 5s')
		await get_tree().create_timer(5).timeout
		await login()
	else:
		match _login_error:
			ERR_UNAUTHORIZED:
				print('Login Error: Unauthorized')
			ERR_UNAVAILABLE:
				print('Login Error: Unavailable')
			FAILED:
				print('Login Error: Failed (Generic)')
	_logged_in = true


func send(messageorchannelid, content, options: Dictionary = {}):
	# channel
	var res = await _send_message_request(messageorchannelid, content, options)
	return res


func reply(message, content, options: Dictionary = {}):
	options.message_reference = {'message_id': message.id}
	var res = await _send_message_request(message, content, options)
	return res


func edit(message, content, options: Dictionary = {}):
	var res = await _send_message_request(message, content, options, HTTPClient.METHOD_PATCH)
	return res


func delete(message):
	var res = await _send_message_request(message, '', {}, HTTPClient.METHOD_DELETE)
	return res


func start_thread(message: Channel.Message, thread_name: String, duration: int = 60 * 24) -> Dictionary:
	var payload = {'name': thread_name, 'auto_archive_duration': duration}
	var res = await _send_request('/channels/%s/messages/%s/threads' % [message.channel_id, message.id], payload)

	return res


func get_guild_icon(guild_id: String, size: int = 256) -> PackedByteArray:
	assert(DiscordHelpers.is_valid_str(guild_id), 'Invalid Type: guild_id must be a valid String')

	var guild = guilds.get(str(guild_id))

	if not guild:
		push_error('Guild not found.')
		await get_tree().process_frame
		return PackedByteArray()

	if not guild.icon:
		push_error('Guild has no icon set.')
		await get_tree().process_frame
		return PackedByteArray()

	if size != 256:
		assert(size in GUILD_ICON_SIZES, 'Invalid size for guild icon provided')

	var png_bytes = await _send_get_cdn('/icons/%s/%s.png?size=%s' % [guild.id, guild.icon, size])
	return png_bytes


func get_guild_emojis(guild_id: String) -> Array:
	var res = await _send_get('/guilds/%s/emojis' % guild_id)
	return res


func get_guild_member(guild_id: String, member_id: String) -> Dictionary:
	var member = await _send_get('/guilds/%s/members/%s' % [guild_id, member_id])
	return member


func create_dm_channel(user_id: String) -> Dictionary:
	var res = await _send_request('/users/@me/channels', {'recipient_id': user_id})
	return res


func remove_member_role(guild_id: String, member_id: String, role_id: String):
	var res = await _send_get('/guilds/%s/members/%s/roles/%s' % [guild_id, member_id, role_id], HTTPClient.METHOD_DELETE)
	return res


func add_member_role(guild_id: String, member_id: String, role_id: String):
	var res = await _send_request('/guilds/%s/members/%s/roles/%s' % [guild_id, member_id, role_id], {}, HTTPClient.METHOD_PUT)
	return res


## Set presence of your bot in the given format...
## [codeblock]
##    p_options {
##       status: String, text of the presence,
##       afk: bool, whether or not the client is afk,
##
##       activity: {
##          type: String, type of the presence [Game, Streaming, Listening, Watching, Custom,
##          name: String, name of the presence,
##          url: String, url of the presence (Only valid if type is "Streaming"),
##          created_at: int, unix timestamp (in milliseconds) of when activity was added to user's session
##       }
##    }
## [/codeblock]
## [br]
## [u][b]Note:[/b][/u] Use only after [signal bot_ready] is emitted.
## [br][br]
## [url=https://discord.com/developers/docs/topics/gateway#presence]Discord Docs: [b]Presence[/b][/url]
func set_presence(p_options: Dictionary) -> void:

	var new_presence = {'status': 'online', 'afk': false, 'activity': {}}

	assert(p_options, 'Missing options for set_presence')
	assert(typeof(p_options) == TYPE_DICTIONARY, 'Invalid Type: options in set_presence must be a Dictionary')

	if p_options.has('status') and DiscordHelpers.is_valid_str(p_options.status):
		assert(str(p_options.status).to_upper() in PRESENCE_STATUS_TYPES, 'Invalid Type: status must be one of PRESENCE_STATUS_TYPES')
		new_presence.status = p_options.status.to_lower()
	if p_options.has('afk') and p_options.afk is bool:
		new_presence.afk = p_options.afk

	# Check if an activity was passed
	if p_options.has('activity') and typeof(p_options.activity) == TYPE_DICTIONARY:
		if p_options.activity.has('name') and DiscordHelpers.is_valid_str(p_options.activity.name):
			new_presence.activity.name = p_options.activity.name

		if p_options.activity.has('url') and DiscordHelpers.is_valid_str(p_options.activity.url):
			new_presence.activity.url = p_options.activity.url

		if p_options.activity.has('created_at') and DiscordHelpers.is_num(p_options.activity.created_at):
			new_presence.activity.created_at = p_options.activity.created_at
		else:
			new_presence.activity.created_at = Time.get_unix_time_from_system() * 1000

		if p_options.activity.has('type') and DiscordHelpers.is_valid_str(p_options.activity.type):
			assert(str(p_options.activity.type).to_upper() in ACTIVITY_TYPES, 'Invalid Type: type must be one of ACTIVITY_TYPES')
			new_presence.activity.type = ACTIVITY_TYPES[str(p_options.activity.type).to_upper()]

	_update_presence(new_presence)


# ONLY custom emojis will work, pass in only the Id of the emoji to the custom_emoji
func create_reaction(messageordict, custom_emoji: String) -> int:
	assert(DiscordHelpers.is_valid_str(custom_emoji), 'Invalid Type: custom_emoji must be a String')
	custom_emoji = 'a:' + custom_emoji
	assert(messageordict is Channel.Message or typeof(messageordict) == TYPE_DICTIONARY, 'Invalid type: Expected a Channel.Message or Dictionary')

	if typeof(messageordict) == TYPE_DICTIONARY and messageordict.has('message_id'):
		messageordict.id = messageordict.message_id

	var status_code = await _send_get('/channels/%s/messages/%s/reactions/%s/@me' % [messageordict.channel_id, messageordict.id, custom_emoji], HTTPClient.METHOD_PUT, ['Content-Length:0'])
	return status_code


func delete_reaction(messageordict, custom_emoji: String, userid: String = '@me') -> int:
	assert(DiscordHelpers.is_valid_str(custom_emoji), 'Invalid Type: custom_emoji must be a String')
	custom_emoji = 'a:' + custom_emoji
	assert(messageordict is Channel.Message or typeof(messageordict) == TYPE_DICTIONARY, 'Invalid type: Expected a Channel.Message or Dictionary')

	if typeof(messageordict) == TYPE_DICTIONARY and messageordict.has('message_id'):
		messageordict.id = messageordict.message_id

	var status_code = await _send_get('/channels/%s/messages/%s/reactions/%s/%s' % [messageordict.channel_id, messageordict.id, custom_emoji, userid], HTTPClient.METHOD_DELETE, ['Content-Length:0'])

	return status_code


func delete_reactions(messageordict, custom_emoji = '') -> int:
	assert(messageordict is Channel.Message or typeof(messageordict) == TYPE_DICTIONARY, 'Invalid type: Expected a Channel.Message or Dictionary')
	if typeof(messageordict) == TYPE_DICTIONARY and messageordict.has('message_id'):
		messageordict.id = messageordict.message_id

	var status_code
	if custom_emoji != '':
		custom_emoji = 'a:' + custom_emoji
		status_code = await _send_get('/channels/%s/messages/%s/reactions/%s' % [messageordict.channel_id, messageordict.id, custom_emoji], HTTPClient.METHOD_DELETE, ['Content-Length:0'])
	else:
		status_code = await _send_get('/channels/%s/messages/%s/reactions' % [messageordict.channel_id, messageordict.id], HTTPClient.METHOD_DELETE, ['Content-Length:0'])

	return status_code


func get_reactions(messageordict, custom_emoji: String):
	assert(DiscordHelpers.is_valid_str(custom_emoji), 'Invalid Type: custom_emoji must be a String')
	custom_emoji = 'a:' + custom_emoji
	assert(messageordict is Channel.Message or typeof(messageordict) == TYPE_DICTIONARY, 'Invalid type: Expected a Channel.Message or Dictionary')
	if typeof(messageordict) == TYPE_DICTIONARY and messageordict.has('message_id'):
		messageordict.id = messageordict.message_id

	var ret = await _send_get('/channels/%s/messages/%s/reactions/%s' % [messageordict.channel_id, messageordict.id, custom_emoji])
	return ret

## [i](Deprecated, use [method ApplicationCommand.register] instead)[/i] Register an Application Command
func register_command(command: ApplicationCommand, id: Snowflake = null) -> ApplicationCommand:
	var slug = '/applications/%s' % application.id

	if id != null:
		# Registering a guild command
		slug += '/guilds/%s' % id.id

	slug += '/commands'
	var res = await _send_request(slug, command._to_dict(true))
	return ApplicationCommand.new(res)

## Register an Array of Application Commands
func register_commands(commands: Array, id: Snowflake = null) -> Array:
	for i in range(len(commands)):
		if commands[i] is ApplicationCommand:
			commands[i] = commands[i]._to_dict(true)

	var slug = '/applications/%s' % application.id

	if id != null:
		# Registering guild commands
		slug += '/guilds/%s' % id.id

	slug += '/commands'
	var res = await _send_request(slug, commands, HTTPClient.METHOD_PUT)
	if typeof(res) == TYPE_ARRAY:
		for i in range(len(res)):
			res[i] = ApplicationCommand.new(res[i])
	return res


func delete_command(command: ApplicationCommand, id: Snowflake = null) -> int:
	var slug = '/applications/%s' % application.id

	if id != null:
		# Deleting a guild command
		slug += '/guilds/%s' % id.id

	slug += '/commands/%s' % command.id
	var res = await _send_get(slug, HTTPClient.METHOD_DELETE)
	return res


func delete_commands(guild_id: String = '') -> int:
	var slug = '/applications/%s' % application.id

	if DiscordHelpers.is_valid_str(guild_id):
		# Deleting guild commands
		slug += '/guilds/%s' % guild_id

	slug += '/commands'
	var res = await _send_request(slug, [], HTTPClient.METHOD_PUT)
	return res


func get_command(command_id: Snowflake, guild_id: Snowflake = null) -> ApplicationCommand:
	var slug = '/applications/%s' % application.id

	if guild_id != null:
		# Getting a guild command
		slug += '/guilds/%s' % guild_id.id

	slug += '/commands/%s' % command_id.id

	var data = await _send_get(slug)
	if DiscordError.code > 0:
		return
	return ApplicationCommand.new(data)


func get_commands(guild_id: Snowflake = null) -> Array:
	var slug = '/applications/%s' % application.id

	if guild_id != null:
		# Getting guild commands
		slug += '/guilds/%s' % guild_id.id

	slug += '/commands'

	var cmds = await _send_get(slug)
	if cmds is Array:
		for index in cmds.size():
			cmds[index] = ApplicationCommand.new(cmds[index])
		return cmds as Array[ApplicationCommand]
	return []


func respond_to_command(interaction_id: String, interaction_token: String, data: Dictionary, reading_time: int = 5):
	await _send_request("/interactions/{interaction.id}/{interaction.token}/callback".format(
			{
			"interaction.id" = interaction_id,
			"interaction.token" = interaction_token
			}
		),
		data
	)
	if reading_time > -1:
		var progress_bar_text: Array[String] = ["⬛", "🟥"]
		var progress: PackedStringArray = []
		for index in reading_time:
			progress.append(progress_bar_text[0])

		for index in reading_time:
			progress.remove_at(index)
			progress.insert(index, progress_bar_text[1])
			_send_request("/webhooks/{application.id}/{interaction.token}/messages/@original".format(
					{
						"application.id" = application.id,
						"interaction.token" = interaction_token
					}
				),
				{
					content = data.data.content + "\n\n`%s`" % "".join(progress)
				},
				HTTPClient.METHOD_PATCH
			)
			await get_tree().create_timer(1).timeout

		await _send_get("/webhooks/{application.id}/{interaction.token}/messages/@original".format(
					{
						"application.id" = application.id,
						"interaction.token" = interaction_token
					}
				),
			HTTPClient.METHOD_DELETE
			)


# Private Functions
func _ready() -> void:
	randomize()

	# Generate needed nodes
	_generate_timer_nodes()

	# Setup web socket client
#	multiplayer.peer_disconnected.connect(_connection_closed)
#	multiplayer.server_disconnected.connect(_connection_error)
#	multiplayer.peer_connected.connect(_connection_established)
#	_client.connect(_data_received)

	$HeartbeatTimer.timeout.connect(_send_heartbeat)


func _generate_timer_nodes() -> void:
	var heart_beat_timer = Timer.new()
	heart_beat_timer.name = 'HeartbeatTimer'
	add_child(heart_beat_timer)

	var invalid_session_timer = Timer.new()
	invalid_session_timer.name = 'InvalidSessionTimer'
	add_child(invalid_session_timer)


func _connection_closed(was_clean_close: bool) -> void:
	if was_clean_close:
		if VERBOSE:
			print('WSS connection closed cleanly')
	else:
		if VERBOSE:
			print('WSS connection closed unexpectedly')


func _connection_error() -> void:
	if VERBOSE:
		print('WSS connection error')


func _connection_established(protocol: String) -> void:
	if VERBOSE:
		print('Connected with protocol: ', protocol)


func _data_received(packet: PackedByteArray) -> void:
	var data := packet.get_string_from_utf8()
	var dict = _jsonstring_to_dict(data)
	var op = str(dict.op)  # OP Code Received
	var d = dict.d  # Data Received

	match op:
		'10':
			# Got hello
			_setup_heartbeat_timer(d.heartbeat_interval)

			var response_d = {'op': -1}
			if _sess_id:
				# Resume session
				response_d.op = 6
				response_d['d'] = {'token': TOKEN, 'session_id': _sess_id, 'seq': _last_seq}
			else:
				# Make new session
				response_d.op = 2
				response_d['d'] = {
					'token': TOKEN,
					'intents': INTENTS,
					'properties':
					{'$os': 'linux', '$browser': 'discord.gd', '$device': 'discord.gd'}
				}

			_send_dict_wss(response_d)
		'11':
			# Heartbeat Acknowledged
			_heartbeat_ack_received = true
			if VERBOSE:
				print('Heartbeat acknowledged!')
		'9':
			# Opcode 9 Invalid Session
			_invalid_session_is_resumable = d
			var timer = $InvalidSessionTimer
			timer.one_shot = true
			timer.wait_time = randi_range(1, 5)
			timer.start()
		'0':
			# Event Dispatched
			_handle_events(dict)


func _process(_delta) -> void:
	# Run only when in game and not in the editor
	_client.poll()
	if not Engine.is_editor_hint():
		# Poll the web socket if connected otherwise reconnect
		var state: = _client.get_ready_state()
		match state:
			WebSocketPeer.STATE_CONNECTING:
				prints("Connecting to the Websocket server at:", _gateway_base)
			WebSocketPeer.STATE_OPEN:
				while _client.get_available_packet_count():
					_data_received(_client.get_packet())

#		elif _logged_in:
#			_client.create_client(_gateway_base)


func _send_heartbeat() -> void:  # Send heartbeat OP code 1
	if not _heartbeat_ack_received:
		_client.close(0, "Connection closed since heartbeat was not recieved")
		return

	var response_payload = {'op': 1, 'd': _last_seq}
	_send_dict_wss(response_payload)
	_heartbeat_ack_received = false
	if VERBOSE:
		print('Heartbeat sent!')


func _handle_events(dict: Dictionary) -> void:
	_last_seq = dict.s
	var event_name = dict.t

	event.emit(dict)
	match event_name:
		'READY':
			_sess_id = dict.d.session_id
			var d: Dictionary = dict.d

			application = d.application
			var _guilds = d.guilds
			_clean_guilds(_guilds)

			var _user: User = User.new(d.user)
			user = _user

			for guild in _guilds:
				guilds[guild.id] = guild

			bot_ready.emit()

		'GUILD_CREATE':
			var guild: Dictionary = dict.d
			guild_create.emit(Guild.new(guild))
#			_clean_guilds([guild])
#			# Update number of cached guilds
#			if guild.has('lazy') and guild.lazy:
#				guilds_loaded += 1
#				if guilds_loaded == guilds.size():
#					bot_ready.emit()

#			if not guilds.has(guild.id):
#				# Joined a new guild
#				guild_create.emit(guild)

			# Update cache
			guilds[guild.id] = guild

		'GUILD_UPDATE':
			var guild = dict.d
			_clean_guilds([guild])
			guilds[guild.id] = guild
			guild_update.emit(guild)

		'GUILD_DELETE':
			var guild = dict.d
			guilds.erase(guild.id)
			guild_delete.emit(Guild.new(guild))

		'GUILD_MEMBER_ADD':
			guild_member_add.emit(Snowflake.new(dict.d.guild_id), Guild.Guild_Member_Object.new(dict.d))
#			print_debug(dict.d)

		'GUILD_MEMBER_UPDATE':
			guild_member_update.emit(Snowflake.new(dict.d.guild_id), Guild.Guild_Member_Object.new(dict.d))
#			print_debug(dict.d)

		'GUILD_MEMBER_REMOVE':
			guild_member_remove.emit(Snowflake.new(dict.d.guild_id), User.new(dict.d.user))
#			print_debug(dict.d)

		'GUILD_MEMBERS_CHUNK':
			var members_array: Array = dict.d.members
			for index in members_array.size():
				members_array[index] = Guild.Guild_Member_Object.new(members_array[index])

			guild_member_chunk.emit(
				Snowflake.new(dict.d.guild_id),
				members_array,
				dict.d.chunk_index,
				dict.d.chunk_count,
				{
					not_found = dict.d.not_found if dict.d.has("not_found") else null,
					presences = dict.d.presences if dict.d.has("presences") else null,
					nonce = dict.d.nonce if dict.d.has("nonce") else ""
				}
			)

		'GUILD_BAN_ADD':
			guild_ban_add.emit(Snowflake.new(dict.d.guild_id), User.new(dict.d.user))

		'GUILD_BAN_REMOVE':
			guild_ban_remove.emit(Snowflake.new(dict.d.guild_id), User.new(dict.d.user))

		'CHANNEL_CREATE', 'THREAD_CREATE':
			channels[dict.d.id] = dict.d
			channel_create.emit(dict.d)
		'CHANNEL_UPDATE', 'THREAD_UPDATE':
			channels[dict.d.id] = dict.d
			channel_update.emit(dict.d)
		'CHANNEL_DELETE', 'THREAD_DELETE':
			channels.erase(dict.d.id)
			channel_delete.emit(dict.d)
		'RESUMED':
			if VERBOSE:
				print('Session Resumed')

		'MESSAGE_CREATE':
			var d = dict.d

			# Dont respond to webhooks
#			if d.has('webhook_id') and d.webhook_id:
#				return
#
#			if d.has('sticker_items') and d.sticker_items and typeof(d.sticker_items) == TYPE_ARRAY:
#				if d.sticker_items.size() != 0:
#					return

#			var coroutine = await _parse_message(d)
#			if typeof(coroutine) == TYPE_OBJECT:
#				coroutine = await coroutine
#				if coroutine == null:
#					# message might be a thread
#					# TODO: Handle sending messages in threads
#					return

			d = Channel.Message.new(d)

#			var channel = channels.get(str(d.channel_id))
			message_create.emit(d)
		'MESSAGE_UPDATE':
			message_update.emit(Channel.Message.new(dict.d))

		'MESSAGE_DELETE':
			message_delete.emit(dict.d)
		'MESSAGE_REACTION_ADD':
			message_reaction_add.emit(dict.d)
		'MESSAGE_REACTION_REMOVE':
			message_reaction_remove.emit(dict.d)
		'MESSAGE_REACTION_REMOVE_ALL':
			message_reaction_remove_all.emit(dict.d)
		'MESSAGE_REACTION_REMOVE_EMOJI':
			message_reaction_remove_emoji.emit(dict.d)

		'INTERACTION_CREATE':
#			var d = dict.d

#			var id = d.id
#			var data = d.data
#			var token = d.token

			var interaction = DiscordInteraction.new(dict.d)
			emit_signal('interaction_create', interaction)


func permissions_in(channel_id: Snowflake):
	# Permissions for the bot in a channel
	return permissions_for(user.id, channel_id)

func permissions_for(user_id: Snowflake, channel_id: Snowflake):
	# Permissions for a user in a channel
	if not channels.has(channel_id):
		push_error('Channel with the id' + str(channel_id) + ' not found.')
		return Permissions.new(Permissions.new().ALL)

	var channel = channels[channel_id]
	var guild = guilds[channel.guild_id]

	# Check for guild owner
	if user_id == guild.owner_id:
		return Permissions.new(Permissions.new().ALL)

	# @everyone base role
	var permissions = Permissions.new(guild.roles[guild.id].permissions)
	if not guild.members.has(user_id):
		push_warning('Member not found in cached members. Make sure the GUILD_MEMBERS intent is setup.')
		return permissions

	var role_ids = guild.members[user_id].roles

	# Apply member global roles
	for role_id in role_ids:
		permissions.add(guild.roles[role_id].permissions)

	if permissions.has('ADMINISTRATOR'):
		return Permissions.new(Permissions.new().ALL)

	var overwrites = channel.permission_overwrites

	# Apply @everyone overwrite
	for overwrite in overwrites:
		if overwrite.id == guild.id:
			permissions.remove(overwrite.deny)
			permissions.add(overwrite.allow)
			break

	# Apply member roles overwrite
	for overwrite in overwrites:
		if overwrite.id in role_ids:
			permissions.remove(overwrite.deny)
	for overwrite in overwrites:
		if overwrite.id in role_ids:
			permissions.add(overwrite.allow)

	# Apply user overwrite
	for overwrite in overwrites:
		if overwrite.id == user_id:
			permissions.remove(overwrite.deny)
			permissions.add(overwrite.allow)
			break

	return permissions

func _send_raw_request(slug: String, payload: Dictionary, method = HTTPClient.METHOD_POST):
	var headers = _headers.duplicate(true)
	var multipart_header = 'Content-Type: multipart/form-data; boundary="boundary"'
	if headers.find(multipart_header) == -1:
		headers.append(multipart_header)

	var http_client = HTTPClient.new()

	var body = PackedByteArray()

	# Add the payload_json to the form
	body.append_array('--boundary\r\n'.to_utf8_buffer())
	body.append_array('Content-Disposition: form-data; name="payload_json"\r\n'.to_utf8_buffer())
	body.append_array('Content-Type: application/json\r\n\r\n'.to_utf8_buffer())

	if payload.has('payload_json'):
		body.append_array(JSON.stringify(payload.payload_json).to_utf8_buffer())
	elif payload.has('payload'):
		body.append_array(JSON.stringify(payload.payload).to_utf8_buffer())

	var count = 0
	for file in payload.files:
		# Extract the name, media_type and data of each file
		var file_name = file.name
		var media_type = file.media_type
		var data = file.data
		# Add the file to the form
		body.append_array('\r\n--boundary\r\n'.to_utf8_buffer())
		body.append_array(
			('Content-Disposition: form-data; name="file' + str(count) + '"; filename="' + file_name + '"').to_utf8_buffer()
		)
		body.append_array(('\r\nContent-Type: ' + media_type + '\r\n\r\n').to_utf8_buffer())
		body.append_array(data)
		count += 1

	# End the form-data
	body.append_array('\r\n--boundary--'.to_utf8_buffer())
	var err = http_client.connect_to_host(_https_domain, -1)
	assert(err == OK, 'Error connecting to Discord HTTPS server')

	while (
		http_client.get_status() == HTTPClient.STATUS_CONNECTING
		or http_client.get_status() == HTTPClient.STATUS_RESOLVING
	):
		http_client.poll()
		await get_tree().process_frame

	assert(http_client.get_status() == HTTPClient.STATUS_CONNECTED, 'Could not connect to Discord HTTPS server')
	err = http_client.request_raw(method, _api_slug + slug, headers, body)

	while http_client.get_status() == HTTPClient.STATUS_REQUESTING:
		http_client.poll()
		await get_tree().process_frame

	# Request is made, now extract the reponse body
	assert((http_client.get_status() == HTTPClient.STATUS_BODY or http_client.get_status() == HTTPClient.STATUS_CONNECTED))

	if http_client.has_response():
		headers = http_client.get_response_headers_as_dictionary()

		var rb = PackedByteArray()
		while http_client.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			http_client.poll()
			var chunk = http_client.read_response_body_chunk()
			if chunk.size() == 0:
				# Got nothing, wait for buffers to fill a bit.
				OS.delay_usec(1000)
			else:
				rb = rb + chunk  # Append to read buffer.

		var response = _jsonstring_to_dict(rb.get_string_from_utf8())
		if response == null:
			if http_client.get_response_code() == 204:
				return true
			return false
		if response.has('code'):
			DiscordError.print(http_client.get_response_code(), response)

		if response.has('code'):
			push_error('Error sending request. See output window')

		if response.has('retry_after'):
			# We got ratelimited
			await get_tree().create_timer(int(response.retry_after)).timeout
			response = await _send_raw_request(slug, payload, method)

		return response
	else:
		assert(http_client.has_response(), 'Unable to upload file. Got empty response from server')


func _send_request(slug: String, payload, method = HTTPClient.METHOD_POST):
	var headers = _headers.duplicate(true)

	var json_header = 'Content-Type: application/json'
	if headers.find(json_header) == -1:
		headers.append(json_header)

	var http_request = HTTPRequest.new()
#	http_request.timeout = 15
	add_child(http_request)
	http_request.call_deferred('request', _https_base + slug, headers, false, method, JSON.stringify(payload))
#	print_debug(_https_base + slug, payload)

	var data = await http_request.request_completed
	http_request.queue_free()

	# Check for errors
	assert(data[0] == HTTPRequest.RESULT_SUCCESS, 'Error sending request: HTTP Failed')
	var response = _jsonstring_to_dict(data[3].get_string_from_utf8())
	if response == null:
		if data[1] == 204:
			return true
		return false

	if response and response.has('code'):
		# Got an error
			DiscordError.print(data[1], response)
	if method != HTTPClient.METHOD_DELETE:
		if response.has('code'):
			push_error('Error sending request. See output window')

	if response.has('retry_after'):
		# We got ratelimited
		await get_tree().create_timer(int(response.retry_after)).timeout
		response = await _send_request(slug, payload, method)

	return response


func _get_dm_channel(channel_id: String) -> Dictionary:
	assert(DiscordHelpers.is_valid_str(channel_id), 'Invalid Type: channel_id must be a valid String')
	var data = await _send_get('/channels/%s' % channel_id)
	return data


func _send_get(slug: String, method = HTTPClient.METHOD_GET, additional_headers: = []):
	var http_request = HTTPRequest.new()
#	http_request.timeout = 15
	add_child(http_request)

	var headers = _headers + additional_headers
	http_request.call_deferred('request', _https_base + slug, headers, method)
#	print_debug(_https_base + slug)

	var data = await http_request.request_completed
	http_request.queue_free()

	assert(data[0] == HTTPRequest.RESULT_SUCCESS, "HTTP Failed!")
	if method == HTTPClient.METHOD_GET:
		var response = _jsonstring_to_dict(data[3].get_string_from_utf8())
		if response != null and response.has('code'):
			# Got an error
			DiscordError.print(data[1], response)
		return response

	else:  # Maybe a PUT/DELETE for reaction
		return data[1]


func _send_get_cdn(slug: String) -> PackedByteArray:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	if slug.find('/') == 0:
		http_request.request(_cdn_base + slug, _headers)
	else:
		http_request.request(slug, _headers)

	var data = await http_request.request_completed
	http_request.queue_free()

	# Check for errors
	assert(data[0] == HTTPRequest.RESULT_SUCCESS, 'Error sending GET cdn request: HTTP Failed')

	if data[1] != 200:
		print_rich('[color=red]HTTPS GET cdn Error:[/color] [color=yellow]Status Code: %s[/color]' % data[1])
		print_rich(DiscordHelpers.get_string_from_dict_or_array(data[3]))

	return data[3]


## Parse the options
##    parse the message options - refer [url=https://discord.com/developers/docs/resources/channel#create-message-jsonform-params]Discord Docs: Create Channel.Message: JSON Form Params [/url]
## [codeblock]
##    options {
##        tts: bool,
##        embeds: Array,
##        components: Array,
##        files: Array,
##        allowed_mentions: object,
##        message_reference: object,
##     }
## [/codeblock]
func _send_message_request(
	messageorchannelid, content, options := {}, method := HTTPClient.METHOD_POST
):
	var payload = {
		'content': null,
		'tts': false,
		'embeds': null,
		'components': null,
		'allowed_mentions': null,
		'message_reference': null
	}

	var slug# = '/channels/%s/messages' % str(message.channel_id)
	if messageorchannelid is Channel.Message:
		slug ='/channels/%s/messages' % str(messageorchannelid.channel_id.id)
	else:
		assert(messageorchannelid.length() > 16, 'channel_id is not valid')
		slug = '/channels/%s/messages' % str(messageorchannelid)

	# Handle edit message or delete message
	if method == HTTPClient.METHOD_PATCH or method == HTTPClient.METHOD_DELETE:
		slug += '/' + str(messageorchannelid.id)

	if method == HTTPClient.METHOD_PATCH:
		if typeof(messageorchannelid) == TYPE_OBJECT and typeof(messageorchannelid.attachments) == TYPE_ARRAY:
			if messageorchannelid.attachments.size() == 0:
				payload.attachments = null
			else:
				# Add the attachments to keep to the payload
				payload.attachments = messageorchannelid.attachments
	#if not message is Channel.Message:
	#	assert(false, 'Invalid Type: message must be a valid Channel.Message')

	# Check if the content is only a string
	if typeof(content) == TYPE_STRING and content.length() > 0:
		assert(content.length() <= 2048, 'Channel.Message content must be less than 2048 characters')
		payload.content = content

	elif typeof(content) == TYPE_DICTIONARY:  # Check if the content is the options dictionary
		options = content
		content = null

	if typeof(options) == TYPE_DICTIONARY:

		if options.has('content') and DiscordHelpers.is_str(options.content):
			assert(options.content.length() <= 2048, 'Channel.Message content must be less than 2048 characters')
			payload.content = options.content

		if options.has('tts') and options.tts:
			payload.tts = true

		if options.has('embeds') and options.embeds.size() > 0:
			for embed in options.embeds:
				if embed is Channel.Message.Embed:
					if payload.embeds == null:
						payload.embeds = []
					payload.embeds.append(embed._to_dict())
				else:
					payload.embeds = options.embeds

		if options.has('components') and options.components.size() > 0:
			assert(options.components.size() <= 5, 'Channel.Message can have a max of 5 MessageActionRow components.')
			for component in options.components:
#				assert(component is MessageActionRow, 'Parent component must be a MessageActionRow.')
				if payload.components == null:
					payload.components = []
#				payload.components.append(component._to_dict())
				payload.components.append(component)

		if options.has('allowed_mentions') and options.allowed_mentions:
			if typeof(options.allowed_mentions) == TYPE_DICTIONARY:
##				"""
##				allowedMentions {
##					parse: array of mention types ['roles', 'users', 'everyone']
##					roles: array of role_ids
##					users: array of user_ids
##					replied_user: bool, whether to mention author of msg
##				}
##				"""
				payload.allowed_mentions = options.allowed_mentions

		if options.has('message_reference') and options.message_reference:
##			"""
##			message_reference {
##				message_id: id of originating msg,
##				channel_id? *: optional
##				guild_id?: optional
##				fail_if_not_exists?: bool, whether to error
##			}
##			"""
			payload.message_reference = options.message_reference

		if options.has('files') and options.files:
			assert(typeof(options.files) == TYPE_ARRAY, 'Invalid Type: files in message options must be an array')

			if options.files.size() > 0:
				# Loop through each file
				for file in options.files:
					assert(file.has('name') and DiscordHelpers.is_valid_str(file.name), 'Missing name for file in files')
					assert(file.has('media_type') and DiscordHelpers.is_valid_str(file.media_type), 'Missing media_type for file in files')
					assert(file.has('data') and file.data, 'Missing data for file in files')
					assert(file.data is PackedByteArray, 'Invalid Type: data of file in files must be PackedByteArray')

			var json_payload = payload.duplicate(true)
			var new_payload = {'files': options.files, 'payload_json': json_payload}
			payload = new_payload

	var res
	if payload.has('files') and payload.files and typeof(payload.files) == TYPE_ARRAY:
		# Send raw post request using multipart/form-data
		var coroutine = await _send_raw_request(slug, payload, method)
		if typeof(coroutine) == TYPE_OBJECT:
			res = await coroutine
		else:
			res = coroutine

	else:
		res = await _send_request(slug, payload, method)

	if method == HTTPClient.METHOD_DELETE:
		return res
	else:
		var coroutine = await _parse_message(res)
		if typeof(coroutine) == TYPE_OBJECT:
			coroutine = await coroutine

		var msg = Channel.Message.new(res)
		return msg

# func request_guild_members(guild_id):
# 	assert(DiscordHelpers.is_valid_str(guild_id), 'Invalid Type: guild_id must be a String')

# 	if not guilds.has(guild_id):
# 		push_error('Guild not found with that guild_id')
#

# 	var response_d = {
# 		'op': 8,  # Request guild members
# 	}

# 	response_d['d'] = {
# 		'guild_id': guild_id,
# 		'query': '',
# 		'limit': 0
# 	}
# 	_send_dict_wss(response_d)

func _update_presence(new_presence: Dictionary) -> void:
	var status = new_presence.status
	var activity = new_presence.activity

	var response_d = {
		'op': 3,  # Presence update
	}
	@warning_ignore("incompatible_ternary")
	response_d['d'] = {
		'since': new_presence if new_presence.has('since') else null,
		'status': new_presence.status,
		'afk': new_presence.afk,
		'activities': [new_presence.activity]
	}
	_send_dict_wss(response_d)


# Helper functions
func _jsonstring_to_dict(data: String):
	var temp: = {}
	if (data.is_empty()):
		return temp

	var _json: = JSON.new()
	if _json.parse(data) == OK:
		return _json.get_data()
	else:
		return temp


func _setup_heartbeat_timer(interval: int) -> void:
	# Setup heartbeat timer and start it
	_heartbeat_interval = int(interval) / 1000.0
	var timer = $HeartbeatTimer
	timer.wait_time = _heartbeat_interval
	timer.start()


func _send_dict_wss(d: Dictionary) -> void:
	var payload = JSON.stringify(d)
	_client.send_text(payload)


func _clean_guilds(_guilds: Array) -> void:
	for guild in _guilds:
		# Converts the unavailable property to available
		if guild.has('unavailable'):
			guild.available = not guild.unavailable
		else:
			guild.available = true
		guild.erase('unavailable')

		if guild.has('channels'):
			for channel in guild.channels:
				_clean_channel(channel)
				channel.guild_id = guild.id
				channels[channel.id] = channel

		if guild.has('members') and typeof(guild.members) == TYPE_ARRAY:
			# Parse the guild members
			var members = {}
			for member in guild.members:
				var member_id = member.user.id
				users[member_id] = member.user
				member.erase('user')
				members[member_id] = member
			guild.members = members

		if guild.has('roles') and guild.roles is Array:
			# Parse the guild roles
			var roles = {}
			for role in guild.roles:
				var role_id = role.id
				role.erase('id')
				roles[role_id] = role
			guild.roles = roles


func _clean_channel(channel: Dictionary) -> void:
	if channel.has('type') and str(channel.type) in CHANNEL_TYPES.keys():
		channel.type = CHANNEL_TYPES.get(str(channel.type))


func _parse_message(message: Dictionary):
	assert(typeof(message) == TYPE_DICTIONARY, 'Invalid Type: message must be a Dictionary')

	if message.has('channel_id') and message.channel_id:
		# Check if channel is cached
		var channel = channels.get(str(message.channel_id))

		if channel == null:
			# Try to check if it is a DM channel
			if VERBOSE:
				print('Fetching DM channel: %s from api' % message.channel_id)

			channel = await _get_dm_channel(message.channel_id)
			_clean_channel(channel)

			if channel and channel.has('type') and channel.type == 'DM':
				channels[str(message.channel_id)] = channel
			else:
				# not a valid channel, it might be a thread
				return null

	if message.has('author') and typeof(message.author) == TYPE_DICTIONARY:
		# get the cached author of the message
		message.author = User.new(message.author)

	return 1
