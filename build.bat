
dmd -v -m64 -shared -ofhook.dll hookdll.d dllmain.d -Luser32.lib -Lgdi32.lib
 -debug -g -inline -L/OPT:REF
 -release -O -g -inline -L/OPT:REF -L/OPT:ICF

dmd -v -m64 main.d -Lhook.lib

