public class ZResztaZDzielenia
    implements Zadanie { //Task

    public Object Wykonaj(Object params) {
        ZDzielenieData data = (ZDzielenieData)params;
        System.out.println("*** Tu zadanie reszta z dzielenia (Task rest from dividing is here).");
        return data.getLicznik()%data.getMianownik();
    }
}
