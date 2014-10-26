#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define list struct list_
struct list_ {
    char * s;
    struct list_ * next;
};
void add(list *l, char* str){
    list * tmp = (l)->next;
    (l)->next = (struct list_ *)malloc(sizeof(list));
    (l)->next->s = (l)->s;
    (l)->s = str;
    (l)->next->next = tmp;
}

void freelist(list*l){
    if(!l)return;
    free(l->s);
    freelist(l->next);
    free(l);
}
void lexadd(list **l, char*s){
    if(!*l){
        *l = (list*)malloc(sizeof(list));
        (*l)->next = NULL;
        (*l)->s = s;
        return;
    }
    int cmp = strcmp(s,(*l)->s);
    if(!cmp)return;
    if(cmp > 0){
        lexadd(&((*l)->next),s);
    }else{
        add(*l, s);
    }
}
void print(list*l){
    if(!l)return;
    printf("%s\n",l->s);
    print(l->next);
}
int main(int argc, char const *argv[])
{
    while(1){
        while(1){
            printf("run?[y/n]\n");
            char ans = 0;
            scanf("%c",&ans);
            if(ans == 'n')return 0;
            if(ans == 'y') break;
        }
        list* l = NULL;
        while(1){
            int p = 4,len=0;
            char * str = (char*)malloc(1<<p);
            char c;
            while((c=getchar())!=EOF && c != '\n'){
                if(len+1 >= 1 << p){
                    str = (char*)realloc(str,1<< ++p);
                }
                str[len++] = c;
            }
            str[len] = '\0';
            lexadd(&l,str);
            if(c == EOF){
                print(l);
                freelist(l);
                break;
            }
        }
    }
    return 0;
}
