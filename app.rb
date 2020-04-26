require'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'

require_relative 'models/model.rb'

enable :sessions 

include Model

#This checks if the user is signed in everytime they change route and redirects to '/' if not.
before do 
    if (session[:id] ==  nil) && (request.path_info != '/') && (request.path_info != '/login' && (request.path_info != '/error')) 
      redirect("/")
    end
end
#This checks if you have done an error
#
# @param [String] error, the error text the user gets
def set_error(error)
    session[:error] = error
end
# Displays an error message
get("/error") do
    slim(:error)
end

# Display Landing Page
#
get("/") do
    slim(:index)
end
# Attempts login and updates the session
#
# @param [String] login_mail, The e-mail
# @param [String] login_password, The password
#
# @see Model#login
post("/login") do

    if session[:now]
        time = session[:now].split("_")
        if Time.new(time[0], time[1], time[2], time[3], time[4], time[5]) > (Time.now - 300)
            set_error("You have to wait 5 minutes until you try again")
            redirect("/error")
        end
    end

    login_mail = params["login_mail"]
    login_password = params["login_password"]

    result = get_info_from_mail(login_mail)

    if login_mail == nil
        set_error("Invalid login details")
        redirect("/error")
    end

    attempts = session[:attempts] 
    if attempts == nil
        attempts = 0
    end

    name = result["name"]
    user_id = result["id"]
    security = result["security_level"]
    password_digest = result["password"]
    if login(password_digest) == login_password 
        session[:id] = user_id
        session[:name] = name
        session[:security] = security
        redirect("/")
    else
        set_error("Invalid login details")
        attempts += 1
        session[:attempts] = attempts

        if attempts >= 3
            session[:now] = Time.now().strftime('%Y_%m_%d_%H_%M_%S')
        end

        redirect("/error")
    end
end
# Route which allows an admin to create new users and redirects to '/error'
#
# @param [String] result, All information from the user which is required
#
# @see Model#get_all_info_from_user
get("/users/new") do

    if session[:security] == 0
        result = get_all_info_from_user()
        slim(:"/users/new",locals:{users:result})
    else
        set_error("You couldn't enter this site because you're not an admin")
        redirect("/error")
    end

end
# Attempts to create a new user and redirects to '/users/new'
#
# @param [String] name, The name of the user
# @param [String] password, The password
# @param [String] rank, The rank
# @param [Integer] security, The security clearance
# @param [String] mail, The e-mail
# @param [String] password_digest, The password digested
#
# @see Model#digest, Model#create_user
post("/users/create_user") do
    name = params[:name]
    password = params[:password]
    rank = params[:rank]
    security = params[:security]
    mail = params[:mail]
    password_digest = digest(password)

    create_user(name, password_digest, rank, security, mail)

    redirect("/users/new")
end
# Deletes an exisiting user and redirects to '/users/create'
#
# @param [Integer] id, The ID of the user
#
# @see Model#delete_user
post("/delete_user/:id/delete") do
    id = params[:id].to_i
    delete_user(id)
    redirect("/users/new")
end
#This route is used to create a new post
get("/post/new") do
    slim(:"/post/new")
end
# Creates a new post and redirects to '/post/new'
#
# @param [String] title, The title of the post
# @param [String] text, The content of the post
# @param [String] genre, The genre of the post
#
# @see Model#create_post
post("/post/new_post") do
    title = params[:title]
    text = params[:text]
    genre = params[:genre]
    id = session[:id]

    create_post(title, text, genre, id)

    redirect("/post/new")
end
# Attempts to enter a genre
#
# @param [String] result, All necessary information about the genre
#
# @see Model#genre_info
get("/genres/:genre") do |genre| 

    result = genre_info(genre) 

    if result.length == 0
        set_error("Genre not found")
        redirectC("/error")
    end

    if session[:security] <= result[0]["security"]
        slim(:"/genres/show",locals:{posts:result})
    else
        set_error("Too low security clearance to enter this genre")
        redirect("/error")
    end
end
# Attempts to add a upvote to a post
#
# @param [Integer] user_id, The ID of the user
# @param [Integer] post_id, The ID of the post
#
# @see Model#upvote
post("/upvote") do
    user_id = session[:id]
    post_id = params["post_id"]
    upvote(user_id, post_id)

    redirect("/")
end
# Deletes an existing post and redirects to '/'
#
# @param [Integer] id, The ID of the post
#
# @see Model#delete_post
post("/delete_post/:id/delete") do
    id = params[:id].to_i
    result = delete_post(id)
    redirect("/")
end
# Updates an existing post and redirects to '/'
#
# @param [Integer] :id, The ID of the post
# @param [String] content, The new content of the post
#
# @see Model#update_post
post("/update_post/:id/update") do
    id = params[:id].to_i
    text = params["content"]
    result = update_post(text, id)
    redirect("/")
end  
#This route is used to logout and redirects to '/'
get("/logout") do
    session[:id] = nil
    redirect("/")
end