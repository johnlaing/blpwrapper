require 'win32ole'

conn = WIN32OLE.new("Bloomberg.Data.1")

def inspect_method(ole_method)
  puts "*" * 20
  puts "ole method: " + ole_method.name
  puts ole_method.invoke_kind + " returns " + ole_method.return_type_detail.join(", ")
  
  args = "takes #{ole_method.size_params} args"
  if ole_method.size_opt_params > 0
    args << " of which #{ole_method.size_opt_params} are optional"
  end
  puts args
  
  ole_method.params.each do |p|
    puts " - " + p.name + " (" + p.ole_type.inspect + ": " + p.ole_type_detail.inspect + ") defaults to: " + p.default.inspect
  end
  
  puts "not visible!" if !ole_method.visible?
end

methods = conn.ole_methods
methods = methods.sort {|a, b| a.name <=> b.name }

methods.map {|m| inspect_method(m)}

# Uncomment this to see what else is out there!
# puts (methods.last.methods - Object.new.methods).sort

# dispid
# event?
# event_interface
# helpcontext
# helpfile
# helpstring
# invkind
# invoke_kind
# name
# offset_vtbl
# params
# return_type
# return_type_detail
# return_vtype
# size_opt_params
# size_params
# visible?