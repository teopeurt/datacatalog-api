def validate_user_params
  validate_params User, %w(
    api_keys
    admin
    creator_api_key
    created_at
    updated_at
  )
end

def create_user_from_params
  user = User.create(params)
  user.add_api_key!({ :key_type => "primary" })
  response.status = 201
  response.headers['Location'] = full_uri('/users/' + user.id)
  user
end
