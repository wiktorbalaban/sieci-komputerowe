import java.net.InetAddress;
public class KlientData {
  InetAddress address;
  int port;

  public KlientData(InetAddress aaddress, int aport){
    address=aaddress;
    port=aport;
  }

  public InetAddress getAddress () {
    return address;
  }

  public int getPort () {
    return port;
  }
}
