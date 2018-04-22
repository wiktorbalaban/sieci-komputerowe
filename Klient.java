import java.net.*;
import java.io.*;

public class Klient {  //Client
    private Socket s;
    private InetAddress adresSerwera; //serverAddress
    private int portSerwera; //serverPort
    private ZLiczbaLosowa zadanie1; //ZRandomNumber
    private ZSortuj zadanie2; //ZSort
    private ZResztaZDzielenia zadanie3; //ZRest from
    private int[] tabSort; //arraySort
    // private int[] tabDivide; //arrayDivide
    private ZDzielenieData dzielenieData;
    private ObjectInputStream ois;
    private ObjectOutputStream oos;

    public Klient(InetAddress sa, int p) {
        super();
        adresSerwera = sa;
        portSerwera = p;
        tabSort = new int[5];
        for (int i = 0; i < 5; i++) {
            tabSort[i] = 5-i;
        }
        // tabDivide=new int[]{10,3};
        dzielenieData = new ZDzielenieData(10,3);
        zadanie1 = new ZLiczbaLosowa();
        zadanie2 = new ZSortuj();
        zadanie3 = new ZResztaZDzielenia();
    }

    public void OtworzPolaczenie() { //open connection
        try {
            System.out.println("Nawiazuje polaczenie (connecting)...");
            s = new Socket(adresSerwera, portSerwera);
            oos = new ObjectOutputStream(s.getOutputStream());
            ois = new ObjectInputStream(s.getInputStream());
            System.out.println("Polaczenie nawiazane (connection established).");
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    public void ZamknijPolaczenie() { //CloseConnection
        try {
            System.out.println("Zamykam polaczenie (closing connection)...");
            oos.close();
            ois.close();
            s.close();
            System.out.println("Polaczenie zamkniete (connection closed).");
        } catch(Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    public Object WykonajZadanieNaSerwerze( //ExecuteTaskOnServer
        Zadanie z, Object par
        ) {
        Object wynik = null;
        try {
            oos.writeObject(z);
            oos.writeObject(par);
            wynik = ois.readObject();
        } catch(Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
        return wynik; //result
    }

    public void Menu() {
        while (true) {
            System.out.println();
            System.out.println();
            System.out.println(
            "1. Wykonaj na serwerze zadanie 1 (liczba losowa) (execute task - random number)");
            System.out.println(
            "2. Wykonaj na serwerze zadanie 2 (sortowanie) (execute task - sort)");
            System.out.println(
            "3. Wykonaj na serwerze zadanie 3 (reszta z dzielenia)"+
              "(execute task - rest from dividing)");
            System.out.println(
            "4. Koniec (end)");
            try {
                BufferedReader klawiatura = new BufferedReader( /*keyboard */
                    new InputStreamReader(
                        System.in
                        )
                    );
                System.out.print("Wybor (choice): ");
                int opcja = Integer.parseInt(
                    klawiatura.readLine());
                if (opcja == 4) System.exit(0);
                if (opcja == 1 || opcja == 2 || opcja == 3) {
                    OtworzPolaczenie();
                    if (opcja == 1) {
                        Double wynik = (Double)
                            WykonajZadanieNaSerwerze(
                                zadanie1,
                                0.0
                            );
                        System.out.println(
                        "Wynik zadania (result of task) 1: "+wynik.doubleValue());
                    } else if (opcja == 2) {
                        int[] wynik = (int[])
                            WykonajZadanieNaSerwerze(
                                zadanie2,
                                tabSort
                            );
                        System.out.print("Wynik zadania (result of task) 2: [ ");
                        for (int i = 0; i < wynik.length; i++) {
                            System.out.print(wynik[i]+" ");
                        }
                        System.out.println("]");
                    } else {
                      int wynik = (int)
                        WykonajZadanieNaSerwerze(
                          zadanie3,
                          // tabDivide
                          dzielenieData
                        );
                        System.out.println(
                        "Wynik zadania (result of task) 3: "+ wynik);
                    }
                    ZamknijPolaczenie();
                }
            } catch (Exception e) {
                System.out.println("NIE POWIODLO SIE (failed)");
            }
        }
    }

    public static void main(String[] args) {
        String host;
        int port;
        try {
            BufferedReader klawiatura = new BufferedReader(
                new InputStreamReader(
                    System.in
                    )
                );
            System.out.print("Host serwera obliczen (address of th computation server): ");
            host = klawiatura.readLine();
            System.out.print("Numer portu serwera obliczen (port number of the server): ");
            port = Integer.parseInt(klawiatura.readLine());
            Klient k = new Klient(
                InetAddress.getByName(host),
                port
                );
            k.Menu();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
