class Dog
  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql_code = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql_code)
  end

  def self.drop_table
    sql_code = <<-SQL
      DROP TABLE if EXISTS dogs
    SQL
    DB[:conn].execute(sql_code)
  end

  def save
    if self.id
      self.update
    else
      sql_code = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql_code, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
   return self
  end

  def self.create (name:, breed:)
    new_dog = Dog.new(name:, breed:)
    new_dog.save
  end

  def self.new_from_db (item)
    self.new(id: item[0], name: item[1], breed: item[2])
  end

  def self.all
    sql_code = <<-SQL
      SELECT * FROM dogs
    SQL
    DB[:conn].execute(sql_code).map do |item|
      self.new_from_db(item)
    end
  end

  def self.find_by_name (name)
    sql_code = <<-SQL
      SELECT * FROM dogs WHERE dogs.name = ? LIMIT 1
    SQL

    DB[:conn].execute(sql_code, name).map do |item|
      self.new_from_db(item)
    end.first
  end

  def self.find (id)
    sql_code = <<-SQL
      SELECT * FROM dogs WHERE dogs.id = ? LIMIT 1
    SQL

    DB[:conn].execute(sql_code, id).map do |item|
      self.new_from_db(item)
    end.first
  end

end
