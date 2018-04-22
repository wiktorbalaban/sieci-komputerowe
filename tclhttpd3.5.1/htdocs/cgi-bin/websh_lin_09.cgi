#!/usr/bin/tclsh
#
# websh - encryption
#

## gdzie jest uzywane szyfrowanie???
# - param w url-ach sa szyfrowane
# - zawartosc ciasteczka i pliku z kontekstem sa szyfrowane

## "encryption plugin" 
# - encryptchain i decryptchain zawieraja liste komend ktore...
#   TCL_OK, TCL_CONTINUE, TCL_ERROR
#   (niedokonczone)

# ---

if [catch { # dbg - poczatek

load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so

web::loglevel add *.error
web::logdest add *.- file websh_lin_09.log

web::command default {
  web::put "<p>A ku ku !!!</p>"
  web::put "<p>"
  web::put "web::config encryptchain= [web::config encryptchain]<br>"
  web::put "web::config decryptchain= [web::config decryptchain]<br>"
  web::put "</p>"
  web::put "<p><a href=[web::cmdurl stronaA qqq 123 www "321 123"]>stronaA</a></p>"
}

web::command stronaA {
  web::put "<p>A ku ku !!! - to ja stronaA</p>"
  web::put "<p>[web::param -names]</p>"
  web::put "<p>"
  foreach x [web::param -names] {
    web::put "$x=[web::param $x], "
  }
  web::put "</p>"
}

web::dispatch

}] {web::put "<pre>errorInfo: $errorInfo</pre>"}; # dbg - koniec


