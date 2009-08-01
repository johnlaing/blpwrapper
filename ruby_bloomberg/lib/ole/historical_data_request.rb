module RubyBloomberg
  class HistoricalDataRequest < OleRequest
    
    def process_param(key, value)
      case key.to_sym
      when :currency
        @currency = value
      when :start_date, :startDate
        @start_date = date_param_to_variant(value)
      when :end_date, :endDate
        @end_date = date_param_to_variant(value)
      else
        raise key.to_s
      end
    end
    
    def date_param_to_variant(value)
      value = value.strftime("%Y-%m-%d") if value.respond_to?(:strftime)
      case value
      when String
        raise ArgumentError, "string #{value} isn't in a valid date format" unless value =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/
        WIN32OLE_VARIANT.new(value, WIN32OLE::VARIANT::VT_DATE)
      when Fixnum
        WIN32OLE_VARIANT.new(value, WIN32OLE::VARIANT::VT_I4)
      else
        raise "unhandled date_variant class #{value.class.name}"
      end
    end
    
    def submit
      @params.each do |k, v|
        process_param(k, v)
      end
      
      if @currency.nil?
        raw_result = data_service.BLPGetHistoricalData(
          @securities, 
          @fields, 
          @start_date, 
          @end_date, 
          @bar_size, 
          @bar_fields
        )
      else
        raw_result = data_service.BLPGetHistoricalData2(
          @securities, 
          @fields, 
          @start_date, 
          @currency,
          @end_date, 
          @bar_size, 
          @bar_fields
        )
      end
      
      prepare_historical_data_table
      
      raw_result.each_with_index do |a, i|
        a.each_with_index do |b, j|
          b.each_with_index do |x, k|
            if k == 0
              next unless j == 0
              # Fill in dates. Only need to do this once due to evil hack.
              @data_table.rows[0].append_to_array(1, Date.strptime(x[0,10].gsub("/", "-")))
            else
              @data_table.rows[j+1].append_to_array(k, x)
            end
          end
        end
      end
    end
  end
end