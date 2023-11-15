// Evan Daveikis

/*

 Just learned about arcade details
 We need to build the jar files to work
 So this file tests how 'sketchPath()' works in a build
 
 */

import java.io.*; // I love importing everything - makes me feel powerful

void setup()
{
  // Yes, I am hardcoding it. It is just a test
  // The desktop is where the magic happens :3
  String filePath = "C:\\Users\\Evan\\Desktop\\Programming Class\\PEntityExtraction\\process\\FilesystemTest";
  String path = sketchPath();
  println(path);
  try
  {
    String fullPath = filePath + File.separator + "out.txt";
    File file = new File(fullPath);
    file.createNewFile();

    FileWriter writer = new FileWriter(fullPath);
    writer.write(path);
    writer.close(); // Yeah yeah if there's an exception it's never closed
  }
  catch (IOException ex)
  {
    ex.printStackTrace();
  }
}

/*

 RESULTS:
 Sketch : C:\Users\Evan\Desktop\Programming Class\PEntityExtraction\process\FilesystemTest
 Build  : C:\Users\Evan\Desktop\Programming Class\PEntityExtraction\process\FilesystemTest\windows-amd64
 
 Perfect (it is exactly what was expected)
 IT EVEN COPIES THE DATA FOLDER OVER (!!!)
 Perfect :)
 
 */
