require 'sinatra'
require_relative 'lib/prelingerpane'
#require 'sinatra/reloader' if development?

set :protection, :except => :ip_spoofing

configure do
  enable :sessions
end

#Result      = Struct.new(:title, :description, :creator, :url)
#Result = result
now_playing             = Prelingerpane::VideoMetadata.new
now_playing.title       = "Nothing chosen to play yet"
now_playing.description = "No file playing yet"
now_playing.creator     = "None"
now_playing.url         = "Nothing yet"

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
  @now_playing          = now_playing
  session[:search_term] = params['searchstring']
  input                 = StringIO.new
  input.rewind
  output         = StringIO.new
  @query_results = Prelingerpane::run(input, output, false, session[:search_term])
  puts "@query_results is an #{@query_results.class}"
  session[:playchoice]    = params['playchoice'].to_i
  session[:query_results] = @query_results #{ 'title' => @query_results[position].title, 'description' => @query_results[position].description, 'creator' => @query_results[position].creator, 'url' => @query_results[position].url }
                                           #puts "post /index session[:query_results] is ---> #{session[:query_results]}"

  output.rewind
  @result = output.string
  erb :index
end

get "/about" do
  erb :about
end

get "/manage" do
  erb :manage
end

get "/local" do
  @now_playing          = now_playing
  curdir = Dir.pwd
  Dir.chdir(save_location)
  @files = Dir.glob "*"
  Dir.chdir curdir
  erb :local
end

post "/play" do
  #puts "post /play session is ---> #{session}"
  #puts "post /play session[:query_results] is ---> #{session[:query_results]}"
  @now_playing = session[:query_results][params['playchoice'].to_i]
  play
  input          = StringIO.new
  output         = StringIO.new
  @query_results = Prelingerpane::run(input, output, false, session[:search_term])
  erb :index
end

post "/save" do
  #puts "Params is ---> #{params}"
  #puts "post /save session[:query_results] is ---> #{session[:query_results]}"

  @now_playing = now_playing
  save
  input          = StringIO.new
  output         = StringIO.new
  @query_results = Prelingerpane::run(input, output, false, session[:search_term])
  erb :index
end

def save_location
      loc = File.join(ENV['HOME'], "Movies", "PrelingerPane") if RUBY_PLATFORM =~ /(darwin)/i
      loc = File.join(ENV['HOME'], "mnt", "usb", "PrelingerPane") if RUBY_PLATFORM =~ /(armv6l-linux-eabi)/i
      loc
end

def play
  player = Prelingerpane::VideoPlayer.new(@now_playing.url)
  Thread.new do
    player.play
  end
end

def save
  to_save = []
  params['savechoice'].each do |choice|
    to_save << session[:query_results][choice.to_i]
  end
  #puts "to_save (app.rb) ---> #{to_save}"
  saver = Prelingerpane::VideoSaver.new(to_save, Prelingerpane::PrelScrape.new)
  #puts "saver (app.rb) ---> #{saver}"
  Thread.new do
    puts "---> (app.rb) in Thread.new"
    saver.save_files
  end
end
