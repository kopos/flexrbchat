#!/usr/bin/ruby
require 'socket'

init    = "Server started. Waiting for connections...\000"
welcome = "Welcome! type EXIT to quit\000"
byebye	= "Disconnected from server\000"
eof     = '\000'

url			= "127.0.0.1"
port		= 9999
server	= TCPServer.new(url, port)
puts init 

while (socket = server.accept)
	socket.puts welcome 

	quit = false
	while !quit
		msg		= socket.gets
		if msg.nil?
			quit = true
		else
			msg		= msg[1..-1] if msg[0] == "\000"
		end

		if msg.chomp != "EXIT"
			socket.puts "<b>me</b>: #{msg.chomp}\000"
		else
			quit = true
		end
	end

	if quit
		socket.puts byebye
#		socket.puts eof
		socket.close
	end

end
