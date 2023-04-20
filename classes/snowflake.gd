class_name Snowflake


## The first second of 2015
const DISCORD_EPOCH = 1420070400000

## The entire snowflake
var _int_id: int
var id:
	set(new):
		if new == null:
			id = null
			return

		if new is String:
			if not new.is_valid_int():
				DiscordUtils.perror("Snowflake::from_string:snowflake cannot be converted to integer, got: %s" % new)
				id = null
				return
			id = new.to_int()
			_int_id = new.to_int()
		elif not new is int:
			DiscordUtils.perror("Snowflake::from_integer:snowflake id is not a valid integer, got: %s of type %s" % [new, typeof(new)])
			return
	get:
		if id == null:
			return null
		return str(id)

## Seconds since Discord Epoch, the first second of 2015
var timestamp_ms: int
var worker_id: int
var process_id: int
## For every id that is generated on that process, this number is incremented
var increment: int


## Create a new snowflake from the id of type [String] or [int]
func _init(p_id = null):
	if p_id is Snowflake:
		p_id = p_id.id

	id = p_id

	timestamp_ms = (_int_id >> 22) + DISCORD_EPOCH
	worker_id = (_int_id & 0x3E0000) >> 17
	process_id = (_int_id & 0x1F000) >> 12
	increment = _int_id & 0xFFF

# Get a [Snowflake] from a unix timestamp in seconds
# @returns self
func from_timestamp_seconds(p_timestamp):
	timestamp_ms = p_timestamp * 1000
	_update_id()
	return self


func _to_string() -> String:
	return str(id)


# Get a date time Dictionary from the current snowflake
# @returns [Dictionary]
func get_datetime() -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(timestamp_ms / 1000.0)


# Get a ISO 8601 string from the current snowflake
# @returns [String]
func get_iso_string() -> String:
	return DiscordUtils.datetime_to_iso_string(get_datetime())


static func is_snowflake(snowflake: String) -> bool:
	return snowflake.is_valid_int() and snowflake.length() > 16


# @hidden
func _from_dict(_p_dict: Dictionary):
	_update_id()

	return self


func _update_id():
	id = (timestamp_ms - DISCORD_EPOCH) << 22
	id += worker_id << 17
	id += process_id << 12
	id += increment
