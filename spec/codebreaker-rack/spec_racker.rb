# frozen_string_literal: true

require_relative '../spec_helper'
require 'simplecov'
SimpleCov.start

feature Racker do
  describe 'root page' do
    background { visit(Codebreaker::ROOT) }

    context 'show the root page to start the game' do
      scenario { expect(page).to have_title('Welcome') }
      scenario { expect(page).to have_content('Codebreaker') }
      scenario { expect(page).to have_button('P l a y') }
      scenario { expect(page).to have_link('Scores') }
    end

    context 'displays the players name on the page /codebreaker' do
      scenario 'displays the name: \'Alex\' that the player entered' do
        fill_in('name_player', with: 'alex')
        click_button('P l a y')
        expect(page).to have_content('Welcome Alex')
      end
      scenario "displays the name: '#{Codebreaker::PLAYER_NAME}' if the player has not entered" do
        click_button('P l a y')
        expect(page).to have_content("Welcome #{Codebreaker::PLAYER_NAME}")
      end
    end

    context 'show the page /codebreaker, after entering the players name' do
      background { click_button('P l a y') }

      scenario { expect(page).to have_content('Codebreaker') }
      scenario { expect(page).to have_button('G u e s s') }
      scenario { expect(page).to have_button('H i n t') }
      scenario { expect(page).to have_content('You used 0/5 attempts') }
      scenario { expect(page).to have_link('Exit the game') }
      scenario { expect(page).to have_field('player_code') }
      scenario { expect(page).to have_selector('input.btn.btn-warning') }
      scenario { expect(page).to have_selector('input.form-control') }
      scenario { expect(page).to have_title('Codebreaker') }
      scenario { expect(page).to have_selector("input[value='0/1']") }
      scenario { expect(page).to have_field('player_code', placeholder: Codebreaker::INPUT_CONDITION.to_s) }
      scenario 'displays the result in the table after clicking on the button \'Guess\'' do
        fill_in('player_code', with: '1234')
        click_button('G u e s s')
        expect(page).to have_content('Attempts:')
        expect(page).to have_table('result_of_step')
        expect(page).to have_content('You used 1/5 attempts')
      end
      scenario 'displays information that a player entered an not valid code' do
        fill_in('player_code', with: '9999')
        click_button('G u e s s')
        expect(page).to have_content(Codebreaker::INPUT_CONDITION)
        expect(page).to have_content('You used 0/5 attempts')
      end
      scenario 'show the contents of the guessing results table' do
        %w[1234 5634 6521 2356].each do |code|
          fill_in('player_code', with: code)
          click_on('G u e s s')
        end
        expect(page).to have_content('You used 4/5 attempts')
        expect(page).to have_selector('span')
        results = page.find('table').all('td').map(&:text).join(',')
        %w[1234 5634 6521 2356 + - _].each do |value|
          expect(results).to include(value)
        end
      end
      scenario 'returns to the root page after clicking on the button \'Exit the game\'' do
        click_on('Exit the game')
        expect(page).to have_current_path(Codebreaker::ROOT)
      end
      scenario 'pressing the button \'Hint\'' do
        click_button('H i n t')
        expect(page).to have_selector("input[value='1/1']")
        click_button('H i n t')
        expect(page).to have_selector("input[value='All hints are exhausted']")
      end
    end

    context 'show the contents of the page /score_game' do
      background do
        click_on('P l a y')
        5.times do
          fill_in('player_code', with: '1234')
          click_on('G u e s s')
        end
      end
      scenario { expect(page).to have_title('Score game') }
      scenario { expect(page).to have_link('Home Page') }
      scenario { expect(page).to have_link('Scores') }
      scenario { expect(page.find('table').visible?).to eq true }
      scenario { expect(page.find_link('Home Page').visible?).to eq true }
      scenario { expect(page.find_link('Scores').visible?).to eq true }
      scenario { expect(page.find_link('Home Page').disabled?).to eq false }
      scenario { expect(page.find_link('Scores').disabled?).to eq false }
      scenario { expect(page).to have_table('score_game') }
      scenario do
        values = page.find('table').all('td').map(&:text)
        time = Time.now.strftime('%Y-%m-%d %H:%M')
        %W[Player #{time} Lose! 0/1 5/5].each do |a|
          expect(values).to include(a)
        end
        expect(values.size).to eq(7)
      end
    end

    context 'show the contents of the page /scores' do
      background do
        file_path = File.expand_path('../../result.yml', __dir__)
        @scores = YAML.safe_load(File.read(file_path))
        click_on('Scores')
      end

      let(:thead_keys) { page.find('table').all('tr th').map(&:text).join(',')[2..-1] }
      let(:tbody_values) { page.find('table').all('td').map(&:text).join(',') }
      let(:scores_values) { @scores.map(&:values).join(',') }
      let(:scores_keys) { @scores.map(&:keys).first.join(',') }

      scenario { expect(page).to have_title('Scores') }
      scenario { expect(page).to have_content("Games results 'Codebreaker'") }
      scenario { expect(page).to have_link('Home Page') }
      scenario { expect(page).to have_selector('table thead tr') }
      scenario { expect(page).to have_selector('table tbody tr') }
      scenario { expect(page.find('table').visible?).to eq(true) }
      scenario { expect(page.find_link('Home Page').visible?).to eq(true) }
      scenario { expect(page.find_link('Home Page').disabled?).to eq(false) }
      scenario { expect(page).to have_table('scores') }
      scenario 'checks the data of the results table on the page' do
        expect(scores_keys).to eq(thead_keys)
        expect(scores_values).to eq(tbody_values)
      end
    end
  end
end
