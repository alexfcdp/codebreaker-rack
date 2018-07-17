# frozen_string_literal: true

require 'slim'
require 'yaml'
require 'codebreaker'

class Racker
  include Codebreaker

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    new_file_path
  end

  def response
    URLS.key?(url) ? URLS[url].call(self) : Rack::Response.new('Not Found', 404)
  end

  def response_to(template)
    Rack::Response.new(render(template))
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    Slim::Template.new(path).render(self)
  end

  def play
    @request.session[:result] = []
    @request.session[:hint] = nil
    @request.session[:name_player] = name_player
    game.start_game
    redirect_to_url(CODEBREAKER)
  end

  def name_player
    unless @request.params['name_player'].nil?
      name = @request.params['name_player'].capitalize
      @request.session[:name_player] = name == '' ? PLAYER_NAME : name
    end
    @request.session[:name_player]
  end

  def guess
    return redirect_to_url(CODEBREAKER) unless code_valid?
    @request.session[:result] << { player_code: game.player_code, result: game.guess.clone }
    result_saved? ? redirect_to_url(SCORE_GAME) : redirect_to_url(CODEBREAKER)
  end

  def result_saved?
    if game.loses_game? || game.win?
      game.data_preparation(name_player)
      game.save_score
      return true
    end
    false
  end

  def code_valid?
    game.player_code = @request.params['player_code']
    game.valid?
  end

  def show_hint
    help = game.hint
    @request.session[:hint] = help || NO_HINT
    redirect_to_url(CODEBREAKER)
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

  def count_hint
    "#{game.count_help}/#{COUNT_HINT}"
  end

  def attempts_count
    "#{game.count_step}/#{COUNT_MOVES}"
  end

  def redirect_to_url(path)
    Rack::Response.new do |response|
      response.redirect(path)
    end
  end

  def new_file_path
    old_file_path = game.instance_variable_get(:@file_path)
    game.instance_variable_set(:@file_path, NEW_FILE_PATH) unless old_file_path == NEW_FILE_PATH
  end

  def url
    @request.path
  end
end
