require 'literal'

class BaseSerializer < Literal::Data
  include Literal::Types
end

def params(&block)
  Class.new(Literal::Data, &block)
end
