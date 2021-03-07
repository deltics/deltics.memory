
{$define CONSOLE}

{$i deltics.inc}

  program test;

uses
  Deltics.Smoketest,
  Deltics.Memory in '..\src\Deltics.Memory.pas',
  Deltics.Memory.Buffer in '..\src\Deltics.Memory.Buffer.pas',
  Deltics.Memory.Class_ in '..\src\Deltics.Memory.Class_.pas',
  Deltics.Memory.Types in '..\src\Deltics.Memory.Types.pas',
  Test.PointerSize in 'Test.PointerSize.pas',
  Test.Memory.Copy in 'Test.Memory.Copy.pas',
  Test.Memory.Randomize in 'Test.Memory.Randomize.pas',
  Test.Memory.AllocCopy in 'Test.Memory.AllocCopy.pas',
  Test.Memory.AllocZeroed in 'Test.Memory.AllocZeroed.pas',
  Test.Memory.Offset in 'Test.Memory.Offset.pas';

begin
  TestRun.Test(PointerSize);
  TestRun.Test(MemoryRandomize);
  TestRun.Test(MemoryCopy);
  TestRun.Test(MemoryAllocCopy);
  TestRun.Test(MemoryAllocZeroed);
  TestRun.Test(MemoryOffset);
end.
