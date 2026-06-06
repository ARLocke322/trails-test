require 'literal'

class Request < Literal::Data
  prop :path, String
  prop :path_params, _Hash?(String, String)
  prop :headers, _Hash?(String, String)
  prop :body, _Nilable(Hash)
end
