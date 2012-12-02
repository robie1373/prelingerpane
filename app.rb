require 'sinatra'
require_relative 'lib/prelingerpane'
#require 'sinatra/reloader' if development?

set :protection, :except => :ip_spoofing

configure do
  enable :sessions
end

#Result      = Struct.new(:title, :description, :creator, :url)
#Result = result
now_playing = Prelingerpane::VideoMetadata.new
now_playing.title = "Nothing chosen to play yet"
now_playing.description = "No file playing yet"
now_playing.creator = "None"
now_playing.url = "Nothing yet"

get "/" do
  @query_results = []
  @now_playing   = now_playing
  erb :index
end

get "/index" do
  @query_results = []
  @now_playing   = now_playing
  erb :index
end

post "/index" do
  @now_playing = now_playing
  session[:search_term] = params['searchstring']
  input        = StringIO.new
  input.rewind
  output                  = StringIO.new
  @query_results          = Prelingerpane::run(input, output, false, session[:search_term])
  puts "@query_results is an #{@query_results.class}"
  session[:playchoice] = params['playchoice'].to_i
  session[:query_results] = @query_results#{ 'title' => @query_results[position].title, 'description' => @query_results[position].description, 'creator' => @query_results[position].creator, 'url' => @query_results[position].url }
  #TODO can this be an array of objects? if so do that and fix things below.
  output.rewind
  @result = output.string
  erb :index
end

get "/about" do
  erb :about
end

post "/play" do
  # reset and render /index
  #reset_index()
  #@now_playing = Prelingerpane::VideoMetadata.new
  #session[:query_results].each_pair do |attribute, value|
  #  @now_playing.title = value if attribute == 'title'
  #  @now_playing.description = value if attribute == 'description'
  #  @now_playing.creator = value if attribute == 'creator'
  #  @now_playing.url = value if attribute == 'url'
  #end
  @now_playing = session[:query_results][params['playchoice'].to_i]
  #puts "session[:playchoice] --> #{[session[:playchoice]]}"
  #puts "session[:query_results] --> #{session[:query_results]}"
  #puts "params[:playchoice] --> #{params['playchoice']}"
  #puts "now playing --> #{@now_playing}"
  #puts "now_playing.url --> #{@now_playing.url}"
  player = Prelingerpane::VideoPlayer.new(@now_playing.url)
  Thread.new do
    player.play
  end
  input          = StringIO.new
  output         = StringIO.new
  @query_results = Prelingerpane::run(input, output, false, session[:search_term])
  erb :index
end

get "/manage" do
  erb :manage
end

def reset_index(args)
  args.each { |arg| args[arg] = "" }
  # clear any search related variables.
end