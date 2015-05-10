class Chats
  # Verify phone; create/update key
  # curl -i -d phone=3525700299 -d code=1234 http://localhost:5100/keys
  def keys_post
    params = Rack::Request.new(@env).POST

    # Validate code
    code = params['code']
    error = code_invalid_response(code)
    return error if error

    # Validate phone
    phone = params['phone']
    error = phone_invalid_response(phone)
    return error if error

    POSTGRES.exec_params('SELECT * FROM keys_post($1, $2)', [phone, code]) do |r|
      if r.num_tuples == 0
        [403, '{"message":"Code is incorrect or expired."}']
      else
        access_token = build_access_token(phone, r.getvalue(0, 0))
        [201, '{"access_token":"'+access_token+'"}']
      end
    end
  end
end