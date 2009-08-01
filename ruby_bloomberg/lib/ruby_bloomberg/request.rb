module RubyBloomberg
  class Request
    attr_reader :data_table
    
    def self.submit(securities, fields, params = {}, override_fields = [], overrides = [])
      securities = [securities] unless securities.is_a?(Array)
      fields = [fields] unless fields.is_a?(Array)

      request = new(securities, fields, params, override_fields, overrides)
      request.submit
      request.data_table
    end
    
    def initialize(securities, fields, params = {}, override_fields = [], overrides = [])
      @securities = securities
      @fields = fields
      @params = params
      @override_fields = override_fields
      @overrides = overrides
      
      @data_table = ForgetMeNot::Table.new
      
      Connection.instance.connect if data_service.nil?
    end
    
    def data_service
      Connection.instance.data_service
    end
  end
end
