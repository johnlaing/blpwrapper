module RubyBloomberg
  class OleRequest < Request
    def date_param_to_variant(value)
      case value
      when Date, Time
        WIN32OLE_VARIANT.new(value, WIN32OLE::VARIANT::VT_DATE)
      when String
        WIN32OLE_VARIANT.new(Time.parse(value), WIN32OLE::VARIANT::VT_DATE)
      when Fixnum
        WIN32OLE_VARIANT.new(value, WIN32OLE::VARIANT::VT_I4)
      else
        raise "unhandled date_variant class #{value.class.name}"
      end
    end
    
    def detect_error(value)
      if value =~ /#N\/A/ # an error, handle it
        case value
        when "#N/A N.A."
          nil
        else
          raise "unknown error #{value}"
        end
        
      else # not an error
        value
      end
    end
    
    def fetch_raw_historical_request
      if @currency.nil?
        data_service.BLPGetHistoricalData(
          @securities, 
          @fields, 
          @start_date, 
          @end_date, 
          @bar_size, 
          @bar_fields
        )
      else
        data_service.BLPGetHistoricalData2(
          @securities, 
          @fields, 
          @start_date, 
          @currency,
          @end_date, 
          @bar_size, 
          @bar_fields
        )
      end
    end
  end
end
