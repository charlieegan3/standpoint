folder_paths = %w(abortion  creation  gayRights  god  guns  healthcare).map {|f|"debates/#{f}/*"}

folder_paths.each do |path|
  puts path
  Dir.glob(path) do |file|
    file = File.open(file)
    contents = file.readlines.reject { |x| x[0] == '#' }
    contents.map! { |l| l.chars.select(&:valid_encoding?).join }
    contents.map! { |l| l.gsub("/>", "") }
    contents.map! { |l| l.gsub(" / ", "") }
    File.open(file, "w").write(contents.join("\n"))
  end
end
