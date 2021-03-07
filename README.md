# Deltics.Memory

A simple library for working with memory.

To allocate a block of memory, use the `Alloc` method of the `Memory` class:

```
   var
     ptr: Pointer;

   // Allocate 1Kb of memory
   Memory.Alloc(ptr, 1024);
```

