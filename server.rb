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
      render(:erb, :index)
    end

    # get('/login') do
    #   session[:name] = params[:name].downcase
    #   redirect to(params[:name].downcase)
    # end

    # get('/:username') do
    #   # once OAuth is working, this is where it goes
    #   if session[:name].downcase != params[:username].downcase
    #     redirect to('/')
    #   end
    #   @name = params[:username].downcase
    #   redirect to('/bookshelf')
    # end

    get('/bookshelf') do
      @bookshelf = $bookshelf.lrange("books", 0, -1)
      @books = @bookshelf.map { |str| JSON.parse(str)}
      render(:erb, :show)
    end

    # get('/oauth_callback') do

    # end

    get('/logout') do
      redirect to('/')
    end

    get('/new_book') do
      render(:erb, :newbook, {:layout => :default})
    end

    post('/bookshelf') do
      id = $bookshelf.incr("book_id")
      $bookshelf.hmset("book#{id}",
      "title", params["title"],
      "author", params["author"],
      "chapter", params["chapter"])
      $bookshelf.rpush("book_ids", id)
      redirect to('/bookshelf')
    end

    get('/books/:title/topics') do
      title = params["title"]
      @books = $bookshelf.lrange("books", 0, -1).map { |str| JSON.parse(str)}
      binding.pry
      @book = @books.find do |book|
        book['title'] == title
      end
      "#{@book['author']}"
    end
# this is what I had originally, when it was a list.
    #   title = params["title"]
    #   author = params["author"]
    #   chapter = params["chapter"]
    #   book = []
    #   book.push(title, author, chapter)
    #   $bookshelf.rpush("books", book.to_json)
    #   redirect to("/bookshelf")

    # get('/:title/topic') do
    #   @title = params[:title]
    #   @bookshelf = $bookshelf.lrange("books_ids", 0, -1)
    #   # this would show the topics for the title
    #   render(:erb, :showtopics, {:layout => :default})
    # end

    # post('/:title/topic') do
    #   @title = params[:title]
    #   $bookshelf.hmset("book#{id}",
    #     "topic_name", params["topic"],
    #     "message", params["message"])
    #   redirect to('/:title/topic')
    # end

    # get('/:title/topic/new') do
    #   title = params[:title]
    #   render(:erb, :newtopic, {:layout => :default})
    # end

    # get('/:title/:topic/messages') do
    #   title = params[:title]
    #   topic = params[:topic]
    #   render(:erb, :showmessages, {:layout => :default})
    # end

    # get('/:title/:topic/messages/new') do
    #   title = params[:title]
    #   topic = params[:topic]
    #   render(:erb, :newmessage, {:layout => :default})
    # end

    # post('/:title/:topic/messages') do
    #   @title = params[:title]
    #   $bookshelf.hmset("book#{id}",
    #     "message", params["message"])
    #   redirect to('/:title/:topic/messages')
    # end

  end
end
