require 'sinatra'
require 'json'
require 'coinbase'
require 'venmo'
require 'restclient'
require './sinatra/bitvendr_helpers'


class Bitvendr < Sinatra::Base
  helpers Sinatra::BitvendrHelpers
  post '/process_payment' do
  	200
  end

  post '/process' do
  	# Pull in response
  	# Get amount, convert to btc at current rate
  	# Get either bitcoin wallet address or coinbase email address
  	# Pay bitcoin
  	# If it fails, then send the money back to the user and text the user saying it failed and the money has been returned
  	# If it succeeds, text the user saying it succeeded and its in the works + email address if something messes up.

 	begin
	  	params = JSON.parse(request.body.read)
	  	note = params["data"]["note"]
	  	id = params["data"]["actor"]["id"]
	  	payment_id = params["data"]["id"]
	  	amount = Sinatra::BitvendrHelpers::Venmo.get_amount(payment_id).abs
	  	send_to = note.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
	  	send_to = note.scan(/[13][1-9A-Za-z][^OIl]{20,40}/) if send_to.empty?
	  	send_to = send_to[0]

	  	if params["data"]["action"] == "pay"
	  		coinbase = Sinatra::BitvendrHelpers::Payment.auth

	  		btc = amount / Sinatra::BitvendrHelpers::Payment.price
	  		if coinbase.balance.to_f > btc
	  			btc_to_send = btc * 0.90 #fucktheuser
	  			response = coinbase.send_money send_to, btc_to_send

	  			if response.success?
	  				success btc_to_send, id
	  				# coinbase.buy!(btc * 0.95)
	  			else
	  				error btc_to_send, id
	  			end
	  		else
	  			error btc_to_send, id
	  		end
	  	end
	rescue Coinbase::Client::Error => msg
		puts msg
		puts send_to
		puts id
		puts payment_id
		puts amount
		puts btc
		puts btc_to_send
		200
	rescue Exception => msg
	  	puts msg
	  	200
	end
  end

  get '/process' do
  	params[:venmo_challenge]
  end

  get '/' do
  	erb :index
  end
end