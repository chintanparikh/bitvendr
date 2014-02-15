require 'sinatra'
require 'json'
require 'coinbase'
require 'venmo'
require './sinatra/bitvendr_helpers'


class Bitvendr < Sinatra::Base
  helpers Sinatra::BitvendrHelpers

  post '/process_payment' do
  	# Pull in response
  	# Get amount, convert to btc at current rate
  	# Get either bitcoin wallet address or coinbase email address
  	# Pay bitcoin
  	# If it fails, then send the money back to the user and text the user saying it failed and the money has been returned
  	# If it succeeds, text the user saying it succeeded and its in the works + email address if something messes up.

  	amount = params["data"]["amount"]
  	note = params["data"]["note"]
  	id = params["data"]["actor"]["id"]

  	if params["data"]["action"] == "pay"
  		coinbase = Coinbase::auth

  		btc = amount / Coinbase::price
  		if coinbase.balance.to_f > btc
  			btc_to_send = btc * 0.90 #fucktheuser
  			response = coinbase.send_money note, btc_to_send

  			if response.success?
  				success id
  				coinbase.buy!(btc * 0.95)
  			else
  				error id
  			end
  		else
  			error id
  		end
  	end
  end

  get '/:venmo_challenge' do
  	params[:venmo_challenge]
  end
end