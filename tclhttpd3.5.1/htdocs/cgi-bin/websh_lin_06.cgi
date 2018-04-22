#!/usr/bin/tclsh

#
# websh - loggin (eksperyment na websh przez CGI)
#

# logging ...
# * dokumentacja kiepska - lepiej patrz: websh_faq !!!
# * mozna rozdzielic komunikaty danego poziomu w zaleznosci od dest (web::log dest.level)
# * filtr to "tag.level" lub "tag.level1-level2"
#   tag.level1-level2: chodzi o zakres poziomow; tag.-debug to poziomy od 1 do debug
#   levels: alert error warning info debug
#   tags: dowolny napis...
# * sa 2 filtry: "overall" (web::loglevel) i "per dest" (web::logdest)

# * otworzyc wszystkie poziomy/tagi i obserwowac komunikaty od websh
#   to jest pouczajace!!!

# -----------------------------------------------------

if [catch { # dbg - poczatek

#load {D:\TclTk\httpd\tclhttpd3.5.1\htdocs\cgi-bin\websh3.6.0b3.dll}
load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so

## to jest "overall filter"
#web::loglevel add websh.info; # tylko websh.info
#web::loglevel add *.info; # otwieram tylko poziom info
#web::loglevel add *.warning
web::loglevel add *.-; # wszystkie poziomy otwieram

## to sa "per dest filters"
#web::logdest add user.info file qqq.log
#web::logdest add websh.info file qqq2.log
#web::logdest add qqq.info file qqq3.log
  # to sa "per dest filters"
  # NIE WOLNA uzyc 2 razy add z tym samym plikiem!!!
web::logdest add *.- file qqq.log
  # dzieki temu wszystko idzie do jednego pliku!

web::command default {

web::put "<p>A ku ku !!!</p>"

#web::put "<p>web::loglevel names=[web::loglevel names]</p>"
#web::put "<p>web::logdest names=[web::logdest names]</p>"
  # zwraca jakies uchwyty???

web::log info "A ku ku 1"
  # dziala jak user.info
web::log debug "A ku ku 2"
  # to sie nie pojawi w logach; a jesli sie pojawi to jako user.debug
web::log qqq.info "A ku ku 3"
  # ok
}

web::dispatch

}] {web::put "<pre>errorInfo: $errorInfo</pre>"}; # dbg - koniec


