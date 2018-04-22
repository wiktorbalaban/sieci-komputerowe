#!/usr/bin/tclsh
#
# websh - kontekst plikowy; troche bardziej zlozony...
#

## Pytania:
# - przeladowanie str. default powoduje utworzenie nowego pliku xxx???.dat
#   jak tego uniknac ???

# - jesli podam ?id=33 w glownej stronie to podlacze sie do sesji z id==33
#   jak sie przed tym zabezpieczyc ???
#     "sess id" NIE moga byc kolejnymi liczbami tyko musza to byc jakies okropne stringi
#     nie do podrobienia ...

# - cos nie tak z formularzami!?!?!!?!?!?
#     action w formularzu nie moze miec parametrow ???
#     sprawdzic jak to dziala pod lin (bo moze to jest problem win???)
#       NIE wiem jak to obejsc !!
#       czyli obecnie websh sie NIE nadaje do prof zast!!!
#       !!! to nie dziala poprawnie tylko pod tclhttpd !!!
#         ktory prawdop. nie potrafi obslugiwac zadania http
#         zawierajcego rownoczesnie dane metoda get ORAZ post

# - problem: przy odwiezeniu glownej strony tworzy sie nowa sesja
#   jak tego uniknac ???
#     * przechowywac id sesji w ciasteczku u klienta???


## Uwagi (ogolne o websh):
# - dziala na dosc niskim poziomie...
# - WCALE nie jestem pewien czy websh sie nadaje do prof. uzytku ...
# - znalezc nowa wersje skomp dla win i lin !!!

# -----------------------------------------------------

if [catch { # dbg - poczatek

load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so

web::filecontext qqq \
  -path /home/mhanckow/tcl/httpd/cgi-bin/xxx%d.dat \
  -idgen {liczsesji nextval} \
  -attachto id
     # zdaje sie ze nie wolno uzywac ~/tcl w tym miejscu ???

web::command default {
  web::filecounter liczsesji \
    -filename /home/mhanckow/tcl/httpd/cgi-bin/liczsesji.dat
  qqq::init
  qqq::cset dane 1000
  qqq::commit

  web::put "<p>A ku ku !!!</p>"
  web::put "<p><a href=[web::cmdurl komenda_a]>komenda_a</a></p>"
}

web::command komenda_a {
  qqq::init
  set dane [qqq::cget dane]
  qqq::cset dane [expr {$dane+1}]
  qqq::commit
    # to musi byc przed put JEDYNIE dla cookiecontext!!!

  web::put "<p>to ja komenda_a</p>"
  web::put "<p>dane= $dane</p>"
  web::put "<p>cnames= [qqq::cnames]</p>"

  if 0 { web::put "<p>
    <form method=\"POST\" action=\"[web::cmdurl koniec_sesji]\">
      <input type=submit value=\"koniec sesji\">
    </form>
    </p>"
  }
  web::put "<p>
    <a href=\"[web::cmdurl koniec_sesji]\">link do koniec_sescji</a>
    </p>"
}

web::command koniec_sesji {
  qqq::init
  set dane [qqq::cget dane]

  web::put "<p>to powinien byc koniec sesji ale nie wiem jak to zrobic...</p>"
  web::put "<p>dane= $dane</p>"

  web::put "<p>param: [web::param -names]</p>"
  web::put "<p>formvar: [web::formvar -names]</p>"
  web::put "<p>cmdurlcfg: [web::cmdurlcfg -names]</p>"
}

web::dispatch -track id

}] {web::put "<pre>errorInfo: $errorInfo</pre>"}; # dbg - koniec


