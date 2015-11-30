Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == "p@ssw0rd"
end