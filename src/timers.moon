import after, every from require "lib.cron"

local timers

timers = {
  after: (...) ->
    table.insert timers, after ...
  every: (...) ->
    table.insert timers, every ...
  continuous: (fn, ...) ->
    table.insert timers, {
      update: (self, dt, ...) ->
        fn dt, ...
    }
  remove: (timer) ->
    for i=1, #timers
      if timers[i] == timer
        table.remove timers, i
        return

    error "Invalid timer specified."
}

return timers
