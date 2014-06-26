module Howell
  match(/worldcup (\S+)/) do |m, cmd|
    case cmd
    when 'help'
      m.reply "#{RubyServ.config.rubyserv.prefix}worldcup [today|current]"
    when 'today'
      today = HTTParty.get('http://worldcup.sfg.io/matches/today')

      m.reply "Today's World Cup matches:"

      today.each do |match|
        out  = "##{match['match_number']} - "
        out += "#{match['home_team']['country']} (#{match['home_team']['code']}) vs. #{match['away_team']['country']} (#{match['away_team']['code']})"
        out += "in #{match['location']} "
        out += "at #{match['datetime']} "
        out += "- Score: #{match['home_team']['goals']}-#{match['away_team']['goals']}" if match['status'] != 'future'

        m.reply out
      end
    when 'current'
      current = HTTParty.get('http://worldcup.sfg.io/matches/current')

      if current.empty?
        m.reply 'No active matches currently'
      end
    end
  end
end
