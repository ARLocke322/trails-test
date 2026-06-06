require 'literal'
require_relative 'request'
require_relative 'response'

class BaseController < Literal::Object
  prop :request, Request, reader: :public

  def status(code)
    Response(body: nil, status: code)
  end

  def Response(body:, status: 200) # rubocop:disable Naming/MethodName
    Response.new(body: body, status: status)
  end
end
