#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include "mixmod.inc"

//new globalwinteam;

public FuncSelectSpec(client){
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
		
		FuncSelectSpec(param1);
	}
	else if(action == MenuAction_Cancel){
		if (param2 == MenuCancel_ExitBack)
		{
			CloseHandle(menu);
		}
	}
}

public FuncSwapTeam(client){
	new Handle:switchteams = CreateMenu(Handle_TeamsVoteMenu);
	SetMenuTitle(switchteams, "Queres cambiar de lado?");
	AddMenuItem(switchteams, "1", "Si");
	AddMenuItem(switchteams, "0", "No");
	DisplayMenu(switchteams, client, 30);
}

public Handle_TeamsVoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Select)
	{
		decl String:opt[255];
		GetMenuItem(menu, param2, opt, sizeof(opt));
		new bool:aux = view_as<bool>(StringToInt(opt));
		
		if(aux){
			new team;
			for (new i=1; i<=MaxClients; i++)
			{
				if (IsClientInGame(i))
				{
					team = GetClientTeam(i);
					if (team == 2)
						ChangeClientTeam(i, 3);
					else if (team == 3)
						ChangeClientTeam(i, 2);
				}
			}
		}
	}
}

public OnPluginStart(){
	CreateTimer(0.1, timer_delay);
}

public Action:timer_delay(Handle:timer, any:data){
	new Function:func = GetFunctionByName(null, "FuncSelectSpec");
	new Function:func2 = GetFunctionByName(null, "FuncSwapTeam");
	AddMixmodKnifeOption("Seleccionar Spec", func);
	AddMixmodKnifeOption("Cambiar de lado", func2, true);
}

public RoundStartMixmod(const String:CTName[], const String:TTName[], CTScore, TTScore, g_CurrentHalf, g_CurrentRound){
	//PrintToServer("RoundStartMixmod IsMixmodStarted()=%i",IsMixmodStarted());
	switch(IsMixmodStarted()){
		case iMixmodStatus_isKo3Running:{
			//PrintToServer("Es ronda cuchi!");
		}
	}
}
/*
public RoundEndMixmod(win_team){
	if(IsMixmodStarted()>0){
		globalwinteam = win_team;
	}
}
*/
