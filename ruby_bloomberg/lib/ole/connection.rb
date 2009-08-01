require 'singleton'

module RubyBloomberg
  class Connection
    include Singleton
    
    attr_reader :data_service
    
    def connect
      @data_service = WIN32OLE.new("Bloomberg.Data.1")
    end
  end
end

module RubyBloomberg
  class OleRequest < Request
  end
end