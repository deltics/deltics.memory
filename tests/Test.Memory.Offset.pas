
{$i deltics.inc}

  unit Test.Memory.Offset;


interface

  uses
    Deltics.Smoketest;


  type
    MemoryOffset = class(TTest)
      procedure YieldsCorrectAddress;
    end;


implementation

  uses
    Deltics.Memory;



{ CopyBytes }

  procedure MemoryOffset.YieldsCorrectAddress;
  var
    s: AnsiString;
    p: Pointer;
  begin
    s := 'dcba01234';
    p := @s[5];

    Test('p').Assert(AnsiChar(p^)).Equals('0');

    Test('p - 1').Assert(AnsiChar(Memory.Offset(p, -1)^)).Equals('a');
    Test('p - 2').Assert(AnsiChar(Memory.Offset(p, -2)^)).Equals('b');
    Test('p - 3').Assert(AnsiChar(Memory.Offset(p, -3)^)).Equals('c');
    Test('p - 4').Assert(AnsiChar(Memory.Offset(p, -4)^)).Equals('d');

    Test('p + 1').Assert(AnsiChar(Memory.Offset(p, 1)^)).Equals('1');
    Test('p + 2').Assert(AnsiChar(Memory.Offset(p, 2)^)).Equals('2');
    Test('p + 3').Assert(AnsiChar(Memory.Offset(p, 3)^)).Equals('3');
    Test('p + 4').Assert(AnsiChar(Memory.Offset(p, 4)^)).Equals('4');
  end;




end.
