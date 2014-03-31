require 'rubygems' 
require 'bundler/setup'
# require all of the gems in the gemfile
Bundler.require

require 'uri'
require './models/ListItem'
# load the environment variables from .env (testing environment)
Dotenv.load
config_file 'config.yml'

db = URI.parse(ENV['DATABASE_URL'])

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

# Session:Cookie needed by OmniAuth
use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET']
# MethodOverride for RESTful interface
use Rack::MethodOverride
# Use OmniAuth Google Strategy
use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_KEY"], ENV["GOOGLE_SECRET"], 
    {
      :scope => "userinfo.email",
      #:prompt => "select_account",
      :image_aspect_ratio => "square",
      :image_size => 50
    }
end

# load title and data before methods that need it
before :method => 'get' do
	@title = settings.title
	@list = ListItem.order('id DESC')
  @scripts = []
end

# the homepage
get '/' do
  if can_edit
    haml :edit
  else
    haml :index
  end
end

get '/login' do 
  redirect("/auth/google_oauth2")
end

post '/' do
  redirect("/unauthorized") unless can_edit
	ListItem.create(title: '+', content: '+')
  redirect '/', 303
end

delete '/:item' do
  redirect("/unauthorized") unless can_edit
  ListItem.find(params[:item]).destroy
  redirect "/", 303
end

put '/:id' do |id|
  redirect("/unauthorized") unless can_edit
  ListItem.update(id, {title: params[:title], content: params[:content]})
  "success"
end

get '/auth/google_oauth2/callback' do
    session[:auth] = request.env['omniauth.auth']
    redirect(request.env['omniauth.origin'], 303)
end

get '/logout' do 
    session.clear
    redirect('/')
end

get '/unauthorized' do 
    haml :unauthorized
end

helpers do 
  def can_edit
    return false if session[:auth].nil?
    settings.can_edit.include? session[:auth][:info][:email]
  end

  # bootstrap glyphicons
  def glyph(i)
      "<span class='glyphicon glyphicon-#{i}'></span>"
  end

  #icomoon icons
  def icon(i, attrs={})
      c = attrs[:class]
      attrs.merge!({class: "icon-#{i} #{c}"})
      attrstring = attrs.map{|k,v| "#{k.to_s}='#{v}'"}.join(' ');
      "<span #{attrstring}></span>"
  end
end
