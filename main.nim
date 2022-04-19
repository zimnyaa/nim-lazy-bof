import winim
import std/dynlib
import system
import ptr_math

import memlib

# wstring -> string 
proc lpwstrc(bytes: array[MAX_PATH, WCHAR]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)


# BOF output callback
proc callback(data: cstring, status: int): int {.gcsafe, stdcall.} = 
  echo "[!] CALLBACK CALLED"
  echo data
  return

#  in-memory loading the COFFLoader dll
const coffloader = staticReadDll("COFFLoader.x64.dll")
proc loadcoff (data: LPVOID, length: int, callback: proc (data: cstring, status: int) : int {.stdcall, gcsafe.}) : int {.cdecl, memlib: coffloader, importc: "LoadAndRun".}

# constant entrypoint arg
var entrypoint_arg: array[11, byte] = [byte 0xff, 0xff, 0xff, 0xff, 0x03, 0x00, 0x00, 0x00, 0x67, 0x6f, 0x00] # len(c"go"), c"go"

# COFF arguments (empty)
var coff_arg: array[4, byte] = [byte 0x00, 0x00, 0x00, 0x00]



# COFF file
var coff_file = readFile("whoami.o")


echo "[+] Starting with ", GetLastError()
echo "[+] loadcoff address -> ", toHex(cast[int](loadcoff))



echo "[+] callback address -> ", toHex(cast[int](callback))
var loader_args = VirtualAlloc(nil, 4 + len(coff_file) + len(entrypoint_arg) + len(coff_arg), MEM_COMMIT, PAGE_READWRITE)

echo "[!] VirtualAlloc ", GetLastError(), " to ", toHex(cast[int](loader_args))
# "go" entrypoint
copyMem(loader_args, addr entrypoint_arg, len(entrypoint_arg))

# file size
var coffsize = len(coff_file)
copyMem(loader_args + len(entrypoint_arg), &coff_size, 4)

# file bytes
copyMem(loader_args + len(entrypoint_arg) + 4, &coff_file[0], len(coff_file))

# args
copyMem(loader_args + len(entrypoint_arg) + len(coff_file) + 4, addr coff_arg, len(coff_arg))

echo "[!] memory copied"
echo "[!] args will be: ( ", toHex(cast[int](loader_args)),", ", toHex(cast[int](len(coff_file)+len(entrypoint_arg)+len(coff_arg)+4)),", ", toHex(cast[int](callback)), " )"

discard loadcoff(loader_args, len(coff_file)+len(entrypoint_arg)+len(coff_arg)+4, callback)

