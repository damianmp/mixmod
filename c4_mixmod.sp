#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>

int entidad;

public OnPluginStart()
{
	HookEvent("bomb_dropped", Event_BombDropped);
	HookEvent("bomb_pickup", Event_BombPick);
}

public OnMapStart(){
	PrecacheModel("materials/sprites/bomb_dropped.vmt");
}

public Event_BombDropped(Handle event, const char[] name, bool dontBroadcast){
	AcceptEntityInput(entidad, "Kill");
	
	new c4 = -1;
	while((c4 = FindEntityByClassname(c4, "weapon_c4"))!=-1){
		new String:szTemp[64];
		new Float:vOrigin[3];
		decl String:szBuffer[128];
		GetEntPropVector(c4, Prop_Data, "m_vecAbsOrigin", vOrigin);
		//vOrigin[2] += 80.0;
		
		PrintToServer("%f %f %f", vOrigin[0], vOrigin[1], vOrigin[2]);
		GetEntPropString(c4, Prop_Data, "m_iName", szTemp, sizeof(szTemp));
		FormatEx(szBuffer, 128, "materials/sprites/bomb_dropped.vmt");
		
		CreateSprite(c4, szBuffer, szTemp, vOrigin);
		
	}
	PrintToServer("Event_BombDropped");
}

public Event_BombPick(Handle event, const char[] name, bool dontBroadcast){
	PrintToServer("Event_BombPick");
	
	if(entidad > 0 && IsValidEntity(entidad))
		AcceptEntityInput(entidad, "Kill");
	
	decl String:szBuffer[128];
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	FormatEx(szBuffer, 128, "materials/sprites/bomb_dropped.vmt");
	
	new String:szTemp[64];
	Format(szTemp, 64, "client%i", iClient);
	DispatchKeyValue(iClient, "targetname", szTemp);
	new Float:vOrigin[3];
	GetClientAbsOrigin(iClient, vOrigin);
	vOrigin[2] += 80.0;
	
	CreateSprite(iClient, szBuffer, szTemp, vOrigin);
}

public CreateSprite(iClient, String:sprite[], String:szTemp[], Float:vOrigin[3])
{
	new ent = CreateEntityByName("env_sprite");
	if (IsValidEntity(ent))
	{
		DispatchKeyValue(ent, "model", sprite);
		DispatchKeyValue(ent, "classname", "env_sprite");
		DispatchKeyValue(ent, "parentname", szTemp);
		if(iClient > MaxClients+1){	
			DispatchKeyValue(ent, "scale", "1.0");
		}
		DispatchSpawn(ent);
		
		TeleportEntity(ent, vOrigin, NULL_VECTOR, NULL_VECTOR);
		SetVariantString("!activator");
		
		AcceptEntityInput(ent, "SetParent", iClient);
		
		entidad = ent;
		
		SDKHook(ent, SDKHook_SetTransmit, OnTrasnmit);
	}
}

public Action OnTrasnmit(int entity, int client)
{
	if (GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	else{	
		return Plugin_Handled;
	}
}