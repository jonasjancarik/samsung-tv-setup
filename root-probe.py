import os
import sys,subprocess,asyncio,json,time,threading
from pathlib import Path
BASE=Path(__file__).resolve().parent
sys.path[:0]=[str(BASE/'transport'),str(BASE/'root-source/src')]
from install import Sdb
from samsung_tv_root.sdb import SdbClient
from samsung_tv_root import archive_root
class DirectSdbClient(SdbClient):
 def __init__(self,*args,**kwargs):
  super().__init__(*args,**kwargs)
  self._direct=None
  self._direct_lock=threading.RLock()
 def _connection(self):
  if self._direct is None:
   for attempt in range(3):
    try:self._direct=Sdb(self.tv_host);break
    except (ConnectionResetError,ConnectionError,OSError):
     if attempt==2:raise
     time.sleep(1)
  return self._direct
 def _stage_script(self,command):
  staged=super()._stage_script(command)
  if not staged.startswith('. '):raise RuntimeError('Unexpected upstream staging command')
  return 'cat '+staged[2:]+' | /bin/bash'
 def run(self,arguments,*,check,timeout=None):
  a=list(arguments)
  if a[:1]==['-s']:a=a[2:]
  op=a[0];out='';code=0
  if op=='devices':out=f'List of devices attached\n{self.serial}\tdevice\tSamsung TV\n'
  elif op=='connect':self._connection();out='direct transport'
  elif op=='disconnect':
   if self._direct is not None:self._direct.sock.close();self._direct=None
   out='disconnected'
  elif op in ('push','shell'):
   s=self._connection()
   s.sock.settimeout(max(timeout or self.timeout,180))
   try:
    if op=='push':s.push(a[2],Path(a[1]).read_bytes())
    else:
     try:out=s.shell(a[1],seconds=timeout or self.timeout)
     except ConnectionError:out='closed';code=1
   finally:pass
  else:raise RuntimeError('Unsupported direct SDB operation: '+op)
  result=subprocess.CompletedProcess(arguments,code,out,'')
  if check and code:raise RuntimeError(out)
  return result
archive_root.SdbClient=DirectSdbClient
archive_root.find_sdb=lambda:BASE/'.direct-sdb-transport'
async def main():
 result=await archive_root.probe(os.environ.get('TV_IP','10.0.0.150'),model='UE43CU7172UXXH',runtime='6.0',callback_host=os.environ.get('TV_CALLBACK_HOST','10.0.0.189'),bind_host='0.0.0.0',payloads=BASE/'payloads/common',commands=('id; uname -r',),accept_timeout=25)
 Path('work').mkdir(exist_ok=True)
 Path('work/root-probe-result.json').write_text(json.dumps(result,indent=2))
 print(json.dumps(result,indent=2))
if '--run' in sys.argv:asyncio.run(main())
elif __name__=='__main__':print('Probe adapter imports OK.')
