module Howell
  URL_BLACKLIST = [
    /github\.com/,
    /https?:\/\/(www\.)?rubygems\.org\/gems\//,
    /https?:\/\/twitter\.com/,
    /\.gif$/, /\.png$/, /\.jpe?g$/, /\.pdf$/, /\.bmp$/
  ]

  match(%r{(https?:\/\/.*?)(?:\s|$|,|\.\s|\.$)}, skip_prefix: true) do |m, url|
    unless URL_BLACKLIST.any? { |bl| url =~ bl }
      html = Nokogiri::HTML(HTTParty.get(url))

      if node = html.at_xpath('html/head/title')
        m.reply node.blank? ? 'Link has no title' : node.text.strip
      end
    end
  end
end
