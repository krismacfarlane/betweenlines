module BetweenLines
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      register Sinatra::Reloader
      require 'pry'
    end

    get('/') do
      redirect to ('/bookshelf')
    end

    get('/bookshelf') do
      # once OAuth is working, this is where it goes
      render(:erb, :index)
    end

    # get('/oauth_callback') do

    # end

    get('/logout') do
      redirect to("/")
    end

    get('/books/new') do
      render(:erb, :newbook, {:layout => :default})
    end

    get('books/:title') do
      title = params[:title]
      # this would show the topics for the title
      render(:erb, :showtopics, {:layout => :default})
    end

    get('/books/:title/new') do
      title = params[:title]
      render(:erb, :newtopic, {:layout => :default})
    end

    get('/books/:title/:topic') do
      title = params[:title]
      topic = params[:topic]
      render(:erb, :showmessages, {:layout => :default})
    end

    get('/books/:title/:topic/new') do
      title = params[:title]
      topic = params[:topic]
      render(:erb, :newmessage, {:layout => :default})
    end

  end
end
