module Howell
  match(/wp (\S+)/) do |m, username|
    stats = HTTParty.get("http://api.whatpulse.org/user.php?user=#{username}&format=json")

    if !stats.include?('WhatPulse')
      stats = JSON.parse stats

      m.reply "\x02#{stats['AccountName']}\x02 - \x02Keys:\x02 #{RubyServ.format_number(stats['Keys'].to_i)} - \x02Clicks:\x02 #{RubyServ.format_number(stats['Clicks'].to_i)} - \x02Computers:\x02 #{stats['Computers'].count} - \x02Down:\x02 #{stats['Download']} - \x02Up:\x02 #{stats['Upload']} - \x02Uptime:\x02 #{stats['UptimeShort']}"
    else
      m.reply "user #{username} does not exist"
    end
  end
end
