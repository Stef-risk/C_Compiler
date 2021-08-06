import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.util.*;

import javax.swing.text.AbstractDocument.Content;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

public class CJson {

    private static final Gson PRETTY_PRINT_GSON = new GsonBuilder().setPrettyPrinting().create();
    private static final Gson GSON = new Gson();

    
  
    public static String toJson(ParseTree tree) {
      return toJson(tree, true);
    }
  
    public static String toJson(ParseTree tree, boolean prettyPrint) {
      return prettyPrint ? PRETTY_PRINT_GSON.toJson(toMap(tree)) : GSON.toJson(toMap(tree));
    }
  
    public static Map<String, Object> toMap(ParseTree tree) {
      Map<String, Object> map = new LinkedHashMap<>();
      traverse(tree, map);
      return map;
    }
  
    public static void traverse(ParseTree tree, Map<String, Object> map) {    //对语法树进行遍历
  
      if (tree instanceof TerminalNodeImpl) {         //将叶节点的类型、值、以及tokenID写入Map类中
        Token token = ((TerminalNodeImpl) tree).getSymbol();
        map.put("type", CLexer.VOCABULARY.getSymbolicName(token.getType()));
        map.put("value", token.getText());
        map.put("tokenID",token.getTokenIndex());
      }
      else {
        List<Map<String, Object>> children = new ArrayList<>();
        String name = tree.getClass().getSimpleName().replaceAll("Context$", "");
        
        // if(tree.getChildCount()!=1)
        map.put(Character.toLowerCase(name.charAt(0)) + name.substring(1), children);
  
        for (int i = 0; i < tree.getChildCount(); i++) {      //遍历当前节点的儿子节点
          Map<String, Object> nested = new LinkedHashMap<>();
          children.add(nested);
          traverse(tree.getChild(i), nested);
        }
      }
    }
    public static String ReadFromFile(String filename)          //从文件读取输入
    {
      try{
        BufferedReader bf=new BufferedReader(new FileReader(filename));
        String content="";
        String line;
        while((line=bf.readLine())!=null)
        {
          content+=line;
          content+="\n";
        }
        bf.close();
        return content;
      }catch(Exception e){
        System.out.println(e.toString());
      }
      return "KKK";
    }
    public static void writeToFile(String filename,String JsonFile){        //将Json写入文件
      try{
          PrintWriter out=new PrintWriter(filename);
          out.print(JsonFile);

          out.flush();
          out.close();
      }catch(Exception e){
          System.out.println(e.toString());
      }
  }

  public static class VerboseListener extends BaseErrorListener{
    @Override
    public void syntaxError(Recognizer<?,?>recognizer,Object offendingSymbol,int line,int charPositionInLine,String msg,RecognitionException e)
    {
      //System.err.println("rule Stack:"+stack);
      System.err.println("line "+line+":"+charPositionInLine+" "+msg);  //打印错误出现的位置以及错误信息
      underlineError(recognizer,(Token)offendingSymbol,line,charPositionInLine);
    }
    protected void underlineError(Recognizer recognizer,Token offendingToken,int line,int charPositionInLine)
    {
      CommonTokenStream tokens=(CommonTokenStream)recognizer.getInputStream();
      String input=tokens.getTokenSource().getInputStream().toString();
      String[] lines=input.split("\n");
      String errorLine=lines[line-1];
      System.err.println(errorLine);
      for(int i=0;i<charPositionInLine;i++) System.err.print(" ");
      int start=offendingToken.getStartIndex();
      int stop=offendingToken.getStopIndex();

      if(start>=0&&stop>=0){
        for(int i=start;i<=stop;i++)  System.err.print("^");
      }
      System.err.println();
    }
  } 

  
    public static void main(String[] args) {
      String source ;
      String filename="";

      System.out.println("Give a input C file name:");
      
      Scanner getfilename=new Scanner(System.in);
      if(getfilename.hasNext())
      {
        filename=getfilename.next();
      }
      getfilename.close();

      source=ReadFromFile(filename);
      CLexer lexer = new CLexer(CharStreams.fromString(source));      //先定义词法分析器以及输入
      CParser parser = new CParser(new CommonTokenStream(lexer));     //定义语法分析器并且以词法分析器所输出的属性字流作为输入
      parser.removeErrorListeners();        //删除默认的错误监听器 使用自己重写的
      parser.addErrorListener(new VerboseListener());
      CParser.SteFriContext tree=parser.steFri();                         //使用进入进入语法作为树的根节点
      writeToFile("parseTree.txt", toJson(tree));
    }
  }