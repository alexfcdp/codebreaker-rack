# frozen_string_literal: true

module Codebreaker
  NEW_FILE_PATH = File.expand_path('../result.yml', __dir__).freeze
  COLOR_TABLE_ROWS = %w[ table-success table-danger table-warning table-primary
                         table-active table-secondary table-info table-light].freeze
  ROOT = '/'
  CODEBREAKER = '/codebreaker'
  SCORES = '/scores'
  SCORE_GAME = '/score_game'
  PLAY = '/play'
  GUESS = '/guess'
  HINT = '/hint'
  URLS = {
    ROOT => ->(racker) { racker.response_to('index.slim') },
    CODEBREAKER => ->(racker) { racker.response_to('codebreaker.slim') },
    SCORES => ->(racker) { racker.response_to('scores.slim') },
    SCORE_GAME => ->(racker) { racker.response_to('score_game.slim') },
    PLAY => ->(racker) { racker.play },
    GUESS => ->(racker) { racker.guess },
    HINT => ->(racker) { racker.show_hint }
  }.freeze
end
