%{
	#include <iostream>
	#include "y.tab.h"
	#include "ex1.h"
	extern "C"{
		int yylex(void);
	}
%}
number (0|[1-9][0-9]*|-[1-9][0-9]*)
id [a-z]([a-z]|[0-9]|"-")*
%%
{number} {
	yylval.ival = atoi(yytext);
	return NUMBER;
}
"#t" {
	yylval.ival = 1;
	return BOOLVAL;
}
"#f" {
	yylval.ival = 0;
	return BOOLVAL;
}
"print-num" {
	yylval.str = strdup(yytext);
	return PRTNUM;
}
"print-bool" {
	yylval.str = strdup(yytext);
	return PRTBOOL;
}
\+ {
	return PLS;
}
\- {
	return MNS;
}
\* {
	return MPLY;
}
\/ {
	return DVD;
}
"mod" {
	return MOD;
}
"<"|">" {
	if(yytext[0] == '<')
		yylval.ival = 1;
	else
		yylval.ival = 2;
	return CMP;
}
"=" {
	yylval.ival = 3;
	return EQL;
}
"and" {
	yylval.ival = 4;
	return AND;
}
"or" {
	yylval.ival = 5;
	return OR;
}
"not" {
	yylval.ival = 6;
	return NOT;
}
"if" {
	yylval.str = strdup(yytext);
	return IF;
}
"define" {
	yylval.str = strdup(yytext);
	return DEFINE;
}
"fun"|"lambda" {
	yylval.str = strdup(yytext);
	return FUN;
}
{id} {
	//cout << lookup() << endl;
	//yylval.str = strdup(yytext);
	//string str = strdup(yytext);
	//cout << str << endl;
	yylval.s = lookup(yytext);
	return ID;
}
[ \t\r\n]+
.	{return yytext[0];}
%%
