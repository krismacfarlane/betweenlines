require 'redis'
require 'sinatra/base'
require 'sinatra/reloader'
require 'pry'
require 'json'
require 'uri'

require_relative 'server'

run BetweenLines::Server
