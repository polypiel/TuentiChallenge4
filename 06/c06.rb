#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 6
#
# Angel Calvo
#######################################

# DO NOT WORK!

require "socket"
require "openssl"

HOST = "54.83.207.90"
PORT = 6969

EXPR = /^(\w+)->(\w+):(.+)$/
CLIENT = "CLIENT"
SERVER = "SERVER"
ERROR = "Error"

KEY_MSG = "key"
KEYPHRASE_MSG = "keyphrase"
RESULT_MSG = "result"

def encrypt(data, key, iv = nil)
  aes = OpenSSL::Cipher::Cipher.new("AES-256-ECB")
  aes.encrypt
  aes.key = key
  aes.iv = iv if iv != nil
  aes.update(data) + aes.final
end

def decrypt(encrypted_data, key, iv = nil)
    aes = OpenSSL::Cipher::Cipher.new("AES-256-ECB")
    aes.decrypt
    aes.key = key
    aes.iv = iv if iv != nil
    aes.update(encrypted_data) + aes.final  
  end
  
# Main block
if __FILE__ == $0
  socket = TCPSocket.new HOST, PORT
  payload = ARGF.readline.chomp
  
  # DF
  s_dh = OpenSSL::PKey::DH.new(256) 
  s_dh.generate_key!
  #s_dh = OpenSSL::PKey::DH.new(c_dh.public_key.to_der)
  #s_dh.generate_key!
  #c_symm_key = c_dh.compute_key(c_dh.pub_key)
  #s_symm_key = s_dh.compute_key(s_dh.pub_key)

  while line = socket.gets
	puts line.chomp
	exit() if line.chomp == ERROR

	# Parses package
	from, to, msg = line.chomp.match(EXPR).captures
	dmsg = msg.split("|")

 	if from == CLIENT and dmsg[0] == KEY_MSG
	  c_dh = OpenSSL::PKey::DH.new([dmsg[1]].pack('H*'))
	  c_dh.generate_key!
	  c_key = c_dh.compute_key(dmsg[2])
	  
	  msg = "#{KEY_MSG}|#{s_dh.public_key.p.to_s(16)}|#{s_dh.public_key.to_der.unpack('H*')[0]}"
	  puts "#{dmsg[1]}"
	elsif from == SERVER and dmsg[0] == KEY_MSG
	  s_key = s_dh.compute_key(dmesg[1])
	  msg = "#{KEY_MSG}|#{s_dh.pub_key.to_s(16)}"
	  
 	elsif from == CLIENT and dmsg[0] == KEYPHRASE_MSG
	  puts "decrypt(#{dmsg[1]}, [#{c_symm_key.unpack('H*')[0]}, #{s_symm_key.unpack('H*')[0]}, #{c_dh.pub_key.to_s(16)}, #{c_dh.priv_key.to_s(16)}, #{s_dh.pub_key.to_s(16)}, #{s_dh.priv_key.to_s(16)}])"
	  #puts decrypt([dmsg[1]].pack('H*'), c_symm_key.to_s).unpack('H*')[0]
	  c_payload = encrypt(payload, [c_dh.priv_key.to_s].pack('H*')).unpack('H*')[0]
 	  msg = "#{KEYPHRASE_MSG}|#{c_payload}"
	  
	elsif from == SERVER and dmsg[0] == RESULT_MSG
	  secret = decrypt(dmsg[1])
	  puts secret
 	end
	
	# Send
	puts "------------->:#{msg}"
	socket.puts "#{msg}\n"
  end
  socket.close  
end
