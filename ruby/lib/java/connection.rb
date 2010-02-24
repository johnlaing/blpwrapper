require 'singleton'

include_class "com.bloomberglp.blpapi.Service"
include_class "com.bloomberglp.blpapi.Session"
include_class "com.bloomberglp.blpapi.SessionOptions"

module RubyBloomberg
  class Connection
    include Singleton
    
    attr_reader :host
    attr_reader :port
    attr_reader :data_service
    attr_reader :session
    
    def initialize
      @host = 'localhost'
      @port = 8194
      @service = "//blp/refdata"
    end
    
    def host=(host)
      raise "cannot change host, already connected" if @session
      @host = host
    end

    def port=(port)
      raise "cannot change port, already connected" if @session
      @port = port
    end
    
    def service=(service)
      raise "cannot change service, already connected" if @session
      @service = service
    end
    
    def connect
      options = SessionOptions.new()
      options.set_server_host(@host)
      options.set_server_port(@port)

      @session = Session.new(options)

      raise "failed to start session" unless @session.start
      raise "Failed to open #{@service}" unless @session.open_service(@service)
      @data_service = @session.get_service(@service)
    end
  end
end

module RubyBloomberg
  class JavaRequest < Request
  end
end