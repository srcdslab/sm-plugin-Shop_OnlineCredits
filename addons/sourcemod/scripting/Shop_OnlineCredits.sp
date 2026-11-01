#include <sourcemod>
#include <shop>

#pragma newdecls required

#define PLUGIN_VERSION "1.5.1"

bool canUseGold;

public Plugin myinfo = 
{
	name = "[Shop] Online Credits",
	description = "Show online players credits",
	author = "White Wolf (HLModders LLC)",
	version = PLUGIN_VERSION,
	url = "http://hlmod.ru"
};

public void OnPluginStart()
{
	LoadTranslations("Shop_OnlineCredits.phrases");

	if (Shop_IsStarted()) Shop_Started();
	
	canUseGold = (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "Shop_GetClientGold") == FeatureStatus_Available);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("Shop_GetClientGold");
	return APLRes_Success;
}

public void Shop_Started()
{
	Shop_AddToFunctionsMenu(OnFuncDisplay, OnFuncSelect);
}

public void OnPluginEnd()
{
	Shop_RemoveFromFunctionsMenu(OnFuncDisplay, OnFuncSelect);
}

public int OnFuncDisplay(int client, char[] buffer, int maxlength)
{
	FormatEx(buffer, maxlength, "%T", "Online Credits Function", client);
}

public bool OnFuncSelect(int client)
{
	Menu PlayerList = new Menu(PlayerList_Handler);
	PlayerList.SetTitle("%T", "Online Credits Title", client);
	int credits, gold;
	char buffer[PLATFORM_MAX_PATH];
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && Shop_IsAuthorized(i))
		{
			credits = Shop_GetClientCredits(i);
			if (canUseGold)
			{
				gold = Shop_GetClientGold(i);
				FormatEx(buffer, sizeof(buffer), "%T", "Online Credits Item Gold", client, i, credits, gold);
			}
			else
				FormatEx(buffer, sizeof(buffer), "%T", "Online Credits Item", client, i, credits);
			PlayerList.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
		}
	}
	PlayerList.Display(client, MENU_TIME_FOREVER);
	return true;
}

public int PlayerList_Handler(Menu menu, MenuAction action, int client, int slot)
{
	switch (action)
	{
		case MenuAction_Cancel:
		{
			if (client > 0 && IsClientInGame(client) && !IsFakeClient(client) && Shop_IsAuthorized(client))
				Shop_ShowFunctionsMenu(client);
		}
		case MenuAction_End: menu.Close();
	}
}