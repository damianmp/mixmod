#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include "mixmod.inc"

new bool:Swap = false;
new bool:ClientChoose[MAXPLAYERS + 1] =  { false, ... };
new Handle:g_CvarAutoMixEnabled = INVALID_HANDLE;

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
	
	if(IsMixmodStarted() != iMixmodStatus_isKo3Running){
		CloseHandle(menu);
	}
	
	if(action == MenuAction_Select){
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		new target = GetClientOfUserId(StringToInt(info));
		
		ClientChoose[target] = true;
		
		CS_SwitchTeam(target, GetClientTeam(param1));
		CS_RespawnPlayer(target);
		
		new loser = GetKnifeLoser();
		new winner = GetKnifeWinner();
		
		if(param1 == loser){
			FuncSelectSpecAuto(winner);
			PrintToChat(winner, "\x03[Mix] \x04Ahora elige el ganador de la ronda!");
		}
		else if(param1 == winner){
			FuncSelectSpecAuto(loser);
			PrintToChat(winner, "\x03[Mix] \x04Ahora elige el perdedor de la ronda!");
		}
	}
	else if(action == MenuAction_Cancel){
		if (param2 == MenuCancel_ExitBack)
		{
			CloseHandle(menu);
		}
	}
}

public OnClientDisconnect(client){
	ClientChoose[client] = false;
}

public OnPluginStart(){
	CreateTimer(0.1, timer_delay);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
	g_CvarAutoMixEnabled = FindConVar("sm_mixmod_auto_warmod_enable");
}

public OnMapStart(){
	Swap = false;
	for (new i = 0; i < MAXPLAYERS + 1; i++){
		ClientChoose[i] = false;
	}
}

public RoundStartMixmod(const String:CTName[], const String:TTName[], CTScore, TTScore, g_CurrentHalf, g_CurrentRound){
	if ((GetConVarInt(g_CvarAutoMixEnabled) == 1)){
		switch(IsMixmodStarted()){
			case iMixmodStatus_isKo3Running:{
				if(!Swap){
					for (new i = 1; i < MaxClients; i++){
						if (IsClientConnected(i)){
							ChangeClientTeam(i, CS_TEAM_SPECTATOR);
						}
					}
					Swap = true;
					
					ServerCommand("exec Match.cfg");
				}
			}
		}
	}
}

public Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast){
	if ((GetConVarInt(g_CvarAutoMixEnabled) == 1)){
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new new_team = GetEventInt(event, "team");
		new old_team = GetEventInt(event, "oldteam");
		switch(IsMixmodStarted()){
			case iMixmodStatus_isKo3Running:{
				if(new_team > CS_TEAM_SPECTATOR){
					/*PrintToServer("CountClientPerTeam(new_team, 1) (%s | %s)", (new_team == 2) ? "CT": (new_team == 3)?"TT":"SPEC"
																			, CountClientPerTeam(new_team, 1) ? "true":"false");*/
																			
					//PrintToServer("client: %N (%s)", client, (!ClientChoose[client])?"NO":"SI");
		
					if(CountClientPerTeam(new_team, 1) && !ClientChoose[client]){
						CreateTimer(0.1, Mover, client);
					}
				}
			}
			case iMixmodStatus_hasMixStarted:{
				if(old_team <= CS_TEAM_SPECTATOR){
					if(CountClientPerTeam(new_team, 5)){
						CreateTimer(0.1, Mover, client);
					}
				}
			}
		}
		dontBroadcast = false;
	}
}

public Action:Mover(Handle:timer, any:client){
	ChangeClientTeam(client, CS_TEAM_SPECTATOR);			
	PrintToChat(client, "\x03[Mix] Fuiste movido a spec");
}

bool:CountClientPerTeam(team, count_d){
	
	int total = 0;
	
	for (new i = 1; i < MaxClients; i++){
		if (IsClientConnected(i)){
			int auxt = GetClientTeam(i);
			
			if(auxt == team)
				total++;
				
			if(total == count_d)
				return true;
		}
	}
	
	return false;
}

public Action:timer_delay(Handle:timer, any:data){
	new Function:func = GetFunctionByName(null, "FuncSelectSpecAuto");
	AddMixmodKnifeOption("Auto-Pick Menu", func, true);
}