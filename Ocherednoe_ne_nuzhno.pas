type
  Str = packed array [1..8] of char;
  Tree = ^Node;
  Node = record 
    Left,Right:Tree;
    Count:integer;
    key:Str;
  end;
var
  t:Tree;
  s:Str;
  c:char;
  i:integer;
  procedure Insert(var p:Tree; var s:Str);
  begin
    if p = nil then begin
      new(p);
      p^.Key := s;
      p^.Count := 0;
      p^.Left := nil;
      p^.Right := nil;
      exit;
    end;
    if p^.key = s then 
      p^.Count := p^.Count + 1
    else if p^.key > s then 
      Insert(p^.Left,s)
    else 
      Insert(p^.Right,s);
  end;  
  procedure Print(t:Tree);
  begin
    if t <> nil then begin
      Print(t^.Left);
      for i := 1 to t^.Count do 
        writeln(t^.Key);
      Print(t^.Right);
    end;
  end;
begin
  read(c);
  t := nil;
  while c <> '.' do begin
    i := 0;
    while (c<>',') and (c<>'.') do begin
      i := i+1;
      s[i] := c;
      read(c);
    end;
    while i < 8 do begin
      i := i+1;
      s[i] := ' ';
    end;
    Insert(t,s);
  end;
  Print(t);
end.
