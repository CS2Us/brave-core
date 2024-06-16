const fs = require('fs')
const https = require('node:https')
const config = require('../lib/config')
const path = require('path')
const zipPath = path.join(config.braveCoreDir, 'vendor') + '/depot_tools.zip'

if (process.platform != "win32") { return }
if (fs.existsSync(zipPath)) { return }
let ws = fs.createWriteStream(zipPath)
https.get(config.depotToolsRepo, (response)=>{
  response.pipe(ws)
})