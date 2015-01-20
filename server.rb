module BetweenLines
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      require 'pry'
      register Sinatra::Reloader
      $bookshelf = Redis.new({
        :host => "127.0.0.1",
        :port => 6379
      })
    end

    get('/') do
      render(:erb, :index)
    end

    post('/index') do
      name = params[:name]
      session[:name] = name
      redirect to ('/bookshelf')
    end

    get('/logout') do
      session.clear
      redirect('/')
    end

    get('/bookshelf') do
      $name = session[:name].capitalize
      @bookshelf = $bookshelf.lrange("books", 0, -1)
      @books = @bookshelf.map { |str| JSON.parse(str)}
      render(:erb, :show)
    end

    get('/new_book') do
      render(:erb, :newbook, {:layout => :default})
    end

    post('/bookshelf') do
      @book_hash = {}
      @book_hash["title"] = params["title"]
      @book_hash["author"] = params["author"]
      @book_hash["topics"] = []
      $bookshelf.rpush('books', @book_hash.to_json)
      redirect to ('/bookshelf')
    end


    get('/books/:title') do
      @title = params["title"]
      @books = $bookshelf.lrange("books", 0, -1).map { |str| JSON.parse(str)}
      @book = @books.find do |book|
        book['title'] == @title
      end
      render(:erb, :showtopics, {:layout => :default})
    end

    post('/books/:title') do
      @title = params["title"]
      @books = $bookshelf.lrange("books", 0, -1).map { |str| JSON.parse(str)}
      @book = @books.find do |book|
        book['title'] == @title
      end

      topic = {}
      topic["topic_title"] = params["topic_title"]
      topic["messages"] = {}
      topic["messages"]["author"] = $name
      topic["messages"]["body"] = params["message"]
      topic
      @book["topics"].push(topic)

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
