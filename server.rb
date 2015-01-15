module BetweenLines
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      register Sinatra::Reloader
      require 'pry'
      $bookshelf = Redis.new({
        :host => "127.0.0.1",
        :port => 6379
      })
    end

    get('/') do
      redirect to ('/bookshelf')
    end

    get('/bookshelf') do
      # once OAuth is working, this is where it goes
      @bookshelf = $bookshelf.lrange("books", 0, -1)
      render(:erb, :index)
    end

    # get('/oauth_callback') do

    # end

    get('/logout') do
      redirect to("/")
    end

    get('/new_book') do
      render(:erb, :newbook, {:layout => :default})
    end

    post('/bookshelf') do
      title = params["title"]
      author = params["author"]
      chapter = params["chapter"]
      book = []
      book.push(title, author, chapter)
      $bookshelf.rpush("books", book.to_json)
      redirect to("/bookshelf")
    end

    # get('/:title/topic') do
    #   title = params[:title]
    #   # this would show the topics for the title
    #   render(:erb, :showtopics, {:layout => :default})
    # end

    # get('/books/:title/new') do
    #   title = params[:title]
    #   render(:erb, :newtopic, {:layout => :default})
    # end

    # get('/books/:title/:topic') do
    #   title = params[:title]
    #   topic = params[:topic]
    #   render(:erb, :showmessages, {:layout => :default})
    # end

    # get('/books/:title/:topic/new') do
    #   title = params[:title]
    #   topic = params[:topic]
    #   render(:erb, :newmessage, {:layout => :default})
    # end

  end
end
