import java.io.*;
import java.net.*;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.security.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Date;


public class Connection {

private int port, bytes;
private InetAddress addr;
private Socket socket;
private DataOutputStream dos;
private DataInputStream dis;

    public Connection()
{
    addr = null;
    bytes=0;
}

    /* łączy z serwerem*/
    public boolean connect(String host, String portNumber) {
        boolean ans = false;
        try {
            addr = InetAddress.getByName(host);
            port = Integer.parseInt(portNumber);
            socket = new Socket(addr, port);

            dos = new DataOutputStream(socket.getOutputStream());
            dis = new DataInputStream(socket.getInputStream());

        } catch (Exception e) {
            e.printStackTrace();
            ans = true;

        }
        return ans;
    }



    /* wysyła informacje o poleceniu przesłania dużego pliku */

    public void initizlizationBigData()
    {
        String text="";
        int endlL=0, send=0;

        File file = new File("/.");
        PrintWriter zapis = null;
        try {

            zapis = new PrintWriter("pobranyDuzyPlik");


        try {
            dos.writeUTF("BD");
            text = dis.readUTF();
            send=Integer.parseInt(text);

            while(bytes<1000000*send*2) { // 1mb * 100
                text = dis.readUTF();
                bytes=bytes+2;
                if((bytes%10000000)==0){System.out.println("odebrano: " + bytes/1000000 + " MB");}
                zapis.print(text);
                //System.out.print(text);

                if(endlL==20){zapis.print("\n"); endlL=0;}
                endlL++;

            }
            System.out.println("koniec odbierania " + String.valueOf(bytes) + " bajtów");
            bytes=0;
        }
        catch (Exception e) {
            e.printStackTrace();
        }


        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }


       // zapis.println("Ala ma kota, a kot ma Alę \n");

        zapis.close();
    }

    /* kończy połączenie */
    public void end()
    {


    try {
        dis.close();
        dos.close();
        socket.close();
        System.out.println("Klient zakonczyl dzialanie");
    }
    catch (Exception e) {
        e.printStackTrace();
    }

    }

    public void seEN()
    {
        try {
            dos.writeUTF("EN");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /* wysyła informacje o poleceniu gry i pobiera ilosc liter slowa */
    public int initizlizationGame(int games) {
        int amount = 0;
        try {
            dos.writeUTF("GR");
            dos.writeUTF("0"+String.valueOf(games));

            String s = dis.readUTF();
            amount = Integer.valueOf(s);
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        System.out.print(amount);
        return amount;
    }



    /* wysyłanie litery */
    public void seLetter(String word)
    {
        try {
            //dos.writeUTF("wn");
            dos.writeUTF(" " + word);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /* odbieranie odpowiedzi i przekazywanie miejsca lokalizacji litery */
    public String teAns() {
        String s="",ss="";
        try {
             s = dis.readUTF();
          //  ss = dis.readUTF();
            System.out.println("\n odczytane: " + s);
        } catch (IOException e) {
            e.printStackTrace();
        }

        return s;
    }

    public void seWn()
    {
        try {
            dos.writeUTF("wn");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void seFl()
    {
        try {
            dos.writeUTF("fl");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }



    /* testy */
    public void test() {
        try {
            // zapisz kolejno int, String i double i wyślij
            dos.writeUTF("TEST");
            //dos.writeInt(1000);
            //dos.writeUTF("Hello World! - testowo");
            //dos.writeDouble(3.14159);
            //dos.writeLong(1234567);
            System.out.println("wysłane \n");
            // czytaj odpowiedz
            String s = dis.readUTF();
            //Long l = dis.readLong();
            System.out.println("odebrane \n");
            // wypisz odpowiedz
            System.out.println("Serwer powiedzial: "+ s);
            } catch (Exception e) {
            e.printStackTrace();
        }
    }
}