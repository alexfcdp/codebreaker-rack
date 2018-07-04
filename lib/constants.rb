module Codebreaker
  NO_HINT = 'All hints are exhausted'.freeze
  INPUT_CONDITION = "Enter the code from #{Game::SIZE_SECRET_CODE} numbers from 1 to 6".freeze
  COLOR_TABLE_ROWS = %w[ table-success table-danger table-warning table-primary
                         table-active table-secondary table-info table-light].freeze
  MAIN = { '/' => 'index.html.erb' }.freeze
  CODEBREAKER = { '/codebreaker' => 'codebreaker.html.erb' }.freeze
  SCORES = { '/scores' => 'scores.html.erb' }.freeze
  SCORE_GAME = { '/score_game' => 'score_game.html.erb' }.freeze
  PLAY = { '/play' => :play }.freeze
  GUESS = { '/guess' => :guess }.freeze
  HINT = { '/hint' => :show_hint }.freeze
  URL = [MAIN, CODEBREAKER, SCORES, SCORE_GAME, PLAY, GUESS, HINT].freeze
end
