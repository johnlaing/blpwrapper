module RubyBloomberg
  module Security
    # Include this module in your security class to add Bloomberg related functions for individual securities.
    # Your class should define a bloomberg_ticker method which returns e.g. "RYA ID Equity"
    
    # Returns a single value for the requested data.
    def bdp(field, params = {})
      ReferenceDataRequest.submit(bloomberg_ticker, field, params).value
    end
    
    def bdh(field, params)
      HistoricalDataRequest.submit(bloomberg_ticker, field, params)
    end
  end
end