#!/usr/bin/tclsh

# bardzo prosty przyklad uzycia websh...

# ---------------------------------------------------------------------

if [catch { # dbg - poczatek

load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so
source /home/mhanckow/tcl/mh_lib.tcl
cd /mnt/hdb5/mhanckow/tcl8.4/httpd/tclhttpd3.5.1/htdocs/cgi-bin
  # ladowanie pakietow i inne ...

web::command default {
  web::put "<p>pwd: [pwd]</p>"
  web::put "<p>package names: [package names]</p>"
  web::put "<p>info load: [info load]</p>"

  web::put "<p>"
  iterate i 5 {
    web::put "a ku ku po raz $i !!!<br>"
  }
  web::put "</p>"
  
  web::put "<blockquote>"
  iterate i 5 {
    web::put "z blockquote a ku ku po raz $i !!!<br>"
  }
  web::put "</blockquote>"

  web::put "<blockquote><blockquote>"
  iterate i 5 {
    web::put "z podwojnym blockquote a ku ku po raz $i !!!<br>"
  }
  web::put "</blockquote></blockquote>"
}

web::dispatch

}] {web::put "<pre>errorInfo: $errorInfo</pre>"}; # dbg - koniec

