
#include <iostream>
#include <cstdlib>

template<typename T> struct list{
    T elem;
    list<T> * next;
};
template<typename T> class Set{
private:
    list<T>* objects;
    void releaseObjects(){
        
        while(objects != NULL){
            list<T> * ptr = objects->next;
            delete objects;
            objects = ptr;
        }
    }
public:
    Set<T>(){
        objects = NULL;//пустое множество
    }
    ~Set<T>(){
        releaseObjects();
    }
    bool contains(const T& a) const {
        list<T> *ptr = objects;
        while(ptr!=NULL){
            if(ptr->elem == a){
                return true;
            }
            ptr = ptr->next;
        }
        return false;
    }
    void add(const T& a){
        if(contains(a))
            return;
        list<T> * p = new list<T>();
        p->elem = a;
        p->next = objects;
        objects = p;
    }
    void del(const T&a){
        if(objects!=NULL){
            if(objects->elem == a){
                list<T> * tmp = objects->next;
                delete objects;
                objects = tmp;
                return;
            }
        }else{
            return;//нет элементов
        }
        
        list<T> * prev = objects;
        list<T>* ptr = objects->next;
        while(ptr!=NULL){
            if(ptr->elem == a){
                list<T> * tmp = ptr->next;
                delete ptr;
                prev->next = tmp;
                return;
            }
            prev = ptr;
            ptr = ptr->next;
        }
    }
    Set<T> operator - (const Set<T> &b){
        Set<T> res;
        list<T> * ptr = objects;
        while(ptr!=NULL){
            if(b.contains(ptr->elem) == false){
                res.add(ptr->elem);
            }
            ptr = ptr->next;
        }
        return res;
        
    }
    
    void print()const{
        list<T>* ptr = objects;
        while(ptr != NULL){
            std::cout << ptr->elem << ' ';
            ptr = ptr->next;
        }
        std::cout << std::endl;
    }
    Set<T>(const Set<T>& a){
        objects = NULL;
        list<T> * ptr = a.objects;
        while(ptr != NULL){
            add(ptr->elem);
            ptr = ptr->next;
        }
    }
    Set<T> & operator = (const Set<T> & a){
        releaseObjects();
        objects = NULL;
        list<T> * ptr = a.objects;
        while(ptr != NULL){
            add(ptr->elem);
            ptr = ptr->next;
        }
        return *this;
    }
};

int main(int argc, const char * argv[]) {
    Set<int> a,b,c;
    a.add(1);
    a.add(2);
    a.add(3);
    b.add(4);
    b.add(5);
    b.add(1);
    c = a-b;
    a.print();
    b.print();
    c.print();
    return 0;
}
