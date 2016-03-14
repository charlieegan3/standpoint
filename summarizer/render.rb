doc = File.open("template.html").read

content = ""
while line=gets
  content += line
end

title = content.scan(/>([\w\s]+)</).flatten.first

doc.gsub!("{{ TITLE }}", title)
doc.gsub!("{{ CONTENT }}", content)

File.open("#{title.gsub(/\s+/, "").downcase}_summary.html", 'w').write(doc)
