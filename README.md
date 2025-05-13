<h1>📄 Project Title:</h1>
<h2><b>Devta Lang</b> - A Custom Programming Language</h2>



<h1>🔧 Description:</h1>
Devta Lang is a custom-designed programming language depicting mytho-modern fusion — cool syntax, godlike commands, powerful vibes. The language introduces simple programming constructs inspired by Sanskrit-like keywords, making it unique and culturally flavored while maintaining core programming concepts.



<h1>🎯 Key Features:</h1>
• <b>Custom Keywords:</b> Uses unique keywords such as om namah, vachan, sthapit, yadi, anyatha, yavat, karya, ahvan, and smaran.


• <b>Basic Constructs Supported:</b>
    o Variable declarations and assignments (sthapit).

    o Arithmetic expressions.
    
    o Output printing (vachan).
    
    o Conditional statements (yadi...anyatha).
    
    o Looping constructs (yavat).
    
    o Function definition and calling (karya, ahvan).
    
    o Program start and end keywords (om namah, smaran).


• <b>Simple Syntax and Semantics:</b>
    o The language supports integer variables, string printing, and basic control flows.

    o Comments using //.

    o Functions with no parameters and no return type.



<h1>💻 Technical Implementation:</h1>
• <b>Lexical Analyzer:</b> Implemented using Flex to tokenize the Devta Lang keywords, identifiers, numbers, operators, and comments.

• <b>Parser:</b> Implemented using Bison to parse the language constructs and generate actions such as evaluating expressions, printing values, and managing control structures.

• <b>Execution Model:</b> The interpreter model directly evaluates the parsed statements, using symbol tables for variables and functions.



<h1>🔄 Scope:</h1>
<b>Devta Lang serves as an educational prototype to demonstrate:</b>

• Lexical and syntax analysis.

• Expression evaluation.

• Symbol table management.

• Function handling and control flow.

• Integration of Flex and Bison.



<h1>✅ Status:</h1>
The project supports basic interpreted execution and provides a simple interactive experience for the defined Devta Lang syntax.



<h1>🖥 Commands to run Lex & YACC Program</h1>
bison -d file_name.y

flex file_name.l

gcc lex.yy.c file_name.tab.c

./a.exe < input.file_name



<h1>🙎🏻‍♂️ Made By: Dhyey Bhandari - 22000810</h1>