module BetweenLines
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      register Sinatra::Reloader
      require 'pry'
      require 'oauth'
    end



  end
end
