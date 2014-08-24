import 'dart:io';
import 'dart:math';

import 'package:irc_client/irc_client.dart';
import 'package:logging/logging.dart';

var settings = {
            "serv": "irc.iotek.org",
            "port": "6667",
            "name": "cbra",
            "chan": "#bot",
};

class Bot extends Handler {
  bool onChannelMessage(String chan, String msg, Connection irc) {
    if(msg == "!ping") { irc.sendMessage(chan, "pong"); }
    else if(msg == "!help") { irc.sendMessage(chan, "todo"); }
    
    return true;
  }
  
  bool onConnection(Connection irc) {
    irc.join(settings["chan"]);
    
    return true;
  }
}

void main() {
  print("[${settings["name"]}] Bot initialized.");
  
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    print("${r.time}: ${r.loggerName} - ${r.message}");
  });
  
  var bot = new IrcClient(settings["name"]);
  bot.realName = settings["name"] + " - using the dartbot template by thevypr";
  
  bot.handlers.add(new Bot());
  bot.connect(settings["serv"], int.parse(settings["port"]));
}
