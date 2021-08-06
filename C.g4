//Stefan Version of C11 grammar , with little adjustment and direct left-recursives
// Ste-Made

grammar C;


//parser rule Below

/* --------------表达式语法定义----------------- */

//进入语法
steFri : (expression|declaration|statement|functionDefination)+;

primaryExpression: Identifier|Constant|StringLiteral|'('expression')';
//后缀表达式
postfixExpression: primaryExpression|postfixExpression'['expression']'
                    |postfixExpression'.'Identifier|postfixExpression'++'
                    |postfixExpression'--'|'('typeName')''{'initializerList'}'
                    |'('typeName')''{'initializerList',''}'|postfixExpression'->'Identifier
                    |postfixExpression'('argumentExpressionList')'|postfixExpression'('')'
                    ;

argumentExpressionList: assignmentExpression|argumentExpressionList','assignmentExpression;

//单目表达式
unaryExpression : postfixExpression|'++'unaryExpression|'--'unaryExpression|unaryOperator castExpression
                    |'sizeof'unaryExpression|'sizeof''('unaryExpression')'|'_Alignof''('typeName')'
                    ;
unaryOperator : '&'|'+'|'-'|'/'|'*'|'~'|'!';

//明确的类型转换
castExpression : unaryExpression| '('typeName')'castExpression;

//乘法除法余数计算表达式
multiplicativeExpression : castExpression|multiplicativeExpression'*'castExpression
                            |multiplicativeExpression'/'castExpression|multiplicativeExpression'%'castExpression;

//加减法表达式
additiveExpression : multiplicativeExpression|additiveExpression '+'multiplicativeExpression|additiveExpression'-'multiplicativeExpression;


//移位表达式
shiftExpression : additiveExpression|shiftExpression'<<'additiveExpression|shiftExpression'>>'additiveExpression;

//关系表达式
relationalExpression : shiftExpression|relationalExpression'<'shiftExpression|relationalExpression'>'
                        |relationalExpression'<=' shiftExpression|relationalExpression'>='shiftExpression;

//相等表达式
equalityExpression : relationalExpression|equalityExpression'=='relationalExpression|equalityExpression'!='relationalExpression;

//按位与、或、异或
andExpression : equalityExpression|andExpression'&'equalityExpression;
exclusiveOrExpression : andExpression|exclusiveOrExpression'^'andExpression;
inclusiveOrExpression : exclusiveOrExpression|inclusiveOrExpression'|'exclusiveOrExpression;

//逻辑与、或
logicalAndExpression : inclusiveOrExpression|logicalAndExpression'&&'inclusiveOrExpression;
logicalOrExpression : logicalAndExpression|logicalOrExpression'||'logicalAndExpression;

//条件表达式
conditionalExpression : logicalOrExpression|logicalOrExpression'?'expression':'conditionalExpression;

//赋值表达式
assignmentExpression : conditionalExpression|unaryExpression assignOperator assignmentExpression;
assignOperator : '='|'+='|'-='|'/='|'*='|'%='|'<<='|'>>='|'&='|'^='|'|=';

//表达式
expression : assignmentExpression|expression','assignmentExpression;
constantExpression : conditionalExpression;

/*-----------------------表达式语法定义结束----------- */

/*--------------声明语法定义------------------- */

declaration : declarationSpecifiers initDeclaratorList';'|declarationSpecifiers';'|staticAssertDeclaration;

declarationSpecifiers : storageClassSpecifier declarationSpecifiers|storageClassSpecifier
                        |typeSpecifier declarationSpecifiers|typeSpecifier
                        |typeQualifier declarationSpecifiers|typeQualifier
                        |functionSpecifier declarationSpecifiers|functionSpecifier
                        |alignmentSpecifier declarationSpecifiers|alignmentSpecifier;
initDeclaratorList : initDeclarator|initDeclaratorList','initDeclarator;
initDeclarator : declarator|declarator'='initializer;
storageClassSpecifier : 'typedef'|'extern'|'static'|'register'|'auto'|'_Thread_local';
typeSpecifier : 'void'|'char'|'short'|'int'|'long'|'float'|'double'|'signed'|'unsigned'|'_Bool'|'_Complex'
                |atomicTypeSpecifier|structOrUnionSpecifier|enumSpecifier|typedefName;

//联合与结构体声明
structOrUnionSpecifier : structOrUnion (Identifier)? '{'structDeclarationList'}'|structOrUnion Identifier;
structOrUnion : 'struct'|'union';
structDeclarationList : structDeclaration+;     //(structDeclarationList)?structDeclaration;
structDeclaration : specifierQualifierList(structDeclaratorList)?';'|staticAssertDeclaration;
specifierQualifierList : typeSpecifier (specifierQualifierList)? | typeQualifier (specifierQualifierList)?;
structDeclaratorList : structDeclarator|structDeclaratorList','structDeclarator;
structDeclarator : declarator|declarator':'constantExpression;

//枚举声明
enumSpecifier : 'enum'Identifier'{'enumratorList'}'|'enum''{'enumratorList'}'
                |'enum'Identifier'{'enumratorList'}'|'enum''{'enumratorList',''}'
                |'enum'Identifier;

enumratorList : enumrator|enumratorList','enumrator;
enumrator : enumrationConstant|enumrationConstant'='constantExpression;
enumrationConstant: Constant;

//原子类型
atomicTypeSpecifier : '_Atomic''('typeName')';

//类型限定符
typeQualifier : 'const'|'restrict'|'volatile'|'_Atomic';

//函数类型
functionSpecifier : 'inline'|'_Noreturn';

//字节对齐
alignmentSpecifier : '_Alignas''('(typeName|constantExpression)')';

//声明器
declarator : pointer? directDeclarator;
directDeclarator : Identifier|'('declarator')'|directDeclarator'['typeQualifierList? assignmentExpression']'
                    |directDeclarator'['assignmentExpression?']'|directDeclarator'['typeQualifierList'static'assignmentExpression']'
                    |directDeclarator'[''static'typeQualifierList assignmentExpression']'
                    |directDeclarator'[''static'assignmentExpression']'
                    |directDeclarator'['typeQualifierList'*'']'|directDeclarator'[''*'']'
                    |directDeclarator'('parametreTypeList')'
                    |directDeclarator'('identifierList?')';   //函数定义
pointer : '*'typeQualifierList|'*'
            |'*'typeQualifierList pointer|'*'pointer;

typeQualifierList : typeQualifier|typeQualifierList typeQualifier;
parametreTypeList : parametreList| parametreList',''...';
parametreList : parametreDeclaration|parametreList','parametreDeclaration;
parametreDeclaration : declarationSpecifiers declarator|declarationSpecifiers abstractDeclarator|declarationSpecifiers;
identifierList : Identifier|identifierList','Identifier;

//类型名
typeName : specifierQualifierList abstractDeclarator|specifierQualifierList;
abstractDeclarator : pointer|pointer directAbstractDeclarator|directAbstractDeclarator;
directAbstractDeclarator : '('abstractDeclarator')'|directAbstractDeclarator'[''static'typeQualifierList assignmentExpression']'
                            |directAbstractDeclarator '[''static'assignmentExpression']'
                            |directAbstractDeclarator'['typeQualifierList'static'assignmentExpression']'
                            |directAbstractDeclarator'[''*'']'|'[*]'
                            |directAbstractDeclarator '('parametreTypeList')'
                            |directAbstractDeclarator '('')'
                            ;
typedefName : Identifier;


//初始化器
initializer : assignmentExpression| '{'initializerList'}'
            |'{'initializerList',''}';
initializerList : designation initializer|initializer
                |initializerList','designation initializer|initializerList','initializer;
designation : designatorList'=';
designatorList : designator|designatorList designator;
designator : '['constantExpression']'|'.'Identifier;

//静态断言
staticAssertDeclaration : '_Static_assert''('constantExpression','StringLiteral')';

/*------------声明到此结束------------ */

/*-------------Statement starts here------ */

statement : labeledStatement
            |compoundStatement
            |expressionStatement
            |selectionStatement
            |iterationStatement
            |jumpStatement;

labeledStatement : Identifier':'statement
                    |'case'constantExpression':'expression
                    |'default'':'statement;
//复合语句
compoundStatement : '{'blockItemList'}'|'{''}'
                    ;
blockItemList : blockItem|blockItemList blockItem;
blockItem : declaration | statement;

//表达式语句
expressionStatement : expression';'|';';

//选择语句
selectionStatement : 'if''('expression')'statement
                    |'if''('expression')'statement'else'statement
                    |'switch''('expression')'statement;

//循环语句
iterationStatement : 'while''('expression')'statement
                    |'do'statement'while''('expression')'';'
                    |'for''('expression?';'expression?';'expression?')'statement
                    |'for''('declaration expression?';'expression?')'statement
                    ;

jumpStatement : 'goto'Identifier|'continue'';'|'break'';'|'return'expression?';';

/*--------------------statement definations end here-------------- */

/* ---------------------Definations Start here------------------- */

functionDefination : declarationSpecifiers declarator declarationList? compoundStatement;   //函数定义
declarationList : declaration+;

/*Defination Ends here */

// lexer rule Below

/*Key Words */
Auto :'auto ';
Break:'break';
Case:'case';
Char:'char';
Const:'const';
Continue:'continue';
Default:'default';
Do:'do';
Double:'double';
Else:'else';
Enum:'enum';
Extern:'extern';
Float:'float';
For:'for';
Goto:'goto';
If:'if';
Inline:'inline';
Int:'int';
Long:'long';
Register:'register';
Restrict:'restrict';
Return:'return';
Short:'short';
Signed:'signed';
Sizeof:'sizeof';
Static:'static';
Struct:'struct';
Switch:'switch';
Typedef:'typedef';
Union:'union';
Unsigned:'unsigned';
Void:'void';
Volatile:'volatile';
While:'while';
/*End of Key words */

/*Specifiers And Qualifiers */

Alignas : '_Alignas';
Alignof : '_Alignof';
Atomic : '_Atomic';
Bool : '_Bool';
Complex : '_Complex';
Generic : '_Generic';
Imaginary : '_Imaginary';
Noreturn : '_Noreturn';
StaticAssert : '_Static_assert';
ThreadLocal : '_Thread_local';

LeftParen : '(';
RightParen : ')';
LeftBracket : '[';
RightBracket : ']';
LeftBrace : '{';
RightBrace : '}';

Less : '<';
LessEqual : '<=';
Greater : '>';
GreaterEqual : '>=';
LeftShift : '<<';
RightShift : '>>';

Plus : '+';
PlusPlus : '++';
Minus : '-';
MinusMinus : '--';
Star : '*';
Div : '/';
Mod : '%';

And : '&';
Or : '|';
AndAnd : '&&';
OrOr : '||';
Caret : '^';
Not : '!';
Tilde : '~';

Question : '?';
Colon : ':';
Semi : ';';
Comma : ',';

Assign : '=';
StarAssign : '*=';
DivAssign : '/=';
ModAssign : '%=';
PlusAssign : '+=';
MinusAssign : '-=';
LeftShiftAssign : '<<=';
RightShiftAssign : '>>=';
AndAssign : '&=';
XorAssign : '^=';
OrAssign : '|=';

Equal : '==';
NotEqual : '!=';

Arrow : '->';
Dot : '.';
Ellipsis : '...';

/*End of specifiers and qualifiers */

WS : [ \t\r\n] -> skip ; //skip white spaces


LineComment: '//' ~[\r\n]* -> skip;
BlockComment: '/*'((('*'[^/])?)|[^*])*'*/' ->skip;

Identifier : [a-zA-Z_][_a-zA-Z0-9]*;
StringLiteral : EncodingPrefix? '"'SCharSequence?'"';
Constant: IntegarConstant|FloatConstant|CharConstant;
fragment
IntegarConstant: DecimalConstant IntegarSuffix?
                |OctalConstant IntegarSuffix?
                |HexConstant IntegarSuffix?
                ;
fragment
DecimalConstant : NonzeroDigit Digit*;
fragment
OctalConstant: '0'|OctalDigit+;
fragment
HexConstant : HexPrefix HexDigit+;
fragment
HexPrefix : '0x'|'0X';
fragment
NonzeroDigit : [1-9];
fragment
OctalDigit : [0-7];
fragment
HexDigit : [0-9a-fA-F];
fragment
Digit : [0-9];
fragment
IntegarSuffix : UnsignedSuffix LongSuffix?
                |UnsignedSuffix LongLongSuffix?
                |LongSuffix UnsignedSuffix
                |LongLongSuffix UnsignedSuffix?
                ;
fragment
UnsignedSuffix : [uU];
fragment
LongSuffix : [lL];
fragment
LongLongSuffix : 'll'|'LL';

fragment
FloatConstant : DecimalFloatConstant|HexFloatConstant;
fragment
DecimalFloatConstant : FractionalConstant ExponentPart FloatingSuffix
                        |DigitSequence ExponentPart FloatingSuffix;
fragment
HexFloatConstant : HexPrefix HexFractionConstant BinaryExponentPart FloatingSuffix
                    |HexPrefix HexDigitSequence BinaryExponentPart FloatingSuffix;
fragment
FractionalConstant : DigitSequence '.' DigitSequence|DigitSequence '.';
fragment
ExponentPart : [eE] Sign DigitSequence;
fragment
Sign : [+-];
fragment
DigitSequence : Digit+;
fragment
HexFractionConstant : HexDigitSequence '.' HexDigitSequence
                    |HexDigitSequence '.';
fragment
BinaryExponentPart : [pP] Sign DigitSequence;
fragment
HexDigitSequence : HexDigit+;
fragment
FloatingSuffix : [flFL];

fragment
CharConstant : [LuU]?'\''CCharSequence'\'';
fragment
CCharSequence :  CChar+;
fragment
CChar : ~['\\\r\n] | EscapeSequence ;
fragment
EscapeSequence
    :   SimpleEscapeSequence
    |   OctalEscapeSequence
    |   HexadecimalEscapeSequence
    ;
fragment
SimpleEscapeSequence
    :   '\\' ['"?abfnrtv\\]
    ;
fragment
OctalEscapeSequence
    :   '\\' OctalDigit OctalDigit? OctalDigit?
    ;
fragment
HexadecimalEscapeSequence
    :   '\\x' HexDigit+
    ;

fragment
EncodingPrefix : [uUL]|'u8';
fragment
SCharSequence : SChar+;
fragment
SChar:  CChar; 
