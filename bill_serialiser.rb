require 'literal'
require_relative 'serializer'

class BillBaseSerializer < BaseSerializer
  prop :id, _Nilable(Integer)
  prop :reference, _String
  prop :date, _String
  prop :time, _String
end

class SingleBillSerializer < BillBaseSerializer
  prop :total, _Float
end

class BillCollectionSerializer < BaseSerializer
  prop :bills, _Array(BillBaseSerializer)
end

class BillSerializer
  def self.one(bill)
    SingleBillSerializer.new(
      id: bill.id,
      reference: bill.reference,
      date: bill.date,
      time: bill.time,
      total: bill.total
    ).to_h
  end

  def self.many(bills)
    { bills: bills.map { |bill| one(bill) } }
  end
end
