# If the client drops offline — the message is lost.
mosquitto_pub -h 10.0.0.1 -t "sensor/temp" -m "20°C" -q 0
#If the message isn’t acknowledged, the broker/client will retry — but it may arrive more than once.
mosquitto_pub -h 10.0.0.1 -t "sensor/temp" -m "20°C" -q 1
# Full handshake between publisher and broker (and subscriber, if subscribing with -q 2). Guarantees delivery exactly once.
mosquitto_pub -h 10.0.0.1 -t "sensor/temp" -m "20°C" -q 2


