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

    result = db.execute("SELECT * FROM users WHERE mail=?", [login_mail]).first
    name = result["name"]
    user_id = result["id"]
    security = result["security_level"]
    password_digest = result["password"]
    if BCrypt::Password.new(password_digest) == login_password 
        session[:id] = user_id
        session[:name] = name
        session[:security] = security
        redirect("/home")
    end
end

get("/home") do 
    slim(:home)
end

get("/users/create") do
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM users")
    slim(:"/users/create",locals:{users:result})
end

post("/users/create_user") do
    name = params[:name]
    password = params[:password]
    rank = params[:rank]
    security = params[:security]
    mail = params[:mail]
    db = connect_to_db("db/db.db")
    password_digest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (name, password, rank, security_level, mail) VALUES (?,?,?,?,?)", name, password_digest, rank, security, mail)
    redirect("/users/create")
end

post("/delete_user/:id/delete") do
    id = params[:id].to_i
    db = connect_to_db("db/db.db")
    result = db.execute("DELETE FROM users WHERE id = ?", id)
    redirect("/create")
end

get("/post/new") do
    title = params[:title]
    text = params[:text]
    genre = params[:genre]
    op = session[:name]
    db = connect_to_db("db/db.db")
    db.execute("INSERT INTO posts (title, text, genre, op) VALUES (?,?,?,?)", title, text, genre, op)
    slim(:"/post/new")
end

get("/home/genres/gaming") do
    db = connect_to_db("db/db.db")
    gaming = "gaming"
    result = db.execute("SELECT * FROM posts WHERE genre = ?", gaming)
    slim(:"/genres/gaming",locals:{posts:result})
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

get("/home/genres/other") do
    db = connect_to_db("db/db.db")
    other = "other"
    result = db.execute("SELECT * FROM posts WHERE genre = ?", other)
    slim(:"/genres/other",locals:{posts:result})
end

get("/logout") do
    session[:id] = nil
    redirect("/")
end