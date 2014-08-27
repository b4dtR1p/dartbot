import 'dart:io';
import 'dart:math';

import 'package:irc_client/irc_client.dart';
import 'package:logging/logging.dart';

var settings = {
            "serv": "irc.iotek.org",
            "port": "6667",
            "name": "dart",
            "chan": "#bot",
            "pref": "!",
};

var sndr;

void commandHandler(String chan, String sndr, String msg, Connection irc) {
  var ncmd = msg.substring(1);
  var cmd = ncmd;
  
  if(msg.contains(" ")) {
    cmd = ncmd.split(" ")[0];
  }
  
  switch(cmd) {
    case "ping":
      print("[cmd] ping");
      irc.sendMessage(chan, "pong");
      break;
    case "help":
      print("[cmd] help");
      irc.sendMessage(chan, "http://github.com/thevypr/dartbot/blob/master/README.md");
      break;
    case "rtd":
      Random r = new Random();
      print("[cmd] rtd");
      irc.sendMessage(chan, "you rolled a ${r.nextInt(6) + 1}");
      break;
    case "sqrt":
    	if(msg.contains(" ")) {
	    	var arg = msg.split(" ")[1];
	    	arg = num.parse(arg);
	    	try {
	    	  if(arg > -1) {
  	    		var fin = sqrt(arg);
  	    		print("[cmd] sqrt($arg)");
            irc.sendMessage(chan, "$fin");
          } else {
            print("[cmd] invalid sqrt request - err: not a number");
            irc.sendMessage(chan, "invalid argument");
          }
	    	} catch(e) {
	    		print("[cmd] invalid sqrt request - $e");
	    		irc.sendMessage(chan, "invalid argument");
	    	}
    	} else {
    		print("[cmd] invalid sqrt request - err: no argument found");
    		irc.sendMessage(chan, "no argument found");
    	}
    	break;
    case "info":
      print("[cmd] info");
      irc.sendMessage(chan, "server: ${settings["serv"]}:${settings["port"]} (channel: ${settings["chan"]})");
      irc.sendMessage(chan, "dartvm version: ${Platform.version.split(" ")[0]} on ${Platform.operatingSystem}");
      irc.sendMessage(chan, "cmdprefix: ${settings["pref"]}");
      irc.sendMessage(chan, "using dartbot 0.4.2 - http://git.io/HbduzQ");
      break;
    default:
      print("[cmd] err: invalid");
      irc.sendMessage(chan, "invalid command");
      break;
  }
}

class Bot extends Handler {
  bool onChannelMessage(String chan, String msg, Connection irc) {
    if(msg.startsWith(settings["pref"])) { commandHandler(chan, sndr, msg, irc); }
    
    return true;
  }
  
  bool onConnection(Connection irc) {
    print("[bot] connection successful");
    irc.join(settings["chan"]);
    print("[bot] joined ${settings["chan"]}\n");
    return true;
  }
}

void main() {
  print("[bot] bot initialized");
  print("[bot] using name '${settings["name"]}'");
  
  var bot = new IrcClient(settings["name"]);
  bot.realName = settings["name"] + " - using the dartbot template by thevypr";
  
  bot.handlers.add(new Bot());
  var handler = bot.handlers.first;
  bot.connect(settings["serv"], int.parse(settings["port"]));
  print("[bot] connecting to ${settings["serv"]}:${settings["port"]}");
  
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    if(r.message.contains("PRIVMSG")) sndr = r.message.split("!")[0].split(":")[1];
  });
}
