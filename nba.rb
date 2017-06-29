require 'awesome_print'
# frozen_string_literal: true

require 'xmlstats'
require 'date'
require 'json'
require 'colorize'

# NBA class
class Nba
  attr_accessor :favorite_team

  def initialize
    Xmlstats.api_key = ENV['XMLSTATS_API_KEY']
    Xmlstats.contact_info = ENV['XMLSTATS_CONTACT_INFO']
  end

  def today_games
    games = Xmlstats.events(Date.today, :nba)

    games.each do |event|
      printf("%-12s %24s vs. %-24s %9s\n",
             event.start_date_time.strftime('%l:%M %p'),
             event.away_team.full_name,
             event.home_team.full_name,
             event.event_status)
    end
  end

  def standings
    standings = Xmlstats.nba_standing(Time.now.strftime('%Y-%m-%d'))

    standings.map do |standing|
      "#{standing.first_name} #{standing.conference} #{standing.division}"
    end
  end

  def my_team_playing_tonight?
    games = Xmlstats.events(Date.today, :nba)

    teams = games.flat_map do |g|
      [g.home_team.full_name, g.away_team.full_name]
    end.uniq

    teams.include? @favorite_team
  end
end

nba = Nba.new
nba.favorite_team = 'Chicago Bulls'
ap nba.standings
ap nba.my_team_playing_tonight?
nba.today_games
