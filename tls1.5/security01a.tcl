#
# TLS na linuxie ...
#

# UWAGA:
#   - linux/ przed uruchomieniem koniecznie wykonac:
#     export LD_LIBRARY_PATH=scie¿ka_do_katalogu_tls1.5

# Uwaga:
#   - handshake musi byc po OBU stronach !!!
#   - klient i serwer musza byc osobnymi procesami/watkami !!!

# SSL:
#   - publiczny klucz jest zawarty w certyfikacie (-certfile),
#     prywatny klucz trzeba(?) dostarczyc osobno (-keyfile)

#   - jak sie potwierdza certyfikaty? chyba tylko sprawdza sie podpis!

#   - w tym przykladzie uzywamy "self-signed cert";
#       jak utworzyc CA i "signed certs" ???
#       polecenie openssl dla win???

#   - co to jest cafile? chyba cert. CA

#   - ??? jak zrobic "uwierzytelnianie klientow" ???
#     (sprawdzanie czy klienci sa tymi za ktorych sie podaja)
#     odp: ??? prawd. klient i serwer NIE moga uzywac tego samego pem
#      dlatego to mi nie dziala ...
#        utworzyc osobna pare kluczy dla klienta (self-signed cert.)!
#        !!! NIE dziala !!!
#          byc moze uwierzytelnianie klientow wymaga prawdziwych cert 
#          (z podpisem prawdziwego CA)

#   - tls/roz.bin. dla win...
#       czy zawiera wlasna wersje bibl. openssl ???
#       i nic zwiazanego z ssl nie musi byc instalowanego na win ???
#	[chyba tak]

# -------------------------------------------------------------------------

#lappend auto_path {E:\TEMP\tcl\openssl\tls1.5}; # na win; pod etcl nie potrzeba!
#lappend auto_path tls1.5; # na lin
package require tls

# w tym przykladzie tylko serwer przedstawia cert (typu self-signed)

## serwer
# server-public.pem to tzw "self-signed cert"!
tls::socket -server obsluga \
  -keyfile server-private.pem -certfile server-public.pem \
  10000
    # opcje -keyfile i -certfile sa niezbedne (w tym przypadku!)
proc obsluga {s args} {
  _puts "server socket $s"
  tls::handshake $s
}
file channels
#close ???
  # trzeba zamykac niepotrzebne kanaly!(?)
  # jesli chcemy restartowac serwer z innymi opcjami!

## klient
# to MUSI byc w osobnym procesie!!!
set s [tls::socket localhost 10000]
tls::handshake $s
set x [tls::status $s]
foreach {q w} $x {_puts "$q $w"}
file channels
#close ???
  # trzeba zamykac niepotrzebne kanaly!(?)


# -------------------------------------------------------------------------
## uwierzytelnianie klientow
# - to NIE dziala z opcja "-require 1" !!!
#   byc moze ta opcja wymaga prawdziwego certyfikatu a nie "self-signed" ???
#   odp: ???
# - bez opcji -required dziala ok!!!
#   serwer musi samodzielnie sprawdzic cert. (na podstawie tls::status $s)

## serwer
tls::socket -server obsluga \
  -keyfile server-private.pem -certfile server-public.pem -require 1 \
  10000
proc obsluga {s args} {
  _puts "server socket $s"
  tls::handshake $s
}
file channels
#close ???

## klient
set s [tls::socket \
  -keyfile client-private.pem -certfile client-public.pem \
  localhost 10000
]
tls::handshake $s
set x [tls::status $s]
foreach {q w} $x {_puts "$q $w"}
file channels
#close ???
  # trzeba zamykac niepotrzebne kanaly!(?)


# -----------------------------
## nowy eksperyment z CA ...

# - zdaje sie ze tak dziala tylko zapomnialem zdef haslo "qwerty";
#   gdzie to nalezy zrobic ???

# - juz wiem jak utworzyc CA (juz to zrobilem)
#   oraz jak tworzyc i podpisywac cert. !!!
#     nie wiem jeszcze jakie opcje musza byc uzyte po stronie klienta
#     i serwera!

# CA.pl -newca; # tworzymy CA
# CA.pl -newcert; # tworzymy cert CA
# CA.pl -newreq
# CA.pl -sign

#lappend auto_path tls1.5; # na lin
package require tls

# ??? czy to powinno dziala ???

# serwer

proc haslo {} {return "qwerty"}

tls::socket -server obsluga \
  -keyfile nowy-private.pem -certfile nowy-public.pem \
  -password haslo \
  10000
  #% sock4
proc obsluga {s args} {
  _puts "server socket $s"
  tls::handshake $s
}
file channels
#close ???

# klient
set s [tls::socket -request 1 -cafile cacert.pem \
  localhost 10000
]
  # klient zada sprawdzenia poprawnosci cert serwera !?!?!?!?!?!
tls::handshake $s
file channels
#close ???

