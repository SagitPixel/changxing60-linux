import sys,struct,subprocess,importlib.util,zlib
from pathlib import Path
p=Path("/work/baseline/codex-handoff-20261027")
spec=importlib.util.spec_from_file_location("repack","/work/boot/repack-ramdisk.py"); m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
b=(p/"boot-b-before.img").read_bytes();k,r=struct.unpack_from("<II",b,8);o=4096+(k+4095)//4096*4096
e,_=m.read_cpio(subprocess.run(["lz4","-d","-c"],input=b[o:o+r],capture_output=True,check=True).stdout)
for n,mo,ino,rv,d in e:
 if n in ["etc/misc-bc-slot-a.bin","etc/misc-bc-slot-b-trial.bin"]:
  print(n,d.hex(),[(x&15,(x>>4)&7,x>>7)for x in(d[12],d[14])]);assert zlib.crc32(d[:28])==struct.unpack_from("<I",d,28)[0];(p/Path(n).name).write_bytes(d)
