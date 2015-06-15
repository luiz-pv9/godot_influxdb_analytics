extends Node

# HTTPRequest has it's own class
var HTTPRequest = preload("http_request.gd")

# Host the server is listening to connections
var host = "localhost"

# Port the server is listening
var port = 80

# Timer used to "simulate" async calls to HTTP
# requests.
var timer = Timer.new()
var timer_interval = 0.3 # seconds

# HTTPClient instance of godot's core HTTP library.
# Will be instantiated in the connect method.
var http_client = null

# Variable that will track status of connection to the
# specified host and port.
var is_connected = false

# Boolean that will indicate if this HTTPHelper is in the
# middle of a request.
var requesting = false

# Time in seconds to abort a connection attempt.
var connection_timeout = 4 # seconds

func can_perform():
	return is_connected and !requesting

# Generate a HTTPRequest instance with the specified arguments.
# THe request is only made when the node is added to the scene tree (_ready is called).
func generate_request(http_method = HTTPClient.METHOD_GET, path = "/", data = null):
	var request = HTTPRequest.new(http_method, path, data)
	add_child(request)
	return request

# Since HTTP is streamed over a TCP connection, it's necessary
# to establish the connection with the server before sending
# any requests. 
# This method tries to connect to the server.
func connect_to_server():
	is_connected = false
	http_client = HTTPClient.new()
	var err = http_client.connect(host, port)
	if err == OK:
		print("Connection start...")
	else:
		print("Failed to connect to server at url: " + host + ":" + str(port))
		return

	# Apparently there is no timeout in the HTTPClient class, which is what happens
	# when you try to connect a non-existing server (it keeps the STATUS_CONNECTING forever).
	# Timeout is checked using the variable connection_timeout
	var time_passed = 0.0 # Used to track time
	timer.start()
	while(http_client.get_status() == HTTPClient.STATUS_CONNECTING or 
		http_client.get_status() == HTTPClient.STATUS_RESOLVING):
		http_client.poll()
		print("Trying to connect... status: " + str(http_client.get_status()))
		yield(timer, "timeout")
		time_passed += timer.get_wait_time()
		if time_passed > connection_timeout:
			break
	timer.stop()

	if http_client.get_status() == HTTPClient.STATUS_CONNECTED:
		print("Connection established!")
		is_connected = true
		emit_signal("connected")
	else:
		print("Failed to connect at url: " + host + ":" + str(port))

# _ready is called when the script is added to the scene tree.
# This is necessary because the timer must be in the scene tree
# to emit timeout signals.
func _ready():
	timer.set_wait_time(timer_interval)
	add_child(timer)

# Constructor
func _init(_host = "localhost", _port = 80, _parent = null):
	host = _host
	port = _port
	print(_host)
	print(port)
	add_user_signal("connected")
	if _parent != null:
		_parent.add_child(self)

# Here are some helper methods to perform GET and POST requests in one call
func GET(path):
	if !is_connected:
		connect_to_server()
	var request = generate_request(HTTPClient.METHOD_GET, path)
	request.perform()
	return request