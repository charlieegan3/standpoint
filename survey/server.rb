require 'sinatra'

set :bind, '0.0.0.0'

get '/' do
  html = File.open("#{rand(0..4)}.html").read
  "<form action=\"/\" method=\"post\">" + html + "<input type=\"submit\" value=\"Submit\">"
end

post '/' do
  "<table>" +
  params.map { |k, v| "<td>#{k}</td><td>#{v}</td>" }.join("</tr><tr>") +
  "</table>"
end
