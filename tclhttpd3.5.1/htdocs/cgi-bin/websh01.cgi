#!/usr/bin/tclsh

#
# websh jako "skrypt cgi"
#

# - dziala calkem sprawnie !!!
# - swietnie sie nadaje do testowania skryptow websh !!!

# - czy z tego powodu ze websh jest przystosowany do pracy m.in. przez cgi
#   nie ma mozliwosci trzymania zmiennych na serwerze ???

# ---------------------------------------------------------------------

load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so

web::cookiecontext qqq

web::command default {

qqq::init "mojecookie"
qqq::cset x [expr [qqq::cget x]+1]
qqq::cset y 123
qqq::commit


web::put "<p>A ku ku !</p>"

web::put "<p>request = [web::request -names]</p>"
web::put "<p>response = [web::response -names]</p>"
web::put "<p>param = [web::param -names]</p>"

web::put "<p>wartosci parametrow:<br><pre>"
foreach x [web::param -names] {
  web::put "   $x = [web::param $x]\n"  
}
web::put "</pre></p>"

web::put "<p>A ku ku !</p>"

qqq::init "mojecookie"
web::put "<p>x= [qqq::cget x], y= [qqq::cget y]</p>"

}

web::dispatch
  # ta komenda jest odpowiedzialna za sparsowanie parametrow zadania...

