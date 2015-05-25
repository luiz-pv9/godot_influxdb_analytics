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
var timer_interval = 0.7 # seconds

# HTTPClient instance of godot's core HTTP library.
# Will be instantiated in the connect method.
var http_client = null

# Variable that will track status of connection to the
# specified host and port.
var is_connected = false

# Since HTTP is streamed over a TCP connection, it's necessary
# to establish the connection with the server before sending
# any requests. 
# This method tries to connect to the server.
func connect():
	is_connected = false
	http_client = HTTPClient.new()
	var err = http_client.connect(host, port)
	if err == OK:
		print("Connection start...")
	else:
		print("Failed to connect to server at url: " + host + ":" + str(port))
		return

	timer.start()
	while(http_client.get_status() == HTTPClient.STATUS_CONNECTING or 
		http_client.get_status() == HTTPClient.STATUS_RESOLVING):
		http_client.poll()
		yield(timer, "timeout")
	timer.stop()

	if http_client.get_status() == HTTPClient.STATUS_CONNECTED:
		is_connected = true
		print("Connection established!")
	else:
		print("Failed to connect to InfluxDB at url: " + host + ":" + str(port))

# _ready is called when the script is added to the scene tree.
# This is necessary because the timer must be in the scene tree
# to emit timeout signals.
func _ready():
	timer.set_wait_time(timer_interval)
	add_child(timer)

# Constructor
func _init(_host = "localhost", _port = 80):
	host = _host
	port = _port