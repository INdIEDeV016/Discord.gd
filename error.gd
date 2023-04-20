extends Node


var code: int
var errors: Dictionary
var message: String


@warning_ignore("shadowed_global_identifier")
func print(error_code: int, response: Dictionary) -> void:
	code = response.code
	message = response.message
	if response.has("errors"): errors = response.errors
	print_rich("[color=firebrick]XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX[/color]")
	print_rich('[color=yellow]GET: status code [/color]: ', "[color=darksalmon]%s[/color]" % [str(error_code) if error_code >= 0 else "<unknown>"])
	print_rich('[color=red]Error[/color][color=darksalmon] sending GET request: [/color]' + JSON.stringify(response, '\t'))
	print_rich("[color=firebrick]XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX[/color]")


func clear():
	code = 0
	errors = {}
	message = ""
