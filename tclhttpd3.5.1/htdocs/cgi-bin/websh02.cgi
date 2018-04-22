#!/usr/bin/tclsh

#
# websh jako "skrypt cgi"
#

# ---------------------------------------------------------------------

load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so
#package require websh

cd /mnt/hdb5/mhanckow/tcl8.4/httpd/tclhttpd3.5.1/htdocs/cgi-bin
  # na wszelki wypadek...

web::command default {
  web::put "<p>A ku ku !</p>"
  
  web::put "<p>[pwd]</p>"

  web::put "<p>wartosci parametrow:<br><pre>"
  foreach x [web::param -names] {
    web::put "   $x = [web::param $x]\n"  
  }
  web::put "</pre></p>"

  web::put "<p>A ku ku !</p>"
}

web::command qqq1 {
  web::put "<p>to ja komenda qqq1</p>"
}

web::command qqq2 {
  web::put "<p>to ja komenda qqq2</p>"
}

web::dispatch
  # ta komenda jest odpowiedzialna za sparsowanie parametrow zadania...

