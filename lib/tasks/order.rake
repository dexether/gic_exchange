namespace :order do
  desc "Cancel all orders of hidden Markets"
  task cancel_for_hidden_markets: :environment do
    Market.all_with_invisible.each do |market|
      next if market.visible
      puts "#{market.id} invisible."

      orders = Order.active.with_currency(market.id)
      Ordering.new(orders).cancel!
    end
  end

  task mock: :environment do
    m = Member.find_by_email 'foo@pickcoinex.com'
    market = Market.find 'btcusd'

    low = 2150
    high = 2250
    mid = 2200
    (low..high).each do |price|
      klass = price < mid ?  OrderBid : OrderAsk
      volume = rand

      order = klass.new(
        source:        'APIv2',
        state:         ::Order::WAIT,
        member_id:     m.id,
        ask:           market.base_unit,
        bid:           market.quote_unit,
        currency:      market.id,
        ord_type:      'limit',
        price:         BigDecimal(Random.new.rand.to_s).round(3) + price,
        volume:        volume,
        origin_volume: volume
      )

      Ordering.new(order).submit
    end
  end
end
