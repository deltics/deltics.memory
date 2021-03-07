
{$i deltics.inc}

  unit Test.Memory.AllocCopy;


interface

  uses
    Deltics.Smoketest;


  type
    MemoryAllocCopy = class(TTest)
      procedure AllocatesNewMemoryWithBytesCopiedFromSource;
    end;


implementation

  uses
    Deltics.Memory;



{ CopyBytes }

  procedure MemoryAllocCopy.AllocatesNewMemoryWithBytesCopiedFromSource;
  const
    BUFSIZE = 1024;
  var
    src: Pointer;
    dest: Pointer;
  begin
    Memory.Alloc(src, BUFSIZE)
            .Managed
            .Randomize
          .AllocCopy(dest)
            .Managed;

    Test('dest').Assert(dest).DoesNotEqual(src);
    Test('dest').Assert(dest).EqualsBytes(src, BUFSIZE);
  end;




end.
