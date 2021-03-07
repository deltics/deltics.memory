
{$i deltics.inc}

  unit Test.Memory.AllocZeroed;


interface

  uses
    Deltics.Smoketest;


  type
    MemoryAllocZeroed = class(TTest)
      procedure AllocatesNewMemoryWithBytesZeroed;
    end;


implementation

  uses
    Deltics.Memory;



{ CopyBytes }

  procedure MemoryAllocZeroed.AllocatesNewMemoryWithBytesZeroed;
  const
    ZEROES: array[1..100] of Byte = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  var
    dest: Pointer;
  begin
    Memory.Alloc(dest, Length(ZEROES)).Managed.Zeroize;

    Test('dest').Assert(dest).IsNotNIL;
    Test('dest').Assert(dest).EqualsBytes(@ZEROES, Length(ZEROES));
  end;




end.
