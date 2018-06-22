love.conf = (t) ->
  t.title = "SCP Clicker"
  t.identity = "scp-clicker"

  t.releases = {
    loveVersion: "0.10.2"
    author: "Guard13007"
    identifier: "com.guard13007.scp-clicker"
    excludeFileList: {
      '.-%.md$', '.-%.css$', '.-%.html$', '.-%.rockspec$', '.-%.luadoc$', '.-%.ld$',
      '.-%.sh$', '.-%.txt$', '.-%.yml$', '.-%.moon$'
    }
  }

  t.window = {
    width: 960
    height: 540
  }
  -- t.window.width = 960
  -- t.window.height = 540

  -- t.build = {} -- TODO finish writing this

    -- title = 'Game Name',
    -- package = 'game',
    -- version = "v1.2.0",
    -- email = "someone@example.com",
    -- description = "A game that does things.",
    -- homepage = "https://example.com/",
