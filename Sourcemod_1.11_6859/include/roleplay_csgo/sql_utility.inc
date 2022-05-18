methodmap RP_DB < DBResultSet 
{
	// Get field value by name
	public int FetchIntByName(char[] name)
	{
		int field;
		this.FieldNameToNum(name, field);
	
		return this.FetchInt(field);
	}
}

stock void SQL_Request(Database db, const char[] format, any ...)
{
	static char buffer[4096];
	VFormat(STRING(buffer), format, 3);
	#if DEBUG
		PrintToServer("[RP_SQL] %s", buffer);
	#endif	
	SQL_FastQuery(db, buffer);
}

stock void SQL_CheckForErrors(Database db, DBResultSet results, const char[] error, any data)
{
	if (!StrEqual(error, ""))
		ThrowError(error);
}

stock void SQL_OnSucces(Database db, any data, int numQuery, Handle[] results, any[] queryData)
{
	PrintToServer("[RP_SQL] Succes of sending %i query's", numQuery);
}	

stock void SQL_OnFailed(Database db, any data, int numQuery, const char[] error, int failIndex, any[] queryData)
{
    PrintToServer("[RP_SQL] Failed of sending %i query's\n %s", numQuery, error);
}