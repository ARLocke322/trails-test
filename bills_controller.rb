require 'literal'
require_relative 'controller'
require_relative 'bill'
require_relative 'bill_serialiser'
require_relative 'bills_repository'

class BillsController < BaseController
  prop :bills_repository, BillsRepository, reader: :public

  def index
    bills = bills_repository.all
    Response(body: BillSerializer.many(bills))
  end

  def show
    return status(404) unless bill

    Response(body: BillSerializer.one(bill))
  end

  def create
    new_bill = Bill.new(**create_params.to_h)
    saved_bill = bills_repository.save(new_bill)

    Response(body: BillSerializer.one(saved_bill), status: 201)
  end

  def destroy
    return status(404) unless bill

    bills_repository.destroy(bill)
    status(204)
  end

  def update
    return status(404) unless bill

    updated_bill = Bill.new(**bill.to_h.merge(**update_params.to_h.compact))
    bills_repository.save(updated_bill)

    Response(body: BillSerializer.one(updated_bill))
  end

  private

  def bill
    @bill ||= bills_repository.find(request.path_params['id'])
  end

  # Returns typed params from request body
  def create_params
    params do
      prop :reference, _String
      prop :date, _String
      prop :time, _String
      prop :total, _Float
    end.new(**request.body)
  end

  # Returns typed params from request body, nilable to allow select fields to
  #   be changed
  def update_params
    params do
      prop :reference, _Nilable(_String)
      prop :date, _Nilable(_String)
      prop :time, _Nilable(_String)
      prop :total, _Nilable(_Float)
    end.new(**request.body)
  end
end
