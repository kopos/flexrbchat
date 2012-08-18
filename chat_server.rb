#!/usr/bin/ruby
require 'socket'

MSGS = {"init" => "Server started. Waiting for connections...",
        "welcome" => "Welcome! type EXIT to quit",
        "byebye" 	=> "Disconnected from server"}

EOF  = "\000"
HOST = "localhost"
PORT = 9999

server	= TCPServer.new(HOST, PORT)
puts MSGS["init"] 

# array to store all the active connections
sessions = []
while (session = server.accept)
    # push the current session(socket) in the array
    sessions << session
    # initialize a new thead for each connection
    Thread.new(session) do |local_session|
        local_session.puts "<i>#{MSGS["welcome"]}</i>" + EOF

    # each time a client sends some data send it to all the connections
    while(true)
        data = local_session.gets
    
        if !data.nil?
            delim_pos = data.index(":")
            name      = data[0..delim_pos-1]
            data      = data[delim_pos+1..-1]
    
            if data[0] == EOF
                data = data[1..-1] 
            elsif data.chomp == "EXIT"
                sessions.delete(local_session)
                local_session.puts "<i>#{MSGS["byebye"]}</i>" + EOF
                local_session.close
    
                data = "<i>#{name} disconnected from the server</i>" + EOF
            end
        end
    
        sessions.each do |s| 
            begin
                s.puts "<b>#{name}</b>: #{data.chomp}" + EOF
                rescue Errno::ECONNRESET
                    # an exception is raised, that means the connection to the client is broken
                    sessions.delete(s)
                end
            end
        end
    end
end
