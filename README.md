# nim-lazy-bof
 Nim port of sliver's BOF loading approach. Embeds the COFFLoader dll, loads it with `memlib`, builds the argument bytearray and defines a callback, and fires `LoadAndRun` (coourtesy to the team behind `sliver`).

 This PoC loads and runs `whoami.o` from `Situational-Awareness-BOF` collection without any arguments.

# build
```
nimble install winim memlib ptr_math
nim c main.c
```

# credits
khchen (memlib/winim), trustedsec (COFFLoader/SA-BOF), sliver(LoadAndRun)