require 'pry'
require 'json'

folder_paths = %w(abortion  creation  gayRights  god  guns  healthcare).map {|f|"analysis_api/debates/#{f}/*"}

folder_paths.each do |path|
  puts path
  Dir.glob(path).to_a.each_with_index do |file, index|
    content = File.open(file).read
    content = content.chars.select(&:valid_encoding?).join

    meta = Hash[*content.scan(/^#.*=.*$/).map { |e| e.delete('#').split("=") }.flatten]
    meta = meta.inject({}){ |memo,(k,v)| memo[k.to_sym] = v; memo }.merge!(post: index)


    content = content
      .gsub(/^#.*=.*$/, "")
      .gsub(/\[[0-9]+\]/, "")
      .gsub(/http\S+|\S{30,}/, "")
      .gsub(/([a-z]{3,}\.)([A-Z][a-z]{3,})/, '\1 \2')
      .gsub(/([a-z]{3,}\.)([0-9]\.)/, '\1 \2')
      .gsub(/\s+/, " ")
      .gsub("[...]", "")
      .gsub("/>", "")
      .gsub(" / ", "")
      .strip
    processed_file = meta.merge(content: content)
    File.open("#{file}.json", "w").write(processed_file.to_json)
  end
end
