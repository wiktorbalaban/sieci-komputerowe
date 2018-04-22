/*
   Kropka klient
   ----------------------------------
*/

#include "sys/un.h"
#include "unix.h"
#include <stdio.h>
#include <stdlib.h>
#define SERWER_PORT 10000

void ObsSygnalu(int)
{ printf("pojawil sie sygnal SIGPIPE !!! (pid==%i)\n",getpid());
}

main()
{
  printf("Program KROPKA - KLIENT zaczyna działanie\n");

  signal(SIGPIPE,ObsSygnalu);
    // na wszelki wypadek ...

  int sock, sock_obsluga, i, nr_klienta;
  sock=socket (AF_INET,SOCK_DGRAM,0);
  sock_obsluga=socket (AF_INET,SOCK_DGRAM,0);

   struct sockaddr_in adres;
   memset(&adres,0,sizeof(adres));
   adres.sin_family=AF_INET;
   adres.sin_addr.s_addr=INADDR_ANY; // adres i port wybierane przez system
   adres.sin_port=htons(0);
   bind(sock,(struct sockaddr *)&adres,sizeof(adres));
   printf("klient: bind()=%i\n",sock);

   struct sockaddr_in odlegly; // tu bedzie adres odbiorcy datagramu
   socklen_t odlegly_len=sizeof(odlegly);
   memset(&odlegly,0,sizeof(odlegly));
   odlegly.sin_family=AF_INET;
   // odlegly.sin_addr.s_addr=inet_addr(AdresCyfrowyKropkowy("venus"));
   odlegly.sin_addr.s_addr=INADDR_ANY;
   odlegly.sin_port=htons(SERWER_PORT);

  char *buffer;
  size_t bufsize = 100;
  size_t characters;
  buffer = (char *)malloc(bufsize * sizeof(char));
  if( buffer == NULL)
  {
    perror("Unable to allocate buffer");
     exit(1);
  }

  //"łączenie"
  char * c = "Eloo\n";
  i=sendto(sock,c,sizeof(c),0,
     (struct sockaddr *)&odlegly,odlegly_len);
   if(i==-1) { // obsluga bledow
     printf("Błąd próba połączenia\n");
   } else {
  printf("próba połączenia\n");
  }

  struct sockaddr_in odlegly_OK; // tu bedzie adres odbiorcy datagramu
   socklen_t odlegly_OK_len=sizeof(odlegly_OK);
   memset(&odlegly_OK,0,sizeof(odlegly_OK));
   odlegly_OK.sin_family=AF_INET;
   // odlegly_OK.sin_addr.s_addr=inet_addr(AdresCyfrowyKropkowy("venus"));
   odlegly_OK.sin_addr.s_addr=INADDR_ANY;
   odlegly_OK.sin_port=htons(SERWER_PORT);

   i=recvfrom(sock,buffer,bufsize-1,0,(struct sockaddr *) &odlegly_OK,
     &odlegly_OK_len);
     if(i==-1) { // obsluga bledow
        printf("Błąd Połączono\n");
     } else{
        printf("Połączono\n");
    }
printf("Otrzymana wiadomość: %s\n",buffer);
  sscanf(buffer, "%d", &nr_klienta);
    printf("Nr klienta odebrany w wiadomości: %d\nRzeczywisty port OK: %hu\n",
      nr_klienta,odlegly_OK.sin_port);

 //exit(0);

  while(1){

    printf("Wpisz coś\n");
    characters = getline(&buffer,&bufsize,stdin);

   // char buf[100];
   i=sendto(sock,buffer,bufsize-1,0,
     (struct sockaddr *)&odlegly_OK,odlegly_OK_len);
   if(i==-1) { // obsluga bledow
     printf("Błąd sendto\n");
   } else {
  printf("Wysłano z sukcesem\n");
  }


   i=recvfrom(sock,buffer,bufsize-1,0,(struct sockaddr *)&
     odlegly_OK,&odlegly_OK_len);
       // w strukt. odlegly_OK dostaniemy "nadawce" datagramu !!!
       // (w tym wypadku ta informacja nie ma znaczenia)
       // -> pocztkowo odlegly_OK_len==sizeof(odlegly_OK)
       // -> po wywolaniu recvfrom() odlegly_OK_len zawiera
       //    rzeczywista dlugosc adresu ...
     if(i==-1) { // obsluga bledow
        printf("Błąd recfrom\n");
     } else{
        printf("Udany odbiór wiadomości: %s\n",buffer);
    }
  }
 close(sock);
  close(sock_obsluga);
  printf("Program KROPKA - KLIENT kończy działanie\n");

}
