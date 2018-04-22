#!/usr/bin/tclsh

# - ladowanie duzego roz.bin. wyraznie spowalni cgi !!!
# - to jest skuteczna metoda debugowania !!!
#     if [catch { # dbg - poczatek
#     }] {web::put "<p>$errorInfo</p>"}; # dbg - koniec
# - ???

# ---------------------------------------------------------------------

load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so

if [catch { # dbg - poczatek

cd /mnt/hdb5/mhanckow/tcl8.4/httpd/tclhttpd3.5.1/htdocs/cgi-bin
  # na wszelki wypadek...

# ladujemy pakiety ...
#load /home/mhanckow/tcl/tcl8.4/xotcl-1.5.2/lib/xotcl1.5.2/libxotcl1.5.2.so
#namespace import xotcl::*

web::command default {
  web::put "<p>A ku ku !</p>"

  web::put "<p>[pwd]</p>"
  web::put "<p>[glob *]</p>"

  web::put "<p>wartosci parametrow:<br>"
  foreach x [web::param -names] {
    web::put "   $x = [web::param $x]<br>"  
  }
  web::put "</p>"

  web::put "<p>A ku ku !</p>"
}

web::command xotcl {
  load /home/mhanckow/tcl/tcl8.4/xotcl-1.5.2/lib/xotcl1.5.2/libxotcl1.5.2.so
  namespace import xotcl::*
    # ladowac roz. tylko jesli jest potrzebne ???
  Object o1
  o1 set x 123
  o1 proc qqq {} {
    my instvar x; incr x; return "x=$x"
  }
  web::put "<p>[o1 qqq]</p>"
}

web::dispatch
  # ta komenda jest odpowiedzialna za sparsowanie parametrow zadania...

}] {web::put "<p>$errorInfo</p>"}; # dbg - koniec

