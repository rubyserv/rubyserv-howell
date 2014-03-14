module Howell
  match(%r{(https?://(www\.)?github\.com/[-\w]+/[-\w]+(/)?$)}, skip_prefix: true) do |m, url|
    response = HTTParty.get("https://api.github.com/repos/#{%r{([-\w]+/[-\w]+(/)?)$}.match(url)}", headers: { 'User-Agent' => 'HTTParty' })

    output = "\x02GitHub\x02: \x0303#{response['name']}\x03"
    output += " \x0302(#{response['description']})\x03" unless response['description'].nil? || response['description'].empty?
    output += " by \x0303#{response['owner']['login']}\x03"
    output += " - \x0307language:\x03 \x0302#{response['language']}\x03"
    output += " \x0307forks:\x03 \x0302#{RubyServ.format_number(response['forks'])}\x03"
    output += " \x0307watchers:\x03 \x0302#{RubyServ.format_number(response['watchers'])}\x03"
    output += " \x0307issues:\x03 \x0302#{RubyServ.format_number(response['open_issues'])}\x03"
    output += " - #{response['homepage']}" unless response['homepage'].nil? || response['homepage'].empty?
    output += " - #{response['html_url']}"

    m.reply output
  end

  match(%r{(https?://(www\.)?github\.com/[-\w]+(/)?$)}, skip_prefix: true) do |m, url|
    response = HTTParty.get("https://api.github.com/users/#{%r{([-\w]+(/)?)$}.match(url)}", headers: { 'User-Agent' => 'HTTParty' })

    output = "\x02GitHub\x02: \x0303#{response['login']}\x03"
    output += " \x0302(#{response['name']})\x03" unless response['name'].nil?
    output += " - \x0307repos:\x03 \x0302#{RubyServ.format_number(response['public_repos'])}\x03"
    output += " \x0307followers:\x03 \x0302#{RubyServ.format_number(response['followers'])}\x03"
    output += " \x0307following:\x03 \x0302#{RubyServ.format_number(response['following'])}\x03"
    output += " \x0307gists:\x03 \x0302#{RubyServ.format_number(response['public_gists'])}\x03"
    output += " \x0307company:\x03 \x0302#{response['company']}\x03" unless response['company'].nil?
    output += " \x0307location:\x03 \x0302#{response['location']}\x03" unless response['location'].nil?
    output += " \x0307email:\x03 \x0302#{response['email']}\x03" unless response['email'].nil? || response['email'].empty?
    output += " - #{response['blog']}" unless response['blog'].nil?
    output += " - #{response['html_url']}"
    output += " - \x0303HIREABLE\x03" unless response['hireable'].nil? || response['hireable'] == false

    m.reply output
  end

  match(%r{(https?://gist\.github\.com/[-\w]+/[\w]+(/)?$)}, skip_prefix: true) do |m, url|
    response = HTTParty.get("https://api.github.com/gists/#{%r{([\w]+(/)?)$}.match(url)}", headers: { 'User-Agent' => 'HTTParty' })

    output = "\x02Gist\x03: \x0303#{response['id']}\x03"
    output += " \x0302(#{response['description']})\x03" unless response['description'].nil? || response['description'].empty?
    output += " by \x0303#{response['user']['login']}\x03" unless response['user'].nil? || response['user'].empty?
    output += " by \x0303anonymous\x03" if response['user'].nil? || response['user'].empty?
    output += " - \x0307files:\x03 \x0302#{RubyServ.format_number(response['files'].count)}\x03"
    output += " \x0307forks:\x03 \x0302#{RubyServ.format_number(response['forks'].count)}\x03"
    output += " \x0307revisions:\x03 \x0302#{RubyServ.format_number(response['history'].count)}\x03"
    output += " \x0307comments:\x03 \x0302#{RubyServ.format_number(response['comments'])}\x03"
    output += " - #{response['html_url']}"
    output += " - \x0304PRIVATE\x03" if response['public'] == false

    m.reply output
  end
end
