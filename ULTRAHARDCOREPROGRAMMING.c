#include <stdio.h>
#include <stdlib.h>
int len_str(char * s){
    if(!s){
        return 0;
    }
    int len = 0;
    while(*s++){
        ++len;
    }
    return len;
}
void merge_str(char * s1, char * s2, char * s3){
    if(!s3){
        return;
    }
    if(s1){
        while(*s1){
            *s3++ = *s1++;
        }
    }
    if(s2){
        while(*s2){
            *s3++ = *s2++;
        }
    }
    *s3 = 0;
}
int main(int argc, char const *argv[])
{
    printf("%i\n",len_str((char*)"12345 abcd\0"));
    const char * s1 = "12345\0";
    const char * s2 = " abcd\0";
    char * s = (char*)malloc(sizeof(*s)*(sizeof(s1)+sizeof(s2)-1));
    merge_str((char*)s1, (char*)s2, s);
    printf("%s\n",s);
    return 0;
}
