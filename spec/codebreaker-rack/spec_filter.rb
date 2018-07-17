# frozen_string_literal: true

require_relative '../spec_helper'
require 'simplecov'
SimpleCov.start

feature Filter do
  describe 'root page' do
    background { visit(Codebreaker::ROOT) }

    context 'returns a 404 error to the user when it tries to access other pages on the site:' do
      status_codes = [Codebreaker::GUESS,
                      Codebreaker::HINT,
                      Codebreaker::PLAY,
                      Codebreaker::CODEBREAKER,
                      Codebreaker::SCORE_GAME,
                      '/lost_page']

      status_codes.each do |url|
        scenario url.to_s do
          visit(url.to_s)
          expect(page.status_code).to eq(404)
        end
      end
    end

    context 'returns the page status (200/404) depending on the current page:' do
      status_codes = { Codebreaker::GUESS => { click_play: 404, click_scores: 404, post_score_game: 404 },
                       Codebreaker::HINT => { click_play: 200, click_scores: 404, post_score_game: 404 },
                       Codebreaker::PLAY => { click_play: 404, click_scores: 404, post_score_game: 404 },
                       Codebreaker::CODEBREAKER => { click_play: 200, click_scores: 404, post_score_game: 404 },
                       Codebreaker::SCORE_GAME => { click_play: 404, click_scores: 404, post_score_game: 200 },
                       Codebreaker::SCORES => { click_play: 200, click_scores: 200, post_score_game: 200 },
                       Codebreaker::ROOT => { click_play: 200, click_scores: 200, post_score_game: 200 } }

      status_codes.each do |url, status|
        scenario "current page '/codebreaker' to '#{url}' => status #{status.fetch(:click_play)}" do
          click_on('P l a y')
          visit(url.to_s)
          expect(page.status_code).to eq(status.fetch(:click_play))
        end
      end

      status_codes.each do |url, status|
        scenario "current page '/scores' to '#{url}' => status #{status.fetch(:click_scores)}" do
          click_on('Scores')
          visit(url.to_s)
          expect(page).to have_current_path(url)
          expect(page.status_code).to eq(status.fetch(:click_scores))
        end
      end

      status_codes.each do |url, status|
        scenario "current page '/score_game' to '#{url}' => status #{status.fetch(:post_score_game)}" do
          click_on('P l a y')
          5.times do
            fill_in('player_code', with: '1234')
            click_on('G u e s s')
          end
          expect(page).to have_current_path(Codebreaker::SCORE_GAME)
          visit(url.to_s)
          expect(page.status_code).to eq(status.fetch(:post_score_game))
        end
      end
    end
  end
end
