receive = love.thread.getChannel "send"
send = love.thread.getChannel "receive"

http = require "socket.http"
json = require "lib.json"
v = require "lib.semver"

current_version = v receive\demand!

body, status = http.request "http://104.236.139.220:16343/get/https://itch.io/api/1/x/wharf/latest?target=guard13007/scp-clicker&channel_name=win32"

if status == 200
  latest_version = v (json.decode body).latest
  if current_version == latest_version
    send\push "Current version: #{tostring current_version} Latest version: #{tostring latest_version} You have the latest version. :D"
  else
    send\push "Current version: #{tostring current_version} Latest version: #{tostring latest_version} There is a newer version available!"
else
  send\push "Current version: #{tostring current_version} Latest version: Connection error while getting latest version."
