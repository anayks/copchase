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

#define MAX_PLOBBY 4
#define MAX_LOBBY 30

#define LOBBY_NOT_CREATED 0
#define LOBBY_CREATED 1
#define LOBBY_WAITING 2
#define LOBBY_PLAYING 3

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
}

enum LI
{
	Suspect,
	Players,
	Activate,
	Timer,
	TextDraws
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
new Speed[MAX_PLAYERS];
new HeartBit;
new PlayerVehicle[MAX_PLAYERS];

public OnGameModeInit()
{
	sql = mysql_connect("db2.myarena.ru", "anayks_anayks", "RicardoMilos", "anayks_Akakiy");
	SetGameModeText("Copchase Beta Test");
	EnableStuntBonusForAll(false);
	DisableInteriorEnterExits();
	Priority = 0;
	for(new k; k < MAX_LOBBY; k++)
	{
		LobbyInfo[k][Suspect] = -1;
		LobbyInfo[k][Timer] = -1;
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
	return 1;
}

public OnGameModeExit()
{
    KillTimer(HeartBit);
    return 1;
}

public OnPlayerConnect(playerid)
{
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
		DestroyVehicle(PlayerInfo[playerid][Vehicle]);
	}
	if(PlayerInfo[playerid][Lb] > -1)
	{
		for(new i; i < MAX_PLOBBY; i++)
		{
			if(LobbyID[PlayerInfo[playerid][Lb]][i] != playerid) continue;
			LobbyID[PlayerInfo[playerid][Lb]][i] = -1;
			LobbyName[PlayerInfo[playerid][Lb]][i] = "";
		}
	}
	PlayerInfo[playerid][Skin] 		= -1;
	PlayerInfo[playerid][ID]		= -1;
	PlayerInfo[playerid][Login] 	= -1;
	PlayerInfo[playerid][Donate] 	= -1;
	PlayerInfo[playerid][Money] 	= -1;
	PlayerInfo[playerid][Admin] 	= -1;
	PlayerInfo[playerid][Lb] 		= -1;
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
						CameraMenu(playerid);
					  	CreateMenuTD(playerid);
					  	ShowMenuTD(playerid);
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
	LoadAccount(playerid);
	PlayerInfo[playerid][Login] = 1;
	SetSpawnInfo(playerid, 0,0,0,0,0,0,0,0, 0,0,0,0);
	SetPlayerCameraPos(playerid, 1627.4650, -1045.1171, 24.8984);
	SpawnPlayer(playerid);
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
	cache_get_value_name_int(0, "Money", PlayerInfo[playerid][Money]);
	cache_get_value_name_int(0, "Admin", PlayerInfo[playerid][Admin]);
	cache_get_value_name_int(0, "Donate", PlayerInfo[playerid][Donate]);
	cache_get_value_name_int(0, "Vehicle", PlayerInfo[playerid][Vehicle]);
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
					if(LobbyInfo[Priority][Players] == 3) // Если игрок подключился третьим
					{
						LobbyInfo[Priority][Timer] = 10; // Задаем 10 секунд до подключения к лобби
						SendClientMessage(playerid, 0xFF000000, "Вы подключились в лобби третьим, таймер запущен");
						SetPlayerVirtualWorld(playerid, Priority);
						LobbyInfo[Priority][Activate] = 2; // Состояние лобби: запущен таймер
						CreateTimerUI(playerid);
					}
				}
				else
				{
					if(LobbyInfo[Priority][Players] + 1 == MAX_PLOBBY) //Если игрок занимает последний слот
					{
						GiveSlot(playerid, Priority);
						SetCameraBehindPlayer(playerid);
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
		if(LobbyID[LB][k] == playerid) continue;
		if(LobbyID[LB][k] == -1) continue;
		if(isnull(LobbyName[LB][k])) continue;
		if(LobbyID[LB][k] == LobbyInfo[LB][Suspect]) continue;
		new Name[MAX_PLAYER_NAME];
		Name = GPN(playerid);

		PoliceUI[playerid][i] = CreatePlayerTextDraw(playerid, 470, 230 + 15 * i, "VyacheslavIvankovmas");
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

forward CreateTimerUI(playerid);
public CreateTimerUI(playerid)
{
	new string[32];
	new lobbyid = PlayerInfo[playerid][Lb];
	format(string, 32, "Time remaining: __%i sec", LobbyInfo[lobbyid][Timer]);
	TimerUI[playerid] = CreatePlayerTextDraw(playerid, 160, 380, string);
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
					LobbyInfo[i][Suspect] = a;
					break;
				}
				for(new k; k < MAX_PLOBBY; k++)
				{
					if(LobbyID[i][k] == LobbyInfo[i][Suspect]) continue;
					if(LobbyID[i][k] == -1) continue;
					if(isnull(LobbyName[i][k])) continue;
					CreatePoliceUI(LobbyID[i][k]);
					ShowPoliceUI(LobbyID[i][k]);
					Speed[LobbyID[i][k]] = SetTimerEx("SpeedTimer", 200, true, "i", LobbyID[i][k]);
					SendClientMessage(LobbyID[i][k], 0xFF000000, "Лобби запущено.");
				}
				SendClientMessage(LobbyInfo[i][Suspect], 0xFF000000, "Лобби запущено.");
				Speed[LobbyInfo[i][Suspect]] = SetTimerEx("SpeedTimer", 200, true, "i", LobbyInfo[i][Suspect]);
				LobbyInfo[i][Activate] = 3;
				LobbyInfo[i][Timer] = 40;
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

			}
			else if(LobbyInfo[i][Timer] > 0) 
			{
				LobbyInfo[i][Timer]--;
			}
		}
	}
	return 1;
}

forward SpeedTimer(playerid);
public SpeedTimer(playerid)
{
	new PlVeh, Float:VX, Float:VY, Float:VZ;
	PlVeh = GetPlayerVehicleID(playerid);
	GetVehicleVelocity(PlVeh, VX, VY, VZ);
	new Float:Speeds;
	Speeds = floatsqroot(VX*VX+VY*VY+VZ*VZ)*179;
	Speeds = floatround(Speeds);
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
	if(sscanf(params, "i", lid)) return SendClientMessage(playerid, 0xFF000000, "Ошибка, вы ввели некорректный ID лобби");
	if(lid < 0 || lid > MAX_LOBBY - 1) return SendClientMessage(playerid, 0xFF000000, "Ошибка, вы ввели некорректный ID лобби");
	new MSGL[1000];
	format(MSGL, 1000, "Лобби номер %i \n");
	new temp[100];
	for(new i; i < MAX_PLOBBY; i++)
	{
		new name[MAX_PLAYER_NAME];
		name = LobbyName[lid][i];
		if(isnull(name))
		{
			name = "Имя не заполнено";
		}
		format(temp, 100, "%i слот: \t\t%s (%i)\n", i, name, LobbyID[lid][i]);
		strcat(MSGL, temp);
	}
	new LN[24];
	format(LN, 24, "Лобби №%i", lid);
	ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, LN, MSGL, "Ок", "");
	return 0;
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
		new PlayerSlot;
		for(new i; i < MAX_PLOBBY; i++)
		{
			if(LobbyID[PlayerLobby][i] == playerid) 
			{
				PlayerSlot = i;
				break;
			}
		}
		format(info, sizeof(info), "Виртуальный мир: \t\t%i\nНомер лобби: \t\t%i\nСлот в лобби: \t\t%i\n", PVW, PlayerLobby, PlayerSlot);
		ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Ваш чекер", info, "Окей", "");
		return 1;
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1) return SendClientMessage(playerid, 0xFF000000, "Вы ввели некорректный ID. Повторите попытку.");
	new info[500];
	new PVW = GetPlayerVirtualWorld(plid);
	new PlayerLobby = PlayerInfo[plid][Lb];
	new PlayerSlot;
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[PlayerLobby][i] == plid) 
		{
			PlayerSlot = i;
			break;
		}
	}
	format(info, sizeof(info), "Виртуальный мир: \t\t%i\nНомер лобби: \t\t%i\nСлот в лобби: \t\t%i\nАвторизован: \t\t%i", PVW, PlayerLobby, PlayerSlot, PlayerInfo[plid][Login]);
	ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Ваш чекер", info, "Окей", "");
	return 1;
}

CMD:alm(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0) 	return 0;
	if(PlayerInfo[playerid][Admin] == 0) 	return 0;
	new lid, ml[100];
	if(sscanf(params, "is", lid, ml)) 		return 0;
	if(isnull(ml)) 							return 0;
	if(lid < 0 || lid > MAX_LOBBY) 			return 0;
	new Message[144];
	format(Message, 144, "Адм. %s в лобби: %s", GPN(playerid), ml);
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[lid][i] == -1) return 0;
		SendClientMessage(LobbyID[lid][i], 0xFF000000, Message);
	}
	return 1;
}

CMD:sinfo(playerid)
{
	if(PlayerInfo[playerid][Login] == 0) return 0;
	if(PlayerInfo[playerid][Admin] < 3) return 0;
	else
	{
		new Text[1000];
		format(Text, 1000, "Приоритет: \t\t%i\n", Priority);
		ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Информация о сервере", Text, "Ок", "Отмена");
		return 1;	
	}
}

CMD:setpriority(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0) return 0;
	if(PlayerInfo[playerid][Admin] < 3) return 0;
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

public OnPlayerCommandPerformed(playerid, cmdtext[], success) 
{ 
    return 1; 
} 