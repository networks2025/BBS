# run on same machine
mosquitto_pub -h 10.0.0.1 -t "updates/now" -m "MQTT works!"
mosquitto_sub -h 10.0.0.1 -t "updates/now"
