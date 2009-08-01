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
      
      # [["2006/11/15 00:00:00", 93.11, 93.08], ["2006/11/15 00:00:00", 29.12, 29.125]]
      raw_result.each_with_index do |a, i|
        break if i > 10
        a.each_with_index do |b, j|
          b.each_with_index do |x, k|
            if k == 0
              next unless j == 0
              @data_table.rows[0].append_to_array(1, x)
            else
              @data_table.rows[j+1].append_to_array(k, x)
            end
          end
        end
      end
    end
  end
end