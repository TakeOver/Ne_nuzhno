const {$D+}{$F+}{$L mut.obj}
	StartN = 10;
	ApValue = 0.779822;
	Pi = 3.14159265359;
type
	Num = record 
		bits:array [0..15] of qword;
		float:double;
	end;
	Cell = ^_Cell;
	_Cell = record
		Next:Cell;
		Value:Num;
		FValue:double;
	end;
var 
	Species: Cell;
	N,K:integer;
	P:real;
	procedure FixFloat(var n:Num);
	var i:integer;
		modifer:double;
	begin
		n.float := 0;
		modifer := 4;
		for i := 0 to 15 do begin
			modifer := modifer / 2;
			n.float := n.float + (n.bits[i])*modifer;
		end;
	end; 
	function CreateNum(k:integer):Num;
	var
		res:Num; 
		i:integer;
	begin
		for i := 0 to 15 do 
			res.bits[i] := integer((k and (1 shl i)) shr i);
		FixFloat(res);
		CreateNum := res;
	end;
	function F(var n:Num):double;
	var x:double;
	begin
		x := n.float;
		F := (x-2)*(x-2.5)*(x-3)*(x-3.5)*(1-exp(x-1.5))*ln(x+0.5);
	end;
	procedure CreateStartSpecies(n:integer; var spec:Cell);
	var 
		i:integer;
		ptr,tmp:Cell;
	begin
		Randomize;
		ptr := spec;
		for i := 1 to StartN do begin
			new(tmp);
			tmp^.Value := CreateNum(Random(1 shl 16));
			tmp^.FValue := F(tmp^.Value);
			tmp^.Next := nil;
			if (ptr = nil) then begin
				spec := tmp;
				ptr := tmp;
			end else begin
				ptr^.Next := tmp;
				ptr := tmp;
			end;
		end;
	end;
	function Completed(value:double):boolean;
	begin
		Completed := abs(value - ApValue) < 1.0/(16383.0);
	end;
	procedure mutation(arr:pointer; p:real); external name 'mutation';
	procedure Mutate(var c:Cell; prob:real; n:integer);
	var j:integer;
		iter:Cell;
	begin
		iter := c;
		while iter <> nil do begin
			//for j := 0 to 15 do begin
			//	if Random >= prob then 
			//		iter^.Value.bits[j] := Random(2);
			//end;*/
			mutation(pointer(@iter^.Value.bits),prob);
			FixFloat(iter^.Value);
			iter^.FValue := F(iter^.Value);
			writeln('F(',iter^.Value.float,')=',iter^.FValue);
			iter :=iter^.next;
		end;
	end;
	function max(a,b:integer):integer;
	begin
		if a > b then max := a else max := b;
	end;
	function min(a,b:integer):integer;
	begin
		if a < b then min := a else min := b;
	end;
	function Merge(a,b:Num):Num;
	var 
		res:Num;
		i,mpoint1,mpoint2:integer;
	begin
		mpoint1 := random(16);
		mpoint2 := random(16);
		for i := 0 to min(mpoint1,mpoint2) -1 do 
			res.bits[i] := a.bits[i];
		for i := min(mpoint1,mpoint2) to max(mpoint1,mpoint2) do
			res.bits[i] := b.bits[i];
		for i := max(mpoint1,mpoint2) + 1 to 15 do
			res.bits[i] := a.bits[i];
		FixFloat(res);
		Merge := res;
	end;
	function Select(var c:Cell;k:integer):Cell;
	var head,ptr,prev,tmp:Cell;
		Sum:double;
		i:integer;
	begin
		ptr := c;
		Sum := 0;
		while ptr <> nil do  begin
			Sum := Sum + ptr^.FValue;
			ptr := ptr^.Next;
		end;
		head := nil;
		i := 0;
		while i < k do begin
			ptr := c;
			prev := nil;
			while (ptr <> nil) and (i < k) do begin
				if ptr^.FValue*2*Pi/Sum > Random*2*Pi then begin
				//	if prev = nil then begin
					//	c := ptr^.next;
					//	ptr^.next := head;
					//	head := ptr;
						inc(i);
						new(tmp);
						tmp^.Value := ptr^.Value;
						tmp^.next := head;
						head := tmp;
						ptr := ptr^.next;
		//			end else begin
		//				prev^.next := ptr^.next;
		//				ptr^.next := head;
		//				head := ptr;
		//				ptr := prev^.next;
		//				inc(i);
		//			end;
				end else begin
					prev := ptr;
					ptr := ptr^.next;
				end;
			end;
		end;
		while c<> nil do begin
			tmp := c^.next;
			dispose(c);
			c := tmp;
		end; 
		Select := head;
	end;
	function TakeAt(c:Cell; i:integer):Num; 
	var iter:Cell;
	begin
		iter := c;
		while (i > 0) do begin
			iter := iter^.next;
			dec(i);
		end;
		TakeAt := iter^.Value;
	end;
	procedure Cross(var head:Cell; k,n:integer);
	var res,tmp:Cell;
	begin
		dec(n,k);
		res := head;
		while n > 0 do begin
			new(tmp);
			tmp^.Value :=  Merge(TakeAt(head,Random(k)),TakeAt(head,Random(k)));
			dec(n);
			tmp^.next := res;
			res := tmp;
		end;
		head := res;
	end;
	function IsCompleted(c:Cell):Cell;
	begin
		if c = nil then IsCompleted := nil
		else if Completed(c^.Value.float) then IsCompleted := c 
		else IsCompleted := IsCompleted(c^.Next);
	end;
begin
	read(n,k,p);
	CreateStartSpecies(n,Species);
	while IsCompleted(Species) = nil do begin
		Species := Select(Species,k);
		Cross(Species,k,n);
		writeln('------------------');
		Mutate(Species,P,n);
	end;
	writeln('max F(',IsCompleted(Species)^.Value.float,')=',IsCompleted(Species)^.FValue);
end.
