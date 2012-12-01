require 'sinatra'
require_relative 'lib/prelingerpane'
require 'sinatra/reloader' if development?

set :protection, :except => :ip_spoofing

configure do
  enable :sessions
end

get "/" do
  erb :index
end

get "/about" do
  erb :about
end

post "/play" do
  # reset and render /index
  reset_index
  erb :index
end

def reset_index
  # clear any search related variables.
end