require 'bcrypt'
require 'sqlite3'

def login(password_digest)
    return BCrypt::Password.new(password_digest)
end

def digest(password)
    return BCrypt::Password.create(password)
end