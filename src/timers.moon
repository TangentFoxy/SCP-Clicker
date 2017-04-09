import after, every from require "lib.cron"

local timers

timers = {
  after: (...) ->
    table.insert timers, after ...
  every: (...) ->
    table.insert timers, every ...
  constant: (fn, ...) ->
    table.insert timers, {
      update: (self, dt, ...) ->
        fn dt, ...
    }
}

return timers
