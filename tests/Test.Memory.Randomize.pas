
{$i deltics.inc}

  unit Test.Memory.Randomize;


interface

  uses
    Deltics.Smoketest;


  type
    MemoryRandomize = class(TTest)
      procedure RandomizesSpecifiedNumberOfBytes;
      procedure RandomizesSpecifiedNumberOfBytesNotLongWordAligned;
      procedure LimitsRandomizedBytesToSpecifiedRange;
    end;


implementation

  uses
    Windows,
    Deltics.Memory;


{ Randomize }

  procedure MemoryRandomize.RandomizesSpecifiedNumberOfBytes;
  const
    BUFSIZE = 1024;
  var
    org: Pointer;
    cpy: Pointer;
  begin
    GetMem(org, BUFSIZE);
    GetMem(cpy, BUFSIZE);
    try
      CopyMemory(cpy, org, BUFSIZE);

      Test('org').Assert(org).IsNotNIL;
      Test('cpy').Assert(cpy).IsNotNIL;
      Test('cpy == org').Assert(cpy).EqualsBytes(org, BUFSIZE);

      Memory(cpy, BUFSIZE).Randomize;

      Test('cpy <> org').Assert(cpy).HasUnequalBytes(org, BUFSIZE);

    finally
      FreeMem(cpy);
      FreeMem(org);
    end;
  end;



  procedure MemoryRandomize.LimitsRandomizedBytesToSpecifiedRange;
  var
    s: AnsiString;
  begin
    SetLength(s, 1024);
    Memory(@s[1], Length(s)).Randomize(65, 66);

    Test('s').Assert(s).Contains('A');
    Test('s').Assert(s).Contains('B');

    Memory(@s[1], Length(s)).Randomize(65, 65);

    Test('s').Assert(s).Contains('A');
    Test('s').Assert(s).DoesNotContain('B');
  end;


  procedure MemoryRandomize.RandomizesSpecifiedNumberOfBytesNotLongWordAligned;
  const
    BUFSIZE = 1024;
  var
    org: Pointer;
    cpy: Pointer;

    procedure TestWith(aSubrange: Word);
    var
      offOrg: Pointer;
      offCpy: Pointer;
      rem: Integer;
    begin
      CopyMemory(cpy, org, BUFSIZE);
      Test('cpy == org').Assert(cpy).EqualsBytes(org, BUFSIZE);

      Memory(cpy, aSubrange).Randomize;

      offOrg := Pointer(IntPointer(org) + aSubrange);
      offCpy := Pointer(IntPointer(cpy) + aSubrange);
      rem    := BUFSIZE - aSubrange;

      Test('{num:%d} subrange bytes', [aSubrange]).Assert(cpy).HasUnequalBytes(org, aSubrange);
      Test('Remaining {num:%d} bytes', [rem]).Assert(offCpy).EqualsBytes(offOrg, rem);
    end;

  const
    SUB1 = 513;
    SUB2 = 514;
    SUB3 = 515;
  begin
    GetMem(org, BUFSIZE);
    GetMem(cpy, BUFSIZE);
    try
      Test('org').Assert(org).IsNotNIL;
      Test('cpy').Assert(cpy).IsNotNIL;

      TestWith(SUB1);
      TestWith(SUB2);
      TestWith(SUB3);

    finally
      FreeMem(cpy);
      FreeMem(org);
    end;
  end;



end.
