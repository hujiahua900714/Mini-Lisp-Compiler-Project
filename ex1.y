%{
	#include "ex1.h"

	extern "C"{
		extern int yylex(void);
		void yyerror(const char *s);
	}

	symbol symtab[199];
	int typeError = 0;
	fstream file;
%}
%union {
	int ival;
	char* str;
	struct symbol *s;
	struct symlist *sl;
	struct pmlist *pl;
	struct ast* a;
}

%start program
%token <ival> NUMBER BOOLVAL
%token <op> PLS MNS MPLY DVD MOD
%token <ival> CMP EQL AND OR NOT
%token <str> DEFINE PRTNUM PRTBOOL IF FUN
%token <s> ID
%type <a> exp explist
%type <a> numexp plusop minusop multiplyop divideop modulusop compareop equalop
%type <a> logexp andop orop notop ifexp
%type <a> funcall funexp funbody
%type <sl> funids arglist
%type <pl> paramlist

%%
program :
	stmt
	{
		
	}
	|
	program stmt
	{
		
	}
;
stmt :
	exp
	{
		//cout << "=====start evaluating=======\n";
		//cout << eval($1) << "\n";
		//cout << "=====end evaluating=======\n";
		value v = eval($1);
		if(typeError) {
			cout << "Type error!\n";
		}
		typeError = 0;
	}
	|
	'(' PRTNUM exp ')'
	{
		//cout << "=====start evaluating=======\n";
		value v = eval($3);
		if(typeError || v.type == 0) {
			cout << "Type error!\n";
			file << "Type error!\n";
		}
		else {
			cout << v.number << endl;
			file << v.number << "\n";
		}
		//cout << "=====end evaluating=======\n";
		typeError = 0;
	}
	|
	'(' PRTBOOL exp ')'
	{
		//cout << "=====start evaluating=======\n";
		value v = eval($3);
		if(typeError || v.type == 1) {
			cout << "Type error!\n";
			file << "Type error!\n";
		}
		else{
			if(v.number != 0){
				cout << "#t" << endl;
				file << "#t\n";
			}
			else{
				cout << "#f" << endl;
				file << "#f\n";
			}
		}
		//cout << "=====end evaluating=======\n";
		typeError = 0;
	}
	|
	defstmt
	{
		typeError = 0;
	}
;
exp :
	ID
	{
		$$ = newref($1);
		//$1 is the symbol in the symboltable
	}
	|
	NUMBER
	{
		//newast => newnum
		//int n = $1;
		//cout << "n=" << n << endl;
		$$ = newnum($1, 1);
	}
	|
	BOOLVAL
	{
		$$ = newnum($1, 0);
	}
	|
	numexp
	{
		$$ = $1;
	}
	|
	logexp
	{
		$$ = $1;
	}
	|
	ifexp
	{
		$$ = $1;
	}
	|
	funexp
	{
		$$ = $1;
		//return the funexp into exp
	}
	|
	funcall
	{
		$$ = $1;
	}
;
explist :
	exp
	{
		$$ = $1;
	}
	|
	explist exp
	{
		//right child is the new one
		//L is the list
		//all the ast in the left of node
		$$ = newast('L', $2, $1);
	}
;
defstmt :
	'(' DEFINE ID exp ')'
	{
		//cout << "=====start defining=====\n";
		userdef($3, $4);
		//$3 has the symbol pointer in the symboltable
		//$4 has the definition(action) of ast
		//define the new symbol
		//cout << "=====end defining=======\n";
	}
;
numexp :
	plusop
	{
		$$ = $1;
	}
	|
	minusop
	{
		$$ = $1;
	}
	|
	multiplyop
	{
		$$ = $1;
	}
	|
	divideop
	{
		$$ = $1;
	}
	|
	modulusop
	{
		$$ = $1;
	}
	|
	compareop
	{
		$$ = $1;
	}
	|
	equalop
	{
		$$ = $1;
	}
;
plusop :
	'(' PLS exp explist ')'
	{
		$$ = newast('+', $3, $4);
	}
;
minusop :
	'(' MNS exp explist ')'
	{
		$$ = newast('-', $3, $4);
	}
;
multiplyop :
	'(' MPLY exp explist ')'
	{
		$$ = newast('*', $3, $4);
	}
;
divideop :
	'(' DVD exp explist ')'
	{
		$$ = newast('/', $3, $4);
	}
;
modulusop :
	'(' MOD exp explist ')'
	{
		$$ = newast('%', $3, $4);
	}
;
compareop :
	'(' CMP exp explist ')'
	{
		$$ = newast($2+'0', $3, $4);
		//char c = $2 + '0';
		//cout << "c=" << c << endl;
	}
;
equalop :
	'(' EQL exp explist ')'
	{
		$$ = newast('3', $3, $4);
		//char c = $2 + '0';
		//cout << "c=" << c << endl;
	}
;
logexp :
	andop
	{
		$$ = $1;
	}
	|
	orop
	{
		$$ = $1;
	}
	|
	notop
	{
		$$ = $1;
	}
;
andop :
	'(' AND explist exp ')'
	{
		$$ = newast('4', $3, $4);
	}
;
orop :
	'(' OR explist exp ')'
	{
		$$ = newast('5', $3, $4);
	}
;
notop :
	'(' NOT exp ')'
	{
		$$ = newast('6', $3, NULL);
	}
;	
ifexp :
	'(' IF exp exp exp ')'
	{
		$$ = newifexp('I', $3, $4, $5);
	}
;
funcall :
	'(' funexp ')'
	{
		$$ = newlocalfncall($2, NULL);
		//$2 is the function definition
		//call a local function without arguments
	}
	|
	'(' funexp paramlist ')'
	{
		$$ = newlocalfncall($2, $3);
	}
	|
	'(' ID ')'
	{
		$$ = newnamefncall($2, NULL);
		//$2 is a function symbol now
	}
	|
	'(' ID paramlist ')'
	{
		//cout << "named function called\n";
		$$ = newnamefncall($2, $3);
	}
;
funexp :
	'(' FUN funids funbody ')'
	{
		$$ = newfndef($3, $4);
		//turn a function into a symbol
		//then return in structure AST
	}
;
funbody :
	defstmt exp
	{
		$$ = $2;
	}
	|
	exp
	{
		$$ = $1;
	}
;
funids :
	'(' ')'
	{//have no arguments
		$$ = NULL;
	}
	|
	'(' arglist ')'
	{
		$$ = $2;
	}
;
arglist :
	ID
	{
		$$ = newarglist(NULL, $1);
	}
	|
	arglist ID
	{
		$$ = newarglist($1, $2);
	}
;
paramlist :
	exp
	{
		$$ = newparamlist(NULL, $1);
	}
	|
	paramlist exp
	{
		$$ = newparamlist($1, $2);
	}
;
%%
void yyerror (const char *message){
        
        printf ("%s \n",message);
        exit(0);

}
ast* newast(int nodetype, ast*l, ast*r){
	
	ast* a = (ast*) malloc(sizeof(ast));
	a->nodetype = nodetype;
	a->l = l;
	a->r = r;
	if( a->l && a->l->nodetype == 'L'){
		a->l->parent = a;
	}
	if( a->r && a->r->nodetype == 'L'){
		a->r->parent = a;
	}
	return a;
}
ast* newnum(int n, int type){
	numast* a = (numast*) malloc(sizeof(numast));
	a->nodetype = 'N';
	a->number = n;
	a->type = type;
	return (ast*) a;
}
ast* newifexp(int nodetype, ast*cond,ast* tl, ast*el){
	ifast* a = (ifast*) malloc(sizeof(ifast));
	a->nodetype = nodetype;
	a->cond = cond;
	a->tl = tl;
	a->el = el;
	return (ast*)a;	
}
ast* newnamefncall(symbol* f, pmlist* l){
	
	namefncallast* n = (namefncallast*) malloc(sizeof(namefncallast));
	n->nodetype = 'F';

	pmlist* tmp = l;
	pmlist* prev = NULL;
	while(tmp){
		prev = tmp;
		tmp = tmp->next;
	}
	n->name = f;
	n->pl = l;
	
	return (ast*)n;
}
ast* newlocalfncall(ast* f, pmlist *l){
	localfncallast* a = (localfncallast*) malloc(sizeof(localfncallast));
	a->nodetype = 'C';
	a->func = ((fnast*)f)->func;
	a->sl = ((fnast*)f)->sl;
	a->pl = l;
	return (ast*)a;
}
symlist* newarglist(symlist* sl, symbol* sym) {		//sl is the old symlist
								//sym is the new arg name
	symlist* newsl = (symlist*)malloc(sizeof(symlist));
	newsl->sym = sym;
	newsl->next = sl;
	//cout << "sym: " << sym->name << "=" << sym->value << endl;
	return newsl;
}

pmlist* newparamlist(pmlist* pl, ast* a) {
	pmlist* newpl = (pmlist*)malloc(sizeof(pmlist));
	newpl->a = a;
	newpl->next = pl;
	//cout << "param: " << eval(a) << endl;
	return newpl;
}

ast* newref(symbol* s){
	symrefast* a = (symrefast*)malloc(sizeof(symrefast));
	a->nodetype = 'R';
	a->s = s;
	return (ast*)a;
}
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
ast* newfndef(symlist* sl, ast* func){
	fnast* a = (fnast*)malloc(sizeof(fnast));
	a->nodetype = 'D';
	a->sl = sl;
	a->func = func;
	
	return (ast*)a;
}
void userdef(symbol* name, ast* d){
	if(d->nodetype == 'D'){
		//cout << "new named function defined\n";
		name->func = ((fnast*)d)->func;
		name->sl = ((fnast*)d)->sl;
	}
	//cout << "evaluating def\n";
	value v = eval(d);
	name->type = v.type;
	name->value = v.number;	
}
value evalfn(ast* fn, symlist* osl, pmlist* params){
	value v;
	if(!params){
		return eval(fn);
	}

	symlist* sl;
	pmlist* pms;
	vector<int> oldval, newval;

	sl = osl;
	pms = params;
	while(pms) {
		newval.push_back(eval(pms->a).number);
		pms = pms->next;
	}
	
	sl = osl;
	for(int i = 0; i < newval.size(); i++) {
		symbol* s = sl->sym;
		oldval.push_back(s->value);
		s->value = newval[i];
		sl = sl->next;
	}
	
	v = eval(fn);
	sl = osl;
	for(int i = 0 ; i < oldval.size(); i++){
		symbol* s = sl->sym;
		s->value = oldval[i];
		sl = sl->next;
	}
	return v;
}

value eval(ast*a){
	value v;
	switch(a->nodetype){
	//recurion eval(ast) to calculate the whole tree
	//number operation
	case '+':
	case '*':
	case '-':
	case '/':
	case '%':
		{
			value l = eval(a->l);
			value r = eval(a->r);
			if(l.type == 0 || r.type == 0){
				typeError = 1;
			}
			switch(a->nodetype){
			//recurion function to calculate the whole tree
			//number operation
			case '+': v.number = l.number + r.number; break;
			case '*': v.number = l.number * r.number; break;
			case '-': v.number = l.number - r.number; break;
			case '/': v.number = l.number / r.number; break;
			case '%': v.number = l.number % r.number; break;
			}
			v.type = 1;
			break;
		}
	
	//smaller than/greater than/equal
	case '1':
	case '2':
	case '3':
		{
			value l = eval(a->l);
			value r = eval(a->r);
			if(l.type == 0 || r.type == 0){
				typeError = 1;
			}
			switch(a->nodetype){
			//recurion function to calculate the whole tree
			//number operation
			case '1': v.number = (l.number < r.number)? 1 : 0; break;
			case '2': v.number = (l.number > r.number)? 1 : 0; break;
			case '3': v.number = (l.number == r.number)? 1 : 0; break;
			}
			v.type = 0;
			break;
		}
	//and/or/not
	case '4':
	case '5':
	case '6':
		{
			value l = eval(a->l);
			value r;
			if(l.type == 1){
				typeError = 1;
			}
			switch(a->nodetype){
			//recurion function to calculate the whole tree
			//number operation
			case '4': r = eval(a->r);
				if(r.type == 1) typeError = 1;
				v.number = (l.number && r.number)? 1 : 0; break;
			case '5': r = eval(a->r);
				if(r.type == 1) typeError = 1;
				v.number = (l.number || r.number)? 1 : 0; break;
			case '6': v.number = (l.number == 0)? 1 : 0; break;
			}
			v.type = 0;
			break;
		}
	
	//'L' is the list of exp at the left child
	case 'L': 
		{
			//get the parent node
			ast* prnt = a->parent;
			//get the node type to calculate
			while(prnt->nodetype == 'L'){
				prnt = prnt->parent;
			}
					
			value l = eval(a->l);
			value r = eval(a->r);
			
			if(prnt->nodetype == '+' || prnt->nodetype == '-'){
				if(l.type == 0 || r.type == 0){
					typeError = 1;
				}
				v.number = r.number + l.number;
				v.type = 1;
			}
			if(prnt->nodetype == '*' || prnt->nodetype == '/'){
				if(l.type == 0 || r.type == 0){
					typeError = 1;
				}
				v.number = r.number * l.number;
				v.type = 1;
			}
			if(prnt->nodetype == '='){
				if(l.type == 0 || r.type == 0){
					typeError = 1;
				}
				v.number = (r.number == l.number)? 1 : 0;
				v.type = 0;
			}
			if(prnt->nodetype == '4'){
				if(l.type == 1 || r.type == 1){
					typeError = 1;
				}
				v.number = (r.number && l.number)? 1 : 0;
				v.type = 0;
			}
			if(prnt->nodetype == '5'){
				if(l.type == 1 || r.type == 1){
					typeError = 1;
				}
				v.number = (r.number || l.number)? 1 : 0;
				v.type = 0;
			}
					
			break;
		}
	//if/then/else
	case 'I':
		{	
			//cond is and exp
			//use eval to judge
			value cond = eval(((ifast*)a)->cond);
			if(cond.number != 0){
				if(cond.type == 1) typeError = 1;
				v = eval(((ifast*)a)->tl);
			}
			else{
				if(cond.type == 1) typeError = 1;
				v = eval(((ifast*)a)->el);
			}
			break;
		}
	case 'F':
		{
			v = evalfn(((namefncallast*)a)->name->func,((namefncallast*)a)->name->sl,((namefncallast*)a)->pl);
			break;
		}
	case 'C':
		{
			v = evalfn(((localfncallast*)a)->func,((localfncallast*)a)->sl,((localfncallast*)a)->pl);
			break;
		}

	case 'R': v.number = ((symrefast*)a)->s->value; v.type = 1; break;
	case 'N': v.number = ((numast*)a)->number; v.type = ((numast*)a)->type; break;
	}
	return v;
}

int main(int argc, char * argv[]){
	file.open ("out", ios::app);
	yyparse();
	file.close();
	return 0;
}
