require 'openssl'
require 'digest/sha1'
require 'yaml'
 
puts "Enter passphrase: "
 
passphrase = gets.chomp
 
puts "Enter text to encrypt: "
 
encrypt = gets.chomp
 
puts "Encrypting '#{encrypt}' with AES-256-CBC using passphrase '#{passphrase}'"
 
cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
cipher.encrypt
# your pass is what is used to encrypt/decrypt
cipher.key = key = Digest::SHA1.hexdigest(passphrase).unpack('a2'*32).map{|x| x.hex}.pack('c'*32)
cipher.iv = iv = cipher.random_iv
encrypted = cipher.update(encrypt)
encrypted << cipher.final
 
puts "Saving encrypted result: '#{encrypted}' with iv: #{iv}"
 
yaml_obj = {
:iv => iv,
:encrypted => encrypted
}
 
File.open('config.yml', 'w') do |out|
YAML::dump(yaml_obj, out)
end
 
exit