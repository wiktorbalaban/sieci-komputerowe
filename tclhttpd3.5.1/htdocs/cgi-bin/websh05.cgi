#!/usr/bin/tclsh

## co zrobic w tym przykladzie ???

# - obsluga sesji ... wreszcie to wyprobowac!!!

# - web::filecontext - do czego to moze sluzyc?

# - rysowanie grafu przy pomocy tcldot i ogladanie przez przegladarke
#   wyprobowac jak to dziala...
#   czy warto cache-owac obrazek w pliku gif ?
#   jakie to moze miec zastosowania na AAL260 ???

# - jak sie obsluguje formularze HTML???
#   czy istotnie web::param nie dziala tylko trzeba uzyc web::formvar
#   odp: ???

# ---------------------------------------------------------------------

if [catch { # dbg - poczatek

load /home/mhanckow/tcl/websh/8.4/libwebsh3.6.0b4.so
source /home/mhanckow/tcl/mh_lib.tcl
cd /mnt/hdb5/mhanckow/tcl8.4/httpd/tclhttpd3.5.1/htdocs/cgi-bin
  # ladowanie pakietow i inne ...

web::command default {
  #load /home/mhanckow/tcl/tcldot/bin/libtkspline.so
  load /home/mhanckow/tcl/tcldot/bin/libtcldot_builtin.so
  set p [package req Tcldot]
    # jak bardzo to jest czasochlonne ???
    #   nie bardzo; ladowanie bibl so nie jest czasochlonne
    # tkspline WYMAGA Tk wiec tu nie mozna tego ladowac
  web::put "<p>wersja Tcldot: $p</p>"
  
  web::put "<p>pwd: [pwd]</p>"
  web::put "<p>package names: [package names]</p>"
  web::put "<p>namespace ch :: : [namespace ch ::]</p>"
  web::put "<p>info load: [info load]</p>"
}

web::dispatch

}] {web::put "<pre>errorInfo: $errorInfo</pre>"}; # dbg - koniec

