class DB
  attr_accessor :collection
  def initialize(database)
    @connection = Mongo::Connection.new
    @database = @connection[database]
  end

  def [] (collection)
    @database[collection]
  end
end


