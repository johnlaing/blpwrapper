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
    
    def prepare_historical_data_table
      return false unless @data_table.rows.empty?
      
      @data_table.set_header_at_index(0, "security")
      
      @fields.each_with_index do |f, i|
        @data_table.set_header_at_index(i + 1, f)
      end
      
      n = @fields.size
      date_row = ["date"] + [[]] * n # evil hack, these n arrays are dups of each other so only 1 of them needs to be filled below
      @data_table.append(date_row)
      
      @securities.each do |s|
        security_row = [s]
        @fields.each do
          security_row << []
        end
        @data_table.append(security_row)
      end
    end
  end
end
