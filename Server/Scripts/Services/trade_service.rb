class TradeService

  def add_item(client, item, amount)
    return unless client.in_trade?

    return unless client.has_item?(item)

    client.lose_item(item, amount)
    client.trade_items[item.id] ||= 0
    client.trade_items[item.id] += amount

    $network.send_trade_update(client)
  end

  def remove_item(client, item, amount)
    return unless client.in_trade?

    return unless client.trade_items[item.id]

    client.trade_items[item.id] -= amount
    client.trade_items.delete(item.id) if client.trade_items[item.id] <= 0

    client.gain_item(item, amount)

    $network.send_trade_update(client)
  end

end