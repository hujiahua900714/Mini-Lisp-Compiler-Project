#ifndef HEADERFILE_H
#define HEADERFILE_H

#include <iostream>
#include <vector>
#include <cstdio>
#include <stack>
#include <cstdlib>
#include <cstring>
#include <string>
#include <fstream>
using namespace std;

//ast node and symbol
struct ast{
	int nodetype;
	ast* l;
	ast* r;
	ast* parent = NULL;
};
struct symbol{
	char *name;
	int type;	//0:1:2 = bool:number:typeError
	int value;
	ast* func;
	struct symlist* sl;
};
//symbol and list of symbols or parameters
struct symlist{
	symbol * sym;
	symlist* next;
};

struct pmlist{
	ast* a;
	pmlist* next;
};
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
};

struct value{
	int type;	//0:1:2 = bool:number:typeError
	int number;
};

value eval(ast* a);
ast* newast(int nodetype, ast*l, ast*r);
ast* newref(symbol*s);
ast* newnum(int n, int check);
ast* newfndef(symlist* sl, ast* body);
ast* newifexp(int nodetype, ast*cond,ast* tl, ast*el);

ast* newnamefncall( symbol* f, pmlist* l);
ast* newlocalfncall(ast* f, pmlist*l);

symlist* newarglist(symlist*, symbol*);
pmlist* newparamlist(pmlist*, ast*);

void userdef(symbol* name, ast* d);

unsigned symhash(char *sym);
symbol* lookup(char*);
value evalfn(ast* fn , symlist*osl,pmlist* params);

#endif
