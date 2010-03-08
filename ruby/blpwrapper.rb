require 'java'
require 'date'

$CLASSPATH << 'C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar'
$CLASSPATH << 'C:\\blpwrapper\\java\\blpwrapper.jar'

class Blpwrapper
  include_class "org.findata.blpwrapper.Connection"

  def initialize
    @conn = Connection.new
  end

  def show_errors
    begin
      yield
    rescue Exception => e
      puts e.inspect
      puts e.backtrace
      raise e.message # Re-raise errors as RuntimeErrors rather than a special class of error.
    end
  end

  def blp(securities, fields, return_format = :array, override_fields = nil, override_values = nil)
    show_errors do
      securities = [securities] unless securities.is_a?(Array)
      fields = [fields] unless fields.is_a?(Array)
      if override_fields.nil?
        result = DataResult.new(@conn.blp(securities.to_java(:string), fields.to_java(:string)))
      else
        result = DataResult.new(@conn.blp(securities.to_java(:string), fields.to_java(:string), override_fields.to_java(:string), override_values.to_java(:string)))
      end
      result.return_as(return_format)
    end
  end

  def bls(security, field, return_format = :array)
    show_errors do
      result = DataResult.new(@conn.bls(security, field))
      result.return_as(return_format)
    end
  end

  def blh(security, fields, start_date, end_date = nil, return_format = :array)
    show_errors do
      fields = [fields] unless fields.is_a?(Array)
      start_date = start_date.strftime("%Y%m%d") if start_date.respond_to?(:strftime)
      if end_date.nil?
        result = DataResult.new(@conn.blh(security.to_java_string, fields.to_java(:string), start_date.to_java_string))
      else
        end_date = end_date.strftime("%Y%m%d") if end_date.respond_to?(:strftime)
        result = DataResult.new(@conn.blh(security.to_java_string, fields.to_java(:string), start_date.to_java_string, end_date.to_java_string))
      end
      result.return_as(return_format)
    end
  end
  
  def value_on_date(security, fields, date)
    show_errors do
      fields = [fields] unless fields.is_a?(Array)
      date = date.strftime("%Y%m%d") if date.respond_to?(:strftime)

      override_fields = [].to_java(:string)
      override_values = [].to_java(:string)

      option_names = ["nonTradingDayFillOption", "nonTradingDayFillMethod"].to_java(:string)
      option_values = ["ALL_CALENDAR_DAYS", "PREVIOUS_VALUE"].to_java(:string)

      result = DataResult.new(@conn.blh(security.to_java_string, fields.to_java(:string), date.to_java_string, date.to_java_string, override_fields, override_values, option_names, option_values))
      result.return_as(:value)
    end
  end
end

class DataResult
  def initialize(result)
    @result = result
  end

  def return_as(return_format)
    case return_format
    when :array
      self.data
    when :data_result
      self 
    when :hash
      self.data.collect do |a|
        hash = {}
        self.headers.each_with_index do |h, i|
          hash[h] = a[i]
        end
        hash
      end
    when :value
      case @result.class.name
      when /HistoricalDataResult/
        self.data[0][1]
      when /ReferenceDataResult/
        self.data[0][0]
      else
        raise ":value not meaningful for " + @result.class.name
      end
    else
      raise return_format.to_s
    end
  end

  def data
    original_array = @result.getData.to_a
    converted_array = []

    original_array.each_with_index do |a, i|
      converted_array[i] = []
      a.each_with_index do |x, j|
        v = case types[j]
        when 'STRING'
          x
        when 'FLOAT64'
          x.to_f
        when 'DATE'
          x.empty? ? x : Date.parse(x)
        when 'NOT_APPLICABLE'
          nil
        else
          raise "Don't know how to convert " + types[j]
        end
        converted_array[i][j] = v
      end
    end

    converted_array
  end

  def headers
    @result.getColumnNames.to_a
  end

  def types
    @result.getDataTypes.to_a
  end
end
