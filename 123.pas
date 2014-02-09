Unit MathPro;


interface
{$F+}
   const Eps=0.0001;
   type Ftype= function(x:real):real;

   procedure RootSearch(f, g:Ftype; a, b:real; var x:real);

implementation

   procedure RootSearch(f, g:Ftype; a, b:real; var x:real);
   var middle:real; p:boolean;

       function SubtFG(x:real):real;
       begin
          SubtFG:=f(x)-g(x)
       end;

   begin
       p:=true;
	  if SubtFG(a)=0 then begin 
		p:=false; 
		x:=a 
	  end
       else if SubtFG(b)=0 then begin 
		p:=false; 
		x:=b 
	  end;
         
       while  p do
       begin
         middle:=(a+b)/2;
         if(SubtFG(middle) = 0) then begin
         	x := middle;
         	p := false;
         end else begin
         	if SubtFG(middle)*SubtFG(a) < 0 then 
			b:=middle
         	else  
           		a:=middle;
         	p:= abs(a-b)>Eps;
         	x:= middle;
         end;
       end;

   end;

end.
