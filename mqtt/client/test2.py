import paho.mqtt.client as mqtt

# Called when a message is received
def on_message(client, userdata, msg):
    print(f"Received on {msg.topic}: {msg.payload.decode()}")

# Create client and set MQTT version
client = mqtt.Client(protocol=mqtt.MQTTv311)
client.on_message = on_message

# Connect to broker
client.connect("10.0.0.1", 1883)

# Subscribe to a topic
client.subscribe("demo/topic")

# Start network loop (keeps the program running!)
client.loop_forever()

