@echo off

PATH C:\masm32\bin
ml /c /Cx /Zf /Zi /Fl /coff stars.asm
ml /c /Cx /Zf /Zi /Fl /coff blit.asm
ml /c /Cx /Zf /Zi /Fl /coff rotate.asm
ml /c /Cx /Zf /Zi /Fl /coff trig.asm
ml /c /Cx /Zf /Zi /Fl /coff logic.asm
ml /c /Cx /Zf /Zi /Fl /coff render.asm
ml /c /Cx /Zf /Zi /Fl /coff game.asm

@echo on
link  /subsystem:windows stars.obj blit.obj rotate.obj trig.obj logic.obj render.obj game.obj libgame.obj /out:game.exe /debug
link  /subsystem:windows stars.obj blit.obj rotate.obj trig.obj logic.obj render.obj game.obj libgamewin.obj /out:gamewin.exe /debug
