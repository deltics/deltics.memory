
{$i deltics.memory.inc}

  unit Deltics.Memory.Types;


interface

  type
  {$ifdef __DELPHIXE}
    {$ifdef WIN32}
      NativeUInt  = Cardinal;
      NativeInt   = Integer;
    {$else}
      NativeUInt  = UInt64;
      NativeInt   = Int64;
    {$endif}
  {$else}
    NativeUInt  = System.NativeUInt;
    NativeInt   = System.NativeInt;
  {$endif}

    IntPointer  = NativeUInt;
    PObject     = ^TObject;
    PUnknown    = ^IUnknown;

    TPointerArray = array of Pointer;
    PPointer      = ^Pointer;
    PPointerArray = array of PPointer;


    IMemoryBuffer = interface
    ['{A698FE97-DEC9-46A2-972C-87B43FBFD021}']
      function get_Address: Pointer;
      function get_AsHex: String;
      function get_Size: Integer;
      procedure set_AsHex(const aHexString: String);

      function AllocCopy(var aPointer): IMemoryBuffer;
      procedure CopyFrom(const aSourceAddress); overload;
      procedure CopyFrom(const aSourceAddress; const aMaxBytes: Integer); overload;
      procedure CopyTo(const aDestinationAddress); overload;
      procedure CopyTo(const aDestinationAddress; const aMaxBytes: Integer); overload;
      procedure Fill(const aValue: Byte);
      function Randomize: IMemoryBuffer; overload;
      function Randomize(const aMin, aMax: Byte): IMemoryBuffer; overload;
      function Managed: IMemoryBuffer;
      function Unmanaged: IMemoryBuffer;
      procedure Zeroize;

      property Address: Pointer read get_Address;
      property AsHex: String read get_AsHex write set_AsHex;
      property Size: Integer read get_Size;
    end;


implementation

end.
