require 'literal'

class Bill < Literal::Data
  prop :id, _Nilable(Integer)
  prop :reference, _String
  prop :date, _String
  prop :time, _String
  prop :total, _Float
end
