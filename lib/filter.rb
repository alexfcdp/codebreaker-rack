# frozen_string_literal: true

require_relative 'constants'

class Filter
  include Codebreaker
  def initialize(app)
    @app = app
  end

  def call(env)
    @request = Rack::Request.new(env)
    include_path? ? @app.call(env) : Rack::Response.new('Not Found', 404)
  end

  def include_path?
    return true if url_root_access?
    path = url.delete(ROOT)
    URLS.key?(url) && send("url_#{path}_access?".to_sym)
  end

  def url_root_access?
    return false unless url == ROOT
    @request.session.clear
    true
  end

  def url_guess_access?
    @request.params['player_code'] ? true : false
  end

  def url_hint_access?
    game_not_over?
  end

  def url_play_access?
    @request.params['name_player'] ? true : false
  end

  def url_codebreaker_access?
    game_not_over?
  end

  def url_scores_access?
    true
  end

  def url_score_game_access?
    game_over?
  end

  def game_over?
    return false unless game.player_code
    game.win? || game.loses_game?
  end

  def game_not_over?
    result.is_a?(Array) unless game_over?
  end

  def game
    @request.session[:game]
  end

  def result
    @request.session[:result]
  end

  def url
    @request.path
  end
end
