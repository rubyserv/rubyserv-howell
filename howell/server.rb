module Howell
  match(/server (\S+)/) do |m, command|
    output = case command
             when 'uptime'
               `uptime`
             when 'uname'
               `uname -a`
             when 'name'
               `hostname`
             end

    m.reply output
  end
end
