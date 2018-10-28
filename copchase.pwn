#include <a_samp>
#include <ZCMD>
#include <a_players>
#include <a_vehicles>
#include <a_mysql>
#include <sscanf>

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

#if defined MAX_PLAYERS
#undef MAX_PLAYERS
#endif

#define MAX_PLAYERS 320
#define MAX_PLOBBY 2
#define MAX_LOBBY 30

#define LOBBY_NOT_CREATED 0
#define LOBBY_CREATED 1
#define LOBBY_WAITING 2
#define LOBBY_PLAYING 3

#define COLOR_RED 0xFF000000
#define COLOR_YELLOW 0xee00ee00

new MySQL:sql;

enum PI
{
	Lb,
	Money,
	Donate,
	ID,
	Login,
	Admin,
	Skin,
	Vehicle,
	Matches, 
	Leaves,
	wins,
	PWins,
	Kills,
	Losses,
	Deaths,
	Mute,
	Warn,
	Score,
}

enum LI
{
	Map,
	Suspect,
	Players,
	Activate,
	Timer,
	TextDraws,
}

new PlayerInfo[MAX_PLAYERS][PI];
new LobbyInfo[MAX_LOBBY][LI];
new LobbyName[MAX_LOBBY][MAX_PLOBBY][MAX_PLAYER_NAME];
new LobbyID[MAX_LOBBY][MAX_PLOBBY];
new Priority;
new PlayerText:MenuTD[MAX_PLAYERS][5];
new PlayerText:PoliceUI[MAX_PLAYERS][9];
new PlayerText:RangeUI[MAX_PLAYERS][9];
new PlayerText:TimerUI[MAX_PLAYERS];
new PlayerText:LeftUI[MAX_PLAYERS];
new PlayerText:LeftUP[MAX_PLAYERS];
new PlayerText:SusUI[MAX_PLAYERS];
new PlayerText:NSusUI[MAX_PLAYERS];
new HeartBit;
new BestBit;
new PlayerVehicle[MAX_PLAYERS];
new TimeInLobby = 10;
new TimeInGame = 40;

public OnGameModeInit()
{
	sql = mysql_connect("db2.myarena.ru", "anayks_anayks", "RicardoMilos", "anayks_Akakiy");
	SetGameModeText("Copchase Beta Test");
	EnableStuntBonusForAll(false);
	AddPlayerClass(36,0.0,0.0,5.0,0.0,0,0,0,0,0,0); 
	DisableInteriorEnterExits();
	Priority = 0;
	for(new k; k < MAX_LOBBY; k++)
	{
		LobbyInfo[k][Suspect] = -1;
		LobbyInfo[k][Timer] = -1;
		LobbyInfo[k][Map] = -1;
		for(new i; i < MAX_PLOBBY; i++)
		{
			LobbyID[k][i] = -1;
		}
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
		PlayerInfo[i][Lb] = -1;
		PlayerInfo[i][Money] = -1;
		PlayerInfo[i][Donate] = -1;
		PlayerInfo[i][ID] = -1;
		PlayerInfo[i][Login] = 0;
		PlayerInfo[i][Skin] = -1;
		PlayerInfo[i][Admin] = -1;
	}
	HeartBit = SetTimer("Bit", 1000, true);
	BestBit = SetTimer("Piu", 200, true);
	return 1;
}

public OnGameModeExit()
{
    KillTimer(HeartBit);
    KillTimer(BestBit);
    mysql_close(sql);
    return 1;
}

public OnPlayerConnect(playerid)
{
	SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	PlayerInfo[playerid][Lb] = -1;
	new Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Name, sizeof(Name));
	new query[256];
	format(query, 256, "SELECT COUNT(*) FROM `Accounts` WHERE `Name` = '%s'", Name);
	mysql_query(sql, query);
	new row;
	cache_get_value_index_int(0, 0, row);
	if(row == 0)
	{
	    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Регистрация", "Регистрация же", "Далее", "Отмена");
	}
	else
	{
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "Добро пожаловать на Copchase Server\nВаш аккаунт зарегистрирован.\nЧтобы начать игру, Вам нужно ввести пароль,\nКоторый Вы указали при регистрации.", "Далее", "Отмена");
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(PlayerInfo[playerid][Login] > 0)
	{
		DestroyVehicle(PlayerVehicle[playerid]);
		HideMenuTD(playerid);
		DestroyMenuTD(playerid);
		new query[256];
		new Name[MAX_PLAYER_NAME];
		Name = GPN(playerid);
		format(query, 256, "UPDATE `Accounts` SET `Online` = -1 WHERE `Name` = '%s'", Name);
		mysql_query(sql, query);
	}
	if(PlayerInfo[playerid][Lb] > -1) // Если игрок находится в лобби
	{
		if(LobbyInfo[PlayerInfo[playerid][Lb]][Activate] < 3)
		{
			for(new i; i < MAX_PLOBBY; i++)
			{
				if(LobbyID[PlayerInfo[playerid][Lb]][i] != playerid) continue;
				LobbyID[PlayerInfo[playerid][Lb]][i] = -1;
				LobbyName[PlayerInfo[playerid][Lb]][i] = "";
				LobbyInfo[PlayerInfo[playerid][Lb]][Players]--;
			}
		}
		else if(LobbyInfo[PlayerInfo[playerid][Lb]][Activate] == 3)
		{
			if(LobbyInfo[PlayerInfo[playerid][Lb]][Suspect] == playerid) 
			{
				HideSusUI(playerid);
				DestroySusUI(playerid);
				// Если ливнувший игрок был саспектом
			}
			else 
			{
				//Если игрок полицейский
				HideLeftUI(playerid);
				HidePoliceUI(playerid);
				DestroyPoliceUI(playerid);
				DestroyLeftUI(playerid);
				new query[256];
				new Name[MAX_PLAYER_NAME];
				Name = GPN(playerid);
				format(query, 256, "UPDATE `Accounts` SET `Matches` = `Matches` + 1, `Leaves` = `Leaves` + 1, `Online` = -1 WHERE `Name` = '%s'", Name);
				mysql_query(sql, query);
				new lobbyid = PlayerInfo[playerid][Lb];
				PlayerInfo[playerid][Lb] = -1;
				for(new i; i < MAX_PLOBBY; i++)
				{
					if(LobbyID[lobbyid][i] == playerid)
					{
						LobbyID[lobbyid][i] = -1;
						LobbyInfo[lobbyid][Players]--;
					}
				}
			}
			//Функция очистки лобби
		}
	}
	PlayerInfo[playerid][Skin] 		= -1;
	PlayerInfo[playerid][ID]		= -1;
	PlayerInfo[playerid][Login] 	= -1;
	PlayerInfo[playerid][Donate] 	= -1;
	PlayerInfo[playerid][Money] 	= -1;
	PlayerInfo[playerid][Admin] 	= -1;
	PlayerInfo[playerid][Lb] 		= -1;
	PlayerInfo[playerid][Matches] 	= -1;
	PlayerInfo[playerid][Leaves]	= -1;
	PlayerInfo[playerid][Mute]		= -1;
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 0:
	    {
	        if(response)
			{
			    if(!strlen(inputtext) || strlen(inputtext) < 6 || strlen(inputtext) > 20)
			    {
       				ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Регистрация", "Произошла ошибка регистрации. \nВ пароле должно быть более 6 и менее 20 символов.\nПожалуйста, повторите попытку", "Продолжить", "");
			    }
				else
				{
					for(new i; i<strlen(inputtext); i++)
					{
						switch(inputtext[i])
						{
						    case 'A'..'Z': continue;
						    case 'a'..'z': continue;
						    case '0'..'9': continue;
						    case '_': continue;
						    default:
						    {
						    	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Регистрация", "Произошла ошибка регистрации.\nВы ввели запрещенные символы.\nПожалуйста, повторите попытку", "Продолжить", "");
								return 1;
						    }
						}
					}
					new Name[MAX_PLAYER_NAME];
					GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
					new query[256];
					format(query, 256, "SELECT COUNT(*) from `Accounts`");
					mysql_query(sql, query);
					new rows;
					cache_get_value_index_int(0, 0, rows);
					format(query, 256, "INSERT INTO `Accounts` (`ID`, `Name`, `Password`, `Admin`, `Money`, `Donate`, `Online`) VALUES ('%i', '%s', '%s', '0', '0', '0', '1')", rows, Name, inputtext);
					mysql_query(sql, query);
					PlayerInfo[playerid][Login] = 1;
					SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
					SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
					CameraMenu(playerid);
				  	CreateMenuTD(playerid);
				  	ShowMenuTD(playerid);
				}
			}
			else
			{
			    Kick(playerid);
			}
	    }
	    case 1:
		{
		    if(response)
		    {
	 			if(!strlen(inputtext) || strlen(inputtext) < 6 || strlen(inputtext) > 20)
			    {
       				ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "Произошла ошибка. \nПожалуйста, повторите попытку.", "Продолжить", "");
			    }
			    else
				{
					for(new i; i<strlen(inputtext); i++)
					{
						switch(inputtext[i])
						{
						    case 'A'..'Z': continue;
						    case 'a'..'z': continue;
						    case '0'..'9': continue;
						    case '_': continue;
						    default:
						    {
						    	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "Вы ввели запрещённые символы\nПожалуйста, повторите попытку.", "Продолжить", "");
								return 1;
						    }
						}
					}
					new Name[MAX_PLAYER_NAME];
					GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
					new query[256];
					format(query, 256, "SELECT * from `Accounts` where `Name` = '%s'", Name);
					mysql_query(sql, query);
					new password[24];
					cache_get_value_name(0, "Password", password);
					if(strcmp(password, inputtext, false) != 0)
					{
						ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "Пароль введен неверно\nПожауйста, повторите попытку.", "Продолжить", "");
					}
					else // Человек авторизовался
					{
						SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
						LoadAccount(playerid);
						CameraMenu(playerid);
					  	CreateMenuTD(playerid);
					  	ShowMenuTD(playerid);
					  	SendClientMessage(playerid, 0xFF000000, "Вы авторизованы.");
					  	format(query, 256, "UPDATE `Accounts` SET `Online` = %i WHERE `Name` = '%s'", playerid, Name);
						mysql_query(sql, query);
					  	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
					}
				}
		    }
		}
	}
	return 1;
}

stock CameraMenu(playerid)
{
	SelectTextDraw(playerid, 0xffffffff);
	PlayerInfo[playerid][Login] = 1;
	SetSpawnInfo(playerid, 0,0,0,0,0,0,0,0, 0,0,0,0);
	SetPlayerCameraPos(playerid, 1627.4650, -1045.1171, 24.8984);
	SpawnPlayer(playerid);
	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
	SetPlayerPos(playerid, 1633.7219, -1045.2396, 23.8984);
	SetPlayerFacingAngle(playerid, 92.0000);
	SetPlayerCameraLookAt(playerid, 1637.7219,-1045.2396,23.8984);
	SetPlayerVirtualWorld(playerid, 1000 + playerid);
	TogglePlayerControllable(playerid, 0);
	PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 1640.4,-1045.2396,23.8984, 0.0000, 0, 0, 0);
	SetVehicleVirtualWorld(PlayerVehicle[playerid], 1000 + playerid);
	return 1;
} 

forward LoadAccount(playerid);
public LoadAccount(playerid)
{
	cache_get_value_name_int(0, "ID", PlayerInfo[playerid][ID]);
	cache_get_value_name_int(0, "Skin", PlayerInfo[playerid][Skin]);
	cache_get_value_name_int(0, "Money", PlayerInfo[playerid][Money]);
	cache_get_value_name_int(0, "Admin", PlayerInfo[playerid][Admin]);
	cache_get_value_name_int(0, "Donate", PlayerInfo[playerid][Donate]);
	cache_get_value_name_int(0, "Leaves", PlayerInfo[playerid][Leaves]);
	cache_get_value_name_int(0, "Vehicle", PlayerInfo[playerid][Vehicle]);
	cache_get_value_name_int(0, "Matches", PlayerInfo[playerid][Matches]);
	return 1;
}

stock CreateMenuTD(playerid)
{
	MenuTD[playerid][0] = CreatePlayerTextDraw(playerid, 320, 360, "~n~~n~~n~");
	PlayerTextDrawTextSize(playerid, MenuTD[playerid][0], 0, 640);
	PlayerTextDrawUseBox(playerid, MenuTD[playerid][0], 1);
	PlayerTextDrawAlignment(playerid, MenuTD[playerid][0], 2);
	PlayerTextDrawBoxColor(playerid, MenuTD[playerid][0], 0x888888ee);

	MenuTD[playerid][1] = CreatePlayerTextDraw(playerid, 100, 350, "~n~PLAY~n~~n~");
	PlayerTextDrawSetShadow(playerid, MenuTD[playerid][1], 0);
	PlayerTextDrawFont(playerid, MenuTD[playerid][1], 2);
	PlayerTextDrawAlignment(playerid, MenuTD[playerid][1], 2);
	PlayerTextDrawLetterSize(playerid, MenuTD[playerid][1], 0.4, 1.8);
	PlayerTextDrawUseBox(playerid, MenuTD[playerid][1], 1);
	PlayerTextDrawTextSize(playerid, MenuTD[playerid][1], 60, 130);
	PlayerTextDrawBoxColor(playerid, MenuTD[playerid][1], 0x003399ff);
	PlayerTextDrawSetSelectable(playerid, MenuTD[playerid][1], 1);

	MenuTD[playerid][2] = CreatePlayerTextDraw(playerid, 350, 365, "CUSTOMIZE");
	PlayerTextDrawLetterSize(playerid, MenuTD[playerid][2], 0.4, 1.8);
	PlayerTextDrawSetShadow(playerid, MenuTD[playerid][2], 0);
	PlayerTextDrawFont(playerid, MenuTD[playerid][2], 2);
	PlayerTextDrawSetSelectable(playerid, MenuTD[playerid][2], 1);

	MenuTD[playerid][3] = CreatePlayerTextDraw(playerid, 470, 365, "SHOP");
	PlayerTextDrawLetterSize(playerid, MenuTD[playerid][3], 0.4, 1.8);
	PlayerTextDrawSetShadow(playerid, MenuTD[playerid][3], 0);
	PlayerTextDrawFont(playerid, MenuTD[playerid][3], 2);
	PlayerTextDrawSetSelectable(playerid, MenuTD[playerid][3], 1);

	MenuTD[playerid][4] = CreatePlayerTextDraw(playerid, 545, 365, "STATS");
	PlayerTextDrawLetterSize(playerid, MenuTD[playerid][4], 0.4, 1.8);
	PlayerTextDrawSetShadow(playerid, MenuTD[playerid][4], 0);
	PlayerTextDrawFont(playerid, MenuTD[playerid][4], 2);
	PlayerTextDrawSetSelectable(playerid, MenuTD[playerid][4], 1);
}

stock ShowMenuTD(playerid)
{
	for(new i; i < 5; i++)
	{
		PlayerTextDrawShow(playerid, MenuTD[playerid][i]);
	}
}

stock HideMenuTD(playerid)
{
	for(new i; i < 5; i++)
	{
		PlayerTextDrawHide(playerid, MenuTD[playerid][i]);
	}
}

stock DestroyMenuTD(playerid)
{
	for(new i; i < 5; i++)
	{
		PlayerTextDrawDestroy(playerid, MenuTD[playerid][i]);
	}
}


public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(PlayerInfo[playerid][Login] == 0) 
	{
		SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы не можете отправлять сообщения.");
		return 0;
	}
	if(PlayerInfo[playerid][Mute] > 0)
	{
		SendClientMessage(playerid, 0xFF000000, "Ошибка: У вас затычка. Вы не можете отправлять сообщения в чат");
		return 0;
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(PlayerInfo[playerid][Login] == 0)
	{
		Kick(playerid);
		return 0;
	}
	if(PlayerInfo[playerid][Lb] == -1)
	{
		SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[],success) 
{ 
    return 1; 
} 

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

CMD:veh(playerid, params[])
{
	if(PlayerInfo[playerid][Admin] == 0)
	{
		SendClientMessage(playerid, 0xFF000000, "Ошибка: эта команда вам недоступна.");
	}
	else
	{
		new Float:x, Float:y, Float:z, veh, idv;
		GetPlayerPos(playerid, x, y, z);
		if(sscanf(params, "d", veh)) return SendClientMessage(playerid, 0xFF000000, "Ошибка: введите корректный id транспорта");
		idv = CreateVehicle(veh, x, y, z, 0, 0, 0, 0);
		new vw = GetPlayerVirtualWorld(playerid);
		SetVehicleVirtualWorld(idv, vw);
	}
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == MenuTD[playerid][1])
	{
		if(Priority > -1) 
		{
			HideMenuTD(playerid);
			TogglePlayerControllable(playerid, 1);
			SetPlayerVirtualWorld(playerid, Priority);
			CancelSelectTextDraw(playerid);
			SetCameraBehindPlayer(playerid);
			SetVehicleVirtualWorld(PlayerVehicle[playerid], Priority);
			SetVehicleHealth(PlayerVehicle[playerid], 10000);
			SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
			DestroyVehicle(PlayerVehicle[playerid]);
			for(new i; i < MAX_PLOBBY; i++)
			{
				if(LobbyID[Priority][i] == -1)
				{
					switch(i)
					{
						case 0:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 311.5427,-1809.3197,4.0424,180.2724, 0, 0, -1);
							SetPlayerPos(playerid, 312.0000,-1812.8839,4.3934);
							SetPlayerFacingAngle(playerid, 180);
						}
						case 1:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 318.2854,-1809.4020,4.2187,180.3335,0,0, -1);
							SetPlayerPos(playerid, 318.0000,-1812.6407,4.4035);
							SetPlayerFacingAngle(playerid, 180);
						}
						case 2:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 324.6554,-1809.1659,4.2263,179.9251,0,0, -1);
							SetPlayerPos(playerid, 324.5000,-1812.6407,4.4035);
							SetPlayerFacingAngle(playerid, 180);
						}
						case 3:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 330.9298,-1809.6777,4.2191,179.8994,0,0, -1);
							SetPlayerPos(playerid, 331.0000,-1812.6407,4.4035);
							SetPlayerFacingAngle(playerid, 180);
						}
						case 4:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 337.3327,-1810.1118,4.2268,179.6051,0,0, -1);
							SetPlayerPos(playerid, 337.5000,-1812.6407,4.4035);
							SetPlayerFacingAngle(playerid, 180);
						}
						case 5:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 311.6900,-1789.3408,4.3135,0.0370,0,0, -1);
							SetPlayerPos(playerid, 311.6015,-1785.3176,4.5888);
							SetPlayerFacingAngle(playerid, 0);
						}
						case 6:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 318.1137,-1789.0255,4.4184,358.9895,0,0, -1);
							SetPlayerPos(playerid, 318.4928,-1785.6693,4.6981);
							SetPlayerFacingAngle(playerid, 0);
						}
						case 7:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 324.6242,-1789.5760,4.5209,0.3305,0, 0, -1);
							SetPlayerPos(playerid, 324.4236,-1785.7852,4.7931);
							SetPlayerFacingAngle(playerid, 0);
						}
						case 8:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 331.0427,-1789.3031,4.6114,0.8495,0,0, -1);
							SetPlayerPos(playerid,331.4016,-1785.3527,4.9074);
							SetPlayerFacingAngle(playerid, 0);
						}
						case 9:
						{
							PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 337.3922,-1789.3604,4.6535,1.2548,0,0, -1);
							SetPlayerPos(playerid, 337.3539,-1785.9169,5.0219);
							SetPlayerFacingAngle(playerid, 0);
						}
					}
					break;
				}
			}
			SetVehicleVirtualWorld(PlayerVehicle[playerid], Priority);
			if(LobbyInfo[Priority][Activate] == 0) // если лобби не создано
			{
				LobbyInfo[Priority][Activate] = 1;
				GiveSlot(playerid, Priority);
				new texts[144];
				format(texts, 144, "Вы попали в лобби №%i, ожидайте игроков.", Priority);
				SendClientMessage(playerid, 0xFF000000, texts);
				SetPlayerVirtualWorld(playerid, Priority);
			}
			else if(LobbyInfo[Priority][Activate] == 1 || LobbyInfo[Priority][Activate] == 2) // Если лобби создано и в процессе поиска
			{
				if(LobbyInfo[Priority][Players] < 3) // Если игроков меньше 3
				{
					GiveSlot(playerid, Priority);
					if(LobbyInfo[Priority][Players] > 2 && LobbyInfo[Priority][Players] < MAX_PLOBBY - 1)
					{
						SendClientMessage(playerid, 0xFF000000, "Вы подключены в лобби, в котором уже начат отсчет");
					}
					if(LobbyInfo[Priority][Players] == 2) // Если игрок подключился третьим
					{
						LobbyInfo[Priority][Timer] = TimeInLobby; // Задаем 10 секунд до подключения к лобби
						SendClientMessage(playerid, 0xFF000000, "Вы подключены");
						SetPlayerVirtualWorld(playerid, Priority);
						LobbyInfo[Priority][Activate] = 2; // Состояние лобби: запущен таймер
						for(new i; i < MAX_PLOBBY; i++)
						{
							if(LobbyID[Priority][i] == -1) continue;
							CreateTimerUI(LobbyID[Priority][i]);
							ShowTimerUI(LobbyID[Priority][i]);
						}
					}
				}
				else
				{
					if(LobbyInfo[Priority][Players] + 1 == MAX_PLOBBY) //Если игрок занимает последний слот
					{
						GiveSlot(playerid, Priority);
						SendClientMessage(playerid, 0xFF000000, "Вы подключились в лобби последним");
						CreateTimerUI(playerid);
						new check = 0;
						while(Priority < MAX_LOBBY)
						{
							Priority++;
							if(Priority == MAX_LOBBY) 
							{
								if(check < 2) // Если цикл ещё не прошел круг
								{
									check++;
									Priority = 0;
								}
								else // Если круг пройден и ни 1 лобби не найден
								{
									Priority = -1;
									break;
								}
							}
							if(LobbyInfo[Priority][Players] == MAX_PLOBBY || LobbyInfo[Priority][Activate] > 2) // Если лобби заполнено или игра уже начата, ищем следующее
							{
								continue;
							}
							else if(LobbyInfo[Priority][Players] < MAX_PLOBBY && LobbyInfo[Priority][Activate] < 3) // Если лобби не заполнено и игра ещё не начата, то
							{
								break;
							}
						}
					}
				}
			}
		}
		else 
		{
			SendClientMessage(playerid, 0xFF000000, "Все лобби заняты, повторите попытку позднее.");
		}
	}
	return 1;
}

stock GPN(playerid)
{
	new Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
	return Name;
}

stock GiveSlot(playerid, lobby)
{
	PlayerInfo[playerid][Lb] = lobby;
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[lobby][i] == -1)
		{
			LobbyID[lobby][i] 		= playerid;
			LobbyName[lobby][i] 	= GPN(playerid);
			break;
		}
	}
	LobbyInfo[Priority][Players]++;
}

stock CreatePoliceUI(playerid)
{
	new i = 0;
	new LB = PlayerInfo[playerid][Lb];
	for(new k; k < MAX_PLOBBY; k++)
	{
		if(LobbyID[LB][k] == -1) continue;
		if(isnull(LobbyName[LB][k])) continue;
		if(LobbyID[LB][k] == LobbyInfo[LB][Suspect]) continue;
		new Name[MAX_PLAYER_NAME];
		Name = GPN(playerid);
		new Text[26];
		format(Text, 26, "%s", Name);
		PoliceUI[playerid][i] = CreatePlayerTextDraw(playerid, 470, 230 + 15 * i, Text);
		PlayerTextDrawSetShadow(playerid, PoliceUI[playerid][i], 0);
		PlayerTextDrawLetterSize(playerid, PoliceUI[playerid][i], 0.2, 0.8);
		PlayerTextDrawUseBox(playerid, PoliceUI[playerid][i], 1);
		PlayerTextDrawTextSize(playerid, PoliceUI[playerid][i], 599, 40);
		PlayerTextDrawBoxColor(playerid, PoliceUI[playerid][i], 0x000000FF);
		PlayerTextDrawFont(playerid, PoliceUI[playerid][i], 2);
		PlayerTextDrawShow(playerid, PoliceUI[playerid][i]);

		RangeUI[playerid][i] = CreatePlayerTextDraw(playerid, 600, 230 + 15 * i, "blizko");
		PlayerTextDrawSetShadow(playerid, RangeUI[playerid][i], 0);
		PlayerTextDrawLetterSize(playerid, RangeUI[playerid][i], 0.2, 0.8);
		PlayerTextDrawUseBox(playerid, RangeUI[playerid][i], 1);
		PlayerTextDrawTextSize(playerid, RangeUI[playerid][i], 640, 40);
		PlayerTextDrawBoxColor(playerid, RangeUI[playerid][i], 0x000000FF);
		PlayerTextDrawFont(playerid, RangeUI[playerid][i], 2);
		i++;
	}
	LobbyInfo[LB][TextDraws] = i;
}

stock ShowPoliceUI(playerid)
{
	new LB = PlayerInfo[playerid][Lb];
	for(new k; k < LobbyInfo[LB][TextDraws]; k++)
	{
		PlayerTextDrawShow(playerid, PoliceUI[playerid][k]);
		PlayerTextDrawShow(playerid, RangeUI[playerid][k]);
	}
}

stock HidePoliceUI(playerid)
{
	new LB = PlayerInfo[playerid][Lb];
	for(new k; k < LobbyInfo[LB][TextDraws]; k++)
	{
		PlayerTextDrawHide(playerid, PoliceUI[playerid][k]);
		PlayerTextDrawHide(playerid, RangeUI[playerid][k]);
	}
}

stock DestroyPoliceUI(playerid)
{
	new LB = PlayerInfo[playerid][Lb];
	for(new k; k < LobbyInfo[LB][TextDraws]; k++)
	{
		PlayerTextDrawDestroy(playerid, PoliceUI[playerid][k]);
		PlayerTextDrawDestroy(playerid, RangeUI[playerid][k]);
	}
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(PlayerInfo[playerid][Login] < 1)
	{
		Kick(playerid);
		return 1;
	}
	if(PlayerInfo[playerid][Lb] > -1) // Если игрок находился в лобби
	{
		new lobbyid = PlayerInfo[playerid][Lb];
		if(LobbyInfo[lobbyid][Suspect] == playerid) // Если игрок - это саспект
		{
			for(new i; i < MAX_PLOBBY; i++)
			{
				if(LobbyID[lobbyid][i] == -1)
				{
					continue;
				}
				if(LobbyID[lobbyid][i] == LobbyInfo[lobbyid][Suspect])
				{
					continue;
				}
				PlayerInfo[LobbyID[lobbyid][i]][Score]++;
				PlayerInfo[LobbyID[lobbyid][i]][Money]=PlayerInfo[LobbyID[lobbyid][i]][Money]+200;
				SendClientMessage(LobbyID[lobbyid][i], 0x3300DD00, "Преступник обезврежен!");
			}
			EndLobby(lobbyid);
			return 1;
		}
		else // Если игрок - полицай
		{
			if(LobbyInfo[lobbyid][Players] > 2) // Если полицейский умер не последним
			{
				PlayerInfo[playerid][Lb] = -1;
				for(new i; i < MAX_PLOBBY; i++)
				{
					if(LobbyID[lobbyid][i] == playerid)
					{
						LobbyID[lobbyid][i] = -1;
						LobbyInfo[lobbyid][Players]--;
						break;
					}
				}
				HideLeftUI(playerid);
				HidePoliceUI(playerid);
				DestroyLeftUI(playerid);
				DestroyPoliceUI(playerid);
				DestroyVehicle(PlayerVehicle[playerid]);
				CameraMenu(playerid);
				ShowMenuTD(playerid);
			}
		}
	}
	return 1;
}

forward CreateTimerUI(playerid);
public CreateTimerUI(playerid)
{
	new string[32];
	new lobbyid = PlayerInfo[playerid][Lb];
	format(string, 32, "Time remaining: __%i sec", LobbyInfo[lobbyid][Timer]);
	TimerUI[playerid] = CreatePlayerTextDraw(playerid, 220, 380, string);
	PlayerTextDrawSetShadow(playerid, TimerUI[playerid], 0);
	PlayerTextDrawFont(playerid, TimerUI[playerid], 2);
	return 1;
}

forward ShowTimerUI(playerid);
public ShowTimerUI(playerid)
{
	PlayerTextDrawShow(playerid, TimerUI[playerid]);
}

forward HideTimerUI(playerid);
public HideTimerUI(playerid)
{
	PlayerTextDrawHide(playerid, TimerUI[playerid]);
}

forward DestroyTimerUI(playerid);
public DestroyTimerUI(playerid)
{
	PlayerTextDrawDestroy(playerid, TimerUI[playerid]);
}

forward UpdateTimerUI(playerid);
public UpdateTimerUI(playerid)
{
	new lobbyid = PlayerInfo[playerid][Lb];
	new string[32];
	format(string, 32, "Time remaining: __%i sec", LobbyInfo[lobbyid][Timer]);
	PlayerTextDrawSetString(playerid, TimerUI[playerid], string);
}

forward Bit();
public Bit()
{
	for(new i; i < MAX_LOBBY; i++)
	{
		if(LobbyInfo[i][Activate] == 2)
		{
			/* Если не осталось времени */
			if(LobbyInfo[i][Timer] == 0) 
			{
				new CountPlayers;
				///
				for(new k; k < MAX_PLOBBY; k++)
				{
					if(LobbyID[i][k] == -1) // Если игрок не найден в лобби
					{
						if(isnull(LobbyName[i][k])) continue; //Если имя игрока пустое
						else if(strlen(LobbyName[i][k]) > 2) //Если имя как-то обнаружилось
						{
							LobbyName[i][k] = "";
							SendException(i, 0);
							continue;
						}
					}
					else if(LobbyID[i][k] > -1) // Если игрок найден
					{
						if(strlen(LobbyName[i][k]) > 2) //Если имя заполнено
						{
							CountPlayers++;
							continue;
						}
						else // Если игрок найден, а имя не заполнено
						{
							SendException(i, 1);
							continue;
						}
					}
				}
				///
				LobbyInfo[i][TextDraws] = CountPlayers - 1;
				while(LobbyInfo[i][Suspect] == -1)
				{
					new a = random(MAX_PLOBBY);
					if(LobbyID[i][a] == -1) continue;
					LobbyInfo[i][Suspect] = LobbyID[i][a];
					SendClientMessage(LobbyInfo[i][Suspect], 0xFF000000, "Вы саспект, сосатб");
					break;
				}
				HideTimerUI(LobbyInfo[i][Suspect]);
				DestroyTimerUI(LobbyInfo[i][Suspect]);
				CreateSusUI(LobbyInfo[i][Suspect]);
				ShowSusUI(LobbyInfo[i][Suspect]);
				for(new k; k < MAX_PLOBBY; k++)
				{
					if(LobbyID[i][k] == LobbyInfo[i][Suspect]) continue;
					if(LobbyID[i][k] == -1) continue;
					if(isnull(LobbyName[i][k])) continue;
					CreatePoliceUI(LobbyID[i][k]);
					ShowPoliceUI(LobbyID[i][k]);
					SendClientMessage(LobbyID[i][k], 0xFF000000, "Лобби запущено.");
					HideTimerUI(LobbyID[i][k]);
					DestroyTimerUI(LobbyID[i][k]);
					CreateLeftUI(LobbyID[i][k]);
					PlayerTextDrawShow(LobbyID[i][k], LeftUP[LobbyID[i][k]]);
					ShowLeftUI(LobbyID[i][k]);
					PutPlayerInVehicle(LobbyID[i][k], PlayerVehicle[LobbyID[i][k]], 0);
					if(Priority == i) 
					{
						SearchPriority();
					}
				}
				PutPlayerInVehicle(LobbyInfo[i][Suspect], PlayerVehicle[LobbyInfo[i][Suspect]], 0);
				SendClientMessage(LobbyInfo[i][Suspect], 0xFF000000, "Лобби запущено.");
				LobbyInfo[i][Map] = 0;
				LobbyInfo[i][Activate] = 3;
				LobbyInfo[i][Timer] = TimeInGame;
			}

			/* Если время таймера ещё более 0 */
			else if(LobbyInfo[i][Timer] > 0)
			{
				LobbyInfo[i][Timer]--;
				for(new k; k < MAX_PLOBBY; k++)
				{
					if(LobbyID[i][k] == -1) continue;
					UpdateTimerUI(LobbyID[i][k]);
				}
			}
		}
		else if(LobbyInfo[i][Activate] == 3) // Если игра в лобби идет
		{
			if(LobbyInfo[i][Timer] == 0) // Если время во время игры в лобби закончилось
			{
				EndLobby(i);
			}
			else if(LobbyInfo[i][Timer] > 0) 
			{
				for(new k; k < MAX_PLOBBY; k++)
				{
					if(LobbyID[i][k] == LobbyInfo[i][Suspect]) 	continue;
					if(LobbyID[i][k] == -1)						continue;
					UpdateLeftUI(LobbyID[i][k]);
				}
				UpdateSusUI(LobbyInfo[i][Suspect]);
				LobbyInfo[i][Timer]--;
			}
		}
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(PlayerInfo[i][Login] == 0)
		{
			continue;
		}
		if(PlayerInfo[i][Mute] == 0)
		{
			continue;
		}
		if(PlayerInfo[i][Mute] > 1)
		{
			PlayerInfo[i][Mute]--;
		}
		else if(PlayerInfo[i][Mute] == 1)
		{
			PlayerInfo[i][Mute]--;
			SendClientMessage(i, 0xee00ee, "Сервер: С Вас снята затычка. Можете продолжать общение ;)");
		}
	}
	return 1;
}

forward EndLobby(lobbyid);
public EndLobby(lobbyid)
{
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[lobbyid][i] == -1)		 					continue;
		if(LobbyID[lobbyid][i] == LobbyInfo[lobbyid][Suspect]) 	continue;
		DestroyVehicle(PlayerVehicle[LobbyID[lobbyid][i]]);
		HideLeftUI(LobbyID[lobbyid][i]);
		DestroyLeftUI(LobbyID[lobbyid][i]);
		HidePoliceUI(LobbyID[lobbyid][i]);
		DestroyPoliceUI(LobbyID[lobbyid][i]);
		CameraMenu(LobbyID[lobbyid][i]);
		ShowMenuTD(LobbyID[lobbyid][i]);
		PlayerInfo[LobbyID[lobbyid][i]][Lb]=-1;
	}
	DestroyVehicle(PlayerVehicle[LobbyInfo[lobbyid][Suspect]]);
	HideSusUI(LobbyInfo[lobbyid][Suspect]);
	DestroySusUI(LobbyInfo[lobbyid][Suspect]);
	CameraMenu(LobbyInfo[lobbyid][Suspect]);
	ShowMenuTD(LobbyInfo[lobbyid][Suspect]);
	PlayerInfo[LobbyInfo[lobbyid][Suspect]][Lb]=-1;
	for(new i; i < MAX_PLOBBY; i++)
	{
		LobbyID[lobbyid][i] = -1;
		LobbyName[lobbyid][i] = "";
		LobbyInfo[lobbyid][Suspect] = -1;
	}
	LobbyInfo[lobbyid][Timer] = -1;
	LobbyInfo[lobbyid][Activate] = 0;
	LobbyInfo[lobbyid][TextDraws] = 0;
	LobbyInfo[lobbyid][Players] = 0;
	if(Priority == -1)
	{
		Priority = lobbyid;
	}
	return 1;
}

stock SendException(lobbyid, exc)
{
	new texts[144];
	format(texts, 144, "Произошла ошибка в лобби %i под номером 0x%i. Сообщите об этом разработчику или гл. адм.", lobbyid, exc);
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(CheckPlayerAdmin(i)) SendClientMessage(i, 0xFF000000, texts);
		else continue;
	}
}

stock CheckPlayerAdmin(playerid)
{
	if(PlayerInfo[playerid][Admin] > 0) return true;
	else return false; 
}


CMD:lobby(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0) return 0;
	new lid;
	if(sscanf(params, "i", lid)) return SendClientMessage(playerid, 0xFF000000, "Ошибка: вы ввели некорректный ID лобби");
	if(lid < 0 || lid > MAX_LOBBY - 1) return SendClientMessage(playerid, 0xFF000000, "Ошибка: вы ввели некорректный ID лобби");
	new MSGL[1000];
	format(MSGL, 1000, "Лобби номер %i \n");
	new temp[100];
	for(new i; i < MAX_PLOBBY; i++)
	{
		new names[MAX_PLAYER_NAME];
		names = LobbyName[lid][i];
		if(isnull(names))
		{
			names = "Нет имени";
		}
		format(temp, 100, "%i слот: \t\t%s (%i)\n", i, names, LobbyID[lid][i]);
		strcat(MSGL, temp);
	}
	if(LobbyInfo[lid][Activate] == 0)
	{
		strcat(MSGL, "Лобби ещё не создано");
	}
	else if(LobbyInfo[lid][Activate] == 1)
	{
		strcat(MSGL, "Лобби заполняется");
	}
	else if(LobbyInfo[lid][Activate] == 2)
	{
		strcat(MSGL, "Лобби заполнено и готово к игре");
	}
	else if(LobbyInfo[lid][Activate] == 3)
	{
		strcat(MSGL, "Лобби находится в игре");
	}
	new LN[24];
	format(temp, 100, "\nИгроков в лобби: %i", LobbyInfo[lid][Players]);
	strcat(MSGL, temp);
	format(temp, 100, "\nID подозреваемого: %i", LobbyInfo[lid][Suspect]);
	strcat(MSGL, temp);
	format(temp, 100, "\nID карты:\t%i", LobbyInfo[lid][Map]);
	format(LN, 24, "Лобби №%i", lid);
	ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, LN, MSGL, "Ок", "");
	return 1;
} 

CMD:check(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0) return 0;
	new plid;
	if(sscanf(params, "i", plid))
	{
		new info[500];
		new PVW = GetPlayerVirtualWorld(playerid);
		new PlayerLobby = PlayerInfo[playerid][Lb];
		new PlayerSlot = -1;
		if(PlayerLobby > -1)
		{
			for(new i; i < MAX_PLOBBY; i++)
			{
				if(LobbyID[PlayerLobby][i] == playerid) 
				{
					PlayerSlot = i;
					break;
				}
			}
		}
		format(info, sizeof(info), "Виртуальный мир:\t\t%i\nНомер лобби:\t\t\t%i\nСлот в лобби:\t\t\t%i\nМатчей:\t\t\t%i\n", PVW, PlayerLobby, PlayerSlot);
		ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Ваш чекер", info, "Окей", "");
		return 1;
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1) return SendClientMessage(playerid, 0xFF000000, "Вы ввели некорректный ID. Повторите попытку.");
	new info[500];
	new PVW = GetPlayerVirtualWorld(plid);
	new PlayerLobby = PlayerInfo[plid][Lb];
	new PlayerSlot = -1;
	if(PlayerLobby > 0)
	{
		for(new i; i < MAX_PLOBBY; i++)
		{
			if(LobbyID[PlayerLobby][i] == plid) 
			{
				PlayerSlot = i;
				break;
			}
		}
	}
	format(info, sizeof(info), "Виртуальный мир: \t\t%i\nНомер лобби: \t\t%i\nСлот в лобби: \t\t%i\nАвторизован: \t\t%i", PVW, PlayerLobby, PlayerSlot, PlayerInfo[plid][Login]);
	ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Ваш чекер", info, "Окей", "");
	return 1;
}

CMD:ainfo(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0)	
	{
		return 0;
	}
	if(PlayerInfo[playerid][Admin] < 2)		
	{
		return 0;
	}
	if(PlayerInfo[playerid][Lb] > -1)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы не можете смотреть информацию во время игры");
	}
	new plid;
	if(sscanf(params, "i", plid)) 
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: введите /ainfo [ID игрока]");
	}
	new Name[MAX_PLAYER_NAME];
	Name = GPN(plid);
	if(PlayerInfo[plid][Login] == 0)
	{
		new Text[200];
		format(Text, 200, "Имя игрока:\t\t%s\nID игрока:\t\t%i\nСтатус:\t\tНе авторизован.");
		ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Информация об аккаунте", Text, "ок", "");
	}
	else
	{
		new text[1000];
		format(text, 1000, "Имя игрока:\t\t\t\t%s\nID игрока:\t\t\t\t%i\nСтатус:\t\t\t\t\tАвторизован\n\nID аккаунта:\t\t\t\t%i\nСыграно матчей:\t\t\t%i\nПокинуто матчей:\t\t\t%i\nМодель транспорта:\t\t\t%i id\nID транспорта на сервере:\t\t%i", Name, plid, PlayerInfo[plid][ID], PlayerInfo[plid][Matches], PlayerInfo[plid][Leaves], PlayerInfo[plid][Vehicle], PlayerVehicle[plid]);
		ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Информация об аккаунте", text, "ок", "");
	}
	return 1;
}

CMD:alm(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0) 	return 0;
	if(PlayerInfo[playerid][Admin] == 0) 	return 0;
	new lid, ml[100];
	if(sscanf(params, "is", lid, ml)) 		return SendClientMessage(playerid, 0xFF003300, "Ошибка: Формат /alm [ID лобби] [Text]");
	if(isnull(ml)) 							return SendClientMessage(playerid, 0xff003300, "Ошибка: Вы не ввели текст.");
	if(lid < 0 || lid > MAX_LOBBY) 			return SendClientMessage(playerid, 0xFF003300, "Ошибка: Вы ввели некорректный id лобби");
	new Message[144];
	format(Message, 144, "Адм. %s в лобби: %s", GPN(playerid), ml);
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[lid][i] == -1) 			continue;
		if(LobbyID[lid][i] == playerid) 	continue;
		SendClientMessage(LobbyID[lid][i], 0xFF000000, Message);
	}
	SendClientMessage(playerid, 0xFF000000, Message);
	return 1;
}

CMD:sinfo(playerid)
{
	if(PlayerInfo[playerid][Login] == 0) 	return 0;
	if(PlayerInfo[playerid][Admin] < 3) 	return 0;
	else
	{
		new iter;
		for(new i; i < MAX_PLAYERS; i++)
		{
			if(PlayerInfo[playerid][Login] < 1) continue;
			iter++;
		}
		new Text[1000];
		format(Text, 1000, "Приоритет:\t\t%i\nАвторизовано игроков:\t\t%i\n", Priority, iter);
		ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Информация о сервере", Text, "Ок", "Отмена");
		return 1;	
	}
}

CMD:setpriority(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0) 	return 0;
	if(PlayerInfo[playerid][Admin] < 4) 	return 0;
	else
	{
		new pa;
		if(sscanf(params, "i", pa))			return SendClientMessage(playerid, 0xff000000, "Вы ввели некорректное значение приоритета.");
		if(pa < 0 || pa > MAX_LOBBY - 1) 	return SendClientMessage(playerid, 0xff000000, "Вы ввели некорректное значение приоритета.");
		new text[144];
		format(text, 144, "Вы поменяли приоритет с %i на %i", Priority, pa);
		SendClientMessage(playerid, 0xff000000, text);
		Priority = pa;
		return 1;
	}
}

CMD:acommands(playerid)
{
	if(PlayerInfo[playerid][Login] == 0) 	return 0;
	if(PlayerInfo[playerid][Admin] < 1) 	return 0;
	new text[1000];
	new temp[140];
	temp = "/sinfo \t\t\t\t-\t\t\tИнформация о сервере";
	strcat(text, temp);
	temp = "\n/alm [№ лобби] [Текст]\t\t-\t\t\tСказать в лобби от имени администратора";
	strcat(text, temp);
	temp = "\n/veh [ID транспорта]\t\t-\t\t\tСоздать транспортное средство";
	strcat(text, temp);
	temp = "\n/check [ID игрока]\t\t-\t\t\tИнформация об игроке";
	strcat(text, temp);
	temp = "\n/lobby [ID лобби]\t\t-\t\t\tИнформация о лобби";
	strcat(text, temp);
	temp = "\n/kill\t\t\t\t-\t\t\tСамоубийство";
	strcat(text, temp);
	if(PlayerInfo[playerid][Admin] > 1)
	{
		temp = "\n/kick [ID игрока] [Причина]\t-\t\t\tКикнуть игрока с указанной причиной";
		strcat(text, temp);
		temp = "\n/ainfo [ID игрока]\t\t-\t\t\tПосмотреть информацию об аккаунте";
		strcat(text, temp);
		temp = "\n/delveh [ID транспорта]\t-\t\t\tУдалить транспортное средство.";
		strcat(text, temp);
		temp = "\n/mute [ID игрока] [время] [причина]\t-\t\t\tВыдать затычку игроку";
		strcat(text, temp);
	}
	if(PlayerInfo[playerid][Admin] > 3)
	{
		temp = "\n/setpriority [приоритет]\t\t-\t\t\tУстановить приоритет лобби";
		strcat(text, temp);
		temp = "\n/gmx\t\t\t\t-\t\t\tПерезагрузить сервер полностью";
		strcat(text, temp);
		temp = "\n/boostlobbies\t\t\t-\t\t\t(отладка для лобби, делает все лобби заполненными кроме последнего)";
		strcat(text, temp);
	}
	ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Команды", text, "Ок", "");
	return 1;
}

forward CreateLeftUI(playerid);
public CreateLeftUI(playerid)
{
	new Text[200];
	new name[MAX_PLAYER_NAME];
	name = GPN(LobbyInfo[PlayerInfo[playerid][Lb]][Suspect]);
	format(Text, 200, "~n~~n~Time remaining: 10 sec~n~~n~Suspect: %s~n~~n~Minimap: HUISIBLE~n~~n~", LobbyInfo[PlayerInfo[playerid][Lb]][Timer], name);
	LeftUI[playerid] = CreatePlayerTextDraw(playerid, 110, 200, Text);
	PlayerTextDrawSetShadow(playerid, LeftUI[playerid], 0);
	PlayerTextDrawUseBox(playerid, LeftUI[playerid], 1);
	PlayerTextDrawLetterSize(playerid, LeftUI[playerid], 0.25, 1.0);
	PlayerTextDrawBoxColor(playerid, LeftUI[playerid], 0x000000FF);
	PlayerTextDrawFont(playerid, LeftUI[playerid], 2);
	PlayerTextDrawAlignment(playerid, LeftUI[playerid], 2);
	PlayerTextDrawTextSize(playerid, LeftUI[playerid], 170, 200);

	new Name[MAX_PLAYER_NAME];
	Name = GPN(playerid);
	new text[36];
	format(text, 36, "~n~%s(%i)~n~~n~", Name, playerid);
	LeftUP[playerid] = CreatePlayerTextDraw(playerid, 110, 180, text);
	PlayerTextDrawSetShadow(playerid, LeftUP[playerid], 0);
	PlayerTextDrawUseBox(playerid, LeftUP[playerid], 1);
	PlayerTextDrawLetterSize(playerid, LeftUP[playerid], 0.25, 1.0);
	PlayerTextDrawBoxColor(playerid, LeftUP[playerid], 0x0044BBFF);
	PlayerTextDrawAlignment(playerid, LeftUP[playerid], 2);
	PlayerTextDrawFont(playerid, LeftUP[playerid], 2);
	PlayerTextDrawTextSize(playerid, LeftUP[playerid], 170, 200);
	return 1;
}

forward ShowLeftUI(playerid);
public ShowLeftUI(playerid)
{
	PlayerTextDrawShow(playerid, LeftUI[playerid]);
	PlayerTextDrawShow(playerid, LeftUP[playerid]);
	return 1;
}

forward HideLeftUI(playerid);
public HideLeftUI(playerid)
{
	PlayerTextDrawHide(playerid, LeftUI[playerid]);
	PlayerTextDrawHide(playerid, LeftUP[playerid]);
	return 1;
}

forward DestroyLeftUI(playerid);
public DestroyLeftUI(playerid)
{
	PlayerTextDrawDestroy(playerid, LeftUI[playerid]);
	PlayerTextDrawDestroy(playerid, LeftUP[playerid]);
	return 1;
}

forward UpdateLeftUI(playerid);
public UpdateLeftUI(playerid)
{
	new Text[120];
	new Name[MAX_PLAYER_NAME];
	new PlayerLobby = PlayerInfo[playerid][Lb];
	new Sus = LobbyInfo[PlayerLobby][Suspect];
	Name = GPN(Sus);
	format(Text, 120, "~n~~n~Time remaining: %i sec~n~~n~Suspect: %s~n~~n~Minimap: HUISIBLE~n~~n~", LobbyInfo[PlayerInfo[playerid][Lb]][Timer], Name);
	PlayerTextDrawSetString(playerid, LeftUI[playerid], Text);
	return 1;
}

CMD:gmx(playerid)
{
	if(PlayerInfo[playerid][Login] != 1) 	return 0;
	if(PlayerInfo[playerid][Admin] < 4) 	return 0;
	SendClientMessage(playerid, 0xFF000000, "Вы перезагрузили сервер.");
	SendRconCommand("gmx");
	return 1;
}

CMD:kill(playerid)
{
	if(PlayerInfo[playerid][Login] == 0) 	return 0;
	if(PlayerInfo[playerid][Lb] < 0)		return 0;
	SetPlayerHealth(playerid, 0);
	return 1;
}

CMD:boostlobbies(playerid)
{
	if(PlayerInfo[playerid][Admin] < 4) return 0;
	for(new i; i < 29; i++)
	{
		LobbyInfo[i][Activate]=2;
	}
	Priority=29;
	return 1;
}

stock SearchPriority()
{
	new a = Priority;
	for(new i = 0; i < MAX_LOBBY; i++)
	{
		if(LobbyInfo[i][Activate] > 1) 		continue;
		Priority = i;
		break;
	}
	if(Priority == a) Priority = -1;
	return 1;
}

forward CreateSusUI(playerid);
public CreateSusUI(playerid)
{
	new Text[200];
	new name[MAX_PLAYER_NAME];
	name = GPN(LobbyInfo[PlayerInfo[playerid][Lb]][Suspect]);
	format(Text, 200, "~n~~n~Time remaining: 10 sec~n~~n~Cops remaining: 1~n~~n~CAR HP: 1000~n~~n~");
	SusUI[playerid] = CreatePlayerTextDraw(playerid, 110, 200, Text);
	PlayerTextDrawSetShadow(playerid, SusUI[playerid], 0);
	PlayerTextDrawUseBox(playerid, SusUI[playerid], 1);
	PlayerTextDrawLetterSize(playerid, SusUI[playerid], 0.25, 1.0);
	PlayerTextDrawBoxColor(playerid, SusUI[playerid], 0x000000FF);
	PlayerTextDrawFont(playerid, SusUI[playerid], 2);
	PlayerTextDrawAlignment(playerid, SusUI[playerid], 2);
	PlayerTextDrawTextSize(playerid, SusUI[playerid], 170, 200);

	new Name[MAX_PLAYER_NAME];
	Name = GPN(playerid);
	new text[36];
	format(text, 36, "~n~%s(%i)~n~~n~", Name, playerid);
	NSusUI[playerid] = CreatePlayerTextDraw(playerid, 110, 180, text);
	PlayerTextDrawSetShadow(playerid, NSusUI[playerid], 0);
	PlayerTextDrawUseBox(playerid, NSusUI[playerid], 1);
	PlayerTextDrawLetterSize(playerid, NSusUI[playerid], 0.25, 1.0);
	PlayerTextDrawBoxColor(playerid, NSusUI[playerid], 0xFF1133FF);
	PlayerTextDrawAlignment(playerid, NSusUI[playerid], 2);
	PlayerTextDrawFont(playerid, NSusUI[playerid], 2);
	PlayerTextDrawTextSize(playerid, NSusUI[playerid], 170, 200);
	return 1;
}

forward ShowSusUI(playerid);
public ShowSusUI(playerid)
{
	PlayerTextDrawShow(playerid, SusUI[playerid]);
	PlayerTextDrawShow(playerid, NSusUI[playerid]);
	return 1;
}

forward HideSusUI(playerid);
public HideSusUI(playerid)
{
	PlayerTextDrawHide(playerid, SusUI[playerid]);
	PlayerTextDrawHide(playerid, NSusUI[playerid]);
	return 1;
}

forward DestroySusUI(playerid);
public DestroySusUI(playerid)
{
	PlayerTextDrawDestroy(playerid, SusUI[playerid]);
	PlayerTextDrawDestroy(playerid, NSusUI[playerid]);
	return 1;
}

forward UpdateSusUI(playerid);
public UpdateSusUI(playerid)
{
	new Text[200];
	new Veh = GetPlayerVehicleID(playerid);
	new Float:VHP;
	new PlayerLobby = PlayerInfo[playerid][Lb];
	if(!IsPlayerInAnyVehicle(playerid)) 
	{
		format(Text, 200, "~n~~n~Time remaining: %i sec~n~~n~Cops remaining: 1~n~~n~CAR HP: NOT SEARCHED~n~~n~", LobbyInfo[PlayerLobby][Timer]);
	}
	else
	{
		GetVehicleHealth(Veh, VHP);
		format(Text, 200, "~n~~n~Time remaining: %i sec~n~~n~Cops remaining: 1~n~~n~CAR HP: %i~n~~n~", LobbyInfo[PlayerLobby][Timer], floatround(VHP));
	}
	PlayerTextDrawSetString(playerid, SusUI[playerid], Text);
	return 1;
}

CMD:kick(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0) 
	{
		return 0;
	}
	if(PlayerInfo[playerid][Admin] < 1)
	{
		return 1;
	}
	if(PlayerInfo[playerid][Admin] == 1)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: у вас недостаточно прав для использования данной функции.");
	}
	new plid, reason[256];
	if(sscanf(params, "is", plid, reason)) 
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Введите /kick [ID игрока] [причина]");
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: id игрока не может быть меньше нуля и больше 299");
	}
	if(PlayerInfo[plid][Login] == 0)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Данный игрок не авторизован.");
	}
	if(isnull(reason))
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы ввели некорректную причину");
	}
	if(strlen(reason) > 32 || strlen(reason) < 2)
	{
		return SendClientMessage(playerid, 0xff000000, "Ошибка: причина должна иметь не менее 2 и не более 32 символов.");
	}
	for(new i; i < strlen(reason); i++)
	{
		switch(reason[i])
		{
			case 'A'..'Z': continue;
			case 'a'..'z': continue;
			case '0'..'9': continue;
			case ' ': continue;
			default: 
			{
				return SendClientMessage(playerid, 0xFF000000, "Ошибка: в причине можно использовать только латиницу, цифры и пробелы");
			}
		}
	}
	new Text[144];
	new AName[MAX_PLAYER_NAME], KName[MAX_PLAYER_NAME];
	AName = GPN(playerid);
	KName = GPN(plid);
	for(new i; i < MAX_PLAYERS; i++)
	{
		format(Text, 144, "Администратор %s(%i) кикнул %s(%i). Причина: %s", AName, playerid, KName, plid, reason);
		SendClientMessage(i, 0xFF000000, Text);
	}
	Kick(plid);
	return 1;
}

CMD:mute(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0) 	
	{
		return 0;
	}
	if(PlayerInfo[playerid][Admin] < 2)		
	{
		return SendClientMessage(playerid, 0xFF000000, "У Вас недостаточно прав для использования данной команды.");
	}
	new plid, time, reason[256];
	if(sscanf(params, "iis", plid, time, reason)) 
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: используйте /mute [id] [кол-во минут] [причина]");
	}
	if(isnull(reason))
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы не ввели причину для мута");
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: id игрока не может быть меньше нуля и больше 299");
	}
	if(PlayerInfo[plid][Mute] > 0)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: данный игрок уже замьючен.");
	}
	if(PlayerInfo[plid][Login] < 1)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: данный игрок не авторизован.");
	}
	if(time < 1 || time > 180) 
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: мут не может быть менее 1 и более 180 минут.");
	}
	if(strlen(reason) < 2 || strlen(reason) > 32) 
	{
		return SendClientMessage(playerid, 0xff000000, "Ошибка: длина причины не может быть менее 2 и более 32 символов.");
	}
	for(new i; i < strlen(reason); i++)
	{
		switch(reason[i])
		{
			case 'A'..'Z': continue;
			case 'a'..'z': continue;
			case '0'..'9': continue;
			case ' ': continue;
			default: 
			{
				return SendClientMessage(playerid, 0xFF000000, "Ошибка: в причине можно использовать только латиницу, цифры и пробелы");
			}
		}
	}
	new text[144];
	new AName[MAX_PLAYER_NAME], PName[MAX_PLAYER_NAME];
	AName = GPN(playerid);
	PName = GPN(plid);
	format(text, 144, "Адм. %s выдал мут игроку %s(%i) на %i мин. Причина:%s", AName, PName, plid, time, reason);
	PlayerInfo[plid][Mute] = time*60;
	SendClientMessageToAll(0xff220000, text);
	return 1;
}

CMD:delveh(playerid, params[])
{
	if(PlayerInfo[playerid][Login] < 1)
	{
		return 0;
	}
	if(PlayerInfo[playerid][Admin] < 2)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: У вас недостаточно прав для этой команды");
	}
	new veh;
	if(sscanf(params, "i", veh))
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы ввели некорректный id транспорта");
	}
	if(veh < 1 || veh > 2048)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы ввели некорректный id транспорта");
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(veh == PlayerVehicle[i]) 
		{
			return SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы не можете удалить транспорт игрока");
		}
	}
	if(IsValidVehicle(veh) == 0)
	{
		return SendClientMessage(playerid, 0xFF000000, "Такой транспорт не существует.");
	}
	DestroyVehicle(veh);
	SendClientMessage(playerid, 0x3300EE, "Транспорт успешно удален.");
	return 1;
}

CMD:report(playerid, params[])
{
	if(PlayerInfo[playerid][Login] < 1) 
	{
		return 1;
	}
	new text[256];
	if(sscanf(params, "s", text))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не ввели текст.");
	}
	if(isnull(text))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не ввели текст.");
	}
	if(strlen(text) > 100)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: В репорте должно быть не более 100 символов.");
	}
	new m[144];
	format(m, 144, "%s(%i) в репорт:%s");
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(PlayerInfo[i][Login] < 1)
		{
			continue;
		} 
		if(PlayerInfo[i][Admin] < 1) 
		{
			continue;
		}
		SendClientMessage(i, COLOR_YELLOW, m);
	}
	SendClientMessage(playerid, COLOR_YELLOW, "Ваш запрос отправлен администрации. Ожидайте ответа!");
	return 1;
}

CMD:warn(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0)	
	{
		return 0;
	}
	if(PlayerInfo[playerid][Admin] < 1) 
	{
		return 0;
	}
	new plid, text[256];
	if(sscanf(params, "is", plid, text))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не ввели текст.");
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы ввели id игрока вне диапазона");
	}
	if(isnull(text))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не ввели текст.");
	}
	if(strlen(text) > 16)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: В причине должно быть 16 символов и менее.");
	}
	for(new i; i < strlen(text); i++)
	{
		switch(text[i])
		{
			case 'A'..'Z': continue;
			case 'a'..'z': continue;
			case '0'..'9': continue;
			case ' ': continue;
			default: 
			{
				return SendClientMessage(playerid, 0xFF000000, "Ошибка: в причине можно использовать только латиницу, цифры и пробелы");
			}
		}
	}
	//Выдача варна
	if(PlayerInfo[plid][Warn] < 3)
	{
		PlayerInfo[plid][Warn]++;
		new Text[144], AName[MAX_PLAYER_NAME], PName[MAX_PLAYER_NAME];
		AName = GPN(playerid);
		PName = GPN(plid);
		format(Text, 144, "Адм. %s выдал предупреждение %s(%i) %i/3. Причина: %s", AName, PName, plid, PlayerInfo[playerid][Warn], text);
		for(new i; i < MAX_PLAYERS; i++)
		{
			SendClientMessage(i, COLOR_YELLOW, Text);
		}
		if(PlayerInfo[plid][Warn] == 3)
		{
			Kick(plid);
		}
	}
	return 1;
}

forward Piu();
public Piu()
{
	for(new k; k < MAX_LOBBY; k++)
	{
		new playerid = LobbyInfo[k][Suspect];
		if(playerid == -1) continue;
		if(PlayerInfo[playerid][Login] == 0) continue;
		if(playerid == LobbyInfo[k][Suspect])
		{
			UpdateSusUI(playerid);
		}
	}
	return 1;
}

CMD:pm(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0) 
	{
		return 0;
	}
	return 1;
}