
{$i deltics.inc}

  unit Test.PointerSize;


interface

  uses
    Deltics.Smoketest;


  type
    PointerSize = class(TTest)
      procedure NativeUIntIsTheExpectedSizeForPlatform;
      procedure IntPointerIsTheExpectedSizeForPlatform;
    end;


implementation

  uses
    Deltics.Memory,
    Deltics.Smoketest.Test;


  const
    POINTER_SIZE = {$ifdef 64BIT} 8
                   {$else}
                     {$ifdef 32BIT} 4
                     {$else}
                       NEITHER_64BIT_NOR_32BIT_DEFINED
                     {$endif}
                   {$endif};


{ TPointerSizeTests }

  procedure PointerSize.IntPointerIsTheExpectedSizeForPlatform;
  begin
    Test('sizeof(IntPointer)').Assert(sizeof(IntPointer)).Equals(POINTER_SIZE);
  end;


  procedure PointerSize.NativeUIntIsTheExpectedSizeForPlatform;
  begin
    Test('sizeof(NativeUInt)').Assert(sizeof(NativeUInt)).Equals(POINTER_SIZE);
  end;



end.
