/*
*   Roleplay CS:GO de Benito est mis à disposition selon les termes de la licence Creative Commons Attribution .
* - Pas d’Utilisation Commerciale 
* - Partage dans les Mêmes Conditions 4.0 International.
*
*   Fondé(e) sur une œuvre à https://github.com/Mbk10201/Roleplay-CS-GO
*   Les autorisations au-delà du champ de cette licence peuvent être obtenues à https://steamcommunity.com/id/xsuprax/.
*
*   Merci de respecter le travail fourni par le ou les auteurs 
*   https://enemy-down.eu - benitalpa1020@gmail.com
*/

/***************************************************************************************

							C O M P I L E  -  O P T I O N S

***************************************************************************************/
#pragma semicolon 1
#pragma newdecls required

/***************************************************************************************

										H E A D E R

***************************************************************************************/
#include <roleplay_csgo.inc>

/***************************************************************************************

							G L O B A L  -  V A R S

***************************************************************************************/

enum WORKSTATUS {
	AVAILABLE,
	NOAVAILABLE
};

enum struct BenchData {
	WORKSTATUS status;
	int item;
	int clientusing;
	int job;
	float percentage;
	Handle CraftHandle;
}
BenchData iBench[MAXENTITIES + 1];

int
	iBenchInUse[MAXPLAYERS + 1] = {-1, ...};

/***************************************************************************************

							P L U G I N  -  I N F O

***************************************************************************************/
public Plugin myinfo = 
{
	name = "Roleplay - [MODULE]CraftSystem", 
	author = "MBK", 
	description = "", 
	version = "1.0", 
	url = "https://github.com/Mbk10201"
};

/***************************************************************************************

									 F U N C T I O N S

***************************************************************************************/

public void OnPluginStart()
{
	LoadTranslation();
}

/***************************************************************************************

									C L I E N T - S I D E

***************************************************************************************/
public void OnClientPutInServer(int client)
{
}	

/***************************************************************************************

									C A L L B A C K

***************************************************************************************/

public void RP_OnClientBuild(Menu menu, int client)
{
	menu.AddItem("workbench", "Table de craft");
}

public void RP_OnClientBuildHandle(int client, const char[] info)
{
	if(StrEqual(info, "workbench"))
	{
		float position[3];
		GetClientAbsOrigin(client, position);
		
		char sModel[128];
		rp_GetGlobalData("model_workbench", STRING(sModel));
		
		rp_CreatePhysics("", position, NULL_VECTOR, sModel);
	}
}

public void RP_OnClientInteract(int client, int target, const char[] class, const char[] model, const char[] name)
{
	if(rp_IsValidWorkBench(target) && Distance(client, target) <= 80.0)
	{
		if(rp_GetClientInt(client, i_Job) != 0)
		{
			if(iBench[target].status == NOAVAILABLE)
				rp_PrintToChat(client, "La table est déjà en cours d'utilisation, veuillez patienter{green}...");
			else
			{
				SetEntProp(target, Prop_Send, "m_nSkin", 1);
				iBench[target].clientusing = client;
				iBenchInUse[client] = target;
				MenuWorkBench(client);
			}
		}
	}
}

void MenuWorkBench(int client)
{
	rp_SetClientBool(client, b_DisplayHud, false);
	
	Menu menu = new Menu(Handle_MenuWorkBench);
	menu.SetTitle("Table de craft");
	
	char sTmp[32], sJob[8], sName[64], sIndex[8];
	
	LoopItems(i)
	{
		if(!rp_IsItemValidIndex(i))
			continue;
			
		rp_GetItemData(i, item_jobid, STRING(sJob));
		
		if(StringToInt(sJob) == rp_GetClientInt(client, i_Job))
		{
			rp_GetItemData(i, item_farmtime, STRING(sTmp));
			
			IntToString(i, STRING(sIndex));
			rp_GetItemData(i, item_name, STRING(sName));
			menu.AddItem(sIndex, sName, (StringToFloat(sTmp) == 0.0) ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		}
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_MenuWorkBench(Menu menu, MenuAction action, int client, int param)
{	
	if(action == MenuAction_Select)
	{
		char info[8];
		menu.GetItem(param, STRING(info));
		
		int item = StringToInt(info);
		
		char sValue[64];
		
		/*rp_GetItemData(item, item_maxgold, STRING(sValue));
		PrintToServer("item_maxgold: %s", sValue);
		if(rp_GetClientResource(client, resource_gold) < StringToInt(sValue))
		{
			rp_PrintToChat(client, "Resources insuffisantes, requis {orange}%s OR{default}.", sValue);
			return -1;
		}
			
		rp_GetItemData(item, item_maxsteel, STRING(sValue));
		if(rp_GetClientResource(client, resource_steel) < StringToInt(sValue))
		{
			rp_PrintToChat(client, "Resources insuffisantes, requis {orange}%s Acier{default}.", sValue);
			return -1;
		}
			
		rp_GetItemData(item, item_maxcopper, STRING(sValue));
		if(rp_GetClientResource(client, resource_copper) < StringToInt(sValue))
		{
			rp_PrintToChat(client, "Resources insuffisantes, requis {orange}%s Cuivre{default}.", sValue);
			return -1;
		}
			
		rp_GetItemData(item, item_maxaluminium, STRING(sValue));
		if(rp_GetClientResource(client, resource_aluminium) < StringToInt(sValue))
		{
			rp_PrintToChat(client, "Resources insuffisantes, requis {orange}%s Aluminium{default}.", sValue);
			return -1;
		}
			
		rp_GetItemData(item, item_maxzinc, STRING(sValue));
		if(rp_GetClientResource(client, resource_zinc) < StringToInt(sValue))
		{
			rp_PrintToChat(client, "Resources insuffisantes, requis {orange}%s Zinc{default}.", sValue);
			return -1;
		}
			
		rp_GetItemData(item, item_maxwood, STRING(sValue));
		if(rp_GetClientResource(client, resource_wood) < StringToInt(sValue))
		{
			rp_PrintToChat(client, "Resources insuffisantes, requis {orange}%s Bois{default}.", sValue);
			return -1;
		}
			
		rp_GetItemData(item, item_maxplastic, STRING(sValue));
		if(rp_GetClientResource(client, resource_plastic) < StringToInt(sValue))
		{
			rp_PrintToChat(client, "Resources insuffisantes, requis {orange}%s Plastique{default}.", sValue);
			return -1;
		}
			
		rp_GetItemData(item, item_maxwater, STRING(sValue));
		if(rp_GetClientResource(client, resource_water) < StringToInt(sValue))
		{
			rp_PrintToChat(client, "Resources insuffisantes, requis {orange}%s Eau{default}.", sValue);
			return -1;
		}*/
		
		iBench[iBenchInUse[client]].item = item;
		iBench[iBenchInUse[client]].status = NOAVAILABLE;
		iBench[iBenchInUse[client]].percentage = 0.0;
		
		rp_GetItemData(item, item_name, STRING(sValue));
		rp_PrintToChat(client, "Vous avez commencer a craft: {green}%s{default}.", sValue);
		
		rp_GetItemData(item, item_farmtime, STRING(sValue));
		iBench[iBenchInUse[client]].CraftHandle = CreateTimer(StringToFloat(sValue), Timer_CraftItem, iBenchInUse[client], TIMER_REPEAT);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param == MenuCancel_Exit || param == MenuCancel_ExitBack)
			rp_SetClientBool(client, b_DisplayHud, true);
	}
	else if(action == MenuAction_End)
	{
		SetEntProp(iBenchInUse[client], Prop_Send, "m_nSkin", 0);
		delete menu;
	}
		
	return -1;
}

public Action Timer_CraftItem(Handle timer, int bench)
{
	if(iBench[bench].percentage < 100.0)
	{
		iBench[bench].percentage += 5.0;
		
		float fPos[3];
		char sParticle[32];
		int iRandom = GetRandomInt(0, 9);
		
		Entity_GetAbsOrigin(bench, fPos);
		
		switch(iRandom)
		{
			case 0:Format(STRING(sParticle), "smoke");
			case 1,2,3,4,5,6,7,8,9:Format(STRING(sParticle), "smoke%i", iRandom);
		}
		
		UTIL_CreateParticle(bench, fPos, _, "", sParticle, 1.0);
		
		char sSound[64];
		Format(STRING(sSound), "sound_craft0%i", GetRandomInt(1, 7));
		rp_SoundAll(bench, sSound, 0.8);
	}
	else
	{
		char sName[64];
		rp_GetItemData(iBench[bench].item, item_name, STRING(sName));
		
		if(IsClientValid(iBench[bench].clientusing))
			rp_PrintToChat(iBench[bench].clientusing, "Vous avez craft: {green}1 %s{default}.", sName);
			
		rp_SetItemStock(iBench[bench].item, rp_GetItemStock(iBench[bench].item) + 1);
		
		iBench[bench].status = AVAILABLE;
		iBench[bench].item = -1;
		iBench[bench].percentage = 0.0;
		iBench[bench].clientusing = -1;
		SetEntProp(bench, Prop_Send, "m_nSkin", 0);
		SetBodyGroup(bench, GetEntityStudioHdr(bench).FindBodyPart("box"), 1);
		TrashTimer(iBench[bench].CraftHandle, true);
	}
	
	return Plugin_Handled;
}

public void RP_OnLookAtTarget(int client, int target, char[] model)
{
	if(!IsValidEntity(target))
		return;
	
	if(rp_IsValidWorkBench(target))
	{
		char sJob[64];
		rp_GetJobName(iBench[target].job, STRING(sJob));
		
		if(iBench[target].status == AVAILABLE)
			PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝙏𝙖𝙗𝙡𝙚 𝙙𝙚 𝙘𝙧𝙖𝙛𝙩</font><font color='%s'>★</font>\n<font color='%s'>%s</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_CHARTREUSE, sJob);
		else
		{
			char sName[64];
			rp_GetItemData(iBench[target].item, item_name, STRING(sName));
			
			PrintHintText(client, "<font color='%s'>★</font><font color='%s'>𝙏𝙖𝙗𝙡𝙚 𝙙𝙚 𝙘𝙧𝙖𝙛𝙩</font><font color='%s'>★</font>\n<font color='%s'>%s</font>\n<font color='%s'>%s</font> <font color='%s'>%0.1f％</font>", HTML_CRIMSON, HTML_FLUOYELLOW, HTML_CRIMSON, HTML_CHARTREUSE, sJob, "#E85D8B", sName, HTML_BLUE, iBench[target].percentage);
		}
	}	
}