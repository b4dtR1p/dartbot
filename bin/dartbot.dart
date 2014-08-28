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
  var arg;
  
  if(msg.contains(" ")) {
    cmd = ncmd.split(" ")[0];
    try {
      arg = msg.split(" ")[1];
    } catch(e) {
      print("[cmd] received command with no argument");
      irc.sendMessage(chan, "$sndr: no argument found");
    }
  }
  
  switch(cmd) {
    case "ping":
      print("[cmd] $sndr: ping");
      irc.sendMessage(chan, "$sndr: pong");
      break;
    case "help":
      print("[cmd] help");
      irc.sendMessage(chan, "$sndr: http://github.com/thevypr/dartbot/blob/master/README.md");
      break;
    case "rtd":
      Random r = new Random();
      print("[cmd] $sndr: rtd");
      irc.sendMessage(chan, "$sndr: you rolled a ${r.nextInt(6) + 1}");
      break;
    case "sqrt":
	    try {
	      arg = num.parse(arg);
	    	if(arg > -1) {
  	      var fin = sqrt(arg);
  	    	print("[cmd] $sndr: sqrt($arg)");
          irc.sendMessage(chan, "$sndr: $fin");
         } else {
          print("[cmd] invalid sqrt request - err: not a number");
          irc.sendMessage(chan, "$sndr: invalid argument");
         }
	    } catch(e) {
	    	print("[cmd] invalid sqrt request");
	    	irc.sendMessage(chan, "$sndr: invalid argument");
	   	}
    	break;
    default:
      print("[cmd] err: invalid");
      irc.sendMessage(chan, "$sndr: invalid command");
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
