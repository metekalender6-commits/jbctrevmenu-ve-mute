#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#define GOD_DURATION 3.0
#define REVIVE_SOUND "friends/friend_online.wav" // CS2'de calismazsa kendi sunucundaki gecerli bir sound path ile degistir

ConVar g_hCvarMaxRev;
int g_iCTRevLeft;
float g_flGodUntil[MAXPLAYERS + 1];

public Plugin myinfo =
{
    name        = "JB Mute + CT Revive",
    author      = "sen",
    description = "T sesini otomatik susturur, CT icin paylasimli revive (canlandirma) sistemi + gecici god mode",
    version     = "1.1",
    url         = ""
};

public void OnPluginStart()
{
    g_hCvarMaxRev = CreateConVar("sm_ctrev_max", "3", "CT takiminin round basina toplam revive hakki");

    RegAdminCmd("sm_mute",   Cmd_Mute,       ADMFLAG_GENERIC, "!mute <hedef> - Hedefin sesini kapatir");
    RegAdminCmd("sm_unmute", Cmd_Unmute,     ADMFLAG_GENERIC, "!unmute <hedef> - Hedefin sesini acar");
    RegAdminCmd("sm_ctrev0", Cmd_CTRevReset, ADMFLAG_GENERIC, "!ctrev0 - CT revive hakkini sifirlar");

    HookEvent("round_start",  Event_RoundStart);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_team",  Event_PlayerTeam);

    PrecacheSound(REVIVE_SOUND);
}

public void OnMapStart()
{
    PrecacheSound(REVIVE_SOUND);
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
    g_flGodUntil[client] = 0.0;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_iCTRevLeft = g_hCvarMaxRev.IntValue;

    for (int i = 1; i <= MaxClients; i++)
    {
        g_flGodUntil[i] = 0.0;

        if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T)
            MuteVoice(i);
    }
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client && IsClientInGame(client) && GetClientTeam(client) == CS_TEAM_T)
        MuteVoice(client);
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!client || !IsClientInGame(client))
        return;

    if (event.GetInt("team") == CS_TEAM_T)
        MuteVoice(client);
    else
        UnmuteVoice(client);
}

void MuteVoice(int target)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
            SetListenOverride(i, target, Listen_No);
    }
}

void UnmuteVoice(int target)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
            SetListenOverride(i, target, Listen_Default);
    }
}

public Action Cmd_Mute(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "Kullanim: !mute <hedef>");
        return Plugin_Handled;
    }

    char arg[64];
    GetCmdArg(1, arg, sizeof(arg));

    int target = FindTarget(client, arg, false, true);
    if (target == -1)
        return Plugin_Handled;

    MuteVoice(target);

    char targetName[MAX_NAME_LENGTH];
    GetClientName(target, targetName, sizeof(targetName));
    PrintToChatAll("[SM] %N, %s adli oyuncunun sesini kapatti.", client, targetName);

    return Plugin_Handled;
}

public Action Cmd_Unmute(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "Kullanim: !unmute <hedef>");
        return Plugin_Handled;
    }

    char arg[64];
    GetCmdArg(1, arg, sizeof(arg));

    int target = FindTarget(client, arg, false, true);
    if (target == -1)
        return Plugin_Handled;

    UnmuteVoice(target);

    char targetName[MAX_NAME_LENGTH];
    GetClientName(target, targetName, sizeof(targetName));
    PrintToChatAll("[SM] %N, %s adli oyuncunun sesini acti.", client, targetName);

    return Plugin_Handled;
}

public Action Cmd_CTRevReset(int client, int args)
{
    g_iCTRevLeft = 0;
    PrintToChatAll("[SM] %N CT revive hakkini sifirladi. Bu round icin revive kalmadi.", client);
    return Plugin_Handled;
}

public Action Hook_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!IsClientInGame(victim) || !IsPlayerAlive(victim))
        return Plugin_Continue;

    // Gecici god mode: revive sonrasi belirlenen sure boyunca tum hasari engelle
    if (g_flGodUntil[victim] > GetGameTime())
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    if (GetClientTeam(victim) != CS_TEAM_CT)
        return Plugin_Continue;

    if (g_iCTRevLeft <= 0)
        return Plugin_Continue;

    float health = float(GetClientHealth(victim));
    if (damage < health)
        return Plugin_Continue; // olumcul degil, karisma

    g_iCTRevLeft--;
    SetEntityHealth(victim, 100);
    damage = 0.0;

    g_flGodUntil[victim] = GetGameTime() + GOD_DURATION;

    EmitSoundToAll(REVIVE_SOUND);
    PrintToChatAll("[SM] CT revlenmistir! Kalan hak: %d (3 saniye dokunulmazlik)", g_iCTRevLeft);

    return Plugin_Changed;
}
