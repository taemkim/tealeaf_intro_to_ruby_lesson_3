require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do 

  def card_image(card)
    "<img src='/images/cards/#{card}.jpg' class='card_image'>"
  end

end

get '/' do 
  if session[:username]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

post '/start' do
  if session[:username]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:username].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end

  session[:username] = params[:username]
  redirect '/game'
end

get '/game' do
  session[:deck] = ["Ace of Clubs", "2 of Clubs", "3 of Clubs", "4 of Clubs", "5 of Clubs", 
       "6 of Clubs", "7 of Clubs", "8 of Clubs", "9 of Clubs", "10 of Clubs", 
       "Jack of Clubs", "Queen of Clubs", "King of Clubs",
       "Ace of Diamonds", "2 of Diamonds", "3 of Diamonds", "4 of Diamonds", "5 of Diamonds", 
       "6 of Diamonds", "7 of Diamonds", "8 of Diamonds", "9 of Diamonds", "10 of Diamonds", 
       "Jack of Diamonds", "Queen of Diamonds", "King of Diamonds",
       "Ace of Hearts", "2 of Hearts", "3 of Hearts", "4 of Hearts", "5 of Hearts", 
       "6 of Hearts", "7 of Hearts", "8 of Hearts", "9 of Hearts", "10 of Hearts", 
       "Jack of Hearts", "Queen of Hearts", "King of Hearts",
       "Ace of Spades", "2 of Spades", "3 of Spades", "4 of Spades", "5 of Spades", 
       "6 of Spades", "7 of Spades", "8 of Spades", "9 of Spades", "10 of Spades", 
       "Jack of Spades", "Queen of Spades", "King of Spades"
    ]

  session[:CALC] = { "Ace of Clubs" => 1, "2 of Clubs" => 2, "3 of Clubs" => 3, "4 of Clubs" => 4, "5 of Clubs" => 5,
       "6 of Clubs" => 6, "7 of Clubs" => 7, "8 of Clubs" => 8, "9 of Clubs" => 9, "10 of Clubs" => 10,
       "Jack of Clubs" => 10, "Queen of Clubs" => 10, "King of Clubs" => 10,
       "Ace of Diamonds" => 1, "2 of Diamonds" => 2, "3 of Diamonds" => 3, "4 of Diamonds" => 4, "5 of Diamonds" => 5,
       "6 of Diamonds" => 6, "7 of Diamonds" => 7, "8 of Diamonds" => 8, "9 of Diamonds" => 9, "10 of Diamonds" => 10,
       "Jack of Diamonds" => 10, "Queen of Diamonds" => 10, "King of Diamonds" => 10,
       "Ace of Hearts" => 1, "2 of Hearts" => 2, "3 of Hearts" => 3, "4 of Hearts" => 4, "5 of Hearts" => 5,
       "6 of Hearts" => 6, "7 of Hearts" => 7, "8 of Hearts" => 8, "9 of Hearts" => 9, "10 of Hearts" => 10,
       "Jack of Hearts" => 10, "Queen of Hearts" => 10, "King of Hearts" => 10,
       "Ace of Spades" => 1, "2 of Spades" => 2, "3 of Spades" => 3, "4 of Spades" => 4, "5 of Spades" => 5,
       "6 of Spades" => 6, "7 of Spades" => 7, "8 of Spades" => 8, "9 of Spades" => 9, "10 of Spades" => 10,
       "Jack of Spades" => 10, "Queen of Spades" => 10, "King of Spades" => 10
    }  
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].sample
  session[:deck].delete(session[:player_cards].last)
  session[:player_cards] << session[:deck].sample
  session[:deck].delete(session[:player_cards].last)
  session[:dealer_cards] << session[:deck].sample
  session[:deck].delete(session[:dealer_cards].last)
  session[:dealer_cards] << session[:deck].sample
  session[:deck].delete(session[:dealer_cards].last)
  
  session[:player_card_value_min] = 0
  session[:player_card_value_adj] = 0
  session[:dealer_card_value_min] = 0
  session[:dealer_card_value_adj] = 0

  session[:player_cards].each do |card|
  session[:player_card_value_min] = session[:player_card_value_min] + session[:CALC][card]
  end
    
  if session[:player_card_value_min] <= 11 && 
        (session[:player_cards].include?("Ace of Clubs") || 
        session[:player_cards].include?("Ace of Diamonds") ||
        session[:player_cards].include?("Ace of Hearts") ||
        session[:player_cards].include?("Ace of Spades"))
    session[:player_card_value_adj] = session[:player_card_value_min] + 10
  else
    session[:player_card_value_adj] = session[:player_card_value_min]
  end

  session[:dealer_cards].each do |card|  
    session[:dealer_card_value_min] = session[:dealer_card_value_min] + session[:CALC][card]
  end
    
  if session[:dealer_card_value_min] <= 11 && 
        (session[:dealer_cards].include?("Ace of Clubs") || 
        session[:dealer_cards].include?("Ace of Diamonds") ||
        session[:dealer_cards].include?("Ace of Hearts") ||
        session[:dealer_cards].include?("Ace of Spades"))
    session[:dealer_card_value_adj] = session[:dealer_card_value_min] + 10
  else
    session[:dealer_card_value_adj] = session[:dealer_card_value_min]
  end

  erb :game  
end

post '/hit' do
  session[:player_cards] << session[:deck].sample
  session[:deck].delete(session[:player_cards].last)

  session[:player_card_value_min] = session[:player_card_value_min] + session[:CALC][session[:player_cards].last]
    
  if session[:player_card_value_min] <= 11 && 
        (session[:player_cards].include?("Ace of Clubs") || 
        session[:player_cards].include?("Ace of Diamonds") ||
        session[:player_cards].include?("Ace of Hearts") ||
        session[:player_cards].include?("Ace of Spades"))
    session[:player_card_value_adj] = session[:player_card_value_min] + 10
  else
    session[:player_card_value_adj] = session[:player_card_value_min]
  end

  if session[:player_card_value_adj] >= 21
    erb :result
  else
    erb :game
  end

end

post '/stay' do

until session[:dealer_card_value_adj] > 16
  session[:dealer_cards] << session[:deck].sample
  session[:deck].delete(session[:dealer_cards].last)


  session[:dealer_card_value_min] = session[:dealer_card_value_min] + session[:CALC][session[:dealer_cards].last]
    
    
   if session[:dealer_card_value_min] <= 11 && 
        (session[:dealer_cards].include?("Ace of Clubs") || 
        session[:dealer_cards].include?("Ace of Diamonds") ||
        session[:dealer_cards].include?("Ace of Hearts") ||
        session[:dealer_cards].include?("Ace of Spades"))
    session[:dealer_card_value_adj] = session[:dealer_card_value_min] + 10
  else
    session[:dealer_card_value_adj] = session[:dealer_card_value_min]
  end
end
erb :result
end

post '/play_again' do
  redirect '/game'
end

post '/back_to_home' do
  redirect '/new_player'
end


