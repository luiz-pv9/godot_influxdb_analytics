extends Node

# Reference to HTTPHelper class to check for inheritance
var HTTPHelper = preload("http_helper.gd")

# HTTP method of this request
var http_method = HTTPClient.METHOD_GET

# Path of the request
var path = "/"

# Data to send the request in case it's a POST.
# The data should *only* be:
# 1) Hash
# 2) Array - of primitives, hash or other arrays
var data = null

# Variables that will store the response from the server after sending
# the request. The user should check this variable after the signal
# "after_response" is emitted.
var response_code = ""
var response_headers = {}
var response_body = ""

# If the request is a POST request, it's necessary to specify the Content-Length
# in the headers. This variable keeps track of the raw content in the request body
# that will be send to the server, and Content-Length is just the length of this
# string.
var request_raw_content = ""

# Headers of the HTTP request
var headers = [
	"User-Agent: Pirulo/1.0 (Godot)",
	"Accept: */*",
	"Connection: keep-alive"
]

func _clear_parent_after_request():
	get_parent().requesting = false

# Called by perform
# Adds the Content-Length header from the request_raw_content string length
# request_raw_content was set by the _encode_data method called by _init
func _add_content_length_to_headers():
	add_header("Content-Length: " + str(request_raw_content.length()))

# Add the specified header to the headers array.
func add_header(header):
	headers.push_back(header)

# Performs the HTTP request and, if it's the case, waits for the response
# body and parses it to a string.
func perform():
	if !get_parent().can_perform():
		print("Could not perform request. Create a new instance of HTTPHelper or wait until the current finishes.")
		return _clear_parent_after_request()

	# Flag to indicate the HTTPHelper is busy doing this request.
	get_parent().requesting = true

	var http_client = get_parent().http_client
	var timer = get_parent().timer
	
	if http_method == HTTPClient.METHOD_POST:
		_add_content_length_to_headers()
	
	var err = http_client.request(http_method, path, headers, request_raw_content)
	if err != OK:
		print("Could not perform request.")
		return _clear_parent_after_request()

	timer.start()
	while (http_client.get_status() == HTTPClient.STATUS_REQUESTING):
		http_client.poll()
		yield(timer, "timeout")
	timer.stop()
	
	if http_client.get_status() != HTTPClient.STATUS_BODY and http_client.get_status() != HTTPClient.STATUS_CONNECTED:
		print("Failed to perform request.")
		return _clear_parent_after_request()
	
	var rb = RawArray()
	if http_client.has_response():
		timer.start()
		while(http_client.get_status() == HTTPClient.STATUS_BODY):
			http_client.poll()
			var chunk = http_client.read_response_body_chunk()
			if(chunk.size() == 0):
				yield(timer, "timeout")
			else:
				rb = rb + chunk
		timer.stop()
	
	response_code = http_client.get_response_code()
	response_headers = http_client.get_response_headers_as_dictionary()
	response_body = rb.get_string_from_utf8()
	emit_signal("after_response")
	return _clear_parent_after_request()

# When sending data through a POST request, the body of the request
# must be a string (usually JSON). This method parses the data variable to
# a string.
func _encode_data():
	var td = typeof(data)
	if td == TYPE_DICTIONARY or td == TYPE_ARRAY:
		var wrapped_json = {"a": data}.to_json()
		# It starts at 5 because:
		# 01234
		# {"a":
		# The second argument is actually the length from the starting index and
		# *not* the end index.
		request_raw_content = wrapped_json.substr(5, wrapped_json.length() - 5 - 1)
	elif td == TYPE_STRING:
		request_raw_content = data

# Called when added to the scene tree.
func _ready():
	if !(get_parent() extends HTTPHelper):
		print("HTTPRequest must be a child of HTTPHelper")

# Constructor
func _init(_http_method = HTTPClient.METHOD_GET, _path = "/", _data = null):
	http_method = _http_method
	path = _path
	data = _data
	_encode_data()
	add_user_signal("after_response")