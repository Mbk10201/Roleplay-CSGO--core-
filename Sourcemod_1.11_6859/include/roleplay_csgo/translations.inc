stock void Translation_PrintNoAccess(int client)
{
	if(IsClientValid(client))
		rp_PrintToChat(client, "%T", "NoAccessCommand", LANG_SERVER);
}

stock void Translation_PrintTooFar(int client)
{
	if(IsClientValid(client))
		rp_PrintToChat(client, "%T", "InvalidDistance", LANG_SERVER);
}

stock void Translation_PrintInvalidTarget(int client)
{
	if(IsClientValid(client))
		rp_PrintToChat(client, "%T", "InvalidTarget", LANG_SERVER);
}

stock void Translation_PrintNoAccessInJail(int client)
{
	rp_PrintToChat(client, "%T", "NoAccessDueJail", LANG_SERVER);
}

stock void Translation_PrintNoAvailable()
{
	PrintToServer("%T", "Command_NotAvailable", LANG_SERVER);
}

stock void Translation_DebugCommand(int client)
{
	char sTmp[64];
	GetCmdArg(0, STRING(sTmp));
	PrintToServer("[%N]Command: %s", client, sTmp);
}