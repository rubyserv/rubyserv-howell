module Howell
  match(/stock (\S+)/) do |m, symbol|
    m.reply build_stock_info(symbol)
  end

  match(/(\$[A-Z0-9]+)/, skip_prefix: true) do |m, symbol|
    m.reply build_stock_info(symbol.gsub('$', ''))
  end

  def build_stock_info(symbol)
    results = JSON.parse(HTTParty.get("http://dev.markitondemand.com/Api/v2/Quote/json?symbol=#{symbol}"))

    if results['Message']
      m.reply "Unknown ticker symbol #{symbol}"

      return
    end

    color = results['Change'].to_s.include?('-') ? 5 : 3

    company         = results['Name']
    last            = results['LastPrice'].round(2)
    change          = results['Change'].round(2)
    perc_change     = results['ChangePercent'].round(2)
    trade_timestamp = results['Timestamp']

    "#{company} - #{last} \x03#{color}#{change} (#{perc_change})\x03 as of #{trade_timestamp}"
  end
end
