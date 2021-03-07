
{$i deltics.memory.inc}

  unit Deltics.Memory.Buffer;


interface

  uses
    Deltics.InterfacedObjects,
    Deltics.StringTypes,
    Deltics.Memory.Types;


  type
    TMemoryBuffer = class(TComInterfacedObject, IMemoryBuffer)
    // IBufferOperations
    protected
      function get_Address: Pointer;
      function get_AsHex: String;
      function get_Size: Integer;
      procedure set_AsHex(const aHexString: String);
    public
      function AllocCopy(var aPointer): IMemoryBuffer;
      procedure CopyFrom(const aSourceAddress); overload;
      procedure CopyFrom(const aSourceAddress; const aMaxBytes: Integer); overload;
      procedure CopyTo(const aDestinationAddress); overload;
      procedure CopyTo(const aDestinationAddress; const aMaxBytes: Integer); overload;
      procedure Fill(const aValue: Byte);
      procedure FromHex(const aHexString: AnsiString); overload;
      procedure FromHex(const aHexString: UnicodeString); overload;
    {$ifdef UNICODE}
      procedure FromHex(const aHexString: Utf8String); overload;
      procedure FromHex(const aHexString: WideString); overload;
    {$endif}
      procedure FromHexUtf8(const aHexString: Utf8String);
      function Randomize: IMemoryBuffer; overload;
      function Randomize(const aMin, aMax: Byte): IMemoryBuffer; overload;
      function Managed: IMemoryBuffer;
      procedure ToHex(var aString: AnsiString); overload;
      procedure ToHex(var aString: UnicodeString); overload;
    {$ifdef UNICODE}
      procedure ToHex(var aString: Utf8String); overload;
      procedure ToHex(var aString: WideString); overload;
    {$endif}
      procedure ToHexUtf8(var aString: Utf8String);
      function Unmanaged: IMemoryBuffer;
      procedure Zeroize;

    private
      fAddress: Pointer;
      fManaged: Boolean;
      fSize: Integer;
    public
      constructor Create(const aAddress: Pointer; const aNumBytes: Integer);
      destructor Destroy; override;
    end;


implementation

  uses
  {$ifdef 64BIT}
    {$ifdef MSWINDOWS}
      Windows,
    {$else}
      {$message fatal '64-bit platforms other than Windows are not supported'}
    {$endif}
  {$endif}
    Deltics.Contracts,
    Deltics.Hex2Bin;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure CopyBytes(const aSource; var aDest; aCount: Integer);
{$ifdef 64BIT}
  begin
    CopyMemory(@aDest, @aSource, aCount);
  end;
{$else}
  asm
                      // ECX = Count
                      // EAX = Const Source
                      // EDX = Var Dest
                      // If there are no bytes to copy, just quit
                      // altogether; there's no point pushing registers.
    Cmp   ECX,0
    Je    @JustQuit
                      // Preserve the critical Delphi registers.
    push  ESI
    push  EDI
                      // Move Source into ESI (SOURCE register).
                      // Move Dest into EDI (DEST register).
                      // This might not actually be necessary, as I'm not using MOVsb etc.
                      // I might be able to just use EAX and EDX;
                      // there could be a penalty for not using ESI, EDI, but I doubt it.
                      // This is another thing worth trying!
    Mov   ESI, EAX
    Mov   EDI, EDX
                      // The following loop is the same as repNZ MovSB, but oddly quicker!
  @Loop:
    Mov   AL, [ESI]   // get a source byte
    Inc   ESI         // bump source address
    Mov   [EDI], AL   // Put it into the destination
    Inc   EDI         // bump destination address
    Dec   ECX         // Dec ECX to note how many we have left to copy
    Jnz   @Loop       // If ECX <> 0, then loop.
                      // Pop the critical Delphi registers that we've altered.
    pop   EDI
    pop   ESI
  @JustQuit:
  end;
{$endif}



{ TBufferOperations ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TMemoryBuffer.Create(const aAddress: Pointer; const aNumBytes: Integer);
  begin
    inherited Create;

    fAddress := aAddress;
    fSize   := aNumBytes;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TMemoryBuffer.Destroy;
  begin
    if fManaged then
      FreeMem(fAddress);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMemoryBuffer.get_Address: Pointer;
  begin
    result := fAddress;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMemoryBuffer.get_AsHex: String;
  begin
    Hex2Bin.ToHex(fAddress, fSize, result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMemoryBuffer.get_Size: Integer;
  begin
    result := fSize;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.set_AsHex(const aHexString: String);
  begin
    Contract.Requires('aHexString', Length(aHexString) = (fSize * 2));

    Hex2Bin.ToBin(aHexString, fAddress);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMemoryBuffer.AllocCopy(var aPointer): IMemoryBuffer;
  var
    ptr: Pointer absolute aPointer;
  begin
    GetMem(ptr, fSize);
    CopyBytes(fAddress^, ptr^, fSize);

    result := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.CopyFrom(const aSourceAddress);
  var
    source: Pointer absolute aSourceAddress;
  begin
    CopyBytes(source^, fAddress^, fSize);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.CopyFrom(const aSourceAddress; const aMaxBytes: Integer);
  var
    source: Pointer absolute aSourceAddress;
  begin
    Contract.Requires('aMaxBytes', aMaxBytes).IsNotGreaterThan(fSize);

    CopyBytes(source^, fAddress^, aMaxBytes);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.CopyTo(const aDestinationAddress);
  var
    dest: Pointer absolute aDestinationAddress;
  begin
    CopyBytes(fAddress^, dest^, fSize);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.CopyTo(const aDestinationAddress; const aMaxBytes: Integer);
  var
    dest: Pointer absolute aDestinationAddress;
  begin
    Contract.Requires('aMaxBytes', aMaxBytes).IsNotGreaterThan(fSize);

    CopyBytes(fAddress^, dest^, aMaxBytes);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.Fill(const aValue: Byte);
  begin
    FillChar(fAddress^, fSize, aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.FromHex(const aHexString: UnicodeString);
  begin
    Hex2Bin.ToBin(aHexString, fAddress);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.FromHex(const aHexString: AnsiString);
  begin
    Contract.Requires('aHexString', Length(aHexString) = (fSize * 2));
    Hex2Bin.ToBin(aHexString, fAddress);
  end;


{$ifdef UNICODE}
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.FromHex(const aHexString: Utf8String);
  begin
    Contract.Requires('aHexString', Length(aHexString) = (fSize * 2));
    Hex2Bin.ToBin(aHexString, fAddress);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.FromHex(const aHexString: WideString);
  begin
    Contract.Requires('aHexString', Length(aHexString) = (fSize * 2));
    Hex2Bin.ToBin(aHexString, fAddress);
  end;
{$endif}


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.FromHexUtf8(const aHexString: Utf8String);
  begin
    Contract.Requires('aHexString', Length(aHexString) = (fSize * 2));
    Hex2Bin.ToBin(aHexString, fAddress);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMemoryBuffer.Randomize: IMemoryBuffer;
  var
    i: Integer;
    intPtr: PInteger;
    bytePtr: PByte absolute intPtr;
    bytesLeft: Integer;
  begin
    intPtr := PInteger(fAddress);
    for i := 1 to (fSize div 4) do
    begin
      intPtr^ := Random(MaxInt);
      Inc(intPtr);
    end;

    bytesLeft := fSize mod 4;
    for i := 1 to bytesLeft do
    begin
      bytePtr^ := Byte(Random(255));
      Inc(bytePtr);
    end;

    result := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMemoryBuffer.Randomize(const aMin, aMax: Byte): IMemoryBuffer;
  var
    i: Integer;
    range: Integer;
    bytePtr: PByte;
  begin
    bytePtr := fAddress;
    range   := aMax - aMin + 1;

    for i := 1 to fSize do
    begin
      bytePtr^ := Byte(Random(range)) + aMin;
      Inc(bytePtr);
    end;

    result := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMemoryBuffer.Managed: IMemoryBuffer;
  begin
    fManaged  := TRUE;
    result    := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.ToHex(var aString: AnsiString);
  begin
    Hex2Bin.ToHex(fAddress, fSize, aString);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.ToHex(var aString: UnicodeString);
  begin
    Hex2Bin.ToHex(fAddress, fSize, aString);
  end;


{$ifdef UNICODE}
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.ToHex(var aString: Utf8String);
  begin
    Hex2Bin.ToHex(fAddress, fSize, aString);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.ToHex(var aString: WideString);
  begin
    Hex2Bin.ToHex(fAddress, fSize, aString);
  end;
{$endif}


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.ToHexUtf8(var aString: Utf8String);
  begin
    Hex2Bin.ToHexUtf8(fAddress, fSize, aString);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMemoryBuffer.Unmanaged: IMemoryBuffer;
  begin
    fManaged  := FALSE;
    result    := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMemoryBuffer.Zeroize;
  begin
    FillChar(fAddress^, fSize, 0);
  end;





end.
