require'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'

load 'db_functions.rb'

enable :sessions

get("/") do
    slim(:index)
end

post("/login") do

    login_password = params["login_password"]

    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true

    result = db.execute("SELECT id, password_digest FROM users WHERE username=?", [login_username])

    user_id = result.first["id"]
    password_digest = result.first["password_digest"]
    if BCrypt::Password.new(password_digest) == login_password 
        session[:id] = user_id
        redirect("/home")
    end
end

get("/home") do 
    slim(:home)
end

get("/create") do
    slim(:create)
end

post("/create_user") do
    name = params[:name]
    password = params[:password]
    rank = params[:rank]
    security = params[:security]
    mail = params[:mail]
    db = connect_to_db("db/db.db")
    db.execute("INSERT INTO users (name, password, rank, security_level, mail) VALUES (?,?,?,?,?)", name, password, rank, security, mail)
    redirect("/create")
end

get("/create_post") do
    slim(:create_post)
end

post("/create_post") do
    title = params[:title]
    text = params[:text]
    genre = params[:genre]
    security = params[:rank]
    db = connect_to_db("db/db.db")
    db.execute("INSERT INTO posts (title, text, genre, security_level) VALUES (?,?,?,?)", title, text, genre, security)
    redirect("/create_post")
end

get("/home/gaming") do
    slim(:gaming)
end