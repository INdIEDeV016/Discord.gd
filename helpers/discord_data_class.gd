class_name DiscordDataclass
## Dataclass to be used by Discord objects


func _init(properties = {}):
	if not properties is Dictionary:
		return

	for item in properties:
		if properties[item] == null:
			properties[item] = null
			continue

		if (item as String).ends_with("id"):
			set(item, Snowflake.new(properties[item]))
			continue

		set(item, properties[item])


func _to_string() -> String:
	var string: String = JSON.stringify(to_dict(), "\t", false, true)
	return string


#func get_properties(script: Script):
#	var property_list: Array[Dictionary] = script.get_script_property_list()
##	var constant_map: Dictionary = script.get_script_constant_map()
#	var properties: Dictionary
#	for item in property_list:
#		properties[item.name] = get(item.name)
##	for item in constant_map:
##		if constant_map[item] is Script:
##			properties[item] = get_properties(constant_map[item])
##		else:
##			properties[item] = constant_map[item]
#	return properties
#

func to_dict() -> Dictionary:
	var dictionary: Dictionary = {}

	for property in (get_script() as Script).get_script_property_list():
		if property.name.begins_with("_") or ".gd" in property.name or property.name == "Built-in script":
			continue

		if get(property.name) is DiscordDataclass:
			dictionary[property.name] = get(property.name).to_dict()
			continue
		dictionary[property.name] = get(property.name)

	return dictionary
