require 'pg'
require 'literal'

require_relative 'serializer'
require_relative 'bill'
require_relative 'bill_serialiser'
require_relative 'repository'
require_relative 'bills_repository'
require_relative 'controller'
require_relative 'bills_controller'

db = PG.connect(dbname: 'trails_test')
db.type_map_for_results = PG::BasicTypeMapForResults.new(db)

db.exec(<<~SQL)
  CREATE TABLE IF NOT EXISTS bills (
    id SERIAL PRIMARY KEY,
    reference TEXT NOT NULL,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    total FLOAT NOT NULL
  )
SQL

bills_repository = BillsRepository.new(
  db: db,
  entity_type: Bill,
  table_name: 'bills'
)

request = lambda do |action, path, path_params: nil, body: nil|
  req = Request.new(path: path, path_params: path_params, headers: nil, body: body)
  BillsController.new(request: req, bills_repository: bills_repository).public_send(action)
end

def print_response(label, response)
  body = response.body ? response.body.inspect : '(no body)'
  puts format('%-20s %s  %s', label, response.status, body)
end

db.exec('DELETE FROM bills')

b1 = request.call(:create, '/bills', body: { reference: 'BILL-001', date: '2026-06-04', time: '19:00', total: 23.99 })
print_response('create BILL-001', b1)

b2 = request.call(:create, '/bills', body: { reference: 'BILL-002', date: '2026-06-05', time: '20:00', total: 45.50 })
print_response('create BILL-002', b2)

print_response('index', request.call(:index, '/bills'))

id1 = b1.body[:id].to_s
print_response('update BILL-001',
               request.call(:update, "/bills/#{id1}", path_params: { 'id' => id1 }, body: { total: 99.99 }))

id2 = b2.body[:id].to_s
print_response('destroy BILL-002', request.call(:destroy, "/bills/#{id2}", path_params: { 'id' => id2 }))

print_response('index', request.call(:index, '/bills'))
