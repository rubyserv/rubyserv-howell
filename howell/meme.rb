module Howell
  match(/meme/) do |m|
    m.reply HTTParty.get('http://api.automeme.net/text.json?lines=1').first
  end
end
