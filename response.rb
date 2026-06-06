require 'literal'

class Response < Literal::Object
  prop :status, _Union(200, 201, 204, 404, 422), reader: :public
  prop :body, _Nilable(Hash), reader: :public
end
