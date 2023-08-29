#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include "mixmod.inc"

public FuncSelectSpecAuto(client){
	new Handle:menu = CreateMenu(seleccionateam);
	SetMenuTitle(menu, "Seleccionar jugador:");
	SetMenuExitButton(menu, true);
	
	new inmunityClient = GetAdminImmunityLevel(GetUserAdmin(client));
	
	decl String:clientName[128], String:useridS[20];
	for (new i = 1; i <= MaxClients; i++){
		if(IsClientInGame(i) 
		&& GetAdminImmunityLevel(GetUserAdmin(i)) <= inmunityClient 
		&& GetClientTeam(i) == CS_TEAM_SPECTATOR){
			GetClientName(i, clientName, sizeof(clientName));
			IntToString(GetClientUserId(i), useridS, sizeof(useridS));
			AddMenuItem(menu, useridS, clientName);
		}	
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public seleccionateam(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		new target = GetClientOfUserId(StringToInt(info));
		
		CS_SwitchTeam(target, GetClientTeam(param1));
		CS_RespawnPlayer(target);
		
		new loser = GetKnifeLoser();
		new winner = GetKnifeWinner();
		
		if(param1 == loser){
			FuncSelectSpecAuto(winner);
		}
		else if(param1 == winner){
			FuncSelectSpecAuto(loser);
		}
	}
	else if(action == MenuAction_Cancel){
		if (param2 == MenuCancel_ExitBack)
		{
			CloseHandle(menu);
		}
	}
}

public OnPluginStart(){
	CreateTimer(0.1, timer_delay);
}

public Action:timer_delay(Handle:timer, any:data){
	new Function:func = GetFunctionByName(null, "FuncSelectSpecAuto");
	AddMixmodKnifeOption("Auto-Pick Menu", func, true);
}