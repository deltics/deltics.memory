
{$i deltics.memory.inc}

  unit Deltics.Memory.Class_;


interface

  uses
    Deltics.Memory.Types;


  type
    MemoryClass = class
    public
      class function Alloc(var aPointer; const aNumBytes: Integer): IMemoryBuffer;
      class procedure Copy(const aSource: Pointer; const aNumBytes: Integer; const aDest: Pointer);
      class procedure Free(var aPointer); overload;
      class procedure Free(aPointers: PPointerArray); overload;
      class function Offset(const aBase: Pointer; aOffset: Integer): Pointer;
    end;
    Memory = class of MemoryClass;



implementation

  uses
    Classes,
    {$ifdef MSWINDOWS}
      Windows,
    {$else}
      {$message fatal '64-bit platforms other than Windows are not supported'}
    {$endif}
    Deltics.Memory.Buffer;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function MemoryClass.Alloc(var   aPointer;
                                   const aNumBytes: Integer): IMemoryBuffer;
  var
    ptr: Pointer absolute aPointer;
  begin
    GetMem(ptr, aNumBytes);
    result := TMemoryBuffer.Create(ptr, aNumBytes);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure MemoryClass.Free(var aPointer);
  var
    ptr: Pointer absolute aPointer;
  begin
    FreeMem(ptr);
    ptr := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure MemoryClass.Copy(const aSource: Pointer;
                                   const aNumBytes: Integer;
                                   const aDest: Pointer);
  begin
    CopyMemory(aDest, aSource, aNumBytes);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure MemoryClass.Free(aPointers: PPointerArray);
  var
    i: Integer;
  begin
    for i := Low(aPointers) to High(aPointers) do
    begin
      FreeMem(aPointers[i]^);
      aPointers[i]^ := NIL;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function MemoryClass.Offset(const aBase: Pointer;
                                          aOffset: Integer): Pointer;
  begin
    result := Pointer(Int64(aBase) + Int64(aOffset));
  end;




end.
