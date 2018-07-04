require_relative 'constants'

class Filter
  include Codebreaker
  def initialize(app)
    @app = app
  end

  def call(env)
    @request = Rack::Request.new(env)
    path = @request.path.delete('/')
    if include_path? && send("url_#{path}_access?".to_sym)
      @app.call(env)
    else
      Rack::Response.new('Not Found', 404)
    end
  end

  def include_path?
    URL.each do |url|
      return true if url.key?(@request.path)
    end
    false
  end

  def url__access?
    @request.session.clear
    true
  end

  def url_guess_access?
    @request.params['player_code'].nil? ? false : true
  end

  def url_hint_access?
    game_not_over?
  end

  def url_play_access?
    @request.params['name_player'].nil? ? false : true
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
    return false if game.nil? || game.player_code == ''
    game.win? || game.loses_game?
  end

  def game_not_over?
    result.is_a?(Array) && !game.loses_game? && !game.win?
  end

  def game
    @request.session[:game]
  end

  def result
    @request.session[:result]
  end
end
