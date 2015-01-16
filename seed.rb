require 'json'
require 'redis'

$redis = Redis.new

book = {
  title: 'The Circle',
  author: 'Dave Eggers',
  chapters: 2,
  topics: [
    {
      title: 'Bad Book',
      messages: [
        {
          author: 'Phil',
          body: 'it was eh'
        },
        {
          author: 'Kristen',
          body: 'agreed'
        }
      ]
    }
  ]
}
$redis.rpush('books', book.to_json)

book = { title: 'Harry Potter',
         author: 'Dave Eggers',
         chapters: 2,
         topics: [
           {
             title: 'Bad Book',
             messages: [
               {
                 author: 'Phil',
                 body: 'it was eh'
               },
               {
                 author: 'Kristen',
                 body: 'agreed'
               }
             ]
           }
         ]
}

$redis.rpush('books', book.to_json)
