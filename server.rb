module BetweenLines
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      require 'pry'
      register Sinatra::Reloader
      $bookshelf = Redis.new
    end

    configure :production do
      $bookshelf = Redis.new({url: ENV['REDISTOGO_URL']})
    end

    get('/') do
      render(:erb, :index)
    end

    post('/index') do
      session[:name] = params[:name].capitalize
      redirect to ('/bookshelf')
    end

    get('/logout') do
      session.clear
      redirect('/')
    end

    # pulls out the hash inside of the redis list and sets it up for displaying on the 'bookshelf' page
    get('/bookshelf') do
      @bookshelf = $bookshelf.lrange("books", 0, -1)
      @books = @bookshelf.map { |str| JSON.parse(str) }
      render(:erb, :show)
    end

    get('/new_book') do
      render(:erb, :newbook, {:layout => :default})
    end

    # creates a new book hash, including an empty array for later use, when adding messages.
    # pushes the book hash to the redis list 'books'
    post('/bookshelf') do
      @book_hash = {}
      @book_hash["title"] = params["title"]
      @book_hash["author"] = params["author"]
      @book_hash["topics"] = []
      $bookshelf.rpush("books", @book_hash.to_json)
      redirect to ('/bookshelf')
    end

    # this will show the list of topics for the book
    get('/books/:title') do
      @title = params["title"]
      @books = $bookshelf.lrange("books", 0, -1).map { |str| JSON.parse(str) }
      @book = @books.find do |book|
        book["title"] == @title
      end
      render(:erb, :showtopics, {:layout => :default})
    end

    # realizing that the first three lines of this is very repetitive
    # creates the new topic and adding the initial message (body) and author (session name)
    post('/books/:title') do
      @title = params["title"]
      @books = $bookshelf.lrange("books", 0, -1).map { |str| JSON.parse(str) }
      @book = @books.find do |book|
        book["title"] == @title
      end

      topic = {}
      topic["topic_title"] = params["topic_title"]
      topic["messages"] = {}
      topic["messages"]["author"] = session[:name]
      topic["messages"]["body"] = params["message"]
      topic
      @book["topics"].push(topic)

      # pushes this new information to the redis list 'books'
      # this is an error! it doesn't overwrite what was there, it adds a whole new hash.
      $bookshelf.lpush("books", @book.to_json)
      redirect to ("/books/#{@title}")
    end

    get('/:title/new') do
      @title = params["title"]
      @books = $bookshelf.lrange("books", 0, -1).map { |str| JSON.parse(str)}
      @book = @books.find do |book|
        book['title'] == @title
      end
      render(:erb, :newtopic, {:layout => :default})
    end

    get ('/:title/:topic') do
      @title = params["title"]
      @books = $bookshelf.lrange("books", 0, -1).map { |str| JSON.parse(str)}
      @book = @books.find do |book|
        book['title'] == @title
      end
      @topic_title = params[:topic]
      render(:erb, :showtopic, {:layout => :default})
    end

    get ('/:title/:topic/new') do
      @title = params["title"]
      @topic = params["topic"]
      @books = $bookshelf.lrange("books", 0, -1).map { |str| JSON.parse(str)}
      @book = @books.find do |book|
        book['title'] == @title
      end
      render(:erb, :newmessage, {:layout => :default})
    end

    post ('/:title/:topic/newmessage') do
      @title = params["title"]
      @topic = params["topic"]
      @books = $bookshelf.lrange("books", 0, -1).map { |str| JSON.parse(str)}
      @book = @books.find do |book|
        book['title'] == @title
      end

      @book["topics"]["messages"]["author"] = $name
      @book["topics"]["messages"]["body"] = params["message"]
      $bookshelf.lpush("books", @book.to_json)
      redirect to ("/#{@title}/#{@topic}")
    end

  end
end
