import java.io.*;
import java.net.*;
import java.util.ArrayList;

public class Serwer {

  private DatagramSocket socket; // gniazdo UDP
  ArrayList<KlientData> klientList;


  public Serwer(int aport) throws IOException {
      // utworzenie i powiazanie z portem
  // creation and binding on port
      socket = new DatagramSocket(aport);
      klientList= new ArrayList<>();
  }

  public void close(){
    socket.close(); // koniec protokolu (end of protocol)
  }

  private int getKlientIndex(KlientData klient){
    int result=-1;
    int index=0;
    for(KlientData d : klientList){
      if(d.getAddress().toString().equals(klient.getAddress().toString())
          && d.getPort()==klient.getPort()){
        result=index;
        break;
      }
      index++;
    }
    return result;
  }

  public void obslugaSerwera(){
    final int BUFOR_SIZE = 256;
    byte[] bufor = new byte[BUFOR_SIZE];
    DatagramPacket p = new DatagramPacket(bufor, BUFOR_SIZE);

    try{
      while(true){
        socket.receive(p); // czekaj na datagram
        System.out.println("*****");
        KlientData klient = new KlientData(p.getAddress(),p.getPort());
        int index = getKlientIndex(klient);
        if(index==-1) {
          klientList.add(klient);
          index=klientList.size()-1;
        }
        if ( new String( p.getData() ).substring(0,Constants.length)
            .equals(Constants.OBSLUGA) ) {
          String response = "Cokolwiek";
          DatagramPacket p2 = new DatagramPacket(
              response.getBytes(), response.length(),
              p.getAddress(), p.getPort());
          socket.send(p2);
          System.out.println("Obsluzono - adres: " + p.getAddress()
              + ", port: " + p.getPort());
        } else {
          klientList.remove(index);
          System.out.println("Koniec polaczenia z - adres: " + p.getAddress()
              + ", port: " + p.getPort());
        }
        System.out.println("Lacznie polaczonych: " + klientList.size());
        System.out.println("*****");
      }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }

  public static void main(String[] args) {
      if (args.length < 1) {
          System.out.println(
              "Podaj numer portu jako parametr"
          );
          return;
      }
      try {
          Serwer serwer = new Serwer(
          Integer.parseInt(args[0]));
          System.out.println("Czekam...");
          serwer.obslugaSerwera();
          serwer.close();
          System.out.println("KONIEC");

      // ew. wyjatek wyrzucany przez konstruktor
  // (exception throwed by the constructor)
      // c5p1a
      } catch (Exception e) {
          e.printStackTrace();
      }
  }

}
