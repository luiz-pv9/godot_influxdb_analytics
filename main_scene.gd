extends Node2D

var InfluxDB = preload("scripts/influxdb.gd")

# Instance of InfluxDB
var analytics = null

func _series1_pressed():
	analytics.http_helper.get("/")
	
func _series2_pressed():
	print("Pressed series 2")
	
func _connect_pressed():
	analytics.http_helper.connect()

func _ready():
	analytics = InfluxDB.new("localhost", 8083)
	add_child(analytics)
	
	get_node("Series1_btn").connect("pressed", self, "_series1_pressed")
	get_node("Series2_btn").connect("pressed", self, "_series2_pressed")
	get_node("Connect_btn").connect("pressed", self, "_connect_pressed")