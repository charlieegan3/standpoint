import net.sf.classifier4J.summariser.*;
import java.io.*;

public class Summary {
  public static void main(String[] args) {
    String line = null;
    try {
      FileReader fileReader = new FileReader("../text.txt");

      BufferedReader bufferedReader = new BufferedReader(fileReader);

      line = bufferedReader.readLine();
      bufferedReader.close();
    } catch (Exception e){
      System.out.println(e);
    }

    SimpleSummariser summariser = new SimpleSummariser();
    String result = summariser.summarise(line, 5);
    System.out.println(result);
  }
}
