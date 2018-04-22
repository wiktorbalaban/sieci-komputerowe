#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

#define PORT htons(8080)

void ObsluzPolaczenie(int gn)
{
    char act[512];
 
/* slowo 1 */
	char w1[6]; 
	w1[2]='m';w1[3]='o';w1[4]='p';w1[5]='s';
	char l1[3]; 
	l1[2]='0';l1[3]='4';
	int len1 = 4;
 /* --- */
 
 
 
	srand(time(NULL));
int numb=0, kontr =0;


/* odbieranie */ 

while(1==1){
    memset(act, 0, 512);
    if (recv(gn, act, 512, 0) <= 0)
    {
        printf("Potomny: blad przy odbieraniu\n");
        return;
    }
  
  
  
  
/* === GRA === */ 
if((act[2]=='G')&&(act[3]=='R'))
{
printf("gra...\n");	

if (recv(gn, act, 512, 0) <= 0){printf("Potomny: blad przy odbieraniu\n");}

printf("gra %c \n",act[3]);
	
/* 1 gra */
if((act[2]=='0')&&(act[3]=='1')){
	printf("gra\n");	
numb=0;	kontr =0;
act[2]=l1[2];act[3]=l1[3];	
if (send(gn, act, 4, 0) <= 0){}//wysyla dlugosc
while(kontr<=0){
if (recv(gn, act, 512, 0) <= 0){printf("Potomny: blad przy odbieraniu\n");}printf("gra + %c%c + %i \n",act[2], act[3], kontr);
if((act[2]=='w')&&(act[3]=='n')){kontr=1;printf("kontr wn = %i \n",kontr);}
if((act[2]=='f')&&(act[3]=='l')){kontr=1;printf("kontr fl = %i \n",kontr);}
if(kontr==0)
{
printf("gra %c \n",act[3]);numb=0;
for(int i=2;i<len1+2;i++)
{
	printf("gra== %c \n",act[3]);
	
	int r=w1[i], rr=act[3];
	printf("%i %i",r,rr);
	if(r==rr) //tu dodane m zamiast w1[i]
	{
		printf("gra- %c \n",act[3]);
		act[2]='0';act[3]=i+48; // 0 i+48
		if (send(gn, act, 4, 0) <= 0){printf("Potomny: blad przy wysylaniu\n");}
		numb++;
	}
}
if(numb!=0){
//act[2]='e';act[3]='n';
//if (send(gn, act, 4, 0) <= 0){} //wysylanie wiecej niz jednej tej samej zablokowane
//printf("gra-- %c \n",act[3]);
}
else
{
act[2]='b';act[3]='r';
if (send(gn, act, 4, 0) <= 0){printf("Potomny: blad przy wysylaniu\n");}	
}
		
}
}
printf("koniec gry\n");

}

/* 2 gry */
if((act[2]=='0')&&(act[3]=='2')){}

/* 3 gry */
if((act[2]=='0')&&(act[3]=='3')){}


}


/* === BigData === */
if((act[2]=='B')&&(act[3]=='D'))
{
printf("Zaczynam wysylanie\n");


//wyslanie wielkosci/2
act[2]='3';
act[3]='0';
if (send(gn, act, 4, 0) <= 0){printf("Potomny: blad przy wysylaniu\n");}


int r=63;
for(int i=0;i<30000000;i++) //30 mb *2 = 60mb
{
	if(r>=((rand()%125)+33))
	r=33;
	
	
	act[2]=r;
	act[3]=r;
	r++;
	if (send(gn, act, 4, 0) <= 0){printf("Potomny: blad przy wysylaniu\n");}
}	
/*act[2]='<';
act[3]='<';
if (send(gn, act, 4, 0) <= 0){}*/
/**/
printf("Koncze wysylanie\n");

}


/* === END === */
if((act[2]=='E')&&(act[3]=='N'))
{

return;

}


}}


int main(void)
{
    int gn_nasluch, gn_klienta;
    struct sockaddr_in adr;
    socklen_t dladr = sizeof(struct sockaddr_in);
    
    gn_nasluch = socket(PF_INET, SOCK_STREAM, 0);
    adr.sin_family = AF_INET;
    adr.sin_port = PORT;
    adr.sin_addr.s_addr = INADDR_ANY;
    memset(adr.sin_zero, 0, sizeof(adr.sin_zero));
    
    if (bind(gn_nasluch, (struct sockaddr*) &adr, dladr) < 0)
    {
        printf("Glowny: bind nie powiodl sie\n");
        return 1;
    }
    
    listen(gn_nasluch, 10);
    
    while(1)
    {
        dladr = sizeof(struct sockaddr_in);
        gn_klienta = accept(gn_nasluch, (struct sockaddr*) &adr, &dladr);
        if (gn_klienta < 0)
        {
            printf("Glowny: accept zwrocil blad\n");
            continue;
        }
        printf("Glowny: polaczenie od %s:%u\n", 
            inet_ntoa(adr.sin_addr),
            ntohs(adr.sin_port)
            );
        printf("Glowny: tworze proces potomny\n");
        if (fork() == 0)
        {
            /* proces potomny */
            printf("Potomny: zaczynam obsluge\n");
            ObsluzPolaczenie(gn_klienta);
            printf("Potomny: zamykam gniazdo\n");
            close(gn_klienta);
            printf("Potomny: koncze proces\n");
            exit(0);
        }
        else
        {
            /* proces macierzysty */
            printf("Glowny: wracam do nasluchu\n");
            continue;
        }
    }
    return 0;
}
