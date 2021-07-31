require "http/server"
require "big/big_int"
require "./diffie_hellman"
require "./dna_algo"

## Add a nice message
puts "Client"
puts "Enter the address :"
address = read_line()

puts "Enter the port :"
port = read_line().to_i()

begin
  client = TCPSocket.new(address, port)
rescue ex
  puts ex
  exit
end

puts "Connected to: #{client.local_address}"

puts "Enter the message to send : "
msg = read_line()

# Get p and g pair from the server
response = client.gets || ""

if response != ""
  puts "Recieved prime and g"
end

r = response.split(",")
p = BigInt.new(r[0], 10)
g = BigInt.new(r[1], 10)

puts "Generating random private key..."
pk = rand(2^63_u64)
puts "Generated private key"

# create public key using above and share
DH.new(BigInt.new(pk), p, g)
pub_c = BigInt.new(DH.get_public_key())

s_s = client.gets()
pub_s = BigInt.new(s_s || "0", 10)
client.puts(pub_c.to_s)

sec_s = DH.get_secret_key(pub_s)

# puts "p : #{p}"
# puts "g : #{g}"
# puts "pub_s: #{pub_s}"
# puts "pub_c: #{pub_c}"
# puts "Secret: #{sec_s}"
# puts "Server gave: #{pub_s}"

# extract the key
key = DNA.new(sec_s)

# use the key to encrypt the message
data = DNA.encrypt(msg)

#send to server
client.puts(data)

puts "Encrypted Message: #{data}"
puts "Message sent to: #{client.local_address}"

client.close()
