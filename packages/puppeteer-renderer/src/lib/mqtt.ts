import mqtt, { MqttClient } from 'mqtt'

export let client: MqttClient | undefined = undefined

export const create = () => {
  const url = process.env.MQTT_SEVER // '127.0.0.1' // emqx
  client = mqtt.connect(`mqtt://${url}`) // create a client
  return client
}
