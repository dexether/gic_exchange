#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

running = true
Signal.trap(:TERM) { running = false }

def process_deposit(coin, deposit)
  # Skip if transaction is processed.
  return if PaymentTransaction::Normal.where(txid: deposit[:id]).exists?

  # Skip zombie transactions (for which addresses don't exist).
  recipients = deposit[:entries].map { |entry| entry[:address] }
  return unless recipients.any? { |address| PaymentAddress.where(currency: coin.id, address: address).exists? }

  Rails.logger.info "Missed #{coin.code.upcase} transaction: #{deposit[:id]}."

  # Immediately enqueue job.
  AMQPQueue.enqueue :deposit_coin, { txid: deposit[:id], currency: coin.code}
rescue StandardError => e
  Rails.logger.fatal e.inspect
end

while running
  begin
    Currency.all.each do |currency|
      next if currency.fiat?
      break unless running
      Rails.logger.debug { "Processing #{currency.code.upcase} deposits." }
      client    = currency.api
      processed = 0
      options   = client.is_a?(CoinAPI::ETH) ? { blocks_limit: 20 } : {}
      client.each_deposit options do |deposit|
        break unless running
        received_at = deposit[:received_at]
        Rails.logger.debug { "Processing deposit received at #{received_at.to_s('%Y-%m-%d %H:%M %Z')}." } if received_at

        process_deposit(currency, deposit)

        break if (processed += 1) >= 1000
        Rails.logger.debug { "Processed #{processed} #{currency.code.upcase} #{'deposit'.pluralize(processed)}." }
        # break if processed >= 100 || (received_at && received_at <= 1.hour.ago)
      end
      Rails.logger.debug { "Finished processing #{currency.code.upcase} deposits." }
    end
  rescue => e
    Rails.logger.fatal e.inspect
  end

  Kernel.sleep 5
end
