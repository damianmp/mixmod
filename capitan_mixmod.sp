#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <adminmenu>
#include "mixmod.inc"

#define CS_MAX_TEAM 4

new ClientCap[CS_MAX_TEAM] ={0,...};
new Handle:menumain = INVALID_HANDLE;

public void OnPluginStart(){
	RegAdminCmd("sm_1v1", UnoVsUno, ADMFLAG_BAN);
	RegConsoleCmd("sm_pic", Pic);
}

public OnMapStart(){
	ClientCap = { 0, 0, 0, 0};
}

public Action:Pic(client, args){
	if(client == ClientCap[CS_TEAM_CT] || client == ClientCap[CS_TEAM_T]){
		new Handle:menu = CreateMenu(seleccionateam);
		SetMenuTitle(menu, "Seleccionar jugador:");
		SetMenuExitButton(menu, true);
		
		new inmunityClient = GetAdminImmunityLevel(GetUserAdmin(client));
		
		decl String:clientName[128], String:useridS[20];
		for (new i = 1; i <= MaxClients; i++){
			if(IsClientInGame(i) && (i != ClientCap[CS_TEAM_CT] && i != ClientCap[CS_TEAM_T] 
			&& GetAdminImmunityLevel(GetUserAdmin(i)) <= inmunityClient 
			&& GetClientTeam(client) != GetClientTeam(i))){
				GetClientName(i, clientName, sizeof(clientName));
				IntToString(GetClientUserId(i), useridS, sizeof(useridS));
				AddMenuItem(menu, useridS, clientName);
			}	
		}
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	else{
		PrintToChat(client, "[SM] No fuiste elegido como capitan!");
	}
	return Plugin_Handled;
}

public seleccionateam(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		new target = GetClientOfUserId(StringToInt(info));
		
		CS_SwitchTeam(target, GetClientTeam(param1));
		CS_RespawnPlayer(target);
		
		Pic(param1, 0)
	}
	else if(action == MenuAction_Cancel){
		if (param2 == MenuCancel_ExitBack)
		{
			CloseHandle(menu);
		}
	}
}

public Action:UnoVsUno(client, args){
	
	menumain = CreateMenu(capitanmenu);
	SetMenuTitle(menumain, "Seleccionar capitan:");
	SetMenuExitButton(menumain, true);
	AddMenuItem(menumain, "1", "Seleccionar un capitan CT");
	AddMenuItem(menumain, "2", "Seleccionar un capitan TT");
	DisplayMenu(menumain, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public capitanmenu(Handle:menu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		new String:info[20];
		GetMenuItem(menu, param2, info, sizeof(info));
		new opt = StringToInt(info);
		
		new Handle:menus = CreateMenu(seleccion);
		SetMenuTitle(menus, "Seleccionar capitan:");
		for (new i = 1; i <= MaxClients; i++){
			decl String:nombre[50];
			decl String:userid[20];
			if((opt == 1 && IsClientInGame(i)) && GetClientTeam(i) == CS_TEAM_CT){
				Format(userid, sizeof(userid),"%i",GetClientUserId(i));
				GetClientName(i, nombre, sizeof(nombre));
				Format(nombre, sizeof(nombre), "%s%s", nombre, i == ClientCap[CS_TEAM_CT] ? "(c)":"");
				AddMenuItem(menus, userid, nombre);
			}
			else if((opt == 2 && IsClientInGame(i)) && GetClientTeam(i) == CS_TEAM_T){
				Format(userid, sizeof(userid), "%i", GetClientUserId(i));
				GetClientName(i, nombre, sizeof(nombre));
				Format(nombre, sizeof(nombre), "%s%s", nombre, i == ClientCap[CS_TEAM_T] ? "(c)":"");
				AddMenuItem(menus, userid, nombre);
			}
		}
		SetMenuExitBackButton(menus, true);
		DisplayMenu(menus, param1, MENU_TIME_FOREVER);
	}
}

public seleccion(Handle:menu, MenuAction:action, param1, param2){
	if (action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		new target = GetClientOfUserId(StringToInt(info));
		
		if(target == ClientCap[CS_TEAM_CT] || target == ClientCap[CS_TEAM_T]){
			PrintToChat(param1, "[SM] %N fue eliminado como capitan %s!", target, GetClientTeam(target) == CS_TEAM_T ? "TT":"CT");
			ClientCap[GetClientTeam(target)] = 0;
		}
		else{
			PrintToChat(param1, "[SM] %N fue seleccionado como capitan %s!", target, GetClientTeam(target) == CS_TEAM_T ? "TT":"CT");
			ClientCap[GetClientTeam(target)] = target;
		}
		
		DisplayMenu(menumain, param1, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel){
		if (param2 == MenuCancel_ExitBack && menumain)
		{
			DisplayMenu(menumain, param1, MENU_TIME_FOREVER);
		}
	}
}
	