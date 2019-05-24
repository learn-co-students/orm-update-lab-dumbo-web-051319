require_relative "../config/environment.rb"
require "pry"
# Remember, you can access your database connection anywhere in this class
#  with DB[:conn]
class Student
  attr_accessor :name, :grade
  attr_reader :id
  @local_id
  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE students (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          grade INTEGER
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
        DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.object_id == @local_id
      self.update
    else
      sql = <<-SQL
          INSERT INTO students (name, grade) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      ary = DB[:conn].execute("SELECT * FROM students ORDER BY students.id DESC LIMIT 1")
      @id = ary[0][0]
      @local_id = self.object_id
    end
  end

  def self.create (name, grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name (name)
    sql = <<-SQL
      SELECT * FROM students WHERE students.name = ?
    SQL
    rows = DB[:conn].execute(sql, name)
    rows.map {|row| new_from_db(row.flatten)}[0]
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end



end
