#
# TLS na linuxie ...
#

# UWAGA:
#   - linux/ przed uruchomieniem koniecznie wykonac:
#     export LD_LIBRARY_PATH=scie¿ka_do_katalogu_tls1.5

## tworzenie CA i podpisanych cert ----------------------------------
# /usr/lib/ssl/misc/CA.pl -newca; # tworzymy CA
# CA.pl -newcert; # tworzymy cert CA; to chyba NIEPOTRZEBNE ??? 
#   TAK !!! to polecenie tworzy self-signed cert
# dla kazdego uzytkownika proszacego CA o podpis:
#   CA.pl -newreq; # tworzymy zadanie podpisania cert; dane uzytkownika sie wprowadza
#   CA.pl -sign; # tworzymy podpisany cert
#   warto podzielic plik na dwa pliki: cert+kluczpub oraz kluczpryw

# podsumowanie tworzenia CA i signed certs:
# 1. CA.pl -newca; # tworzy CA; (cert tego CA to demoCA/cacert.pem)
# 2. CA.pl -newcert; # tworzy self-signed cert
# 3. CA.pl -newreq; # tworzy prosbe o podpisanie cert
# 4. CA.pl -sign; # podpisuje cert

# pliki:
#   nowy-private.pem - kluczpryw
#   nowy-public.pem - signed cert z kluczpub
#   cacert.pem - cert CA (zawiera kluczpub CA pozwalajacy sprawdzic podpis na cert!)

#   user_1_cert.pem - cert z kluczem pub ORAZ klucz pryw w jednym pliku!!!
#   ca2cert.pem - to jest cert CA ktory podpisal user_1_cert.pem
#     (sprawdzilem ze to dziala)


## klient sprawdza cert serwera -------------------------------------
# - uzywamy cetyfikatow podpisanych przez pewnego CA
# - to dziala !!!

#lappend auto_path {E:\TEMP\tcl\openssl\tls1.5}; # na win; pod etcl nie potrzeba!
#lappend auto_path tls1.5; # na lin
package require tls

## serwer
tls::socket -server obsluga \
  -keyfile nowy-private.pem -certfile nowy-public.pem \
  -password haslo \
  10000
    # -keyfile: klucz pryw serwera (moze byc zawarty w cert!)
    # -certfile: cert serwera (zawiera klucz pub)
proc haslo {} {return "qwerty"}; # haslo do klucza pryw serwera
proc obsluga {s args} {
  _puts "server socket $s"
  tls::handshake $s
}
file channels
foreach s [file channels] {if {[string match "sock*" $s]} {close $s}}


## klient
set s [tls::socket -require 1 -cafile cacert.pem \
  localhost 10000
]
  # "-require 1": klient zada sprawdzenia certyfikatu serwera
  # UWAGA: nie mylic -require z -request !!!
  # bez -cafile to NIE dziala !!!

tls::handshake $s
file channels
foreach s [file channels] {if {[string match "sock*" $s]} {close $s}}


## uwierzytelnianie klientow --------------------------------------

# - dziala !!!
# - jak widac nic nie szkodzi ze serw i kli uzywaje tego samego cert!

#lappend auto_path {E:\TEMP\tcl\openssl\tls1.5}; # na win; pod etcl nie potrzeba!
#lappend auto_path tls1.5; # na lin
package require tls

## serwer
proc haslo {} {return "qwerty"}
tls::socket -server obsluga -require 1 -cafile cacert.pem \
  -password haslo -keyfile nowy-private.pem -certfile nowy-public.pem \
  10000
proc obsluga {s args} {
  _puts "server socket $s"
  tls::handshake $s
}
file channels
#foreach s [file channels] {if {[string match "sock*" $s]} {close $s}}

## klient
proc haslo {} {return "qwerty"}
set s [tls::socket -require 1 -cafile cacert.pem \
  -password haslo -keyfile nowy-private.pem -certfile nowy-public.pem \
  localhost 10000
]
tls::handshake $s
file channels
#foreach s [file channels] {if {[string match "sock*" $s]} {close $s}}
tls::status $s
tls::status -local $s

if 0 {
# Uwaga: tak tez dziala!!!

## serwer
tls::socket -server obsluga -require 1 -cafile cacert.pem \
  -keyfile server-private.pem -certfile server-public.pem \
  10000
    # serwer uzywa self-signed cert

## klient
set s [tls::socket -require 0 \
  -password haslo -keyfile nowy-private.pem -certfile nowy-public.pem \
  localhost 10000
]
  # klient NIE moze zadac sprawdzenia cert serwera bo jest on self-signed!

}

if 0 {
# wyciaganie info z tls::status ...

set x [tls::status sock???]

lappend auto_path {E:\TEMP\tcl\dict8.5.1}
package require dict
set x1 [dict get $x subject]
  #% /C=AU/ST=Some-State/O=Internet Widgits Pty Ltd/CN=Michal4

set x2 [split $x1 /]
  #% {} C=AU ST=Some-State {O=Internet Widgits Pty Ltd} CN=Michal4

foreach y $x2 { if {[string match "CN=*" $y]} {lappend x3 $y} }
set x3
  #% CN=Michal4

}


