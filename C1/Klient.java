import java.io.*;
import java.net.*;

public class Klient {

    // args[0] - nazwa hosta (lub IP) (hostname)
    // args[1] - numer portu (port number)
    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println(
                "Podaj nazwe hosta i numer portu"
            );
            return;
        }
        try {
          // utworzenie gniazda - lokalny port niewazny (socket creation on "any" port)
          DatagramSocket socket = new DatagramSocket();

            // ustalenie adresu na podstawie args[0] (address from args[0])
          InetAddress addr = InetAddress.getByName(args[0]);
          while(true){
            System.out.println();
            System.out.println("1: Obsluga przez serwer");
            System.out.println("2: Przerwij polaczenie");
            int input = Integer.parseInt(System.console().readLine());
            // utworzenie datagramu z wiadomoscia (creation of datagram with message)
            String s="";
            if(input==1)
              s = Constants.OBSLUGA;
            else
              s = Constants.KONIEC;
            DatagramPacket p = new DatagramPacket(
                s.getBytes(), s.length(),
                addr, Integer.parseInt(args[1]));

            // wyslanie wiadomosci (message sending)
            socket.send(p);

            // utworzenie "pustego" datagramu (creation of empty datagram)
            final int BUFOR_SIZE = 256;
            byte[] bufor = new byte[BUFOR_SIZE];
            DatagramPacket p2 = new DatagramPacket(bufor, BUFOR_SIZE);

            if(input==2) break;
            // czekaj na wiadomosc zwrotna (wait for reply message)
            socket.receive(p2);
            System.out.println("Obsluzono przez serwer");
          }
          // koniec protokolu (end of protocol)
          socket.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
