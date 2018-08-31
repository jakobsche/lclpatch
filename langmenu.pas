unit LangMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Menus;

type
  TLanguageMenu = class(TComponent)
  private
    FDefaultPoFile: string;
    FLangMenuItem: TMenuItem;
    FLocaleDir: string;
  protected

  public

  published
    property DefaultPoFile: string read FDefaultPoFile write FDefaultPoFile;
    property LangMenuItem: TMenuItem read FLangMenuItem write FLangMenuItem;
    property LocaleDir: string read FLocaleDir write FLocaleDir;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard',[TLanguageMenu]);
end;

end.
