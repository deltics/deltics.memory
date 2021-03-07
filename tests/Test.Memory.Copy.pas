
{$i deltics.inc}

  unit Test.Memory.Copy;


interface

  uses
    Deltics.Smoketest;


  type
    MemoryCopy = class(TTest)
      procedure CopiesSpecifiedNumberOfBytes;
    end;


implementation

  uses
    Deltics.Memory;



{ CopyBytes }

  procedure MemoryCopy.CopiesSpecifiedNumberOfBytes;
  const
    BUFSIZE   = 1024;
    BYTECOUNT = 512;
  var
    src: Pointer;
    dest: Pointer;
  begin
    GetMem(src,   BUFSIZE);
    GetMem(dest,  BUFSIZE);
    try
      Memory(src, BUFSIZE).Randomize;
      Memory(dest, BUFSIZE).Randomize;

      Test('Bytes of dest are different to src').Assert(dest).HasUnequalBytes(src, BUFSIZE);
      Test('First {bytes:%d} of dest are different to src', [BYTECOUNT]).Assert(dest).HasUnequalBytes(src, BYTECOUNT);

      Memory(src, BYTECOUNT).CopyTo(dest, BYTECOUNT);

      Test('Bytes of dest are different to src').Assert(dest).HasUnequalBytes(src, BUFSIZE);
      Test('First {bytes:%d} of dest == src', [BYTECOUNT]).Assert(dest).EqualsBytes(src, BYTECOUNT);

    finally
      FreeMem(dest);
      FreeMem(src);
    end;
  end;




end.
