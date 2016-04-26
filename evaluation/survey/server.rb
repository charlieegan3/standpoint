# server.rb
#
# This is simple test server for generated surveys. It hosts surveys in a
# similar way to mturk, allowing you to test the responses

require 'sinatra'

set :bind, '0.0.0.0'

get '/' do
  html = File.open(Dir.glob('*.html').sample).read
  "<form action=\"/\" method=\"post\">" + html + "<input type=\"submit\" value=\"Submit\">"
end

post '/' do
  "<table>" +
  params.map { |k, v| "<td>#{k}</td><td>#{v}</td>" }.join("</tr><tr>") +
  "</table>"
end
