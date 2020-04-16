require 'sqlite3'

load 'db_functions.rb'

def genre_info(genre)

    db = connect_to_db("db/db.db")

    db.execute("SELECT posts.title, posts.text, posts.id, posts.upvotes, genre.security, genre.name AS genre FROM genre LEFT JOIN posts ON genre.id = posts.genre LEFT JOIN users ON posts.user_id = users.id WHERE genre.name = ?", genre)

end