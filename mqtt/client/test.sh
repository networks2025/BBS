# mosquitto_pub -h 10.0.0.1 -p 1883 -t "demo/topic" -m "Hello classroom!"
mosquitto_sub -h 10.0.0.1 -p 1883 -t "demo/topic"
