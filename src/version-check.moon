receive = love.thread.getChannel "send"
send = love.thread.getChannel "receive"

http = require "socket.http"
json = require "lib.json"
require "love.timer"

current_version = receive\demand!
complete = false

while not complete
  body, status = http.request "http://104.236.139.220:16343/get/https://itch.io/api/1/x/wharf/latest?target=guard13007/scp-clicker&channel_name=win32"

  if status == 200
    latest_version = (json.decode body).latest
    send\push latest_version
    complete = true
  else
    send\push "error"
    love.timer.sleep 2 -- wait two seconds before trying again

-- after we're done, we start checking every half hour
bypass = false
while true
  if bypass
    bypass = false
  else
    love.timer.sleep 60*30

  body, status = http.request "http://104.236.139.220:16343/get/https://itch.io/api/1/x/wharf/latest?target=guard13007/scp-clicker&channel_name=win32"

  if status == 200
    latest_version = (json.decode body).latest
    send\push latest_version
  else
    send\push "error"
    bypass = true
    love.timer.sleep 2
