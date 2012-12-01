require 'sinatra'
require_relative 'lib/prelingerpane'
require 'sinatra/reloader' if development?

set :protection, :except => :ip_spoofing

configure do
  enable :sessions
end

get "/" do
  @query_results = []
  erb :index
end

get "/index" do
  @query_results = []
  erb :index
end

post "/index" do
  @search_term = params['searchstring']
  input = StringIO.new('\nn\nn\nn\nn\nn\nn\n\n')
  input.rewind
  output = StringIO.new
  @query_results = Prelingerpane::run(input, output, false, @search_term)
  output.rewind
  @result = output.string
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

get "/manage" do
  erb :manage
end

def reset_index(args)
  args.each  { |arg| args[arg] = "" }
  # clear any search related variables.
end