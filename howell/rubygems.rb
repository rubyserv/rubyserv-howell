module Howell
  match(/gem ([-\w]+)( [-\w]+)?/) do |m, command, value|
    value = value.strip unless value.nil?

    case command
    when 'search'
      m.reply !value.nil? ? search_for_gems(value) : 'search for what?'
    when 'info'
      m.reply !value.nil? ? find_gem(value) : 'info for what?'
    else
      m.reply find_gem(command.strip)
    end
  end

  match(%r{(https?://(www\.)?rubygems\.org/gems/[-\w]+(/)?$)}, skip_prefix: true) do |m, url|
    m.reply find_gem(%r{([-\w]+(/)?)$}.match(url))
  end

  def search_for_gems(name)
    response = HTTParty.get("https://rubygems.org/api/v1/search.json?query=#{name}")

    if response.count > 0
      response = response.count > 5 ? response[0...5] : response
      results  = response.map { |x| x['name'] }.join(', ')

      output = "\x02RubyGems Search\x02: #{results}"
      output += " - https://rubygems.org/search?query=#{name}"
    else
      output = "no rubygems found matching #{name}"
    end

    output
  end

  def find_gem(name)
    response = HTTParty.get("https://rubygems.org/api/v1/gems/#{name}.json")

    output = "\x02RubyGems\x02: \x0303#{response['name']}\x03"
    output += " \x0302(#{response['info']})\x03"
    output += " by \x0303#{response['authors']}\x03"
    output += " - \x0306version:\x03 \x0302#{response['version']}\x03"
    output += " \x0306downloads:\x03 \x0302#{RubyServ.format_number(response['downloads'])}\x03"
    output += " - #{response['project_uri']}"

    output
  end
end
