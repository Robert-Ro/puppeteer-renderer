/* eslint-disable no-case-declarations */
import { writeFile } from 'fs'
import { renderer } from './lib/renderer'
import { pageViewportSchema, screenshotSchema } from './lib/validate-schema'
import { create as createMqttClient } from './lib/mqtt'

const mqttClient = createMqttClient()
mqttClient.on('connect', () => {
  console.log('mqtt connect')
  mqttClient.subscribe('screenshot', err => {
    if (!err) {
      mqttClient.publish('screenshot', 'Hello mqtt')
    }
  })
})
mqttClient.on('error', e => {
  console.log('error', e)
})

mqttClient.on('disconnect', () => {
  // message is Buffer
  console.log('mqtt disconnect')
})

mqttClient?.on('message', async (topic, message) => {
  // message is Buffer
  console.log(message.toString(), topic)
  switch (topic) {
    case 'screenshot':
      const pageViewportOptions = pageViewportSchema.validateSync({ width: 400, height: 400 })
      const screenshotOptions = screenshotSchema.validateSync({ type: 'webp' })
      if (!renderer) return
      const { type, buffer } = await renderer.screenshot(
        message.toString(),
        {
          timeout: 30000,
          waitUntil: 'load',
          credentials: {
            username: '',
            password: '',
          },
        },
        pageViewportOptions,
        screenshotOptions,
      )
      writeFile(`./test.${type}`, buffer, e => {
        if (e) {
          console.log(e)
        }
      })
      break

    default:
      break
  }
})
