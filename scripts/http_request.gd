extends Node

# Timer used to "simulate" async calls to HTTP
# requests.
var timer = Timer.new()
var timer_interval = 0.7 # seconds

# HTTP method of this request
var http_method = HTTPClient.METHOD_GET

# Path of the request
var path = "/"

# Data to send the request in case it's a POST.
# The data should *only* be:
# 1) Hash
# 2) Array - of primitives, hash or other arrays
var data = null

# Headers of the HTTP request
var headers = [
	"User-Agent: Godot/1.1",
	"Accept: */*"
]

# Actually performs the 
func perform_request():
	pass

# Called when added to the scene tree.
func _ready():
	timer.set_wait_time(timer_interval)
	add_child(timer)
	perform_request()

# Constructor
func _init(_http_method = HTTPClient.METHOD_GET, _path = "/", _data = null):
	http_method = _http_method
	path = _path
	data = _data