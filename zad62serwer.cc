/*
   Kropka serwer
   ----------------------------------
*/

#include "sys/un.h"
#include "unix.h"
#define PORT 10000

void ObsSygnalu(int)
{ printf("pojawil sie sygnal SIGPIPE !!! (pid==%i)\n",getpid());
}

main()
{
  printf("Program KROPKA - SERWER zaczyna działanie\n");

  signal(SIGPIPE,ObsSygnalu);
    // na wszelki wypadek ...

  int sock, sock_obsluga_klienta,i,j, pid;
  int nr_klienta=1;
  sock=socket (AF_INET,SOCK_DGRAM,0);

  struct sockaddr_in adres;
  memset(&adres,0,sizeof(adres));
  adres.sin_family=AF_INET;
  adres.sin_addr.s_addr=INADDR_ANY; // adres i port wybierane przez system
  adres.sin_port=htons(PORT);
  i=bind(sock,(struct sockaddr *)&adres,sizeof(adres));
  printf("serwer: bind()=%i\nOczekuję na klientów...\n",i);
  printf("Port serwera: %hu\n",adres.sin_port);

  while(1){// główna pętla serwera

    struct sockaddr_in odlegly;
    socklen_t odlegly_len=sizeof(odlegly);
    char buf[100];
    i=recvfrom(sock,buf,99,0,(struct sockaddr *)&odlegly,&odlegly_len);
       // w strukt. odlegly dostaniemy "nadawce" datagramu !!!
       // -> pocztkowo odlegly_len==sizeof(odlegly)
       // -> po wywolaniu recvfrom() odlegly_len zawiera
       //    rzeczywista dlugosc adresu ...
    if(i==-1) { // obsluga bledow
      printf("Błąd recfrom serwer\n");
    } else {
          printf("serwer: recvfrom(...)=%i\n",sock);
   }
    sprintf(buf,"%d", nr_klienta); // wrzuca do bufora nr klienta
    printf("Bufor z nr klienta: %s\n",buf);

    sock_obsluga_klienta=socket (AF_INET,SOCK_DGRAM,0);
    struct sockaddr_in obsluga_klienta;
    memset(&obsluga_klienta,0,sizeof(obsluga_klienta));
    obsluga_klienta.sin_family=AF_INET;
    obsluga_klienta.sin_addr.s_addr=INADDR_ANY; // adres i port wybierane przez system
    obsluga_klienta.sin_port=htons(PORT+nr_klienta);
    i=bind(sock_obsluga_klienta,(struct sockaddr *)&obsluga_klienta,sizeof(obsluga_klienta));
    if(i==-1) { // obsluga bledow
          printf("Błąd bind\n");
          exit( -1);
        }
   printf("Port obslugi klienta: %hu\n",obsluga_klienta.sin_port);
   j=sendto(sock_obsluga_klienta,buf,i,0,(struct sockaddr *)&odlegly,odlegly_len);
   if(j==-1) { // obsluga bledow
     printf("Błąd sendto obsluga klienta\n");
   }  else {
     printf("obsluga klienta: sendto(...)=%i\n",sock_obsluga_klienta);
   }
   printf("obsluga_klienta %i: bind()=%i\nOczekuję na klienta...\n",
    nr_klienta, i);
  //close(sock);

    pid=fork();
    if(pid==0){// przyjmowanie zgłoszeń

    nr_klienta=nr_klienta+1;

    }else{// obsługa zgłoszenia

      while(1){
        i=recvfrom(sock_obsluga_klienta,buf,99,0,(struct sockaddr *)&odlegly,&odlegly_len);
       // w strukt. odlegly dostaniemy "nadawce" datagramu !!!
       // -> pocztkowo odlegly_len==sizeof(odlegly)
       // -> po wywolaniu recvfrom() odlegly_len zawiera
       //    rzeczywista dlugosc adresu ...
        if(i==-1) { // obsluga bledow
          printf("Błąd recfrom\n");
        } else {
          printf("obsługa klienta %hu: recvfrom(...)=%i\n",
            obsluga_klienta.sin_port, sock_obsluga_klienta);
        }
        j=sendto(sock_obsluga_klienta,buf,i,0,(struct sockaddr *)&odlegly,odlegly_len);
        if(j==-1) { // obsluga bledow
          printf("Błąd sendto\n");
        }  else {
          printf("obsługa klienta %hu: sendto(...)=%i\n",
            obsluga_klienta.sin_port, sock_obsluga_klienta);
        }
      }
    }
  }

  close(sock);
  close(sock_obsluga_klienta);

  printf("Program KROPKA - SERWER kończy działanie\n");


}
