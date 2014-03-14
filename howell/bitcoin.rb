module Howell
  match(/bitcoin lag/) do |m|
    response = JSON.parse(URI.parse('https://data.mtgox.com/api/1/generic/order/lag').open.read)['return']
    output = "Current Mt.Gox Lag: \x0307#{response['lag_text']}\x0f"
    m.reply output
  end

  match(/bitcoin\s(\d?\.?\d+)/) do |m, amount|
    response = JSON.parse(URI.parse('https://data.mtgox.com/api/2/BTCUSD/money/ticker').open.read)['data']
    calc = (amount.to_f * response['buy']['value'].to_f)
    output = sprintf "#{amount} BTC to USD: \x0307$%.2f\x0f", calc
    m.reply output
  end

  match(/bitcoin\s\$(\d?\.?\d+)/) do |m, amount|
    response = JSON.parse(URI.parse('https://data.mtgox.com/api/2/BTCUSD/money/ticker').open.read)['data']
    calc = (amount.to_f / response['buy']['value'].to_f)
    output = "$#{amount} USD to BTC: \x0307#{calc.round(8)}\x0f"
    m.reply output
  end

  match(/bitcoin$/) do |m|
    response = JSON.parse(URI.parse('https://data.mtgox.com/api/2/BTCUSD/money/ticker').open.read)['data']
    data = { buy: response['buy']['value'], high: response['high']['value'], low: response['low']['value'], vol: response['vol']['display'] }

    output = sprintf "Current: \x0307$%<buy>.2f\x0f - High: \x0307$%<high>.2f\x0f", data
    output += sprintf " - Low: \x0307$%<low>.2f\x0f - Volume: %<vol>s", data

    m.reply output
  end
end
