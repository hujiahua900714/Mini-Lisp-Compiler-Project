# Mini Lisp Compiler Project with yacc and lex

## 内容列表

- [Reference](#Reference)
- [Execution](#Execution)
- [使用说明](#使用说明)
- [程式碼重點簡介](#程式碼重點簡介)

## Reference

http://web.iitd.ac.in/~sumeet/flex__bison.pdf
ch.3 and ch.9

## Execution

use the shell to execute or use the following instruction:
```sh
$ yacc -d ex1.y
$ flex ex1.l
$ g++ -o ex1 y.tab.c lex.yy.c -ll
```

## 使用说明

```sh
$ ./ex1 < "the file you want to input"
```

## 程式碼重點簡介

### AST node
This program will create an abstract tree following the production rule of mini lisp in "MiniLisp.pdf".
#### Types of AST node
```cpp
struct ast{
	int nodetype;
	ast* l;
	ast* r;
	ast* parent = NULL;
};
```
```cpp
//types of ast node
struct symrefast{
	int nodetype;	//R
	symbol* s;
};
struct numast{
	int nodetype;	//N
	int number;
	int type;
};
struct ifast{
	int nodetype;	//I
	ast* cond;
	ast* tl;
	ast* el;
};
struct fnast{
	int nodetype;	//D
	ast* func;
	symlist* sl;
};
struct namefncallast{
	int nodetype;	//F
	symbol* name;
	pmlist* pl;

};
struct localfncallast{
	int nodetype;	//C
	ast* func;
	symlist* sl;
	pmlist* pl;
}
```

### Variable Definition
#### Use an array to store the variable as symbol
```cpp
symbol symtab[199];
```
#### Use hash function to find the specific location of every single variable
```cpp
unsigned symhash(char *sym){
	unsigned int hash = 0;
	unsigned c;
	while(c = *sym++) hash = hash*9 ^ c;
	return hash;
}
symbol* lookup(char* sym ){
	symbol* sp = &symtab[symhash(sym)%199];
	int scount = 199;

	while(--scount >= 0){
		if(sp->name && !strcmp(sp->name,sym)){ return sp;}
		if(!sp-> name){
			sp->name = strdup(sym);
			sp->value = 0;
			sp->func = NULL;
			sp-> sl = NULL;
			return sp;
		} 
		if(++sp >= symtab+199) sp = symtab;
	}
	exit(0);
}
```
### Function
```cpp
value evalfn(ast* fn, symlist* osl, pmlist* params){
	value v;
	if(!params){
		return eval(fn);
	}

	symlist* sl;
	pmlist* pms;
	vector<int> oldval, newval;
    
    //evaluate the new value of every parameters
    //store the new value into a vector
    sl = osl;
	pms = params;
	while(pms) {
		newval.push_back(eval(pms->a).number);
		pms = pms->next;
	}
	
    //store the old value of every specific symbol from symbol table
    //put the new value into symbol table
	sl = osl;
	for(int i = 0; i < newval.size(); i++) {
		symbol* s = sl->sym;
		oldval.push_back(s->value);
		s->value = newval[i];
		sl = sl->next;
	}
	
    //evaluate the function
	v = eval(fn);

    //put the old value back into the symbol table from oldval
	sl = osl;
	for(int i = 0 ; i < oldval.size(); i++){
		symbol* s = sl->sym;
		s->value = oldval[i];
		sl = sl->next;
	}
	return v;
}
```