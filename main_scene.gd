extends Node2D

var HTTPHelper = preload("scripts/http_helper.gd")

# Instance of HTTPHelper to make the request
var http_helper = null

func _series1_pressed():
	var http_helper = HTTPHelper.new("localhost", 4567)
	add_child(http_helper)
	http_helper.connect_to_server()
	yield(http_helper, "connected")
	var request = http_helper.generate_request(HTTPClient.METHOD_POST, "/", {"b": 10})
	request.perform()
	yield(request, "after_response")
	print(request.response_body)

func _connect():
	http_helper.connect_to_server()
	
func _request():
	var request = HTTPHelper.new("localhost", 80, self).GET("/")
	yield(request, "after_response")
	
func _update_status():
	http_helper.http_client.poll()
	var status = http_helper.http_client.get_status()
	get_node("StatusValue_label").set_text(str(status))

func _ready():
	# http_helper = HTTPHelper.new("www.google.com", 80)
	get_node("Connect_btn").connect("pressed", self, "_connect")
	get_node("Request_btn").connect("pressed", self, "_request")
	get_node("UpdateStatus_btn").connect("pressed", self, "_update_status")