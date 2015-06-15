extends Node

# Name of the database to insert events on
var influxdb_database = "game_development"

# Name of the series to insert gameplay events.
# Usually, number of downloads, opening and closing the game 
# and other activities will be stored in a different time series.
var influxdb_event_series = "ingame_events"

# If log_events is set to true, all events will
# be logged to console before sending.
var log_events = true

# If log_requests is set to true, a message of success
# or failure will be printed after each HTTP request.
var log_requests = true

# HTTPHelper script. Should be in the same directory of the
# influxdb.gd script.
var HTTPHelper = preload("http_helper.gd")

# HTTPHelper was designed to provide a better API (than HTTPClient)
# for dealing with HTTP requests.
var http_helper = null

# If there is any property that is the same across all events (user_id, app_name, etc)
# it's better to set in the global_properties.
# This hash will be merged into every event before sending them.
var global_properties = {}

# Constructor. Initializes host and port that InfluxDB is running.
func _init(host="localhost", port=8083):
	http_helper = HTTPHelper.new(host, port)
	
func _ready():
	add_child(http_helper)