get '/users' do
  validate_admin_privileges
  User.find(:all).to_json
end

get '/users/:id' do
  validate_admin_privileges
  id = params.delete("id")
  user = User.find_by_id(id)
  if user
    user.to_json
  else
    error 404, [].to_json
  end
end

post '/users' do
  validate_admin_privileges
  id = params.delete("id")
  validate_user_params
  user = create_user_from_params
  user.to_json
end

put '/users/:id' do
  validate_admin_privileges
  id = params.delete("id")
  user = User.find_by_id(id)
  unless user
    error 404, [].to_json
  end
  validate_user_params
  user = User.update(id, params)
  user.to_json
end

delete '/users/:id' do
  validate_admin_privileges
  id = params.delete("id")
  user = User.find(id)
  user.destroy
  { "_id" => id }.to_json
end
