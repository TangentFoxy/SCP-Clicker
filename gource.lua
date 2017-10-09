os.execute([[gource -960x540 --auto-skip-seconds 1 --key --title "SCP Clicker development" --output-custom-log out.txt]])

local file = io.open('out.txt', 'r')
local buffer = ""

local patterns = {
  "|/icons%-inverted/",
  "|/icons/",
  "|/icons%-resources%-toggles/",
  "|/icons%-scps%-events/",
}

for line in file:lines() do
  local useline = true
  for _, pattern in ipairs(patterns) do
    if line:find(pattern) then
      useline = false
    end
  end
  if useline then
    buffer = buffer .. "\n" .. line
  end
end

file:close()

buffer = buffer:gsub("Paul Liverman III", "Guard13007"):gsub("/Fox %-%-develop", "Guard13007"):gsub("Fox", "Guard13007"):sub(2) .. "\n"

file = io.open('log.txt', 'w')
file:write(buffer)
file:close()

os.execute([[gource -960x540 --auto-skip-seconds 1 --key --title "SCP Clicker development" ./log.txt]])
