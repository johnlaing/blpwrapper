raise "this script is windows only" unless RUBY_PLATFORM =~ /mswin32/
require "tempfile"



dir = Dir.new(File.expand_path(File.join(File.dirname(__FILE__), %w[.. webby content rbloomberg examples])))

dir.each do |f|
  next unless f =~ /R$/
  next if f =~ /^._/
  
  original_file = File.join(dir.path, f)
  
  data = File.read(original_file)
  data = data.gsub(/^\#\#\#.*$\n/, "") # strip out idiopidae comments so they don't clutter output
  
  file = Tempfile.new("rbloomberg")
  file.write(data)
  file.close
  
  cmd = "cd #{dir.path.gsub("/", "\\")} & R CMD BATCH #{file.path} #{original_file.gsub(/R$/, "Rout")}"
  system(cmd)
end
