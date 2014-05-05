#!/usr/bin/env node

var net = require('net');
var util = require('util');
var crypto = require('crypto');

var CLIENT = "CLIENT";
var SERVER = "SERVER";
var ERROR = "Error";

var KEY_MSG = "key";
var KEYPHRASE_MSG = "keyphrase";
var RESULT_MSG = "result";

var options = {
	'port': 6969,
	'host': "54.83.207.90",
};


process.stdin.resume();
process.stdin.setEncoding('utf8');
var payload = null;
process.stdin.on('data', function (chunk) {
	payload = chunk.trim();
});

var socket = net.connect(options);

socket.on('data', function(data) {
	data = data.toString().trim();
	if(data == ERROR) {
		socket.end();
		return;
	}

	// Parses msg
	data = data.split(':');
	var msg = data[1];
	var dmsg = msg.split('|'); 
	data = data[0].split('->');
	var from = data[0];
	var to = data[1];
	
	// Man in the middle
	if(from == CLIENT && dmsg[0] == KEY_MSG) {
		sim_c_dh = crypto.createDiffieHellman(dmsg[1], 'hex');
		sim_c_dh.generateKeys();
		sim_c_secret = sim_c_dh.computeSecret(dmsg[2], 'hex');

		sim_s_dh = crypto.createDiffieHellman(256);
		sim_s_dh.generateKeys();
		msg = util.format('key|%s|%s\n', sim_s_dh.getPrime('hex'), sim_s_dh.getPublicKey('hex'));

	} else if(from == SERVER && dmsg[0] == KEY_MSG) {
		sim_s_secret = sim_s_dh.computeSecret(dmsg[1], 'hex');
		msg = util.format('key|%s\n', sim_c_dh.getPublicKey('hex'));

	} else if(from == CLIENT && dmsg[0] == KEYPHRASE_MSG) {
		var cipher = crypto.createCipheriv('aes-256-ecb', sim_s_secret, '');
		var keyphrase1 = cipher.update(payload, 'utf8', 'hex') + cipher.final('hex');
		msg = util.format('keyphrase|%s\n', keyphrase1);

		//var decipher2 = crypto.createDecipheriv('aes-256-ecb', sim_c_secret, '');
		//var keyphrase3 = decipher2.update(dmsg[1], 'hex', 'utf8') + decipher2.final('utf8');
		//process.stdout.write("Original keyphrase: " + keyphrase3 + '\n');
	} else if(from == SERVER && dmsg[0] == RESULT_MSG) {
		var decipher = crypto.createDecipheriv('aes-256-ecb', sim_s_secret, '');
		var keyphrase2 = decipher.update(dmsg[1], 'hex', 'utf8') + decipher.final('utf8');

		var cipher2 = crypto.createCipheriv('aes-256-ecb', sim_c_secret, '');
		var result = cipher2.update(keyphrase2, 'utf8', 'hex') + cipher2.final('hex');
		msg = util.format('result|%s\n', result);

		// prints solution
		process.stdout.write(keyphrase2 + '\n');
	}

	//process.stdout.write("------------->:" + msg + "\n");
	socket.write(msg);
});
