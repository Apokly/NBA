require 'awesome_print'
require 'rubygems'
require 'xmlstats'
require 'date'
require 'json'
require 'colorize'
require 'mandrill'

class Nba

	 attr_accessor :favorite_team

	def initialize
		Xmlstats.api_key = ENV['XMLSTATS_API_KEY']
		Xmlstats.contact_info = ENV['XMLSTATS_CONTACT_INFO'] || 'fabien.dobat@gmail.com'
		@mandrill = Mandrill::API.new ENV['MANDRILL_API_KEY']
	end

	def yesterday_games
		games_json = Xmlstats.events(Date.today - 1, :nba)
		ap "Yesterday games :"
		games_json.each do |event|
			printf("%-12s %24s %3i vs. %3i %-24s\n",
       event.start_date_time.strftime('%l:%M %p'),
       event.away_team.full_name,
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
       event.away_team.full_name,
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

	def is_my_team_playing_tonight?
		games_json = Xmlstats.events(Date.today, :nba)
		games_json.each do |game|
			if (game.away_team.full_name.eql?(self.favorite_team) || game.home_team.full_name.eql?(self.favorite_team))
        return game
      end
    end
    false
  end

  def send_mail game
    begin
     message = {
      "subject" => "NBA #{self.favorite_team} game infos",
      "from_name" => "NBA Bot",
      "from_email" => "no-reply@nbabot.fr",
      "to" => [{
       "name" => "Recipent test",
       "type" => "to",
       "email" => "fabien.dobat@gmail.com"
       }],
       "html" => "#{game.away_team.full_name} vs. #{game.home_team.full_name} at #{game.start_date_time.strftime('%l:%M %p')}"
     }

     result = @mandrill.messages.send message
     ap result

   rescue Mandrill::Error => e
    puts "A mandrill error occurred: #{e.class} - #{e.message}"
  end
end

end

nba = Nba.new
nba.favorite_team = "Chicago Bulls"
game = nba.is_my_team_playing_tonight?
#nba.yesterday_games
#nba.today_games
nba.send_mail(game)
