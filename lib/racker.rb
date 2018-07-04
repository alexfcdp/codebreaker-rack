require 'erb'
require 'yaml'
require 'codebreaker'
require_relative 'constants'

class Racker
  include Codebreaker

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    URL.each do |url|
      if url.key?(@request.path)
        is_symbol = url[@request.path].is_a? Symbol
        return is_symbol ? send(url[@request.path]) : response_to(url[@request.path])
      end
    end
    Rack::Response.new('Not Found', 404)
  end

  def response_to(template)
    Rack::Response.new(render(template))
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def play
    @request.session[:result] = []
    @request.session[:hint] = nil
    @request.session[:name_player] = name_player
    game.start_game
    redirect_to_url(CODEBREAKER.keys)
  end

  def name_player
    unless @request.params['name_player'].nil?
      name = @request.params['name_player'].capitalize
      @request.session[:name_player] = name == '' ? View::PLAYER_NAME : name
    end
    @request.session[:name_player]
  end

  def guess
    @request.session[:result] << { player_code: player_code, result: game.guess }
    path = result_saved? ? SCORE_GAME.keys : CODEBREAKER.keys
    redirect_to_url(path)
  end

  def result_saved?
    if game.loses_game? || game.win?
      game.data_preparation(name_player)
      game.save_score
      return true
    end
    false
  end

  def player_code
    game.player_code = @request.params['player_code']
  end

  def show_hint
    help = game.hint
    @request.session[:hint] = help.nil? ? NO_HINT : help
    redirect_to_url(CODEBREAKER.keys)
  end

  def hint
    @request.session[:hint]
  end

  def scores
    game.read_score
  end

  def score_game
    game.data_processing.result_game
  end

  def game
    @request.session[:game] ||= Game.new
  end

  def result_of_step
    @request.session[:result]
  end

  def size_code
    Game::SIZE_SECRET_CODE
  end

  def attempts_count
    "#{game.count_step}/#{Game::COUNT_MOVES}"
  end

  def redirect_to_url(path)
    Rack::Response.new do |response|
      response.redirect(path)
    end
  end
end
