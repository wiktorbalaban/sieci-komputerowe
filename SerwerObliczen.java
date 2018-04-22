import java.net.*;
import java.io.*;

public class SerwerObliczen {
    private int port;
    private ServerSocket ss;

    public SerwerObliczen(int aport) {
        super();
        port = aport;
        ss = null;
    }

    public void InicjujGniazdo() {
        try {
            ss = new ServerSocket(port);
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    public void WykonujZadania() {
        Socket s;
        ObjectInputStream ois;
        ObjectOutputStream oos;

        while (true) {
            System.out.println("Czekam na zadanie...");
            try {
                s = ss.accept();
                System.out.println("Polaczenie z "+
                    s.getInetAddress().getHostName());
                System.out.println("Odczytywanie zadania ...");
                oos = new ObjectOutputStream(s.getOutputStream());
                ois = new ObjectInputStream(s.getInputStream());
                Zadanie z = (Zadanie) ois.readObject();
                System.out.println("Odebrano zadanie typu "+
                    z.getClass().getName());
                System.out.println(
                    "Odczytywanie parametrow ...");
                Object par = ois.readObject();
                System.out.println(
                    "Parametry odczytane. Wykonuje zadanie ...");
                Object wynik = z.Wykonaj(par);
                System.out.println(
                    "Zadanie wykonane. Wysylam wyniki ...");
                oos.writeObject(wynik);
                System.out.println("Gotowe. Zamykam sesje z "+
                    s.getInetAddress().getHostName());
                ois.close();
                oos.close();
                s.close();
            } catch(Exception e) {
                e.printStackTrace();
                System.exit(1);
            }
        }
    }
    public static void main(String[] args) {
        int port = 0;
        BufferedReader klawiatura;

        try {
            klawiatura = new BufferedReader(
                new InputStreamReader(
                    System.in
                    )
                );
            System.out.print("Podaj numer portu: ");
            port = Integer.parseInt(
                klawiatura.readLine()
                );

        } catch(Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
        SerwerObliczen serwer = new SerwerObliczen(port);
        serwer.InicjujGniazdo();
        serwer.WykonujZadania();
    }
}
