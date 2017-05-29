local data

data = {
  cash: 200
  cash_rate: 2.5
  cash_multiplier: 0

  research: 0
  research_rate: 0
  research_multiplier: 0

  danger: 0.02
  danger_rate: 0
  danger_multiplier: 1/8

  icons: {}
  -- cleared really just means "has triggered at least once before"
  cleared_scps: {}
  cleared_randoms: {}
  scp_multiples: {}
  scp_descriptions: {}

  scp_count: 0
  savings_accounts: 0
  bank_count: 0
  agent_count: 0
  expedition_running: false
  expedition_progress: 0
  agent_rehire_enabled: false
  class_d_count: 0
  automatic_expeditions: false
  syringe_usage: false
  ronald_regan: false
  book_of_endings: false
  scp092_researched_count: 0
  automatic_research: false
  automatic_class_d: false

  version: 4
}

return data
