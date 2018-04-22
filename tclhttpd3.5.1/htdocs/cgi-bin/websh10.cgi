#!/usr/bin/tclsh
load /home/mhanckow/tcl/websh/libwebsh3.6.0b4.so

## eksperymenty z websh...
# - oddzielenie logiki (biznesowej) od prezentacji ???
# - lepsze web::put ???

# ---

if [catch { # dbg - poczatek

source /home/mhanckow/tcl/mh_lib.tcl

## proc bibl ulepszajace web::put ???
proc web::puts t {
  uplevel "web::put \[subst [list $t]\]"
}
proc web::putsfile f {
  set f [open $f r]; set t [read $f]; web::puts $t; close $f
}

web::command default {
  web::put "<p>pwd: [pwd]</p>"
  
  set x 123

  web::putx {
  <p>
    x = {web::put $x}<br>
    info vars = {web::put [info vars]}<br>
    array get tcl_platform = {web::put [array get tcl_platform]}
  </p>
  <p> 
    uzycie wstawki tcl...
    {iterate i 20 {web::put "$i, "}}
  </p>
  }

  web::puts { 
  <p>
    x = $x <br>
    info vars = [info vars] <br>
    array get tcl_platform = [array get tcl_platform]
  </p>
  <p> 
    uzycie wstawki tcl...
    [set _ ""; iterate i 20 {append _ "$i, "}; set _]
  </p>
  }
}

web::dispatch

}] {web::put "<pre>errorInfo: $errorInfo</pre>"}; # dbg - koniec


