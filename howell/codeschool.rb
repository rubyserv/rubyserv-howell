module Howell
  match(/cs (\S+)/) do |m, username|
    stats = HTTParty.get("http://www.codeschool.com/users/#{username}.json")

    begin
      m.reply "\x02#{stats['user']['username']}\x02 - \x02Courses Completed:\x02 #{stats['courses']['completed'].count} - \x02Badges:\x02 #{stats['badges'].count} - \x02Points:\x02 #{stats['user']['total_score'].to_s.to_str.split('.')[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, '\\1,')} - \x02Profile:\x02 http://codeschool.com/users/#{stats['user']['username']}"
    rescue
      m.reply "user #{username} does not exist"
    end
  end
end
