{Компилировать в Freepascal.}
type
    FType = function(const x:double):double; 
var
    S,EPSILON:double;{Точность вычислений}
    roots: array [1..3] of double;  {Массив корней разностей функций}
function F1(const x:double):double;
begin
    F1:= ln(x);     
end;
function F2(const x:double):double;
begin
    F2:= -2*x+14;
end;
function F3(const x:double):double;
begin
    F3:= 1/(2-x) + 6;
end;
{бинарный поиск корня, метод деления отрезка. На вход подается интервал поиска [from,next] и точность корня eps.
Концы отрезка должны удоволетворять условию: F(from)*F(next)<0, и функция должны быть непрерывна на интервале. Тогда берем точку по середине отрезка и смотрит на знак функции в данной точке.}
function BinarySearch(f,g:FType; from,next,eps:double):double;
var
    m:double;{середина отрезка}
    function SubFG(const x:double):double; {разность двух функций}
    begin
        SubFG:= f(x) - g(x);
    end;
begin
    if(SubFG(from) = 0) then begin
        BinarySearch:=from;
        exit;
    end else if(SubFG(next) = 0) then begin
        BinarySearch:=next;
        exit;
    end;
    while ((next - from) > eps) do begin
        m := (next + from)/2;
        if(SubFG(m) = 0) then begin
            BinarySearch := m;
            exit;
        end;
        if SubFG(m)*SubFG(from) < 0 then begin
            next := m
        end else begin
            from := m;
        end;
    end;
    BinarySearch := (next + from)/2;
end;
{Интегрирование методом Симпсона: a,b - область интегрирования, eps - точность
In = (b-a)/n/3*(f(a) + f(b) + 2(2*Fi + Fj))
|I - In| <= p*|I2n - In|, где p = 1/15, I - точное значение интеграла, I2n и In приближенный интеграл, тогда заданное eps достигается, когджа выполнено это условие.}
{Тк на каждой итерации в четных точках значения уже известны, но вычисляются только нечетные}
function Integrate(f,g:FType; const a,b,eps:double):double; {идея метода -  апроксимизация функции на каждом сегменте [a+i*h,a+(i+2)*h] параболой и взятие интеграла от параболы}
var 
    j,n:longint;
    F0,FN, {значения функции на концах отрезка, их отдельно, тк в методе Симпсона они идут с еденичным коэф. и учавствуют всегда}
    h {h/3 = delta x}
    ,I,Iold, {новое и старое значения приближенного интеграла}
    Fi,Fj {значения функции в четных и нечетных участках умноженное на 2}
            :double;
    function SubFG(const x:double):double; {разница двух функций}
    begin
        SubFG := f(x) - g(x);
    end;
begin
    F0 := SubFG(a);
    FN := SubFG(b);
    Fi := 2*SubFG(a + (b-a)/2); {тк n=2, неч. элементов 1}
    I := (b-a)/6*(F0 + 2*Fi + FN); {начальное приближение, n=2}
    n := 2;
    Fj := 0;
    Iold := I + 359*eps; { 359 - чтобы наверняка цикл выполнился хотя бы 1 раз.}
    while abs(Iold - I)/15 > eps do begin
        h := (b-a)/n/2; {delta X.}
        Iold := I;
        Fj := Fi + Fj; {тк n -> 2n, то все четные и нечетные на n итерации станут четным, а нечетные - надо вычислить}
        Fi := 0;
        for j := 0 to n-1 do begin
            Fi := Fi + 2*SubFG(a + (2*j+1)*h); {вычисляем только нечетные значения}
        end;
        I := h/3*(F0 + FN + 2*Fi + Fj);
        inc(n,n);
    end;
    Integrate := I;
end;
begin // http://www.wolframalpha.com/input/?i=%7C%28integrate+log%28x%29-+1%2F%282-x%29+-+6++from+2.1917435+to++4.2247%29%7C+%2B+%7C%28integrate++ln%28x%29+%2B2*x+-+14+from+4.2247+to+6.09618+%29%7C
    // проверить ответ можно тут. ~ 11.236376. Но тк в вольфраме указаны не точные корни, то ответ там приблизтельный, программа же считает точнее. 
    writeln('Square of {ln(x), -2*x+14 ,1/(2-x) + 6}.');
    EPSILON := -1;
    while EPSILON <= 0 do begin
        write('Input epsilon(0<eps):');
        read(EPSILON);
    end; 
    // корни примерно равны: {2.1917435 4.2247 6.09618}
    roots[3] := BinarySearch(@F1,@F2,2.1,10,EPSILON); {данное расположение корней видно в графике: http://www.wolframalpha.com/input/?i=ln(x),+-2*x%2B14+,1/(2-x)+%2B+6 и интервалы тоже.}
    roots[1] := BinarySearch(@F1,@F3,2.1,10,EPSILON);
    roots[2] := BinarySearch(@F2,@F3,2.1,10,EPSILON);
    writeln('Roots:',roots[1], ' ',roots[2],' ',roots[3]);
    S := abs(Integrate(@F1,@F3,roots[1], roots[2], EPSILON)) + abs(Integrate(@F1,@F2,roots[2],roots[3],EPSILON));
    writeln('Integral of area is ', S:1:10);
end.
