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
  
  function CreateMList(k0,d:integer):pMList;
  var tmp:pMList;
  begin
    new(tmp);
    with tmp do begin
      k := k0;
      deg := d;
      next := nil;
    end;
    CreateMList := tmp;
  end;
  
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
    read(сurChar);
    read(curChar);
    tmp^.deg := ReadInt;
    tmp^.next := nil;
  end;
