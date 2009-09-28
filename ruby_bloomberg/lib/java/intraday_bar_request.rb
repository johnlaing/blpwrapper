module RubyBloomberg
  class IntradayBarRequest < JavaRequest
    AVAILABLE_FIELDS = ["TRADE", "BID", "ASK", "BEST_BID", "BEST_ASK"]
    AVAILABLE_BARFIELDS = ["OPEN", "HIGH", "LOW", "CLOSE", "NUM_EVENTS", "VOLUME"]
    
    def prepare_parameter(param)
      case param
      when String
        if param =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})/
          time = Time.parse(param).utc
          Datetime.new(time.year, time.month, time.day, time.hour, time.min, 0, 0)
        else
          param
        end
      when Fixnum
        # Use a Short, otherwise it converts to Int64 which Bloomberg rejects
        java.lang.Short.new(param.to_s)
      when Date, Time
        param.utc
        Datetime.new(param.year, param.month, param.day, param.hour, param.min, param.sec, 0)
      else
        param
      end
    end
    
    def submit
      request = data_service.create_request(self.class.name.split("::").last)
      
      security = @securities.first
      field = @fields.first

      raise "only 1 security allowed" if @securities.size > 1
      raise "only 1 field allowed" if @fields.size > 1
      raise "#{field} is not a valid field, valid options are #{AVAILABLE_FIELDS.join(", ")}" unless AVAILABLE_FIELDS.include?(field)
      
      request.set("security", security)
      request.set("eventType", field)
      
      @params.each do |k, v|
        if k.to_s == 'barfields'
          v.each do |b|
            raise "#{b} is not a valid barfield, valid options are #{AVAILABLE_BARFIELDS.join(", ")}" unless AVAILABLE_BARFIELDS.include?(b)
          end
          @bar_fields = v
        else
          @bar_fields = AVAILABLE_BARFIELDS
          k = 'startDateTime' if k.to_s === 'start_date'
          k = 'endDateTime' if k.to_s === 'end_date'
          k = 'interval' if k.to_s === 'barsize'
          request.set(k.to_s, prepare_parameter(v))
        end
      end
      
      session.send_request(request, nil)
      read_response
    end
    
    def read_message_data(message)
      prepare_historical_data_table
      
      bardata = message.getElement("barData").getElement("barTickData")
      n = bardata.numValues
      
      0.upto(n - 1) do |i|
        bar = bardata.getValueAsElement(i)
        time = bar.getElementAsDate("time").toString

        @data_table.rows[0].append_to_array(1, time)
        
        @bar_fields.each_with_index do |f, i|
          data = case f
          when "OPEN"
            bar.getElementAsFloat64("open")
          when "HIGH"
            bar.getElementAsFloat64("high")
          when "LOW"
            bar.getElementAsFloat64("low")
          when "CLOSE"
            bar.getElementAsFloat64("close")
          when "NUM_EVENTS"
            bar.getElementAsInt32("numEvents")
          when "VOLUME"
            bar.getElementAsFloat64("volume")
          else
            raise f
          end
          
          @data_table.rows[1].append_to_array(i+1, data)
        end
      end
    end
  end
end