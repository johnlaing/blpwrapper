include_class "com.bloomberglp.blpapi.Request"
include_class "com.bloomberglp.blpapi.Element"
include_class "com.bloomberglp.blpapi.Event"
include_class "com.bloomberglp.blpapi.Message"
include_class "com.bloomberglp.blpapi.MessageIterator"

module RubyBloomberg
  class JavaRequest < Request
    def session
      Connection.instance.session
    end
    
    # Do any data type conversion or cleaning needed to send parameters to Bloomberg
    def prepare_parameter(param)
      case param
      when String
        if param =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ # This is a date like 2006-01-01, strip out the dashes.
          param.gsub("-", "")
        else
          param
        end
      when Fixnum
        # Use a Short, otherwise it converts to Int64 which Bloomberg rejects
        java.lang.Short.new(param.to_s)
      when Date, Time
        param.strftime("%Y%m%d")
      else
        param
      end
    end
    
    def field_value(field)
      case field.datatype.to_s
      when "DATE"
        # TODO find out what datetime class is being returned and how to convert it properly i.e. time zones
        field.getValueAsDate.to_s
      when "FLOAT64"
        field.getValueAsFloat64
      when "STRING"
        field.getValueAsString
      else
        raise field.datatype.to_s
      end
    end
    
    def submit
      request = data_service.create_request(self.class.name.split("::").last)
      
      securities = request.get_element("securities")
      @securities.each do |s|
        securities.append_value(s)
      end

      fields = request.get_element("fields")
      @fields.each do |f|
        fields.append_value(f)
      end
      
      unless @override_fields.empty?
        overrides = request.get_element("overrides")
        
        @override_fields.zip(@overrides).each do |f, v|
          o = overrides.appendElement
          o.setElement("fieldId", f)
          o.setElement("value", v)
        end
      end
      
      @params.each do |k, v|
        k = 'startDate' if k.to_s === 'start_date'
        k = 'endDate' if k.to_s === 'end_date'
        request.set(k.to_s, prepare_parameter(v))
      end
      
      session.send_request(request, nil)
      read_response
    end
    
    def read_message_data(event)
      raise "define in subclass"
    end
    
    def expected_response_message_type
      self.class.name.split("::").last.gsub(/Request$/, "Response")
    end
    
    def read_response
      loop do
        event = session.next_event
        
        case event.event_type
        when Event::EventType::SESSION_STATUS
        when Event::EventType::SERVICE_STATUS
        when Event::EventType::PARTIAL_RESPONSE, Event::EventType::RESPONSE
          message_iterator = event.message_iterator

          while message_iterator.has_next do
            message = message_iterator.next

            is_expected_type = (message.message_type.to_s === expected_response_message_type)
            unexpected_type_message = "unexpected message type #{message.message_type}, expected #{expected_response_message_type}"
            raise unexpected_type_message unless is_expected_type
            
            read_message_data(message)
          end
          
        else
          raise event.event_type
        end
        
        # All requested data has been returned when we get RESPONSE
        break if event.event_type == Event::EventType::RESPONSE
      end
      
      @data_table
    end
  end
end
