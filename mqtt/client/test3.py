import paho.mqtt.client as mqtt

def on_message(client, userdata, msg):
    print(f"Received: {msg.payload.decode()}")

client = mqtt.Client()
client.on_message = on_message
client.connect("10.0.0.1", 1883)
client.subscribe("demo/topic")

client.loop_forever()
