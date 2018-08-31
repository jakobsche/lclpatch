{
 /***************************************************************************
                                   media.pas
                                   ---------


 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus packages by Andreas Jakobsche

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit Media;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

procedure Play(FileName: string); overload;

implementation

uses FileUtil
  {$ifdef Windows}, Windows
  {$else}, Process
  {$endif};

{$ifdef windows}

procedure Play(FileName: string);
begin
  ShellExecute(0, nil, @FileName[1], nil, nil, 0)
end;

{$else}

procedure Play(FileName: string);
var
  Proc: TProcess;
begin
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindDefaultExecutablePath('play');
    Proc.Parameters.Add(FileName);
    Proc.Execute;
  finally
    Proc.Free
  end;
end;

{$endif}

end.

