require 'literal'

class Repository < Literal::Object
  prop :db, PG::Connection, reader: :public
  prop :entity_type, _Class(Literal::Data), reader: :public
  prop :table_name, _String(/\A[a-z_][a-z0-9_]*\z/), reader: :public

  def find(id)
    row = db.exec_params("SELECT * FROM #{table_name} WHERE id = $1 LIMIT 1", [id]).first
    row && hydrate(row)
  end

  def all
    db.exec("SELECT * FROM #{table_name}").map { |row| hydrate(row) }
  end

  def save(entity)
    if entity.id
      update(entity)
    else
      insert(entity)
    end
  end

  def destroy(entity)
    db.exec_params("DELETE FROM #{table_name} WHERE id = $1", [entity.id])
    entity
  end

  def hydrate(row)
    entity_type.new(**row.transform_keys(&:to_sym))
  end

  private

  def insert(entity)
    columns, values = columns_and_values(entity, except: :id)
    placeholders = (1..columns.size).map { |i| "$#{i}" }.join(', ')

    row = db.exec_params(
      "INSERT INTO #{table_name} (#{columns.join(', ')}) VALUES (#{placeholders}) RETURNING *",
      values
    ).first
    hydrate(row)
  end

  def update(entity)
    columns, values = columns_and_values(entity, except: :id)
    assignments = columns.each_with_index.map { |col, i| "#{col} = $#{i + 1}" }.join(', ')

    row = db.exec_params(
      "UPDATE #{table_name} SET #{assignments} WHERE id = $#{columns.size + 1} RETURNING *",
      values + [entity.id]
    ).first
    hydrate(row)
  end

  def columns_and_values(entity, except:)
    names = entity_type.literal_properties
                       .map(&:name)
                       .reject { |name| name == except }
    values = names.map { |name| entity.public_send(name) }
    [names.map(&:to_s), values]
  end
end
