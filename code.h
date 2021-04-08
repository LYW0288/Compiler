#define MAX_TABLE_SIZE 5000

typedef struct symbol_entry *PTR_SYMB;
struct symbol_entry {
   char name[300];
   int scope;
   int offset;
   int id;
   int variant;
   int type;
   int total_args;
   int total_locals;
   int mode;
}  table[MAX_TABLE_SIZE];

#define T_FUNCTION 1
#define ARGUMENT_MODE   2
#define LOCAL_MODE      3
#define GLOBAL_MODE     4

extern int cur_scope;
extern int cur_counter;

void install_symbol(char *,int);
int look_up_symbol(char *);
void pop_up_symbol(int);
void code_gen_func_header(char *);
void code_gen_end();



