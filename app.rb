require'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'

load 'db_functions.rb'

enable :sessions

#This checks if the user is signed in everytime they change route.
before do 
    if (session[:id] ==  nil) && (request.path_info != '/') && (request.path_info != '/login') 
      redirect("/")
    end
end

get("/") do
    slim(:index)
end

post("/login") do
    login_mail = params["login_mail"]
    login_password = params["login_password"]

    db = connect_to_db("db/db.db")

    result = db.execute("SELECT id, password FROM users WHERE mail=?", [login_mail])

    user_id = result.first["id"]
    password_digest = result.first["password"]
    if BCrypt::Password.new(password_digest) == login_password 
        session[:id] = user_id
        redirect("/home")
    end
end

get("/home") do 
    slim(:home)
end

get("/create") do
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM users")
    slim(:create,locals:{users:result})
end

post("/create_user") do
    name = params[:name]
    password = params[:password]
    rank = params[:rank]
    security = params[:security]
    mail = params[:mail]
    db = connect_to_db("db/db.db")
    password_digest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (name, password, rank, security_level, mail) VALUES (?,?,?,?,?)", name, password_digest, rank, security, mail)
    redirect("/create")
end

post("/delete_user/:id/delete") do
    id = params[:id].to_i
    db = connect_to_db("db/db.db")
    result = db.execute("DELETE FROM users WHERE id = ?", id)
    redirect("/create")
end

get("/create_post") do
    slim(:create_post)
end

post("/create_post") do
    title = params[:title]
    text = params[:text]
    genre = params[:genre]
    db = connect_to_db("db/db.db")
    db.execute("INSERT INTO posts (title, text, genre) VALUES (?,?,?)", title, text, genre)
    redirect("/create_post")
end

get("/home/gaming") do
    db = connect_to_db("db/db.db")
    gaming = "gaming"
    result = db.execute("SELECT * FROM posts WHERE genre = ?", gaming)
    slim(:gaming,locals:{posts:result})
end

post("/delete_post/:id/delete") do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    result = db.execute("DELETE FROM posts WHERE id = ?", id)
    redirect("/home")
end

post("/update_post/:id/update") do
    id = params[:id].to_i
    text = params["content"]
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    result = db.execute("UPDATE posts SET text = ? WHERE id = ?", text, id)
    redirect("/home")
end  

get("/home/other") do
    db = connect_to_db("db/db.db")
    other = "other"
    result = db.execute("SELECT * FROM posts WHERE genre = ?", other)
    slim(:other,locals:{posts:result})
end

get("/logout") do
    session[:id] = nil
    redirect("/")
end