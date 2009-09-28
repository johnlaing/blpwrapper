module RubyBloomberg
  class DrbWrapper
    def reference_data_request(*params)
      puts "processing reference_data_request with #{params.inspect}"
      e { ReferenceDataRequest.submit(*params) }
    end
    
    def historical_data_request(*params)
      HistoricalDataRequest.submit(*params)
    end
    
    def intraday_bar_request(*params)
      e {IntradayBarRequest.submit(*params)}
    end
    
    private
    
    def e
      begin
        yield
      rescue Exception => e
        puts e.inspect
        false
      end
    end
  end
end
