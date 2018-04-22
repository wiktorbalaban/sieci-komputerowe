#!/usr/bin/tclsh

#
# websh - przekazywanie danych w ramach sesji
#

## jak przekazywac dane miedzy stronami w pojedynczej sesji ...
# 1. w cmd default utworzyc dane przy pomocy: "web::cmdurlcfg -set par dana"
#      tworzymy par stat
# 2. web::dispatch -track lista_par
#      jeszcze raz trzeba wymienic z nazwy par stat
# 3. w pozostalych cmd, na poczatku: "set dana [web::param par]"
#      jesli chcemy zmodyf par stat to MUSIMY uzyc "web::cmdurlcfg -set"

# uwaga 1: param sa dostepne dopiero PO dispatch!
# uwaga 2: aby zmodyf par stat trzeba uzyc "web::cmdurlcfg -set" 
#  (a nie "web::param -set")

# -----------------------------------------------------

if [catch { # dbg - poczatek

#load {D:\TclTk\httpd\tclhttpd3.5.1\htdocs\cgi-bin\websh3.6.0b3.dll}
load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so

web::command default {
  set dane(imie) "Michal"
  set dane(nazwisko) "Hanckowiak"
  set dane(tel) 123456
  web::cmdurlcfg -set dane [array get dane]
    # to jest niezbedne tylko dlatego ze przed wywolaniem default
    # param dane nie istnieje i -track nie dziala ...

  web::put "<p>A ku ku !!!</p>"

  web::put "<p><a href=[web::cmdurl komenda_a]>komenda_a</a></p>"
  web::put "<p><a href=[web::cmdurl komenda_b]>komenda_b</a></p>"

  web::put "<p>$dane(imie)</p>"
  web::put "<p>[array get dane]</p>"
  web::put "<p>web::cmdurlcfg -names = [web::cmdurlcfg -names]</p>"
  web::put "<p>web::param -names = [web::param -names]</p>"
}

web::command komenda_a {
  array set dane [web::param dane]

  web::put "<p>to ja komenda_a</p>"
  web::put "<p>$dane(imie)</p>"
  web::put "<p>[array get dane]</p>"
  web::put "<p>web::cmdurlcfg -names = [web::cmdurlcfg -names]</p>"
  web::put "<p>web::param -names = [web::param -names]</p>"
}

web::command komenda_b {
  array set dane [web::param dane]

  web::put "<p>to ja komenda_b</p>"

  web::put "<p><a href=[web::cmdurl komenda_b1]>komenda_b1</a></p>"

  web::put "<p>$dane(imie)</p>"
  web::put "<p>[array get dane]</p>"
  web::put "<p>web::cmdurlcfg -names = [web::cmdurlcfg -names]</p>"
  web::put "<p>web::param -names = [web::param -names]</p>"
}

web::command komenda_b1 {
  array set dane [web::param dane]

  set dane(dodatek) "111222333"
  web::cmdurlcfg -set dane [array get dane]
    # troche modyfikujemy par dane ...
    # (aby zmodyf par stat trzeba uzyc "web::cmdurlcfg -set")

  web::put "<p>to ja komenda_b1</p>"

  web::put "<p><a href=[web::cmdurl komenda_b11]>komenda_b11</a></p>"

  web::put "<p>$dane(imie) $dane(nazwisko) $dane(tel)</p>"
  web::put "<p>[array get dane]</p>"
  web::put "<p>web::cmdurlcfg -names = [web::cmdurlcfg -names]</p>"
  web::put "<p>web::param -names = [web::param -names]</p>"
}

web::command komenda_b11 {
  array set dane [web::param dane]

  web::put "<p>to ja komenda_b11</p>"
  web::put "<p>[array get dane]</p>"
  web::put "<p>web::cmdurlcfg -names = [web::cmdurlcfg -names]</p>"
  web::put "<p>web::param -names = [web::param -names]</p>"
}

web::dispatch -track dane
  # to jest niezbedne!!!

}] {web::put "<pre>errorInfo: $errorInfo</pre>"}; # dbg - koniec

