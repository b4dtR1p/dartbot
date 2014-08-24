import 'dart:io';

import 'package:irc_client/irc_client.dart';
import 'package:logging/logging.dart';

var settings = {
            "serv": "irc.iotek.org",
            "port": "6667",
            "name": "cbra",
            "chan": "#bot",
            "pref": "!",
};

void commandHandler(String chan, String org, Connection irc) {
  var cmd = org.substring(1);
  
  switch(cmd) {
    case "ping":
      print("[bot] command: ping");
      irc.sendMessage(chan, "pong");
      break;
    case "dartvm":
      print("[bot] command: dartvm");
      irc.sendMessage(chan, "dartvm version: ${Platform.version}");
      break;
    case "help":
      print("[bot] command: help");
      irc.sendMessage(chan, "http://github.com/thevypr/dartbot/blob/master/README.md");
      break;
    default:
      print("[bot] invalid command");
      irc.sendMessage(chan, "invalid command");
      break;
  }
}

class Bot extends Handler {
  bool onChannelMessage(String chan, String msg, Connection irc) {
    if(msg.startsWith(settings["pref"])) { commandHandler(chan, msg, irc); }
    
    return true;
  }
  
  bool onConnection(Connection irc) {
    print("[bot] connection successful");
    irc.join(settings["chan"]);
    print("[bot] joined ${settings["chan"]}");
    return true;
  }
}

void main() {
  print("[bot] bot initialized");
  print("[bot] using name '${settings["name"]}'");
  
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((r) {
    print("[ERR] ${r.message}");
  });
  
  var bot = new IrcClient(settings["name"]);
  bot.realName = settings["name"] + " - using the dartbot template by thevypr";
  
  bot.handlers.add(new Bot());
  bot.connect(settings["serv"], int.parse(settings["port"]));
  print("[bot] connecting to ${settings["serv"]}:${settings["port"]}");
}
