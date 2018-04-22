public class ZDzielenieData implements java.io.Serializable{ //Task
  private int licznik;
  private int mianownik;

  public ZDzielenieData (int alicznik,int amianownik){
    licznik = alicznik;
    mianownik = amianownik;
  }

  public ZDzielenieData(ZDzielenieData data){
    licznik = data.getLicznik();
    mianownik = data.getMianownik();
  }

  public int getLicznik(){
    return licznik;
  }
  public int getMianownik(){
    return mianownik;
  }
  public void setLicznik(int alicznik){
    licznik = alicznik;
  }
  public void setMianownik(int amianownik){
    mianownik = amianownik;
  }
}
