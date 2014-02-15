require 'restclient'
require "coinbase"
require 'json'
require 'venmo'

module Sinatra
	module BitvendrHelpers
		class Venmo
			ACCESS_TOKEN = 'XsVhjhLEfRVqBsap2LmkVaYt3vNCyuvU'
			API_BASE = "https://api.venmo.com/v1/"

			def self.pay id, note, amount
				RestClient.post API_BASE + 'payments', access_token: ACCESS_TOKEN, user_id: id, note: note, amount: amount, audience: 'private'
			end

			def self.charge id, note, amount
				RestClient.post API_BASE + 'payments', access_token: ACCESS_TOKEN, user_id: id, note: note, amount: -1 * amount, audience: 'private'
			end

			def self.get_amount id
				response = RestClient.get API_BASE + "payments/#{id}?access_token=#{ACCESS_TOKEN}"
				json = JSON.parse(response.body)
				json["data"]["amount"].to_f
			end
		end

		class Payment
			API_KEY = 'TRxlrMqm5Z0K1w31'
			API_SECRET = 'XjZcr1TGyqC6mZglWHiR1q17xfjbj5B5'
			
			def self.auth
				Coinbase::Client.new(API_KEY, API_SECRET)
			end

			def self.price
				JSON.parse(RestClient.get("https://coinbase.com/api/v1/currencies/exchange_rates").body)["btc_to_usd"].to_f
			end
		end

		def success amount, id
			Venmo::charge id, "Success! #{amount} BTC is on the way. It can take up to an hour - email support@bitvendr.com for help.", 0.01
		end

		def error amount, id
			Venmo::charge id, "Sorry, something went wrong! Your money has been returned. Email support@bitvendr.com for help.", 0.01
		end
	end
end