#!/home/mhanckow/tcl/tcl8.4/tcl8.4.14/unix/tclsh
#
# websh - eksperymenty; win, cgi; czy websh sie nadaje do powaznych zastosowan?
#

# - jak wykonywac "wstawki kodowe" w stronach pisanych w html pod websh ???

# - jak uzywac stron statycznych spod websh ???

# - jesli mamy statyczna strone www i chcemy ja zamienic na dynamicznie generowana
#   przy pomocy websh - to co powinnismy zrobic ???

# -----------------------------------------------------

#load {D:\TclTk\httpd\tclhttpd3.5.1\htdocs\cgi-bin\websh3.6.0b3.dll}
load /home/mhanckow/tcl/websh/libwebsh3.6.0b4.so
package require websh

web::command default {

web::putxfile sag.html
  # - dlaczego to tak wolno dziala ???
  #     (tylko na win, na lin jest ok !!!)
  # - jak spowodowac aby obrazek byl widoczny ???
  # - to nie jest dobry pomysl jesli strona zawiera linki lub inne odwolania
  #   ze wzglednymi url-ami (robi sie wtedy np http://localhost:8015/cgi-bin/logo.gif)

  # Uwaga: wystarczylo umiescic plik websh03.cgi w katalogu templates
  # (w ktorym sa statyzne pliki html) i wszystko dziala !!!
  #   (ale jak to rozwiazac w systemach w ktorych skrypty cgi
  #    MUSZA byc w katalogu cgi-bin ???)
}

web::dispatch

