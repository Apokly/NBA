require 'awesome_print'
require 'rubygems'
require 'xmlstats'
require 'date'
require 'json'
require 'colorize'

class Nba

	attr_accessor :favorite_team

	def initialize
		Xmlstats.api_key = ENV['XMLSTATS_API_KEY']
		Xmlstats.contact_info = ENV['XMLSTATS_CONTACT_INFO'] || 'fabien.dobat@gmail.com'
	end

	def yesterday_games
		games_json = Xmlstats.events(Date.today - 1, :nba)
		ap "Yesterday games :"
		games_json.each do |event|
			printf("%-12s %24s %3i vs. %3i %-24s\n",
			event.start_date_time.strftime('%l:%M %p'),
			event.away_team.full_name.eql?(self.favorite_team) ? "==> #{event.away_team.full_name}" : event.away_team.full_name,
			event.away_points_scored,
			event.home_points_scored,
			event.home_team.full_name)
		end
	end

	def today_games
		games_json = Xmlstats.events(Date.today, :nba)
		ap "Today games :"
		games_json.each do |event|
			printf("%-12s %24s vs. %-24s %9s\n",
			event.start_date_time.strftime('%l:%M %p'),
			event.away_team.full_name.eql?(self.favorite_team) ? "==> #{event.away_team.full_name}" : event.away_team.full_name,
			event.home_team.full_name,
			event.event_status)
		end
	end

	def standings
		standings_json = Xmlstats.nba_standing(Time.now.strftime('%Y-%m-%d'))
		standings_json.each do |standing|
			ap "#{standing.first_name} #{standing.conference} #{standing.division}"
		end
	end

end

nba = Nba.new
nba.favorite_team = "Chicago Bulls"
nba.yesterday_games
nba.today_games