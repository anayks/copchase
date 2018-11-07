#include <a_samp>
#include <ZCMD>
#include <a_players>
#include <a_vehicles>
#include <a_mysql>
#include <sscanf>
#include <streamer>

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
#define MAX_PLOBBY 10
#define MAX_LOBBY 30

#define LOBBY_NOT_CREATED 0
#define LOBBY_CREATED 1
#define LOBBY_WAITING 2
#define LOBBY_PLAYING 3

#define COLOR_RED 0xFF000000
#define COLOR_YELLOW 0xeeee0000
#define COLOR_BLUE 0x0077FF00

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
	PWins,
	Kills,
	Losses,
	Deaths,
	Mute,
	Warn,
	Score,
	Attempts,
	Wins,
	Slot,
	Vision,
	Amt,
}

enum LI
{
	Map,
	Suspect,
	Players,
	Activate,
	Timer,
	TextDraws,
	SA,
}

enum SI
{
	TimeInLobby,
	TimeInGame
}

new ServerInfo[SI];
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
		PlayerInfo[i][Vision] = 1;
	}
	ServerInfo[TimeInLobby] = 30;
	ServerInfo[TimeInGame] = 60;
	HeartBit = SetTimer("Bit", 1000, true);
	BestBit = SetTimer("Piu", 200, true);
	CreateDynamicObject(4504, 60.18874, -1532.35376, 6.83591,   0.00000, 0.00000, -5.76000);
	CreateDynamicObject(978, 163.43134, -1403.72998, 46.40740,   0.00000, 5.00000, 235.00000);
	CreateDynamicObject(978, 169.27522, -1396.12659, 47.25826,   0.00000, 4.00000, 231.26009);
	CreateDynamicObject(19972, 165.75171, -1399.22803, 45.47409,   0.00000, 0.00000, 58.08001);
	CreateDynamicObject(3568, 782.69305, -912.95221, 57.77720,   14.00000, 0.00000, 58.00000);
	CreateDynamicObject(16439, 790.26508, -930.01837, 43.47972,   -4.00000, 0.00000, 196.00000);
	CreateDynamicObject(16439, 738.22394, -888.17786, 43.81797,   0.00000, 0.00000, 59.51999);
	CreateDynamicObject(18225, 1212.73401, -754.83734, 79.07655,   0.00000, 0.00000, -76.80002);
	CreateDynamicObject(18225, 1117.55151, -765.09766, 86.96117,   0.00000, 0.00000, 58.37998);
	CreateDynamicObject(18225, 1144.12256, -761.30280, 69.51940,   0.00000, 0.00000, 106.01994);
	CreateDynamicObject(3578, 1160.32751, -800.51031, 54.66018,   0.00000, 0.00000, 0.36000);
	CreateDynamicObject(3578, 1149.78882, -800.69733, 54.66018,   0.00000, 0.00000, 0.36000);
	CreateDynamicObject(18225, 1145.16321, -752.10913, 69.21547,   6.06000, -1.08000, 138.11996);
	CreateDynamicObject(19950, 1155.17395, -802.60437, 53.30225,   0.00000, 0.00000, -1.44000);
	CreateDynamicObject(19972, 1153.40686, -802.27588, 53.28902,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1712.87830, -613.71167, 39.66547,   0.00000, 0.00000, -28.38000);
	CreateDynamicObject(981, 1712.59082, -609.99280, 39.66547,   0.00000, 0.00000, 149.69989);
	CreateDynamicObject(4519, 2286.90991, -1118.06641, 27.52838,   0.00000, 5.00000, -90.00000);
	CreateDynamicObject(981, 2880.33472, -989.59070, 10.74246,   0.00000, 0.00000, -1.68000);
	CreateDynamicObject(981, 2880.45923, -986.15216, 10.74246,   0.00000, 0.00000, 178.85997);
	CreateDynamicObject(981, 2842.64038, -1038.45044, 23.31260,   0.00000, 0.00000, 161.04031);
	CreateDynamicObject(621, 2920.26831, -1393.22034, 8.69464,   348.00000, 75.00000, 185.00000);
	CreateDynamicObject(621, 2913.71826, -1390.14478, 9.44726,   357.00000, -84.00000, 99.82001);
	CreateDynamicObject(1423, 2907.02979, -1386.97571, 10.63716,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1423, 2901.10767, -1387.04663, 10.63716,   0.00000, 0.00000, 2.88000);
	CreateDynamicObject(1423, 2903.44995, -1418.55530, 10.63716,   0.00000, 0.00000, 2.88000);
	CreateDynamicObject(1423, 2908.44360, -1418.62854, 10.63716,   0.00000, 0.00000, 2.88000);
	CreateDynamicObject(1237, 2903.93970, -1386.99792, 9.94540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1237, 2905.81787, -1418.14063, 9.94540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3626, 2158.96729, -2500.90186, 14.90399,   -78.00000, 0.00000, 89.81996);
	CreateDynamicObject(3567, 2161.64233, -2502.43359, 12.94284,   0.00000, 0.00000, 176.93996);
	CreateDynamicObject(979, 2159.69092, -2489.49121, 13.12054,   0.00000, 0.00000, -24.78000);
	CreateDynamicObject(979, 2165.88062, -2496.23608, 13.12054,   0.00000, 0.00000, -66.96001);
	CreateDynamicObject(979, 2169.58569, -2505.09497, 13.12054,   0.00000, 0.00000, -67.44001);
	CreateDynamicObject(978, 2159.18481, -2517.56421, 13.06041,   0.00000, 0.00000, 187.43993);
	CreateDynamicObject(978, 2167.47998, -2513.67725, 13.06041,   0.00000, 0.00000, 225.95985);
	CreateDynamicObject(1290, 1530.44373, -2671.83472, 8.17315,   -94.00000, 0.00000, 2.00000);
	CreateDynamicObject(1423, 1536.15576, -2673.32617, 7.92449,   0.00000, 0.00000, 87.65997);
	CreateDynamicObject(1423, 1536.29187, -2667.79028, 7.92449,   0.00000, 0.00000, 87.65997);
	CreateDynamicObject(1423, 1525.16052, -2667.56152, 8.50177,   0.00000, 0.00000, 89.81996);
	CreateDynamicObject(1423, 1525.50354, -2672.77246, 8.50177,   0.00000, 0.00000, 89.81996);
	CreateDynamicObject(3757, 1594.82715, -1367.89087, 29.18693,   357.00000, 83.00000, -89.24003);
	CreateDynamicObject(1423, 1598.82117, -1380.45996, 28.30688,   0.00000, 0.00000, 6.36000);
	CreateDynamicObject(1423, 1593.73303, -1381.00952, 28.30688,   0.00000, 0.00000, 6.36000);
	CreateDynamicObject(1423, 1589.11719, -1381.47107, 28.30688,   0.00000, 0.00000, 6.36000);
	CreateDynamicObject(979, 1592.38330, -1364.31226, 28.48394,   0.00000, 0.00000, -17.88000);
	CreateDynamicObject(979, 1600.89783, -1368.11121, 28.48394,   0.00000, 0.00000, -30.30000);
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
	PlayerInfo[playerid][Warn] = 0;
	PlayerInfo[playerid][Attempts] = 0;
	cache_get_value_index_int(0, 0, row);
	PlayerInfo[playerid][Amt] = 0;
	if(row == 0)
	{
		new text[1000];
		format(text, 1000, "{ffffff}Добро пожаловать на CopChase Project.\nЧтобы начать игру, Вам необходимо зарегистрироваться.\n\nВведите пароль для Вашего аккаунта.\nПри вводе учтите правила, написанные ниже:\n\n\t{009933}Примечание:\n\t- Пароль может состоять из латинских символов, цифр и подчеркиваний.\n\t- Пароль чувствителен к регистру.\n\t- Пароль должен содержать от 6-ти до 20-ти символов.");
	    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Регистрация", text, "Далее", "Отмена");
	}
	else
	{
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "{ffffff}Добро пожаловать на Copchase Server\nВаш аккаунт зарегистрирован.\nЧтобы начать игру, Вам нужно ввести пароль,\nКоторый Вы указали при регистрации.", "Далее", "Отмена");
	}
	RemoveBuildingForPlayer(playerid, 3757, 1593.4688, -1368.7344, 32.2500, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1530.5625, -2677.1250, 13.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 621, 2913.8750, -1389.0859, 7.3594, 0.25);
	RemoveBuildingForPlayer(playerid, 621, 2915.0156, -1392.9141, 6.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 13717, 1161.3203, -755.0156, 84.8047, 0.25);
	RemoveBuildingForPlayer(playerid, 13785, 1161.3203, -755.0156, 84.8047, 0.25);
	RemoveBuildingForPlayer(playerid, 4504, 56.3828, -1531.4531, 6.7266, 0.25);
	InterpolateCameraPos(playerid, 1634.7979,-1169.3313,118.7199, 1622.6156,-1345.4376,130.4928, 10000, CAMERA_CUT);
	InterpolateCameraLookAt(playerid, 1622.6156,-1345.4376,130.4928,1619.6156,-1380.4376,120.4928, 10000, CAMERA_MOVE);
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
						continue;
					}
					if(LobbyID[lobbyid][i] != -1)
					{
						ColorPoliceUI(playerid, PlayerInfo[playerid][Slot]);
					}
				}
				PlayerInfo[playerid][Slot] = -1;
			}
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
	PlayerInfo[playerid][Warn]		= -1;
	PlayerInfo[playerid][Attempts] 	= -1;
	PlayerInfo[playerid][Vision] 	= 0;
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
       				PlayerInfo[playerid][Attempts]++;
       				if(PlayerInfo[playerid][Attempts] == 3)
       				{
       					Kick(playerid);
       				}
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
						    	PlayerInfo[playerid][Attempts]++;
			       				if(PlayerInfo[playerid][Attempts] == 3)
			       				{
			       					Kick(playerid);
			       				}
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
					new a = random(3);
					switch(a)
					{
						case 0: PlayerInfo[playerid][Skin] = 3;
						case 1: PlayerInfo[playerid][Skin] = 6;
						case 2: PlayerInfo[playerid][Skin] = 8;
					}
					format(query, 256, "INSERT INTO `Accounts` (`ID`, `Name`, `Password`, `Admin`, `Money`, `Donate`, `Online`, `Skin`) VALUES ('%i', '%s', '%s', '0', '0', '0', '1', '%i')", rows, Name, inputtext, PlayerInfo[playerid][Skin]);
					mysql_query(sql, query);
					PlayerInfo[playerid][Login] = 1;
					SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
					SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
					PlayerInfo[playerid][Vehicle] = 614;
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
       				ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "{ffffff}Произошла ошибка. \nПожалуйста, повторите попытку авторизации.\n\n\t{00ff00}Примечание:\n\t- Пароль чувствителен к регистру.", "Продолжить", "");
       				PlayerInfo[playerid][Attempts]++;
       				if(PlayerInfo[playerid][Attempts] == 3)
       				{
       					Kick(playerid);
       				}
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
						    	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "{ffffff}Вы ввели запрещённые символы\nПожалуйста, повторите попытку авторизации.\n\n\t{00ff00}Примечание:\n\t- Пароль чувствителен к регистру.", "Продолжить", "");
						    	PlayerInfo[playerid][Attempts]++;
			       				if(PlayerInfo[playerid][Attempts] == 3)
			       				{
			       					Kick(playerid);
			       				}
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
						ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Авторизация", "{ffffff}Пароль введен неверно\nПожауйста, повторите попытку авторизации.\n\n\t{00ff00}Примечание:\n\t- Пароль чувствителен к регистру.", "Продолжить", "");
						PlayerInfo[playerid][Attempts]++;
	       				if(PlayerInfo[playerid][Attempts] == 3)
	       				{
	       					Kick(playerid);
	       				}
					}
					else // Человек авторизовался
					{
						SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
						LoadAccount(playerid);
						CameraMenu(playerid);
					  	CreateMenuTD(playerid);
					  	ShowMenuTD(playerid);
					  	SendClientMessage(playerid, 0x0055FF00, "Добро пожаловать на CopChase Project");
					  	format(query, 256, "UPDATE `Accounts` SET `Online` = %i WHERE `Name` = '%s'", playerid, Name);
						mysql_query(sql, query);
					  	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
					  	for(new i; i < MAX_PLAYERS; i++)
					  	{
					  		SetPlayerMarkerForPlayer(playerid, i, 0xFFFFFF00);
					  		SetPlayerMarkerForPlayer(i, playerid, 0xFFFFFF00);
					  	}
					}
				}
		    }
		}
		case 3:
		{
			if(response)
			{
				if(listitem == 0)
				{
					new text[300];
					format(text, 300, "Настройка сервера\tЗначение\nТаймер в лобби:\t%i сек\nТаймер игры:\t%i сек", ServerInfo[TimeInLobby], ServerInfo[TimeInGame]);
					ShowPlayerDialog(playerid, 4, DIALOG_STYLE_TABLIST_HEADERS, "Настройки лобби", text, "Выбор", "Отмена");
				}
			}
		}
		case 4:
		{
			if(response)
			{
				new text[300];
				if(listitem == 0) // Таймер в лобби
				{
					format(text, 300, "Формат ввода данных: целочисленное значение.\nФормат числа: секунды.\nУстановленное время сейчас:\t{0066ff}%i", ServerInfo[TimeInLobby]);
					ShowPlayerDialog(playerid, 5, DIALOG_STYLE_INPUT, "Настройка таймера в лобби.", text, "Ввод", "Отмена");
				}
				else if(listitem == 1) //Таймер игры
				{
					format(text, 300, "Формат ввода данных: целочисленное значение.\nФормат числа: секунды.\nУстановленное время сейчас:\t{0066ff}%i", ServerInfo[TimeInLobby]);
					ShowPlayerDialog(playerid, 6, DIALOG_STYLE_INPUT, "Настройка таймера в игре.", text, "Ввод", "Отмена");
				}
			}
		}
		case 5:
		{
			if(response) //Если нажал "Ввод"
			{
				new text[300];
				if(isnull(inputtext))
				{
					format(text, 300, "Формат ввода данных: целочисленное значение.\nФормат числа: секунды.\nУстановленное время сейчас:\t{0066ff}%i\n\n{ff0000}Ошибка: Вы не ввели число!", ServerInfo[TimeInLobby]);
					ShowPlayerDialog(playerid, 5, DIALOG_STYLE_INPUT, "Настройка таймера в лобби.", text, "Ввод", "Отмена");
				}
				new ch;
				ch = strval(inputtext);
				if(ch < 1)
				{
					format(text, 300, "Формат ввода данных: целочисленное значение.\nФормат числа: секунды.\nУстановленное время сейчас:\t{0066ff}%i\n\n{ff0000}Ошибка: Вы ввели некорректное число!", ServerInfo[TimeInLobby]);
					ShowPlayerDialog(playerid, 5, DIALOG_STYLE_INPUT, "Настройка таймера в лобби.", text, "Ввод", "Отмена");
				}
				else
				{
					new Name[MAX_PLAYER_NAME];
					Name = GPN(playerid);
					format(text, 300, "Адм. %s изменил время в лобби с %i до %i сек.", Name, ServerInfo[TimeInLobby], ch);
					for(new i; i < MAX_PLAYERS; i++)
					{
						SendClientMessage(i, COLOR_BLUE, text);
					}
					ServerInfo[TimeInLobby] = ch;
				}
			}
		}
		case 6:
		{
			if(response)
			{
				new text[300];
				if(isnull(inputtext))
				{
					format(text, 300, "Формат ввода данных: целочисленное значение.\nФормат числа: секунды.\nУстановленное время сейчас:\t{0066ff}%i\n\n{ff0000}Ошибка: Вы не ввели число!", ServerInfo[TimeInLobby]);
					ShowPlayerDialog(playerid, 6, DIALOG_STYLE_INPUT, "Настройка таймера в игре.", text, "Ввод", "Отмена");
				}
				new ch;
				ch = strval(inputtext);
				if(ch < 1)
				{
					format(text, 300, "Формат ввода данных: целочисленное значение.\nФормат числа: секунды.\nУстановленное время сейчас:\t{0066ff}%i\n\n{ff0000}Ошибка: Вы ввели некорректное число!", ServerInfo[TimeInLobby]);
					ShowPlayerDialog(playerid, 6, DIALOG_STYLE_INPUT, "Настройка таймера в игре.", text, "Ввод", "Отмена");
				}
				else
				{
					new Name[MAX_PLAYER_NAME];
					Name = GPN(playerid);
					format(text, 300, "Адм. %s изменил время в игре с %i до %i сек.", Name, ServerInfo[TimeInLobby], ch);
					for(new i; i < MAX_PLAYERS; i++)
					{
						SendClientMessage(i, COLOR_BLUE, text);
					}
					ServerInfo[TimeInGame] = ch;
				}
			}
		}
	}
	return 1;
}

stock CameraMenu(playerid)
{
	SetPlayerWorldBounds(playerid, 20000, -20000, 20000, -20000);
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
	if(PlayerInfo[playerid][Amt] > 5)
	{
		SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете писать в чат так часто.");
		return 0;
	}
	else
	{
		new Name[MAX_PLAYER_NAME];
		Name = GPN(playerid);
		new texts[144];
		if(strlen(text) > 100) 
		{
			SendClientMessage(playerid, COLOR_RED, "Ошибка: Ваше сообщение слишком длинное!");
			return 0;
		}
		format(texts, 144, "{ffb000}%s (%i): %s", Name, playerid, text);
		for(new i; i < MAX_PLAYERS; i++)
		{
			SendClientMessage(i, 0xFFFFFF00, texts);
		}
		PlayerInfo[playerid][Amt] = PlayerInfo[playerid][Amt] + 4;
		return 0;
	}
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
	else if(PlayerInfo[playerid][Lb] > -1)
	{
		SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
		SetPlayerPos(playerid, 285.9170, -1809.1401, 4.4176);
		SetPlayerFacingAngle(playerid, 270);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	new lobbyid = PlayerInfo[playerid][Lb];
	if(lobbyid < 0) // Если человек не в лобби
	{
		return 1;
	}
	else //Если человек в лобби
	{	
		if(LobbyInfo[lobbyid][Activate] > 2) // Если лобби в стадии игры
		{
			if(LobbyInfo[lobbyid][Suspect] == playerid)
			{
				if(LobbyInfo[lobbyid][SA] == 0) // Если он ещё не выходил из машины
				{
					LobbyInfo[lobbyid][SA] = 1;
					for(new i; i < MAX_PLOBBY; i++)
					{
						if(LobbyID[lobbyid][i] == -1)
						{
							continue;
						}
						GivePlayerWeapon(LobbyID[lobbyid][i], 24, 40);
						SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 1000);
					}
					for(new i; i < MAX_PLOBBY; i++)
					{
						if(LobbyID[lobbyid][i] == -1)
						{
							continue;
						}
						if(LobbyInfo[lobbyid][Suspect] == LobbyID[lobbyid][i])
						{
							continue;
						}
						SendClientMessage(playerid, 0x005F9900, "** [Рация 911] Диспетчер: подозреваемый вооружен! Разрешено применение огнестрельного оружия! **");
					}
					return 1;
				}
				else // Если выходил ранее
				{
					return 1;
				}
			}
			else // Если игрок не саспект
			{
				return 1;
			}
		}
		else // Если он вышел в лобби
		{
			return 1;
		}
	}
}

public OnPlayerCommandReceived(playerid,cmdtext[])
{
	if(PlayerInfo[playerid][Login] < 1)
	{
		return 0;
	}
	if(PlayerInfo[playerid][Amt] < 5)
	{
		PlayerInfo[playerid][Amt] = PlayerInfo[playerid][Amt] + 2;
		return 1;
	}
	else
	{
		SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы вводите команды слишком часто!");
		return 0;
	}
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
	if(newkeys & KEY_YES)
	{
		if(PlayerInfo[playerid][Amt] < 5)
		{
			new Lobby = PlayerInfo[playerid][Lb];
			if(PlayerInfo[playerid][Vision] == 0)
			{
				for(new i; i < MAX_PLOBBY; i++)
				{
					if(LobbyID[Lobby][i] == -1)
					{
						continue;
					}	
					if(LobbyID[Lobby][i] == LobbyInfo[Lobby][Suspect])
					{
						continue;
					}
					BluePoliceUI(LobbyID[Lobby][i], PlayerInfo[playerid][Slot]);
					SetPlayerMarkerForPlayer(LobbyID[Lobby][i], playerid, 0x0000FFFF);
				}
				PlayerInfo[playerid][Vision] = 1;
			}
			else
			{
				for(new i; i < MAX_PLOBBY; i++)
				{
					if(LobbyID[Lobby][i] == -1)
					{
						continue;
					}
					if(LobbyID[Lobby][i] == LobbyInfo[Lobby][Suspect])
					{
						continue;
					}
					DefaultPoliceUI(LobbyID[Lobby][i], PlayerInfo[playerid][Slot]);
					SetPlayerMarkerForPlayer(LobbyID[Lobby][i], playerid, 0xFFFFFF00);
				}
				PlayerInfo[playerid][Vision] = 0;
			}
			PlayerInfo[playerid][Amt]++;
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "Ошибка:Не флудите!");
		}
	}
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
						LobbyInfo[Priority][Timer] = ServerInfo[TimeInLobby]; // Задаем 10 секунд до подключения к лобби
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
	if(playertextid == MenuTD[playerid][4])
	{
		new text[1000];
		format(text, 1000, "Имя аккаунта:\t\t\t\t\t\t%s (%i id в игре)\nID аккаунта:\t\t\t\t\t\t%i\nДоната в данный момент:\t\t\t\t%i CC\n\nПобед в лобби:\t\t\t\t\t%i\nПоражений в лобби:\t\t\t\t\t%i\nМодель транспорта за подозреваемого:\t\t%i ID\nМодель персонажа за подозреваемого:\t\t%i ID", GPN(playerid), playerid, PlayerInfo[playerid][ID], PlayerInfo[playerid][Donate], PlayerInfo[playerid][Wins], PlayerInfo[playerid][Losses], PlayerInfo[playerid][Vehicle], PlayerInfo[playerid][Skin]);
		ShowPlayerDialog(playerid, 32000, DIALOG_STYLE_MSGBOX, "Статистика аккаунта", text, "Ок", "");
	}
	if(playertextid == MenuTD[playerid][3])
	{
		new text[1000];
		format(text, 1000, "Модель транспорта\tСтоимость\nElegy\t{00ee33}500.000$");
		ShowPlayerDialog(playerid, 2, DIALOG_STYLE_TABLIST_HEADERS, "Покупка транспортного средства.", text, "Выбор", "Отмена");
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

		RangeUI[playerid][i] = CreatePlayerTextDraw(playerid, 600, 230 + 15 * i, "");
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

stock DefaultPoliceUI(playerid, slot)
{
	PlayerTextDrawBoxColor(playerid, PoliceUI[playerid][slot], 0x000000FF);
	PlayerTextDrawBoxColor(playerid, RangeUI[playerid][slot], 0x000000FF);
}

stock ColorPoliceUI(playerid, slot)
{
	PlayerTextDrawBoxColor(playerid, PoliceUI[playerid][slot], 0xFF0000FF);
	PlayerTextDrawBoxColor(playerid, RangeUI[playerid][slot], 0xff0000FF);
	PlayerTextDrawSetString(playerid, RangeUI[playerid][slot], "");
}

stock BluePoliceUI(playerid, slot)
{
	PlayerTextDrawBoxColor(playerid, PoliceUI[playerid][slot], 0x00DD33FF);
	PlayerTextDrawBoxColor(playerid, RangeUI[playerid][slot], 0x00DD33FF);
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
				for(new i; i < MAX_PLOBBY; i++)
				{
					if(LobbyID[lobbyid][i] == playerid)
					{
						continue;
					}
					if(LobbyID[lobbyid][i] == -1)
					{
						continue;
					}
					ColorPoliceUI(i, PlayerInfo[playerid][Slot]);
				}
				HideLeftUI(playerid);
				HidePoliceUI(playerid);
				DestroyLeftUI(playerid);
				DestroyPoliceUI(playerid);
				DestroyVehicle(PlayerVehicle[playerid]);
				CameraMenu(playerid);
				ShowMenuTD(playerid);
			}
			else // Если полицейский умер последним
			{

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
				PutPlayerInVehicle(LobbyInfo[i][Suspect], PlayerVehicle[LobbyInfo[i][Suspect]], 0);
				new d = 0;
				new l = random(3);
				for(new k; k < MAX_PLOBBY; k++)
				{
					if(LobbyID[i][k] == LobbyInfo[i][Suspect]) continue;
					if(LobbyID[i][k] == -1) continue;
					if(isnull(LobbyName[i][k])) continue;
					PlayerInfo[LobbyID[i][k]][Slot] = d;
					d++;
					CreatePoliceUI(LobbyID[i][k]);
					ShowPoliceUI(LobbyID[i][k]);
					SendClientMessage(LobbyID[i][k], 0xFF000000, "Лобби запущено.");
					HideTimerUI(LobbyID[i][k]);
					DestroyTimerUI(LobbyID[i][k]);
					CreateLeftUI(LobbyID[i][k]);
					PlayerTextDrawShow(LobbyID[i][k], LeftUP[LobbyID[i][k]]);
					ShowLeftUI(LobbyID[i][k]);
					PutPlayerInVehicle(LobbyID[i][k], PlayerVehicle[LobbyID[i][k]], 0);
					switch(l)
					{
						case 0:
						{
							SendClientMessage(LobbyID[i][k], 0x005F9900, "** [Рация 911] Диспетчер: подозреваемый ограбил магазин с продуктами, пытается скрыться! **");
						}
						case 1:
						{
							SendClientMessage(LobbyID[i][k], 0x005F9900, "** [Рация 911] Диспетчер: подозреваемый избил бездомного, пытается скрыться! **");
						}
						case 2:
						{
							SendClientMessage(LobbyID[i][k], 0x005F9900, "** [Рация 911] Диспетчер: подозреваемый угрожал пистолетом банкиру, пытается скрыться! **");
						}
					}

					if(Priority == i) 
					{
						SearchPriority();
					}
				}
				new pl = LobbyInfo[i][TextDraws] + 1;
				new Occupied[MAX_PLOBBY];
				for(new k; k < MAX_PLOBBY; k++)
				{
					if(LobbyID[i][k] == -1)
					{
						continue;
					}
					new q = random(pl);
					new playerid = LobbyID[i][k];
					new a;
					switch(q)
					{
						case 0: 
						{
							da:
							a = 0;
							if(Occupied[a] == 1)
							{
								goto mu;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 1215.0729,-1828.4176,13.1877,182.6918,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 1215.0729,-1828.4176,13.1877,182.6918,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
						case 1:
						{
							la:
							a = 1;
							if(Occupied[a] == 1)
							{
								goto go;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 1347.4016,-1752.6587,13.1397,0.7036,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 1347.4016,-1752.6587,13.1397,0.7036,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
						case 2:
						{
							ho:
							a = 2;
							if(Occupied[a] == 1)
							{
								goto viy;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 1469.5994,-1495.2206,13.3267,91.8238,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 1469.5994,-1495.2206,13.3267,91.8238,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
						case 3:
						{
							ro:
							a = 3;
							if(Occupied[a] == 1)
							{
								goto ho;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 1758.0417,-1483.1327,13.3162,266.9442,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 1758.0417,-1483.1327,13.3162,266.9442,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
						case 4:
						{
							di:
							a = 4;
							if(Occupied[a] == 1)
							{
								goto la;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 2118.1333,-1782.9792,13.1673,356.8727,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 2118.1333,-1782.9792,13.1673,356.8727,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
						case 5:
						{
							viy:
							a = 5;
							if(Occupied[a] == 1)
							{
								goto de;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 2481.6543,-1748.2977,13.3253,2.1950,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 2481.6543,-1748.2977,13.3253,2.1950,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
						case 6:
						{
							de:
							a = 6;
							if(Occupied[a] == 1)
							{
								goto bil;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 2458.4316,-1351.1938,23.7756,90.0464,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 2458.4316,-1351.1938,23.7756,90.0464,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
						case 7:
						{
							go:
							a = 7;
							if(Occupied[a] == 1)
							{
								goto ro;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 2750.8398,-1177.9519,69.1831,89.5616,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 2750.8398,-1177.9519,69.1831,89.5616,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
						case 8:
						{
							mu:
							a = 8;
							if(Occupied[a] == 1)
							{
								goto di;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 2682.1985,-1671.4551,9.2058,180.2605,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 2682.1985,-1671.4551,9.2058,180.2605,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
						case 9:
						{
							bil:
							a = 9;
							if(Occupied[a] == 1)
							{
								goto da;
							}
							else 
							{
								Occupied[a] = 1;
								if(LobbyID[i][k] != LobbyInfo[i][Suspect])
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(596, 2745.1641,-1944.3124,13.3246,90.3242,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
								else
								{
									DestroyVehicle(PlayerVehicle[playerid]);
									PlayerVehicle[playerid] = CreateVehicle(PlayerInfo[playerid][Vehicle], 2745.1641,-1944.3124,13.3246,90.3242,0,0, -1);
									PutPlayerInVehicle(playerid, PlayerVehicle[playerid], 0);
								}
							}
						}
					}
				}
				SendClientMessage(LobbyInfo[i][Suspect], 0xFF000000, "Лобби запущено.");
				LobbyInfo[i][Map] = 0;
				LobbyInfo[i][Activate] = 3;
				LobbyInfo[i][Timer] = ServerInfo[TimeInGame];
				if(LobbyInfo[i][Map] == 0)
				{
					for(new k; k < MAX_PLOBBY; k++)
					{
						if(LobbyID[i][k] == -1) continue;
						SetPlayerWorldBounds(LobbyID[i][k], 2923.8906, 112.1450, -954.2859, -2718.8538);
					}
				}
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
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(PlayerInfo[i][Login] == 0)
		{
			continue;
		}
		if(PlayerInfo[i][Amt] == 0)
		{
			continue;
		}
		if(PlayerInfo[i][Amt] > 0)
		{
			PlayerInfo[i][Amt]--;
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
	new temp[228];
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
	temp = "\n/kill\t\t\t\t-\t\t\tСамоубийство\n\n";
	strcat(text, temp);
	if(PlayerInfo[playerid][Admin] > 1)
	{
		temp = "\n/kick [ID игрока] [Причина]\t-\t\t\tКикнуть игрока с указанной причиной";
		strcat(text, temp);
		temp = "\n/ainfo [ID игрока]\t\t-\t\t\tПосмотреть информацию об аккаунте";
		strcat(text, temp);
		temp = "\n/delveh [ID транспорта]\t-\t\t\tУдалить транспортное средство.";
		strcat(text, temp);
		temp = "\n/mute [ID игрока] [время] [причина]\t-\t\t\tВыдать затычку игроку\n\n";
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
		temp = "\n/setadminlevel [id] [level]\t-\t\t\tВЫдать игроку уровень админки.";
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
	new lobbyid = PlayerInfo[playerid][Lb];
	new ch;
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[lobbyid][i] == LobbyInfo[lobbyid][Suspect])
		{
			continue;
		}
		if(LobbyID[lobbyid][i] == -1)
		{
			continue;
		}
		ch++;
	}
	format(Text, 200, "~n~~n~Time remaining: %i sec~n~~n~Cops remaining: %i~n~~n~CAR HP: 1000~n~~n~", ServerInfo[TimeInGame],ch);
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
	NSusUI[playerid] = CreatePlayerTextDraw(playerid, 110, 170, text);
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
	new ch;
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[PlayerLobby][i] == LobbyInfo[PlayerLobby][Suspect])
		{
			continue;
		}
		if(LobbyID[PlayerLobby][i] == -1)
		{
			continue;
		}
		ch++;
	}
	if(!IsPlayerInAnyVehicle(playerid)) 
	{
		format(Text, 200, "~n~~n~Time remaining: %i sec~n~~n~Cops remaining: %i~n~~n~CAR HP: NOT SEARCHED~n~~n~", LobbyInfo[PlayerLobby][Timer], ch);
	}
	else
	{
		GetVehicleHealth(Veh, VHP);
		format(Text, 200, "~n~~n~Time remaining: %i sec~n~~n~Cops remaining: %i~n~~n~CAR HP: %i~n~~n~", LobbyInfo[PlayerLobby][Timer], ch, floatround(VHP));
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
	if(plid == playerid)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете кикнуть самого себя");
	}
	if(PlayerInfo[plid][Login] == 0)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Данный игрок не авторизован.");
	}
	if(PlayerInfo[plid][Admin] >= PlayerInfo[playerid][Admin])
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете этого сделать.");
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
	if(playerid == plid)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете использовать мут на самого себя.");
	}
	if(isnull(reason))
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы не ввели причину для мута");
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: id игрока не может быть меньше нуля и больше 299");
	}
	if(PlayerInfo[plid][Admin] >= PlayerInfo[playerid][Admin])
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете этого сделать.");
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
	new PName[MAX_PLAYER_NAME];
	PName = GPN(playerid);
	format(m, 144, "%s(%i) в репорт: %s", PName, playerid, text);
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
	SendClientMessage(playerid, COLOR_RED, "Ваш запрос отправлен администрации. Ожидайте ответа!");
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
	if(plid == playerid)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете выдать предупреждение самому себе.");
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1)
	{
		return SendClientMessage(playerid, 0xFF000000, "Ошибка: Вы ввели id игрока вне диапазона");
	}
	if(PlayerInfo[plid][Admin] >= PlayerInfo[playerid][Admin])
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете этого сделать.");
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
	new plid, text[256];
	if(sscanf(params, "is", plid, text))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Введите /pm [ID игрока] [Текст].");
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы ввели некорректный ID игрока.");
	}
	if(PlayerInfo[plid][Login] == 0)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Игрок находится не в сети.");
	}
	if(isnull(text))
	{
	 	return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не ввели сообщение.");
	}
	if(strlen(text) > 80)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Ваше сообщение слишком длинное");
	}
	new m[144];
	new OName[MAX_PLAYER_NAME];
	new PName[MAX_PLAYER_NAME];
	OName = GPN(playerid);
	PName = GPN(plid);
	format(m, 144, "%s(%i) для %s(%i): %s", OName, playerid, PName, plid, text);
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(PlayerInfo[i][Admin] > 1)
		{
			if(playerid == i) continue;
			SendClientMessage(i, COLOR_YELLOW, m);
		}
	}
	format(m, 144, "Вам от %s(%i) в ЛС: %s", OName, playerid, text);
	SendClientMessage(plid, COLOR_YELLOW, m);
	format(m, 144, "Вы для %s(%i) в ЛС: %s", PName, plid, text);
	SendClientMessage(playerid, COLOR_YELLOW, m);
	return 1;
}

CMD:giveskin(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0)
	{
		return 0;
	}
	if(PlayerInfo[playerid][Admin] < 2)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: У вас нет доступа к этой команде.");
	}
	new plid, skin;
	if(sscanf(params, "ii", plid, skin))
	{
		return SendClientMessage(playerid, COLOR_RED, "Формат ввода: /skin [ID игрока] [ID скина]");
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы ввели некорректный id игрока.");
	}
	if(PlayerInfo[plid][Login] == 0)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Данный игрок не авторизован.");
	}
	if(skin < 0 || skin > 311)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы ввели некорректный id скина.");
	}
	SetPlayerSkin(plid, skin);
	new PName[MAX_PLAYER_NAME];
	new AName[MAX_PLAYER_NAME];
	PName = GPN(plid);
	AName = GPN(playerid);
	new query[256];
	format(query, 256, "UPDATE `Accounts` SET `Skin` = '%i' WHERE `Name` = '%s'", skin, PName);
	mysql_query(sql, query);
	format(query, 256, "SELECT Skin FROM `Accounts` WHERE `Name` = '%s'", PName);
	mysql_query(sql, query);
	new nskin;
	cache_get_value_name_int(0, "Skin", nskin);
	if(nskin == skin)
	{
		new text[144];
		format(text, 144, "Сервер: Вы выдали постоянный скин %i игроку %s (%i).", skin, PName, plid);
		SendClientMessage(playerid, COLOR_BLUE, text);
		format(text, 144, "Администратор %s выдал Вам скин %i id.", AName, skin);
		SendClientMessage(plid, COLOR_BLUE, text);
		PlayerInfo[plid][Skin] = skin;
	}
	else
	{
		new text[144];
		SendClientMessage(playerid, COLOR_RED, "Ошибка: Произошла серверная ошибка. Сообщите об этом Главному Администратору.");
		format(text, 144, "Вы выдали ВРЕМЕННЫЙ скин %i id игроку %s (%i)", skin, PName, plid);
		SendClientMessage(playerid, COLOR_BLUE, text);
		format(text, 144, "Администратор %s выдал Вам ВРЕМЕННЫЙ скин %i id", AName, skin);
		SendClientMessage(plid, COLOR_BLUE, text);
		PlayerInfo[plid][Skin] = skin;
	}
	return 1;
}

CMD:setadminlevel(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0)
	{
		return 0;
	}
	if(PlayerInfo[playerid][Admin] < 4)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: У вас нет доступа к этой команде.");
	}
	new plid, lvl;
	if(sscanf(params, "ii", plid, lvl))
	{
		return SendClientMessage(playerid, COLOR_RED, "Формат ввода: /setadminlevel [ID игрока] [уровень админки]");
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы ввели некорректный id игрока.");
	}
	if(PlayerInfo[plid][Login] == 0)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Данный игрок не авторизован.");
	}
	if(plid == playerid)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете этого сделать.");
	}
	if(PlayerInfo[playerid][Admin] <= PlayerInfo[plid][Admin])
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете этого сделать.");
	}
	if(lvl < 0 || lvl > 3)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете выдать админку выше 3 уровня");
	}
	new query[256];
	new PName[MAX_PLAYER_NAME];
	PName = GPN(plid);
	new AName[MAX_PLAYER_NAME];
	AName = GPN(playerid);
	format(query, 256, "UPDATE `Accounts` SET `Admin` = '%i' WHERE `Name` = '%s'", lvl, PName);
	mysql_query(sql, query);
	format(query, 256, "SELECT Admin FROM `Accounts` WHERE `Name` = '%s'", PName);
	mysql_query(sql, query);
	new nlvl;
	cache_get_value_name_int(0, "Admin", nlvl);
	if(nlvl == lvl)
	{
		//Поставил админа
		format(query, 256, "Вы установили игроку %s(%i) уровень админа %i.", PName, plid, nlvl);
		SendClientMessage(playerid, COLOR_BLUE, query);
		format(query, 256, "Администратор %s выдал Вам %i уровень админа", AName, nlvl);
		SendClientMessage(playerid, COLOR_BLUE, query);
		PlayerInfo[plid][Admin] = nlvl;
	}
	else
	{
		//Произошла ошибка
		format(query, 256, "Сервер: произошла некоторая ошибка. Сообщите об этом главному администратору.");
		SendClientMessage(playerid, COLOR_RED, query);
	}
	return 1;
}

CMD:amenu(playerid)
{
	if(PlayerInfo[playerid][Login] < 1)
	{
		return 0;
	}
	if(PlayerInfo[playerid][Admin] < 3)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: У вас нет доступа к этой команде!");
	}
	ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Меню сервера", "Настройки лобби", "Выбрать", "Отмена");
	return 1;
}

CMD:an(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0)
	{
		return 0;
	}
	if(PlayerInfo[playerid][Admin] < 1)
	{
		return 1;
	}
	new plid, answer[256];
	if(sscanf(params, "is", plid, answer))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: формат команды - /an [ID игрока] [Текст]");
	}
	if(playerid == plid)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете ответить самому себе.");
	}
	if(plid < 0 || plid > MAX_PLAYERS - 1)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы ввели некорректный ID игрока.");
	}
	if(PlayerInfo[plid][Login] == 0)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Данный игрок не авторизован.");
	}
	if(strlen(answer) > 80)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Ваше сообщение слишком длинное.");
	}
	if(isnull(answer))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не ввели ответ."); 
	}
	if(strlen(answer) < 3)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Ваше сообщение слишком короткое.");
	}
	new text[144];
	new PName[MAX_PLAYER_NAME], AName[MAX_PLAYER_NAME];
	PName = GPN(plid);
	AName = GPN(playerid);
	format(text, 144, "Адм. %s Вам: %s", AName, answer);
	SendClientMessage(plid, COLOR_YELLOW, text);
	format(text, 144, "Вы для %s: %s", PName, answer);
	SendClientMessage(playerid, COLOR_YELLOW, text);
	format(text, 144, "Адм. %s для %s (%i): %s", AName, PName, plid, answer);
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(i == playerid)
		{
			continue;
		}
		if(PlayerInfo[i][Login] == 0)
		{
			continue;
		}
		if(PlayerInfo[i][Admin] < 1)
		{
			continue;
		}
		SendClientMessage(i, COLOR_RED, text);
	}
	return 1;
}

CMD:l(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0)
	{
		return 0;
	}
	new text[256];
	if(PlayerInfo[playerid][Lb] < 0)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не находитесь в лобби.");
	}
	if(sscanf(params, "s", text))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Формат команды - /l [Текст]");
	}
	if(isnull(text))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не ввели текст.");
	}
	if(strlen(text) > 100)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Ваше сообщение слишком длинное");
	}
	new lobbyid = PlayerInfo[playerid][Lb];
	new m[144];
	new PName[MAX_PLAYER_NAME];
	PName = GPN(playerid);
	format(m, 144, "%s (%i) в лобби: %s", PName, playerid, text);
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[lobbyid][i] == -1)
		{
			continue;
		}
		SendClientMessage(LobbyID[lobbyid][i], 0x2EC70000, m);
	}
	return 1;
}

CMD:r(playerid, params[])
{
	if(PlayerInfo[playerid][Login] == 0)
	{
		return 0;
	}
	if(PlayerInfo[playerid][Lb] < 0)
	{
		return 0;
	}
	new lobbyid = PlayerInfo[playerid][Lb];
	if(LobbyInfo[lobbyid][Activate] < 3)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не можете говорить в рацию");
	}
	if(playerid == LobbyInfo[lobbyid][Suspect])
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Подозреваемый не может говорить в рацию");
	}
	new text[256];
	if(sscanf(params, "s", text))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: формат команды - /r [Текст]");
	}
	if(strlen(text) > 80)
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Ваш сообщение слишком длинное.");
	}
	if(isnull(text))
	{
		return SendClientMessage(playerid, COLOR_RED, "Ошибка: Вы не ввели сообщение");
	}
	new m[144];
	new PName[MAX_PLAYER_NAME];
	PName = GPN(playerid);
	format(m, 144, "%s (%i) в рацию: %s", PName, playerid, text);
	for(new i; i < MAX_PLOBBY; i++)
	{
		if(LobbyID[lobbyid][i] == -1) 
		{
			continue;
		}
		if(LobbyInfo[lobbyid][Suspect] == LobbyID[lobbyid][i])
		{
			continue;
		}
		SendClientMessage(LobbyID[lobbyid][i], 0x003C99FF, m);
	}
	return 1;
}
