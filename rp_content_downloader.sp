/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu - benitalpa1020@gmail.com
*/

/***************************************************************************************

							P L U G I N  -  D E F I N E S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

#include <roleplay_csgo.inc>

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - Downloader", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

char ValidFormats[][] = //VALID, DOWNLOADABLE FILE FORMATS
{
	"mdl", "phy", "vtx", "vvd", //Model files
	"vmt", "vtf", "png", "svg", //Texture and material files
	"mp3", "wav", "pcf" //Sound files
};

public void OnPluginStart()
{
}

public void OnMapStart()
{
	AddFolderToDownloadsTable("materials");
	AddFolderToDownloadsTable("models");
	AddFolderToDownloadsTable("sound");
	AddFolderToDownloadsTable("particles");	
}

//-----STOCKS-----//
void AddFolderToDownloadsTable(char[] Folder)
{
	if(DirExists(Folder))
	{
		Handle DIR = OpenDirectory(Folder);
		char BUFFER[PLATFORM_MAX_PATH];
		FileType FILETYPE = FileType_Unknown;
		
		while(ReadDirEntry(DIR, STRING(BUFFER), FILETYPE))
		{
			if(!StrEqual(BUFFER, "") && !StrEqual(BUFFER, ".") && !StrEqual(BUFFER, ".."))
			{
				Format(STRING(BUFFER), "%s/%s", Folder, BUFFER);
				if(FILETYPE == FileType_File)
				{
					if(FileExists(BUFFER, true) && IsFileDownloadable(BUFFER))
					{
						AddFileToDownloadsTable(BUFFER);
					}
				}
				else if(FILETYPE == FileType_Directory)
				{
					AddFolderToDownloadsTable(BUFFER);
				}
			}
		}
		CloseHandle(DIR);
	}
	else
	{
		LogError("Automatic Downloader: Directory not exists - \"%s\"", Folder);
	}
}

bool IsFileDownloadable(char[] string)
{
	char buffer[PLATFORM_MAX_PATH];
	GetFileExtension(string, STRING(buffer));
	for(int i = 0; i < sizeof(ValidFormats); i++)
	{
		if(StrEqual(buffer, ValidFormats[i], false))
		{
			return true;
		}
	}
	return false;
}

bool GetFileExtension(const char[] filepath, char[] filetype, int filetypelen)
{
    int loc = FindCharInString(filepath, '.', true);
    if(loc == -1)
    {
        filetype[0] = '\0';
        return false;
    }
    strcopy(filetype, filetypelen, filepath[loc + 1]);
    return true;
}