import paho.mqtt.client as mqtt

#client = mqtt.Client()
client = mqtt.Client(protocol=mqtt.MQTTv311) 
client.connect("10.0.0.1", 1883)

client.publish("demo/topic", "Hello from Python!")

client.disconnect()


