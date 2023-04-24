class_name DiscordHelpers

## General purpose helper functions
## used by discord.gd plugin.

var Months: = {
	1 : "January",
	2 : "February",
	3 : "March",
	4 : "April",
	5 : "May",
	6 : "June",
	7 : "July",
	8 : "August",
	9 : "September",
	10 : "October",
	11 : "November",
	12 : "December"
}

var Weekdays: = {
	0 : "Sunday",
	1 : "Monday",
	2 : "Tuesday",
	3 : "Wednesday",
	4 : "Thursday",
	5 : "Friday",
	6 : "Saturday"
}

var Day: = {
	0 : "Yesterday",
	1 : "Today",
	2 : "Tomorrow"
}

# Returns true if value if an int or real float
static func is_num(value) -> bool:
	return value is int or value is float


# Returns true if value is a string
static func is_str(value) -> bool:
	return value is String


# Returns true if the string has more than 1 character
static func is_valid_str(value) -> bool:
	return is_str(value) and value.length() > 0


static func is_valid_url(url) -> bool:
		if url is String and url.begins_with("http"):
			return true
#		push_error("Malformed Url: %s" % url)
		return false

static func set_color(color: Color) -> int:
	return color.to_html(false).hex_to_int()

static func set_color_html(html: String) -> int:
	if html.is_valid_html_color():
		return html.hex_to_int()
	push_error("Bad html color provided, can't convert to a proper color. Returning 0")
	return 0

static func get_color(hex: int) -> Color:
#	color_int = r*65536 + g*256 + b
	return Color(int_to_hex(hex))


# Pretty prints a Dictionary
static func print_dict(d: Dictionary) -> void:
	print_debug("-------------------\n" + JSON.stringify(d, '\t') + "\n--------------------")


static func get_string_from_dict_or_array(dictionary_or_array, sort_keys: = true):
	return JSON.stringify(dictionary_or_array, "\t", sort_keys, true)


# Saves a Dictionary to a file for debugging large dictionaries
func save_dict(d: Dictionary, filename = 'saved_dict') -> void:
	assert(typeof(d) == TYPE_DICTIONARY, 'type of d is not Dictionary in save_dict')
	var file: = FileAccess.open('user://%s%s.json' % [filename, str(Time.get_ticks_msec())], FileAccess.WRITE)
	file.store_string(JSON.stringify(d, '\t'))
	file.close()
	print('Dictionary saved to file')


# Converts a raw image bytes to a png Image
static func to_png_image(bytes: PackedByteArray) -> Image:
	var image = Image.new()
	image.load_png_from_buffer(bytes)
	return image


static func to_jpg_image(bytes: PackedByteArray) -> Image:
	var image = Image.new()
	image.load_jpg_from_buffer(bytes)
	return image


# Converts a Image to ImageTexture
static func to_image_texture(image: Image) -> ImageTexture:
	return ImageTexture.create_from_image(image)


# Ensures that the String's length is less than or equal to the specified length
#static func assert_length(variable: String, length: int, msg: String):
#	assert(variable.length() <= length, msg)


# Convert the ISO string to a unix timestamp
static func iso2unix(iso_string: String, utc: = false) -> int:
	var date := Array(iso_string.get_slice("T", 0).split("-"))
	var time := Array(iso_string.get_slice("T", 1).trim_suffix("Z").split(":"))

	if not utc:
		var time_zone: = {
			add = Time.get_offset_string_from_offset_minutes(Time.get_time_zone_from_system().bias)[0] == "+",
			hour = Time.get_offset_string_from_offset_minutes(Time.get_time_zone_from_system().bias).get_slice(":", 0).to_int(),
			minute = Time.get_offset_string_from_offset_minutes(Time.get_time_zone_from_system().bias).get_slice(":", 1).to_int()
		}
#		print_debug(time)
		if time_zone.add:
			time[0] = time[0].to_int() + time_zone.hour
			time[1] = time[1].to_int() + time_zone.minute
		else:
			time[0] = time[0].to_int() - time_zone.hour
			time[1] = time[1].to_int() - time_zone.minute
#
		time[0] += int(time[1] / 60)
		date[2] = date[2].to_int()
		date[2] += int(date[2] / 24)
		time[0] = int(time[0] % 24)
		time[1] = int(time[1] % 60)

#			iso_string = date[0] + "-" + date[1] + "-" + date[2] + "T" + time[0] + ":" + time[1] + ":" + time[2] + ("+" if time_zone.add else "-") + time_zone.hour + ":" + time_zone.minute
#		print_debug(iso_string)

	var datetime: = {
		year = date[0].to_int() if date[0] is String else date[0],
		month = date[1].to_int() if date[1] is String else date[1],
		day = date[2].to_int() if date[2] is String else date[2],
		hour = time[0].to_int() if time[0] is String else time[0],
		minute = time[1].to_int() if time[1] is String else time[1],
		second = time[2].get_slice("+", 0).to_int(),
	}
#	print_debug(datetime)
	return Time.get_unix_time_from_datetime_dict(datetime)

# Return a ISO 8601 timestamp as a String
static func make_iso_string(datetime: Dictionary = Time.get_date_dict_from_system(true)) -> String:
	var iso_string = '%s-%02d-%02dT%02d:%02d:%02d' % [datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute, datetime.second]

	return iso_string

static func get_pretty_datetime(
	iso_timestamp: String,
	template: = {
		full_date = false,
		airport_format = false,
		capital_am_pm = true,
		date = "{month}/{day}/{year}",
		time = "{day} at {hour}:{minute} {am/pm}"
	}
) -> Array[String]:
	var helpers: = DiscordHelpers.new()
	var datetime: = Time.get_datetime_dict_from_unix_time(iso2unix(iso_timestamp))
	var system_date: = Time.get_date_dict_from_system()
	var array: Array[String] = []

	if template.has("date"):
		array.append(template.date.format(
			{
				day = ("%02d" % datetime.day) if not template.full_date else ("%01d%s" % [datetime.day, "st" if datetime.day == 1 else "nd" if datetime.day == 2 else "rd" if datetime.day == 3 else "th"]),
				month = ("%02d" % datetime.month) if not template.full_date else helpers.Months[datetime.month],
				year = "%04d" % datetime.year,
				weekday = helpers.Weekdays[datetime.weekday]
			}
		).strip_edges())
	if template.has("time"):
		array.append(template.time.format(
			{
				day = helpers.Day[0 if system_date.day == datetime.day + 1 else 1 if system_date.day == datetime.day else 2 if system_date.day == datetime.day - 1 else 1],
				hour = "%02d" % datetime.hour if template.airport_format else ("%02d" % [datetime.hour - 12 if datetime.hour > 12 else datetime.hour]),
				minute = "%02d" % datetime.minute,
				second = "%02d" % datetime.second,
				"am/pm" = (("AM" if template.capital_am_pm else "am") if datetime.hour < 12 else ("PM" if template.capital_am_pm else "pm")) if not template.airport_format else ""
			}
		).strip_edges())
	return array

static func get_discord_datetime_string(iso_timestamp: String) -> String:
	var datetime: = Time.get_datetime_dict_from_unix_time(iso2unix(iso_timestamp))
	var system_date: = Time.get_date_dict_from_system()
#	print_debug(get_pretty_datetime(iso_timestamp))
	var final_datetime: = get_pretty_datetime(iso_timestamp)
	if ((system_date.day - datetime.day) * signi(system_date.day - datetime.day)) > 2:
		return final_datetime[0]
	else:
		return final_datetime[1]

static func time_diff_in_seconds_between(from, to) -> int:
	from = Time.get_datetime_dict_from_unix_time(iso2unix(from))
	to = Time.get_datetime_dict_from_unix_time(iso2unix(to))

	if from.day == to.day\
			and from.month == to.month\
			and from.year == to.year:
		var difference = (from.hour*60 + from.minute*60 + from.second) - (to.hour*60 + to.minute*60 + to.second)
		if signi(difference) != -1:
			return difference

	return int(2**32)

static func do_recursive(root: Object, function: Callable, do_on_self: bool = false) -> Array:
	var return_array: = []
	if root is TreeItem:
		if do_on_self:
			return_array = [(function.call(root))]
		for tree_item in root.get_children():
			return_array.append(function.call(tree_item))
			if tree_item.get_child_count() > 0:
				return_array += do_recursive(tree_item, function, do_on_self)

	return return_array


static func int_to_hex(num: int) -> String:
	var conversion_table = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a' , 'b', 'c', 'd', 'e', 'f']
	var hexadecimal = ''

	var decimal: int = num
	var remainder = -1
	while decimal > 0:
		remainder = decimal % 16
		hexadecimal = conversion_table[remainder] + hexadecimal
		decimal = int(decimal / 16.0)

	return "#" + hexadecimal
