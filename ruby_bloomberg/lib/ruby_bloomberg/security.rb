module RubyBloomberg
  module Security
    # Include this module in your security class to add Bloomberg related functions for individual securities.
    # Your class should define a bloomberg_ticker method which returns e.g. "RYA ID Equity"
    
    # Returns a single value for the requested data.
    def bdp(field)
      ReferenceDataRequest.submit(bloomberg_ticker, field).value
    end
  end
end