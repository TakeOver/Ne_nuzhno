type
  specie = array [1..16] of integer;
  var N0,N,K,L,test:integer; P:real; 
    S: array of specie;
    i,j:integer;
  function f(x:real):real;
  begin
    f := (x-2)*(x-3)*(x-0.01)*(x-0.01)*(x-0.01)*(x-0.01)*(x-3.99)*(x-3.99)*(x-3.99)*(x-3.99)*(1-exp(x-1.5))*sin(x/3+0.2);
  end;
  function value(x:specie):real;
  var r,k:real; i:integer;
  begin
    k:=2;
    r:=0;
    for i := 1 to 16 do 
    begin
      r := r + x[i]*k;
      k := k/2;
    end;
    value := r;
  end;
  procedure Mutate(var s:specie);
  var i,k,t:integer;
  begin
    k := random(16) + 1;
    for i := k to (16-k + 1)div 2 + k -1 do 
    begin
      t := s[i];
      s[i] := s[16 - k +1];
      s[16 - k + 1] := t;
    end;
  end;
  
  function cross(var a,b:specie):specie;
  var r:specie;
    c,d,e:integer;
  begin
    c := random(16)+1;
    d := random(16)+1;
    if (c > d) then 
    begin
      e := c;
      c := d;
      d := e;
    end;
    for e := 1 to c do
      r[e] := a[e];
    for e := c+1 to d do
      r[e] := b[e];
    for e := d+1 to 16 do 
      r[e] := a[e];
    cross := r;
  end;
  
    procedure selection(n:integer);
    var i,j:integer;
      t:specie;
    begin
      for i :=1 to N do
        for j := i+1 to N do 
        begin
          if f(Value(s[i])) < f(value(s[j])) then 
          begin
            t := s[i];
            s[i] := s[j];
            s[j] := t;
          end;
        end;
    end;
begin
  randomize;
  writeln('Введите N,P,K, число итераций и 0 или 1 для выкл./вкл. тестового режима');
  read(N,P,K,L,test);
  if N < 10 then N0 := 10 else N0 := N;
  SetLength(S,N0+1);
  for i := 1 to 10 do
  	for j := 1 to 16 do
  		s[i][j] := random(2);
    if k <= 10 then 
    begin
      selection(10);
      for i := k+1 to n do 
        s[i] := cross(s[random(k)+1],s[random(k)+1]);
      for i := 1 to n do
        if random < p then
          mutate(s[i]);
    end else
    begin
      for i := 11 to n do 
        s[i] := cross(s[random(10)+1],s[random(10)+1]);
      for i := 1 to n do
        if random < p then
          mutate(s[i]);
    end;
    if k > n then k :=n;
    for i := 2 to L do 
    begin 
    	writeln(i);
      if test<>0 then 
      begin
        writeln('***');
        for j := 1 to n do 
        begin
          write(value(s[j]));
          writeln(' ',f(value(s[j])));
         end;
      end;
      selection(n);
      for j := k+1 to n do 
        s[j] := cross(s[random(k)+1],s[random(k)+1]);
      for j := 1 to n do
        if random < p then
          mutate(s[j]);
    end;
    selection(n);
    writeln('Max:', value(s[1]),' ', f(value(s[1])));
end.
