const Num = ['0'..'9'];
type
  pMList = ^MList;
  MList = record 
    k:integer;
    deg:integer;
    next:pMList;
  end;
var 
  curChar:char;
  ptr,head:pMList;
  
  function ReadInt:integer;
  var tmp:integer;
  begin
    tmp := 0;
    while curChar in Num do begin
      tmp := tmp*10 + ord(curChar) - ord('0');
      read(curChar);
    end;
    ReadInt := tmp;
  end;
  
  function ReadMonom:pMList;
  var 
    tmp:pMList;
  begin
    new(tmp);
    if(curChar = '-') then begin
      read(curChar);
      tmp^.k := -ReadInt;
    end else begin
      if(curCHar = '+') then
        read(curChar);
      tmp^.k := ReadInt;
    end;
    read(curChar);
    read(curChar);
    tmp^.deg := ReadInt;
    tmp^.next := nil;
  end;
  procedure SubM(var a,p:pMList);
  var iter,prev:pMList;
  begin
    if(a^.deg = p^.deg) and (a^.k + p^.k = 0) then begin
      iter := a^.next;
      dispose(a);
      a := iter;
      exit;
    end;
    prev := nil;
    iter := a;
    while iter <> nil do begin
      if iter^.deg = p^.deg then begin
        if iter^.k + p^.k = 0 then begin
            prev^.next := iter^.next;
            dispose(iter);
            exit;
        end;
        iter^.k := iter^.k + p^.k;
        exit;
      end;
      prev := iter;
      iter := iter^.next;
    end;
  end;
  procedure Flush(p:pMList);
  begin
    if p = nil then writeln('0x^0') 
    else begin
      write(p^.k,'x^',p^.deg);
      p := p^.next;
      while p <> nil do begin
        if p^.k >=0 then write('+');
        write(p^.k,'x^',p^.deg);
        p := p^.next;
      end;
    end;
  end;
begin
  read(curChar);
  head := ReadMonom;
  ptr := head;
  while curChar <> ',' do begin
    ptr^.next := ReadMonom;
    ptr := ptr^.next;
  end;
  read(curChar);
  ptr := ReadMonom;
  SubM(head,ptr);
  dispose(ptr);
  Flush(head);
end.
