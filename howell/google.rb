module Howell
  match(/g(oogle)? (.*)/) do |m, _, search|
    api = search_for(search)

    if api.nil?
      m.reply 'no results found'
    else
      m.reply "#{api['link']} -- \x02#{api['title']}\x02: \"#{api['snippet'].split().join(' ')}\""
    end
  end

  def search_for(search)
    api = HTTParty.get("https://www.googleapis.com/customsearch/v1?cx=007629729846476161907:ud5nlxktgcw&fields=items(title,link,snippet)&safe=off&key=#{RubyServ.config.api_keys.google}&q=#{URI.escape(search)}")

    if api.has_key?('items')
      api['items'].first
    else
      nil
    end
  end
end
