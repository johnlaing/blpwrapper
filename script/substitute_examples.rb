files = %w{blp bls blh}

files.each do |f|
  manual_page_file_path = File.join("rbloomberg", "man", "#{f}.Rd")
  manual_page_text = File.read(manual_page_file_path)
  
  example_file_path = File.join("webby", "content", "rbloomberg", "examples", "#{f}.R")
  example_file_text = File.read(example_file_path)

  File.open(manual_page_file_path, "w") do |f|
    f.write manual_page_text.gsub("#EXAMPLE", example_file_text)
  end
end

