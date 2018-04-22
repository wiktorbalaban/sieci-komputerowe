import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
// ip addr
public class Main extends JFrame implements ActionListener{

    private JLabel lIP, lPort;
    private JLabel lStatStat, lStatVar;
    private JLabel lLetters;
    private JLabel l1, l2, l3, l4, l5;

    private JTextField tIP, tPort, tAns;

    private JButton bConnect,bDisconnect, b1Game, b2Games, bEnd, bBigData, bPlay;

    private  Connection con1 = new Connection();

    private String word;

    private int con=0, pos=0;

    private Boolean test=false;


    public Main()
    {

         /* FRAME */
        setSize(1000,600);
        setTitle("Wisielec");
        setLayout(null);

        /* LABEL - IP */
        lIP = new JLabel("podaj adres: ");
        lIP.setBounds(10,10,100,20);
        add(lIP);

        /* LABEL - port */
        lPort = new JLabel("podaj port: ");
        lPort.setBounds(10,60,100,20);
        add(lPort);

        /* LABEL - status - stat. */
        lStatStat = new JLabel("status:");
        lStatStat.setBounds(10,140,60,20);
        add(lStatStat);

        /* LABEL - status - var. */
        lStatVar = new JLabel(" --- ");
        lStatVar.setBounds(65,140,200,20);
        lStatVar.setForeground(Color.black);
        add(lStatVar);

        /* TextField - IP */
        tIP = new JTextField("150.254.79.72");
        tIP.setBounds(10,30,200,20);
        tIP.setToolTipText("Podaj adres");
        add(tIP);

        /* TextField - port */
        tPort = new JTextField("8080");
        tPort.setBounds(10,80,100,20);
        tPort.setToolTipText("Podaj port");
        add(tPort);

        /* TextField - ans */
        tAns = new JTextField("");
        tAns.setBounds(10,300,40,20);
        tAns.setToolTipText("Podaj port");
        add(tAns);

        /* JButton - connect*/
        bConnect = new JButton("POŁĄCZ");
        bConnect.setBounds(20,110,100,20);
        add(bConnect);
        bConnect.addActionListener(this);

        /* JButton - disconnect*/
        bDisconnect = new JButton("ROZŁĄCZ");
        bDisconnect.setBounds(130,110,100,20);
        add(bDisconnect);
        bDisconnect.addActionListener(this);

        /* JButton - 1Game*/
        b1Game = new JButton("1 GRA");
        b1Game.setBounds(10,170,120,20);
        add(b1Game);
        b1Game.addActionListener(this);

        /* JButton - 2Games*/
        b2Games = new JButton("2 GRY");
        b2Games.setBounds(10,200,120,20);
        add(b2Games);
        b2Games.addActionListener(this);
        b2Games.setVisible(false);

        /* JButton - 3Games*/
        bEnd = new JButton("KONIEC");
        bEnd.setBounds(10,230,120,20);
        add(bEnd);
        bEnd.addActionListener(this);

        /* JButton - BigData*/
        bBigData = new JButton("DUŻE DANE");
        bBigData.setBounds(10,260,120,20);
        add(bBigData);
        bBigData.addActionListener(this);

        /* JButton - Play*/
        bPlay = new JButton("PODAJ");
        bPlay.setBounds(60,300,90,20);
        add(bPlay);
        bPlay.addActionListener(this);

        /* LABEL - letters */
        lLetters = new JLabel("");
        lLetters.setBounds(20,350,500,20);
        add(lLetters);

        /* LABEL - l1 */
        l1 = new JLabel("█████████████████████████████████");
        l1.setBounds(500,450,500,20);
        add(l1);
        l1.setVisible(false);

        /* LABEL - l1 */
        l2 = new JLabel("<html>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█</html>");
        l2.setBounds(500,150,500,310);
        add(l2);
        l2.setVisible(false);

        /* LABEL - l1 */
        l3 = new JLabel("████████████████████");
        l3.setBounds(500,140,500,20);
        add(l3);
        l3.setVisible(false);

        /* LABEL - l1 */
        l4 = new JLabel("<html>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█<br/>█</html>");
        l4.setBounds(670,145,500,120);
        add(l4);
        l4.setVisible(false);

        /* LABEL - l1 */
        l5 = new JLabel("<html>&nbsp&nbsp&nbsp███&nbsp<br/>&nbsp&nbsp████<br/>&nbsp&nbsp&nbsp███&nbsp<br/>&nbsp&nbsp&nbsp&nbsp█&nbsp&nbsp<br/>██████<br/>&nbsp&nbsp&nbsp&nbsp█<br/>&nbsp&nbsp&nbsp&nbsp█<br/>&nbsp&nbsp&nbsp&nbsp█<br/>██████<br<br/></html>");
        l5.setBounds(655,240,500,200);
        add(l5);
        l5.setVisible(false);



    }

    public static void main(String[] args)
    {

        Main window = new Main();
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        window.setVisible(true);
    }


    @Override
    public void actionPerformed(ActionEvent e) {
        Object source = e.getSource();

        if(source == bConnect)
        {
        System.out.print("adres: " + tIP.getText() + " port: " + tPort.getText() + "\n");


        if(con1.connect(tIP.getText(), tPort.getText()))
        {
            lStatVar.setForeground(Color.red);
            lStatVar.setText("Błąd połączenia");
        }
        lStatVar.setForeground(Color.green);
        lStatVar.setText("Połączono");
        //con1.test();

        }
        else if(source == bDisconnect)
        {
            con1.end();
            lStatVar.setForeground(Color.red);
            lStatVar.setText("Zakończono połączenie");
        }

        /* 1 gra */
        else if(source == b1Game){

            l1.setVisible(false);
            l2.setVisible(false);
            l3.setVisible(false);
            l4.setVisible(false);
            l5.setVisible(false);


           int len = con1.initizlizationGame(1);

           word="";
           for(int i =0; i<len;i++)
           {
               word = word + "-";
           }

           lLetters.setText(word);

        }

        /* 2 gry */
        else if(source == b2Games){
            con1.initizlizationGame(2);
            b2Games.setVisible(false);
        }

        /* Koniec serwera */
        else if(source == bEnd){
            con1.seEN();
        }

        /* duże dane */
        else if(source == bBigData){
            con1.initizlizationBigData();
        }

        /* przesłanie litery */
        else if(source == bPlay){

            if(con==0) {
                con1.seLetter(tAns.getText());
                String ss = con1.teAns();
                if ((ss.trim()).equals("br")) {
                    l1.setVisible(true);
                    con++;
                } else if (ss.equals("en")) {}
                else {

                    System.out.println("miejsce: " + (ss.charAt(1)));
                    pos=ss.charAt(1)-48-2;

                    String buf="" ;//= lLetters.getText();

                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if (i==pos)
                        {
                            buf=buf+tAns.getText();
                        }
                        else if(lLetters.getText().charAt(i)!='-')
                        {
                            buf=buf+lLetters.getText().charAt(i);
                        }
                        else
                        {
                            buf=buf+"-";

                        }
                    }
                    lLetters.setText(buf);
                    test=true;
                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if(buf.charAt(i)=='-')
                        {
                            test=false;
                        }
                    }

                    if (test)
                    {
                        lLetters.setText("KONIEC GRY - WYGRANA");
                        con1.seWn();
                    }

                         //  buf.setC =tAns.getText().charAt(0);


                }
            }

           else if(con==1) {
                con1.seLetter(tAns.getText());
                String ss = con1.teAns();
                if ((ss.trim()).equals("br")) {
                    l1.setVisible(true);
                    l2.setVisible(true);
                    con++;
                } else if (ss.equals("en")) {}
                else {

                    System.out.println("miejsce: " + (ss.charAt(1)));
                    pos=ss.charAt(1)-48-2;

                    String buf="" ;//= lLetters.getText();

                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if (i==pos)
                        {
                            buf=buf+tAns.getText();
                        }
                        else if(lLetters.getText().charAt(i)!='-')
                        {
                            buf=buf+lLetters.getText().charAt(i);
                        }
                        else
                        {
                            buf=buf+"-";

                        }
                    }
                    lLetters.setText(buf);
                    test=true;
                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if(buf.charAt(i)=='-')
                        {
                            test=false;
                        }
                    }

                    if (test)
                    {
                        lLetters.setText("KONIEC GRY - WYGRANA");
                        con1.seWn();
                    }

                    //  buf.setC =tAns.getText().charAt(0);


                }
            }

            else if(con==2) {
                con1.seLetter(tAns.getText());
                String ss = con1.teAns();
                if ((ss.trim()).equals("br")) {
                    l1.setVisible(true);
                    l2.setVisible(true);
                    l3.setVisible(true);
                    con++;
                } else if (ss.equals("en")) {}
                else {

                    System.out.println("miejsce: " + (ss.charAt(1)));
                    pos=ss.charAt(1)-48-2;

                    String buf="" ;//= lLetters.getText();

                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if (i==pos)
                        {
                            buf=buf+tAns.getText();
                        }
                        else if(lLetters.getText().charAt(i)!='-')
                        {
                            buf=buf+lLetters.getText().charAt(i);
                        }
                        else
                        {
                            buf=buf+"-";

                        }
                    }
                    lLetters.setText(buf);
                    test=true;
                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if(buf.charAt(i)=='-')
                        {
                            test=false;
                        }
                    }

                    if (test)
                    {
                        lLetters.setText("KONIEC GRY - WYGRANA");
                        con1.seWn();
                    }

                    //  buf.setC =tAns.getText().charAt(0);


                }
            }

            else if(con==3) {
                con1.seLetter(tAns.getText());
                String ss = con1.teAns();
                if ((ss.trim()).equals("br")) {
                    l1.setVisible(true);
                    l2.setVisible(true);
                    l3.setVisible(true);
                    l4.setVisible(true);
                    con++;
                } else if (ss.equals("en")) {}
                else {

                    System.out.println("miejsce: " + (ss.charAt(1)));
                    pos=ss.charAt(1)-48-2;

                    String buf="" ;//= lLetters.getText();

                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if (i==pos)
                        {
                            buf=buf+tAns.getText();
                        }
                        else if(lLetters.getText().charAt(i)!='-')
                        {
                            buf=buf+lLetters.getText().charAt(i);
                        }
                        else
                        {
                            buf=buf+"-";

                        }
                    }
                    lLetters.setText(buf);
                    test=true;
                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if(buf.charAt(i)=='-')
                        {
                            test=false;
                        }
                    }

                    if (test)
                    {
                        lLetters.setText("KONIEC GRY - WYGRANA");
                        con1.seWn();
                    }

                    //  buf.setC =tAns.getText().charAt(0);


                }
            }

            else if(con==4) {
                con1.seLetter(tAns.getText());
                String ss = con1.teAns();
                if ((ss.trim()).equals("br")) {
                    l1.setVisible(true);
                    l2.setVisible(true);
                    l3.setVisible(true);
                    l4.setVisible(true);
                    l5.setVisible(true);
                    con++;
                } else if (ss.equals("en")) {}
                else {

                    System.out.println("miejsce: " + (ss.charAt(1)));
                    pos=ss.charAt(1)-48-2;

                    String buf="" ;//= lLetters.getText();

                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if (i==pos)
                        {
                            buf=buf+tAns.getText();
                        }
                        else if(lLetters.getText().charAt(i)!='-')
                        {
                            buf=buf+lLetters.getText().charAt(i);
                        }
                        else
                        {
                            buf=buf+"-";

                        }
                    }
                    lLetters.setText(buf);
                    test=true;
                    for(int i=0;i<lLetters.getText().length();i++)
                    {
                        if(buf.charAt(i)=='-')
                        {
                            test=false;
                        }
                    }

                    if (test)
                    {
                        lLetters.setText("KONIEC GRY - WYGRANA");
                        con1.seWn();
                    }

                    //  buf.setC =tAns.getText().charAt(0);


                }
            }

            else  {

                    lLetters.setText("KONIEC GRY");
                }
            }
        }
    }

